
class Sonar {

  private final int RANGE = 100; 

  private PVector startPoint;
  private PVector endPoint;

  private float startPointX, startPointY;
  private float endPointX, endPointY;

  private float obstacleX, obstacleY;

  private float distance;

  public Sonar(float originX, float originY, float angle) {
    endPoint = PVector.fromAngle(angle);
    endPoint.setMag(RANGE);

    startPoint = new PVector(originX, originY);
  }

  public float read(Pose pose, boolean[][] occGrid) {

    float rotAngle = pose.getDirection();

    startPointX = startPoint.x * cos(rotAngle) - startPoint.y * sin(rotAngle);
    startPointY = startPoint.x * sin(rotAngle) + startPoint.y * cos(rotAngle);
    startPointX += pose.getX();
    startPointY += pose.getY();

    endPointX = endPoint.x * cos(rotAngle) - endPoint.y * sin(rotAngle);
    endPointY = endPoint.x * sin(rotAngle) + endPoint.y * cos(rotAngle);
    endPointX += startPointX;
    endPointY += startPointY;

    // ----------- Get distance
    float alpha = 0.1; 
    float t = 0; 
    float x = startPointX, y = startPointY;
    obstacleX = endPointX;
    obstacleY = endPointY;

    while (t < 1) {
      try {
        if (occGrid[(int)x][(int)y]) {
          obstacleX = x;
          obstacleY = y;
          break;
        }
      }
      catch(ArrayIndexOutOfBoundsException e) {
      }

      t += alpha;
      x = ((1 - t) * startPointX + t * endPointX);
      y = ((1 - t) * startPointY + t * endPointY);
    }

    distance = dist(startPointX, startPointY, obstacleX, obstacleY);

    return distance;
  }

  public float getStartPointX() {
    return this.startPointX;
  }

  public float getStartPointY() {
    return this.startPointY;
  }

  public float getEndPointX() {
    return this.endPointX;
  }

  public float getEndPointY() {
    return this.endPointY;
  }

  public float getObstacleX() {
    return this.obstacleX;
  }

  public float getObstacleY() {
    return this.obstacleY;
  } 

  public float getDirection() {
    return endPoint.heading();
  }

  public float getDistance() {
    return distance;
  }
}
