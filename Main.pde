import processing.sound.*;
import ddf.minim.*;

SoundFile ballSoundEffect;
SoundFile scorePointSound;
//Minim minim;
//AudioPlayer scoreSound;

// load assets
String[] ballImageFiles = {
  "assets/Black-Circle-3d-icon.png",
  "assets/Blue-Circle-3d-icon.png",
  "assets/Brown-Circle-3d-icon.png",
  "assets/Green-Circle-3d-icon.png",
  "assets/Orange-Circle-3d-icon.png",
  "assets/Purple-Circle-3d-icon.png",
  "assets/Red-Circle-3d-icon.png",
  "assets/White-Circle-3d-icon.png",
  "assets/Yellow-Circle-3d-icon.png"
};

int currentScene = 0;  // default scene
PImage backgroundImage;
PImage obstacleImage;
PImage[] ballImages = new PImage[ballImageFiles.length];
ArrayList<Ball> ballsList = new ArrayList<Ball>();
ArrayList<ScoreBox> scoreBoxes = new ArrayList<ScoreBox>();
ArrayList<Line> branches = new ArrayList<Line>();
ArrayList<ParticleSystem> fireworks = new ArrayList<ParticleSystem>();

//scoring
int totalScore = 0;
int ballsDropped = 0;

void setup() {
  size(1732, 1155);
  //minim = new Minim(this);
  //scoreSound = minim.loadFile("assets/score.mp3");
  ballSoundEffect = new SoundFile(this, "assets/ballSoundEffect.mp3");
  //scorePointSound = new SoundFile(this, "assets/score.mp3");
  backgroundImage = loadImage("assets/background.png");
  obstacleImage = loadImage("assets/obstacle.png");
  for (int i = 0; i < ballImageFiles.length; i++) {
    ballImages[i] = loadImage(ballImageFiles[i]);
  }
  initGame();
}

void initGame() {
  ballsList.clear();
  branches.clear();
  switch(currentScene) {
    case 0:
      setupScene0();
      break;
    case 1:
      setupScene1();
      break;
    case 2:
      setupScene2();
      break;
  }
  
  // score boxes 
  int[] boxScores = {5, 10, 15, 10, 5};
  float boxWidth = width / boxScores.length;
  for (int i = 0; i < boxScores.length; i++) {
    scoreBoxes.add(new ScoreBox(i * boxWidth, height - 50, boxWidth, 50, boxScores[i]));
  }
}

// default
void setupScene0() {
  float spacing = 120;
  int numRows = 7;
  int[] numBallsInRows = {9, 8, 9, 8, 9, 8, 9};
  for (int i = 0; i < numRows; i++) {
    float initialX = (width - (numBallsInRows[i] - 1) * spacing) / 2;
    for (int j = 0; j < numBallsInRows[i]; j++) {
      float x = initialX + j * spacing;
      float y = 100 + i * spacing;
      Ball staticBall = new Ball(new Vec2(x, y), 20, true);
      ballsList.add(staticBall);
    }
  }
  float yOffset = height / 4;
  float gapBetweenX = 400;
  addXPattern(yOffset);
  addXPattern(yOffset + gapBetweenX);
}

// circle
void setupScene1() {
  float centerX = width / 2;
  float centerY = height / 2;
  float radius = 300; 
  int numBalls = 30;  // circumference balls
  for (int i = 0; i < numBalls; i++) {
    float angle = TWO_PI / numBalls * i;
    float x = centerX + radius * cos(angle);
    float y = centerY + radius * sin(angle);
    Ball staticBall = new Ball(new Vec2(x, y), 20, true);
    ballsList.add(staticBall);
  }
}

