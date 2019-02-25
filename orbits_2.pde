PShape ship, shipSquare, shipSphere;

int c, speedZ, textCounter, speedY, speedX, planetCounter, shipRotation, shipVertRotation, shipAngle, shipVertAngle, cameraVertTilt, upY, inverter;
float textYOffset, shipX, shipY, shipZ, cameraX, cameraY, cameraZ, upYSign;
boolean thirdPerson;
PImage img;
final float[] radii = {0.25, 0.3, 0.35, 0.5, 0.6, 0.65};
final float[] orbitSpeed = {1, 0.9, 0.8, 0.7, 0.6, 0.5};
final float[] startingAngle = {random(1), random(1), random(1), random(1), random(1), random(1)};
final int[] planetSizes = {10, 15, 18, 30, 25, 8};


void setup(){
  size(1200, 800, P3D);
  surface.setResizable(false);
  stroke(0);
  c = 0;
  initShipPosition();
  //speedZ = 10;
  img = loadImage("space_image.jpg");
  img.resize(width, height);
  sphereDetail(20);
  fill(255);
  generateShip();
  setControlsTextStyle();
  thirdPerson = false;
}

void initShipPosition(){
  shipX = 0;
  shipY = -50;
  shipZ = 100;
  shipAngle = 0;
  shipVertAngle = 0;
  cameraVertTilt = 27;
  upYSign = 1;
  upY = 1;
  inverter = 1;
}

void keyPressed(){
  if (key == 'w') speedZ = -2;
  else if (key == 's') speedZ = 2;
  else if (key == 'a') speedX = -2;
  else if (key == 'd') speedX = 2;
  else if (key == 'z') speedY = -2;
  else if (key == 'c') speedY = 2;
  else if (key == 'q') shipRotation = 1 * inverter;
  else if (key == 'e') shipRotation = -1 * inverter;
  else if (keyCode == CONTROL) shipVertRotation = -1;
  else if (keyCode == SHIFT) shipVertRotation = 1;
  else if (key == 'v') {
    if (thirdPerson) camera();
    thirdPerson = !thirdPerson;
  } else if (key == 'r') initShipPosition();
}

void keyReleased(){
  if (key == 'w' || key == 's') speedZ = 0;
  else if (key == 'a' || key == 'd') speedX = 0;
  else if (key == 'z' || key == 'c') speedY = 0;
  else if (key == 'q' || key == 'e') shipRotation = 0;
  else if (keyCode == CONTROL || keyCode == SHIFT) shipVertRotation = 0;
}

void setBackground(){
  background(0);
}

void setPlanetsBackground(){  
  background(img);
}

void globalCoords(){
  translate(width/2, height/2, 0);  
  //rotateX(radians(-30));
}

void starCoords(){
  pushMatrix();  
  rotateZ(radians(-15));
  rotateY(radians(++c));
  sphere(80);
  popMatrix();
}

void planetCoords(float radius, float orbitSpeed, float startingOrbit, int planetSize){
  pushMatrix();
  rotateY(radians(c*orbitSpeed + startingOrbit*360));
  translate(width*radius, 0, 0);
  sphere(planetSize);
  if (planetSize == 18 || planetSize == 25) satelliteCoords(planetSize + 10, 1, 0, 5);
  popMatrix();
}

void satelliteCoords(float radius, float orbitSpeed, float startingOrbit, int satelliteSize){
  pushMatrix();  
  rotateY(radians(c*orbitSpeed + startingOrbit*360));
  translate(radius, 0, 0);
  sphere(satelliteSize);
  popMatrix();
}

void generateShip(){
  ship = createShape(GROUP);
  shipSquare = createShape(BOX, 30);
  shipSquare.translate(0, 15);
  shipSphere = createShape(SPHERE, 10);
  ship.addChild(shipSquare);
  ship.addChild(shipSphere);
  ship.translate(0, 0, 0);
}

