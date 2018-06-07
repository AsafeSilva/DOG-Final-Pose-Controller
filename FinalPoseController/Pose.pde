
class Pose {
  private PVector poseVector;
  private float direction;

  Pose(float x, float y, float direction) {
    this.poseVector = new PVector(x, y);
    this.direction = direction;
  }
  
  public float distanceTo(Pose otherPose){
    return PVector.dist(this.poseVector, otherPose.poseVector);
  }

  public void setPose(Pose newPose) {
    this.poseVector = newPose.getPoseVector(); 
    this.direction = newPose.getDirection();
  }

  public void setPose(float x, float y, float direction) {
    this.poseVector.set(x, y); 
    this.direction = direction;
  }

  public void setX(float x) {
    this.poseVector.x = x;
  }

  public void setY(float y) {
    this.poseVector.y = y;
  }

  public void setDirection(float direction) {
    this.direction = direction;
  }

  public PVector getPoseVector() {
    return poseVector;
  }

  public float getX() {
    return poseVector.x;
  }

  public float getY() {
    return poseVector.y;
  }

  public float getDirection() {
    return direction;
  }
}