// triangle
void setupScene2() {
  float topX = width / 2;
  float topY = 250; 
  float baseLeftX = topX - 250;
  float baseRightX = topX + 250;
  float baseY = topY + 500;  
  
  // top vertex
  Ball topBall = new Ball(new Vec2(topX, topY), 20, true);
  ballsList.add(topBall);

  // base
  int numBallsBase = 20;
  float spacing = (baseRightX - baseLeftX) / (numBallsBase - 1);
  for (int i = 0; i < numBallsBase; i++) {
    float x = baseLeftX + spacing * i;
    Ball staticBall = new Ball(new Vec2(x, baseY), 20, true);
    ballsList.add(staticBall);
  }

  // left/right slope
  float slopeSpacingY = (baseY - topY) / 10;
  float slopeSpacingX = (baseRightX - topX) / 10;
  for (int i = 1; i <= 9; i++) {
    Ball leftSlopeBall = new Ball(new Vec2(topX - slopeSpacingX * i, topY + slopeSpacingY * i), 20, true);
    Ball rightSlopeBall = new Ball(new Vec2(topX + slopeSpacingX * i, topY + slopeSpacingY * i), 20, true);
    ballsList.add(leftSlopeBall);
    ballsList.add(rightSlopeBall);
  }
}
void draw() {
  background(220);
  image(backgroundImage, 0, 0, width, height); 
  drawInstructionsBox();  // Render the instructions box
  for (Ball ball : ballsList) {
    ball.update();
    ball.render();
  }
  for (ScoreBox box : scoreBoxes) {
    box.render();
    for (int i = ballsList.size() - 1; i >= 0; i--) {
      Ball b = ballsList.get(i);
      if (!b.isStatic && box.collidesWith(b)) {
        box.updateScore(1);
        //scoreSound.play();
        ballsList.remove(i);
        if (box.getScore() == 15) {
          celebrate(box.getCenterX());
        }
      }
    }
  }
  for (Line branch : branches) {
    branch.render();
  }
  for (ParticleSystem ps : fireworks) {
    ps.run();
  }
  updateGame();
  fill(255, 0, 0);  // red text
  textSize(32);
  textAlign(LEFT, CENTER);
  text("Balls Dropped: " + ballsDropped, 10, 30);
  textAlign(RIGHT, CENTER);
  text("Total Score: " + totalScore, width - 10, 30);
}

void updateGame() {
  //resetState();
  CheckCollisions();
  // Play ball sound effect if necessary
  for (Ball ball : ballsList) {
    if (!ball.isStatic) {
      for (Ball staticBall : ballsList) {
        if (staticBall.isStatic && areBallsColliding(ball, staticBall)) {
          ballSoundEffect.play();
          break; 
        }
      }
    }
  }
           
}
void addXPattern(float y) {
  float branchLength = 300;
  float angle = PI / 4; // 45 degrees
  float xOffset = 100; // distance from the wall

  // upper left
  branches.add(new Line(
    new Vec2(xOffset, y), 
    new Vec2(xOffset + cos(angle) * branchLength, y - sin(angle) * branchLength)
  ));

  // lower left
  branches.add(new Line(
    new Vec2(xOffset, y), 
    new Vec2(xOffset + cos(angle) * branchLength, y + sin(angle) * branchLength)
  ));

  // upper right
  branches.add(new Line(
    new Vec2(width - xOffset, y), 
    new Vec2((width - xOffset) - cos(angle) * branchLength, y - sin(angle) * branchLength)
  ));

  // lower right
  branches.add(new Line(
    new Vec2(width - xOffset, y), 
    new Vec2((width - xOffset) - cos(angle) * branchLength, y + sin(angle) * branchLength)
  ));
}
void celebrate(float x) {
  ParticleSystem ps = new ParticleSystem(new PVector(x, height - 75));  // 75 is 50 (box height) + 25 (half particle size)
  for (int i = 0; i < 100; i++) {  // 100 particles for the firework effect
    ps.addParticle();
  }
  fireworks.add(ps);
}

void drawInstructionsBox() {
  // intruct box
  fill(50, 50, 50, 200);  // semi-transparent dark gray for the box
  rect(10, 10, width - 20, 80, 10);  // box with rounded corners
  
  // Text
  fill(255);  
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Press '1' for Default, '2' for Circle, '3' for Triangle, Press 'SPACE' to drop a ball.", width/2, 30);
}

void keyPressed() {
  if (key == '1') {
    currentScene = 0;
    initGame();  // reset the game whenever we switch scenes
  } else if (key == '2') {
    currentScene = 1;
    initGame();
  } else if (key == '3') {
    currentScene = 2;
    initGame();
  } else if (key == ' ') {
    ballsDropped++;
    float randomX = random(width);
    Ball movingBall = new Ball(new Vec2(randomX, 20), 20, false);
    ballsList.add(movingBall);
  }
}
