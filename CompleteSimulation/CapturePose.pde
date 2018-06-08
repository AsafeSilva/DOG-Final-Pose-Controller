final float THRESHOLD = 40;       // VARIAÇÃO MÁXIMA DE COR A SER CONSIDERADA
final int DISTANCIA_MAXIMA = 50;  // DEFINIR DISTÂNCIA MÁXIMA PONTO MÉDIO ATÉ PONTOS FLUTUANTES

color backColor;  // COR OBJETIVO 1
color frontColor; // COR OBJETIVO 2

ArrayList<Integer> backColorX = new ArrayList<Integer>(); // ARRAYLIST RESPONSÁVEL POR GUARDAR CORDENADAS X EQUIVALENTES AOS PONTOS QUE SÃO CONHECIDENTES AO OBJETIVO 1 
ArrayList<Integer> backColorY = new ArrayList<Integer>(); // ARRAYLIST RESPONSÁVEL POR GUARDAR CORDENADAS Y EQUIVALENTES AOS PONTOS QUE SÃO CONHECIDENTES AO OBJETIVO 1 
ArrayList<Integer> frontColorX = new ArrayList<Integer>(); // ARRAYLIST RESPONSÁVEL POR GUARDAR CORDENADAS X EQUIVALENTES AOS PONTOS QUE SÃO CONHECIDENTES AO OBJETIVO 2 
ArrayList<Integer> frontColorY = new ArrayList<Integer>(); // ARRAYLIST RESPONSÁVEL POR GUARDAR CORDENADAS Y EQUIVALENTES AOS PONTOS QUE SÃO CONHECIDENTES AO OBJETIVO 2


void captureEvent(Capture cam) {
  cam.read();
}

void capturePose(Pose pose) {

  cam.loadPixels(); 

  //LEITURA DE TODOS OS PIXELS DA IMAGEM
  for (int x = 0; x < cam.width; x++) {
    for (int y = 0; y < cam.height; y++) {
      int pos = x + y * cam.width;

      if (robot.occGrid[x][y]) {
        continue;
      }

      color cor = cam.pixels[pos];

      float r1 = red(cor);
      float g1 = green(cor);
      float b1 = blue(cor);

      float r2 = red(backColor);
      float g2 = green(backColor);
      float b2 = blue(backColor);

      float r3 = red(frontColor);
      float g3 = green(frontColor);
      float b3 = blue(frontColor);

      float d = distSq(r1, g1, b1, r2, g2, b2); 

      //ESSE PIXEL SE PARECE COM O OBJETIVO 1?
      if (d < THRESHOLD*THRESHOLD) {
        backColorX.add(x);
        backColorY.add(y);
      }

      d = distSq(r1, g1, b1, r3, g3, b3); 

      //ESSE PIXEL SE PARECE COM O OBJETIVO 2?
      if (d < THRESHOLD*THRESHOLD) {

        frontColorX.add(x);
        frontColorY.add(y);
      }
    }
  }

  int avgBackColorX = calcAverage(backColorX);
  int avgBackColorY = calcAverage(backColorY);
  int avgFrontColorX = calcAverage(frontColorX);
  int avgFrontColorY = calcAverage(frontColorY);

  //ANALISA TODOS OS PONTOS CONHECIDENTES AO OBJETIVO 1
  for (int i = 0; i < backColorX.size(); i++) {
    //FILTRAGEM DOS PONTOS
    if (dist(backColorX.get(i), backColorY.get(i), avgBackColorX, avgBackColorY) > DISTANCIA_MAXIMA) {
      backColorX.remove(i);
      backColorY.remove(i);
    }
  }

  //ANALISA TODOS OS PONTOS CONHECIDENTES AO OBJETIVO 2
  for (int i = 0; i < frontColorX.size(); i++) {
    //FILTRAGEM DOS PONTOS
    if (dist(frontColorX.get(i), frontColorY.get(i), avgFrontColorX, avgFrontColorY) > DISTANCIA_MAXIMA) {
      frontColorX.remove(i);
      frontColorY.remove(i);
    }
  }

  avgBackColorX = calcAverage(backColorX);
  avgBackColorY = calcAverage(backColorY);
  avgFrontColorX = calcAverage(frontColorX);
  avgFrontColorY = calcAverage(frontColorY);

  backColorX.clear();
  backColorY.clear();
  frontColorX.clear();
  frontColorY.clear();

  // Calcula pose do robô
  float x, y, direction;

  x = (avgBackColorX + avgFrontColorX) / 2;
  y = (avgBackColorY + avgFrontColorY) / 2;

  direction = atan2(avgFrontColorY - avgBackColorY, avgFrontColorX - avgBackColorX);

  pose.setPose(x, y, direction);
}

int click = 0;
void getRobotColors() {
  if (click == 0) {
    //SELECIONAR RGB OBJETIVO 1
    int location = mouseX + mouseY*cam.width;
    backColor = cam.pixels[location];
    click = 1;
  } else if (click == 1) {
    //SELECIONAR RGB OBJETIVO 2
    int location = mouseX + mouseY*cam.width;
    frontColor = cam.pixels[location];
    click = 0;
  }
}

// FUNÇÃO PARA CALCULO DE POSIÇÃO MÉDIA NO ARRAYLIST
int calcAverage(ArrayList<Integer> points) {

  int avg = 0;

  if (!points.isEmpty()) {    
    for (int i = 0; i < points.size(); i++)
      avg += points.get(i);

    avg = avg / points.size();
  }

  return avg;
}

// FUNÇÃO PARA "DISTANCIAR" RGB'S
float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}
