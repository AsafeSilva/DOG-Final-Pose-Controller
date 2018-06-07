
class Robot {

  private PImage map;
  private boolean[][] occGrid;

  private Pose pose;

  private Sonar[] sonars;

  public Robot(float originX, float originY, float direction, PImage map) {
    pose = new Pose(originX, originY, direction);

    sonars = new Sonar[16];

    sonars[0] = new Sonar(20, 22, radians(90));  
    sonars[1] = new Sonar(32.85, 15.32, radians(50));
    sonars[2] = new Sonar(37.32, 9.99, radians(30));
    sonars[3] = new Sonar(39.69, 3.47, radians(10));
    sonars[4] = new Sonar(39.69, -3.47, radians(-10));
    sonars[5] = new Sonar(37.32, -9.99, radians(-30));
    sonars[6] = new Sonar(32.85, -15.32, radians(-50));
    sonars[7] = new Sonar(20, -22, radians(-90));

    sonars[8] = new Sonar(-20, -22, radians(-90));
    sonars[9] = new Sonar(-32.85, -15.32, radians(-130));
    sonars[10] = new Sonar(-37.32, -9.99, radians(-150));
    sonars[11] = new Sonar(-39.69, -3.47, radians(-170));
    sonars[12] = new Sonar(-39.69, 3.47, radians(170));
    sonars[13] = new Sonar(-37.32, 9.99, radians(150));
    sonars[14] = new Sonar(-32.85, 15.32, radians(130));
    sonars[15] = new Sonar(-20, 22, radians(90));

    this.map = map;
    this.map.loadPixels();

    occGrid = new boolean[map.width][map.height];
    for (int x = 0; x < map.width; x++) {
      for (int y = 0; y < map.height; y++) {
        occGrid[x][y] = (map.pixels[x + (map.height-1-y) * map.width] & 0xFF) == 0;
      }
    }
  }

  public void move(float v, float w) {
    float dt = 0.003;

    float x = pose.getX();
    float y = pose.getY();
    float direction = pose.getDirection();

    x += (v * cos(direction))*dt;
    y += (v * sin(direction))*dt;
    direction += w * dt;

    pose.setX(x);
    pose.setY(y);
    pose.setDirection(direction);
  }

  public Pose getPose() {
    return this.pose;
  }

  float[] getError(Pose target) {
    float rho = pose.distanceTo(target);

    float errorX = target.getX() - pose.getX();
    float errorY = target.getY() - pose.getY();

    float theta = atan2(errorY, errorX);
    float alpha = theta - this.pose.getDirection();

    int sinalInv;
    if (abs(alpha) > PI) {
      sinalInv = alpha > 0 ? -1 : 1;

      alpha = (TWO_PI - abs(alpha)) * sinalInv;
    }

    float[] error = {rho, alpha, theta};

    return error;
  }

  public Sonar getSonar(int id) {
    return this.sonars[id];
  }
}