void shipCoords(){
  pushMatrix();  
  cameraVertTilt += shipVertRotation; //needed in case there is rotation outside 3rd person camera
  shipAngle += shipRotation;
  shipVertAngle += shipVertRotation;
  shipX = shipX + speedX * cos(radians(shipAngle)) + speedZ * sin(radians(shipAngle)) * cos(radians(shipVertAngle)) + speedY * sin(radians(shipVertAngle)) * sin(radians(shipAngle));
  shipY = shipY + speedY * cos(radians(shipVertAngle)) - speedZ * sin(radians(shipVertAngle));
  shipZ = shipZ - speedX * sin(radians(shipAngle)) + speedZ * cos(radians(shipAngle)) * cos(radians(shipVertAngle)) + speedY * sin(radians(shipVertAngle)) * cos(radians(shipAngle));
  translate(shipX, shipY, shipZ);
  rotateY(radians(shipAngle));
  rotateX(radians(shipVertAngle));
  shape(ship);
  if (thirdPerson) setControlsTextAlt();
  popMatrix();
}

void setShipCamera(){
  /*if ((shipVertAngle % 360) >= 180) inverter = -1;
  else inverter = 1;*/
  cameraX = width/2 + shipX + 223 * sin(radians(shipAngle)) * cos(radians(cameraVertTilt));
  cameraY = height/2 + shipY - 223 * sin(radians(cameraVertTilt));
  cameraZ = shipZ + 223 * cos(radians(shipAngle)) * cos(radians(cameraVertTilt));
  if (abs(cameraVertTilt + 90) % 360 == 180) camera(cameraX, cameraY, cameraZ, width/2 + shipX, height/2 + shipY, shipZ, sin(radians(shipAngle)), 0, cos(radians(shipAngle)));
  else if (abs(cameraVertTilt + 90) % 360 == 0) camera(cameraX, cameraY, cameraZ, width/2 + shipX, height/2 + shipY, shipZ, -sin(radians(shipAngle)), 0, -cos(radians(shipAngle)));
  else {
    upY = round(1 * (cos(radians(cameraVertTilt))/abs(cos(radians(cameraVertTilt)))));
    camera(cameraX, cameraY, cameraZ, width/2 + shipX, height/2 + shipY, shipZ, 0, upY, 0);
  }
  println(shipVertAngle);
}

void setControlsText(){
  textSize(14);
  text("Press W, A, S, D, to control the ship", -width/2 + 10, -height/2 + 20);
  text("Press Q to rotate left and E to rotate right", -width/2 + 10, -height/2 + 40);
  text("CAREFUL WITH INVERTED FLIGHT", -width/2 + 10, -height/2 + 60);
  text("Press CTRL to rotate up and SHIFT to rotate down", -width/2 + 10, -height/2 + 80);
  text("Press Z to ascend and C to descend", -width/2 + 10, -height/2 + 100);
  text("Press V to change the view", -width/2 + 10, -height/2 + 120);
  text("Press R to reset the ship position", -width/2 + 10, -height/2 + 140);
}

void setControlsTextAlt(){
  textSize(6);
  pushMatrix();
  rotateX(PI/8);
  text("Press W, A, S, D, to control the ship", -180, -115);
  text("Press Q to rotate left and E to rotate right", -180, -105);
  text("CAREFUL WITH INVERTED FLIGHT", -180, -95);
  text("Press CTRL to rotate up and SHIFT to rotate down", -180, -85);
  text("Press Z to ascend and C to descend", -180, -75);
  text("Press V to change the view", -180, -65);
  text("Press R to reset the ship position", -180, -55);
  popMatrix();
}

void setControlsTextStyle(){
  textSize(14);
  fill(255);
  textAlign(LEFT, LEFT);
}

void draw(){
  setPlanetsBackground();
  globalCoords();
  starCoords();
  shipCoords();    
  for (int i = 0; i < 6; i++) planetCoords(radii[i], orbitSpeed[i], startingAngle[i], planetSizes[i]);
  //setControlsText();
  if (thirdPerson) setShipCamera();
  else setControlsText();
}
