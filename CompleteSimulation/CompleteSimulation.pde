import processing.video.*;
import processing.serial.*;
import pt.citar.diablu.processing.nxt.*;

LegoNXT lego;

Capture cam;

PImage map;

Robot robot;
Pose currentPose;
Pose target;

float vmax = 0.1;
float wmax = 3.63;

boolean run = false;

void settings() {
  size(CAMERA_WIDTH, CAMERA_HEIGHT);
}

void setup() {

  println("Inicializando bluetooth");
  lego = new LegoNXT(this, BT_LEGO);

  println("Inicializando camera");
  cam = new Capture(this, CAMERA_WIDTH, CAMERA_HEIGHT, EXTERNAL_CAM);
  cam.start();

  println("Inicializando mapa");
  map = loadImage("Map1.bmp");

  println("Inicializando variaveis");
  robot = new Robot();
  currentPose = new Pose();
  target = new Pose();
}

void draw() {
  noTint();
  image(cam, 0, 0);
  tint(255, 50);
  image(map, 0, 0);

  capturePose(currentPose);
  robot.setPose(currentPose);

  target.setX(mouseX);
  target.setY(height-mouseY);

  //----------
  float[] error = robot.getError(target);
  float rho = error[0];
  float alpha = error[1];

  if (rho >= 15.0) {
    float Kw = (abs(wmax) - 0.5 * vmax) / PI;
    Kw = abs(Kw);

    float v = (float) (vmax * Math.tanh(rho) * cos(alpha));
    float w = (float) (Kw * alpha + vmax * Math.tanh(rho) * sin(alpha) * cos(alpha) / rho);

    if (run)  robot.move(v, w);
    else      robot.stop();
  } else {
    robot.stop();
  }


  //----------
  stroke(255, 255, 255);
  line(currentPose.getX(), height-currentPose.getY(), target.getX(), height-target.getY());

  stroke(50);
  ellipse(currentPose.getX(), height-currentPose.getY(), 10, 10);

  textSize(10);
  text("Power: (" + robot.powerD + ", " + robot.powerE + ")", 10, 20);
  text("Pose: (" + (int)currentPose.getX() + ", " + (int)currentPose.getY() + ", " + (int)degrees(currentPose.getDirection()) + ")", 10, 35);
  text("Error: (" + (int)rho + ", " + (int)degrees(alpha) + ")", 10, 50);
}

void mousePressed() {
  getRobotColors();
}

void keyPressed() {
  run = !run;
}
