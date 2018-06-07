
class Robot {

  private Pose pose;

  Robot(float x, float y, float direction) {
    pose = new Pose(x, y, direction);
  }

  public void move(float v, float w) {
    float dt = 0.005;

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

    float targetDirection = atan2(errorY, errorX); 
    float alpha = targetDirection - pose.getDirection();

    int sinalInv;
    if (abs(alpha) > PI) {
      sinalInv = alpha > 0 ? -1 : 1;

      alpha = (TWO_PI - abs(alpha)) * sinalInv;
    }

    float[] error = {rho, alpha};

    return error;
  }
}
