Robot robot;

Pose currentPose;
Pose target;
Pose targetTemp;

float[] error;
float rho, alpha, theta;
float phi, betha;

boolean isOnTarget = false;

PImage map;

float V_MAX = 400;
float W_MAX = 50;
float SAFE_DISTANCE = 40;

void setup() {
  size(1200, 600, P3D);

  map = loadImage("Map3.bmp");

  robot = new Robot(100, 100, HALF_PI, map);

  target = new Pose(500, 500, 0);
  targetTemp = new Pose(target.getX(), target.getY(), target.getDirection());
}

void draw() {
  image(map, 0, 0);
  cursor(CROSS);

  target.setX(mouseX);
  target.setY(height-mouseY);

  // Ler pose do robô (x, y, PHI)
  currentPose = robot.getPose();

  // Cálculo do erro em relação à posição final
  error = robot.getError(target);
  rho = error[0];
  alpha = error[1];
  theta = error[2];

  isOnTarget = rho < 2.0 ? true : false;

  float shortestSensor = SAFE_DISTANCE;
  int shortestSensorID = -1;
  float shortestDistance;

  // Realiza a leitura dos 16 sensores
  for (int i = 0; i < 16; i++)  robot.getSonar(i).read(currentPose, robot.occGrid);

  // Procura o sensor frontal que leu a menor distância
  for (int i = 0; i < 8; i++) {
    float distance = robot.getSonar(i).getDistance();
    //if ( (distance > 30) && (distance < 70) ) {
    if (distance < shortestSensor) {
      shortestSensor = distance;
      shortestSensorID = i;
    }
    //}
  }

  // Realiza uma média entre o sensor com menor distância e seus vizinhos
  if (shortestSensor < SAFE_DISTANCE) {
    int centralSensorID = shortestSensorID;
    int rightSensorID = centralSensorID + 1;
    int leftSensorID = centralSensorID == 0 ? 15 : centralSensorID - 1;

    float centralDistance = robot.getSonar(centralSensorID).getDistance();
    float rightDistance = robot.getSonar(rightSensorID).getDistance();
    float leftDistance = robot.getSonar(leftSensorID).getDistance();

    float centralAngle = robot.getSonar(centralSensorID).getDirection();
    float rightAngle = robot.getSonar(rightSensorID).getDirection();
    float leftAngle = robot.getSonar(leftSensorID).getDirection();

    float difRightCentral = abs(centralDistance - rightDistance);
    float difLeftCentral = abs(centralDistance - leftDistance);
    float difRightLeft = abs(leftDistance - rightDistance);

    if (difLeftCentral < difRightCentral) {
      shortestDistance = difLeftCentral;
      betha = (leftAngle + centralAngle)/2;
    } else {
      shortestDistance = difRightCentral;
      betha = (rightAngle + centralAngle)/2;
    }

    if (difRightLeft < shortestDistance) {
      shortestDistance = difRightLeft;
      betha = (rightAngle + leftAngle)/2;
    }

    // Calcula o ângulo de rotação para o alvo virtual
    int reverseSign = betha > 0 ? -1 : 1;
    phi = ((HALF_PI - abs(betha)) * reverseSign) - alpha;
  } else {
    phi = 0;
    betha = 0;
  }

  // Calcula um ponto próximo ao robô na direção do alvo
  float xNear = currentPose.getX() + 100 * cos(theta);
  float yNear = currentPose.getY() + 100 * sin(theta);

  // Calcula o alvo virtual através do ângulo de rotação 'phi'
  float xTemp = (xNear - currentPose.getX()) * cos(phi) - (yNear - currentPose.getY()) * sin(phi);
  float yTemp = (xNear - currentPose.getX()) * sin(phi) + (yNear - currentPose.getY()) * cos(phi);
  targetTemp.setX(xTemp + currentPose.getX());
  targetTemp.setY(yTemp + currentPose.getY());

  // Calcula novo erro em relação ao alvo virtual
  error = robot.getError(targetTemp);
  rho = error[0];
  alpha = error[1];

  if (!isOnTarget) {
    float Kw = (abs(W_MAX) - 0.5 * V_MAX) / PI;
    Kw = abs(Kw);

    float v = (float) (V_MAX * Math.tanh(rho) * cos(alpha));
    float w = (float) (Kw * alpha + V_MAX * Math.tanh(rho) * sin(alpha) * cos(alpha) / rho);

    robot.move(v, w);
  }

  paint();
}

void paint() {
  //----------- DRAWS ROBOT AND LINES
  pushMatrix();
  translate(0, height);
  rotateX(PI);

  stroke(0);
  line(currentPose.getX(), currentPose.getY(), target.getX(), target.getY());
  stroke(255, 0, 0);
  line(currentPose.getX(), currentPose.getY(), targetTemp.getX(), targetTemp.getY());

  stroke(0, 0, 255);
  for (int i = 0; i < 16; i++) {
    Sonar sonar = robot.getSonar(i);
    line(sonar.getStartPointX(), sonar.getStartPointY(), sonar.getObstacleX(), sonar.getObstacleY());
  }

  pushMatrix();
  translate(currentPose.getX(), currentPose.getY());
  rotate(currentPose.getDirection());

  //fill(255, 0, 0);
  stroke(0);
  quad(20, 20, 20, -20, -20, -20, -20, 20);
  arc(20, 0, 30, 40, -HALF_PI, HALF_PI);
  arc(-20, 0, -30, 40, -HALF_PI, HALF_PI);
  //fill(0);
  rect(20, -22, -15, -6);
  rect(20, 22, -15, 6);
  popMatrix();
  popMatrix();
}
