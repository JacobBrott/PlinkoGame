class Ball {
  Vec2 position, velocity, acceleration;
  float radius;
  float mass;
  boolean isStatic;
  PImage currentImage;
  Ball(Vec2 pos, float r, boolean isStatic) {
    position = pos;
    velocity = new Vec2(0, 0);
    acceleration = new Vec2(0, 0.5f);  // gravity
    radius = r;
    this.isStatic = isStatic;
    this.mass = 1;
    if (!isStatic) {
        int randomIndex = int(random(ballImages.length));
        currentImage = ballImages[randomIndex];
    }
  }

  void update() {
    if (!isStatic) {
      velocity.add(acceleration);
      position.add(velocity);
    }
  }

  void render() {
    pushStyle(); 
    imageMode(CENTER);
    if (isStatic) {
      // obstacle
      image(obstacleImage, position.x, position.y, radius * 4, radius * 4);
    } else {
      // drop ball
      image(currentImage, position.x, position.y, radius * 3, radius * 3);
    }
    popStyle(); // Restore the style settings to what they were before
}
}

class ScoreBox {
  float x, y, w, h;
  int score = 0;
  int boxScore;

  ScoreBox(float x, float y, float w, float h, int scoreValue) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.boxScore = scoreValue;
  }
  int getScore() {
    return this.score;
  }
  float getCenterX() {
    return this.x + this.w / 2;
  }
  void render() {
    pushMatrix();
    fill(200);  // light grey
    rect(x, y, w, h);
    fill(0);  // black text
    textSize(24);
    textAlign(CENTER, CENTER);
    text(boxScore, x + w / 2, y + h / 2);
    popMatrix();
  }

  boolean collidesWith(Ball ball) {
    return ball.position.x > x && ball.position.x < x + w && ball.position.y + ball.radius > y;
  }

  void updateScore(int value) {
    this.score += value;
    totalScore += boxScore; // Add the box score to total score
  }
}
class Line {
  Vec2 start, end;

  Line(Vec2 start, Vec2 end) {
    this.start = start;
    this.end = end;
  }

  void render() {
    stroke(165,42,42); // Black color for branches
    strokeWeight(10); // Set the line thickness
    line(start.x, start.y, end.x, end.y);
  }
  public Vec2 getStartPoint() {
    return start;
  }

  public Vec2 getEndPoint() {
    return end;
  }
}
