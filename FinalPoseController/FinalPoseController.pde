Robot robot;

Pose currentPose;
Pose target;

float vMax = 400;
float wMax = 50;

void setup() {
  size(1200, 600, P3D);
  background(0);

  robot = new Robot(20, 20, 0);

  target = new Pose(500, 500, 0);
}

void draw() {
  background(0);

  target.setX(mouseX);
  target.setY(height-mouseY);

  //-----------
  currentPose = robot.getPose();
  float[] error = robot.getError(target);
  
  float rho = error[0];
  float alpha = error[1];

  if (rho >= 2.0) {
    float Kw = (abs(wMax) - 0.5 * vMax) / PI;
    Kw = abs(Kw);

    float v = (float) (vMax * Math.tanh(rho) * cos(alpha));
    float w = (float) (Kw * alpha + vMax * Math.tanh(rho) * sin(alpha) * cos(alpha) / rho);

    robot.move(v, w);
  }

  pushMatrix();
  translate(0, height);
  rotateX(PI);
  //////////////////////////////////////////////////////////
  stroke(255, 255, 255);
  line(currentPose.getX(), currentPose.getY(), target.getX(), target.getY());

  pushMatrix();
  translate(currentPose.getX(), currentPose.getY());
  rotate(currentPose.getDirection());
  triangle(-16, 20, -16, -20, 34, 0);
  popMatrix();
  //////////////////////////////////////////////////////////
  popMatrix();
}
