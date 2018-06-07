
class Robot {

  public final float D = 0.11;      // Distância entre rodas  [m]
  public final float R = 0.028;     // Raio da roda           [m]

  public final float V_MAX = 0.2;   // Velocidade linear máxima do robô  [m/s]
  public final float W_MAX = 3.63;  // Velocidade angular máxima do robô [rad/s]

  public final float V_WHEEL_MAX = V_MAX + D * W_MAX / 2;   // Velocidade linear máxima da roda  [m/s]
  public final float W_WHEEL_MAX = V_WHEEL_MAX / R;         // Velocidade angular máxima da roda [rad/s]

  private Pose pose;

  private int powerD, powerE;

  public Robot() {
    pose = new Pose();

    powerD = powerE = 0;

    initThread();

    println();
    println("Robot vars:");
    println("V_MAX = " + V_MAX);
    println("W_MAX = " + W_MAX);
    println("V_WHEEL_MAX = " + V_WHEEL_MAX);
    println("W_WHEEL_MAX = " + W_WHEEL_MAX);
  }

  public Robot(float x, float y, float direction) {
    pose = new Pose(x, y, direction);
  }

  private void initThread() {
    Thread thread = new Thread() {
      @Override
        public void run() {
        while (true) {
          lego.motorForward(LegoNXT.MOTOR_B, powerD);
          lego.motorForward(LegoNXT.MOTOR_C, powerE);

          try {
            Thread.sleep(50);
          }
          catch(InterruptedException e) {
          }
        }
      }
    };

    thread.start();
  }

  public void move(float v, float w) {

    v = constrain(v, -V_MAX, V_MAX);
    w = constrain(w, -W_MAX, W_MAX);

    // Cálculo da velocidade linear de cada roda
    float vD = v + D * w / 2;
    float vE = v - D * w / 2;

    // Conversão da velocidade linear da roda para angular [V = W * raio] 
    float wD = vD / R;
    float wE = vE / R;

    // Conversão da velocidade angular [rad/s] para porcentagem [0 - 100] 
    wD = 100 * wD / W_WHEEL_MAX;
    wE = 100 * wE / W_WHEEL_MAX;

    powerD = (int)constrain(wD, -100, 100);
    powerE = (int)constrain(wE, -100, 100);
  }

  public void stop() {
    powerD = powerE = 0;
  }
  
  public void setPose(Pose newPose){
    this.pose.setPose(newPose);
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

    int signalInv;
    if (abs(alpha) > PI) {
      signalInv = alpha > 0 ? -1 : 1;

      alpha = (TWO_PI - abs(alpha)) * signalInv;
    }

    float[] error = {rho, alpha, theta};

    return error;
  }
}
