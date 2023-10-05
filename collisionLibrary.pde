//USED JEFFERSON TEXTBOOK ON COLLISIONS HERE
boolean areBallsColliding(Ball b1, Ball b2) { //
  float distX = b1.position.x - b2.position.x;
  float distY = b1.position.y - b2.position.y;
  float distance = sqrt((distX * distX) + (distY * distY));
  return (distance <= b1.radius + b2.radius);
}

boolean ballCollidesWithOther(Ball b) {
    for (Ball otherBall : ballsList) {
        // Make sure we're not checking the ball against itself and the other ball is moving
        if (!b.equals(otherBall) && !otherBall.isStatic) {
            float dist = b.position.distanceTo(otherBall.position);
            if (dist <= 2 * b.radius) {  // since both balls have the same radius
                return true;
            }
        }
    }
    return false;
}

boolean ballCollidesWithLine(Ball ball, Line line) {
    Vec2 ballDirection = new Vec2(ball.velocity.x, ball.velocity.y);
    Vec2 ballNextPosition = ball.position.plus(ballDirection);
    return lineIntersectsCircle(line.start, line.end, ball.position, ball.radius) || 
           lineIntersectsCircle(line.start, line.end, ballNextPosition, ball.radius);
}

boolean lineIntersectsCircle(Vec2 lineStart, Vec2 lineEnd, Vec2 circleCenter, float r) {
    Vec2 lineVec = lineEnd.minus(lineStart);
    Vec2 circleToLine = lineStart.minus(circleCenter);
    float a = dot(lineVec, lineVec);
    float b = 2*dot(circleToLine, lineVec);
    float c = dot(circleToLine, circleToLine) - r*r;
    float discriminant = b*b - 4*a*c;
    if (discriminant < 0) {
        // not intersect
        return false;
    } else {
        discriminant = sqrt(discriminant);
        float t1 = (-b - discriminant) / (2*a);
        float t2 = (-b + discriminant) / (2*a);
        return (t1 >= 0 && t1 <= 1) || (t2 >= 0 && t2 <= 1);
    }
}
void handleCollision(Ball b1, Ball b2) {
    if(b1.isStatic && b2.isStatic) return;  // if both static do nothing
    Vec2 collisionVector = new Vec2(b1.position.x - b2.position.x, b1.position.y - b2.position.y);
    float distance = collisionVector.mag();
    float overlap = 0.5 * (distance - b1.radius - b2.radius);

    // overlap bug
    if (!b1.isStatic && !b2.isStatic) {
        // both balls are movable
        b1.position.x -= overlap * (b1.position.x - b2.position.x) / distance;
        b1.position.y -= overlap * (b1.position.y - b2.position.y) / distance;
        b2.position.x += overlap * (b1.position.x - b2.position.x) / distance;
        b2.position.y += overlap * (b1.position.y - b2.position.y) / distance;
    } else if (!b1.isStatic) {
        // only b1 is movable
        b1.position.x -= overlap * 2 * (b1.position.x - b2.position.x) / distance;
        b1.position.y -= overlap * 2 * (b1.position.y - b2.position.y) / distance;
    } else if (!b2.isStatic) {
        // Only b2 is movable
        b2.position.x += overlap * 2 * (b1.position.x - b2.position.x) / distance;
        b2.position.y += overlap * 2 * (b1.position.y - b2.position.y) / distance;
    }
    Vec2 normal = collisionVector.normalized();
    Vec2 relativeVelocity = b1.velocity.minus(b2.velocity);
    float velAlongNormal = dot(relativeVelocity, normal);
    if (velAlongNormal > 0) {
        return;
    }
    float restitution = 1.5;
    float impulseScalar = -(1 + restitution) * velAlongNormal;
    impulseScalar /= (1/b1.mass + 1/b2.mass);
    Vec2 impulse = normal.times(impulseScalar);
    if(!b1.isStatic) {
      b1.velocity.add(impulse.times(1/b1.mass));
    }
    if(!b2.isStatic) {
      b2.velocity.subtract(impulse.times(1/b2.mass));
    }
}
//void resetState() {
//}

void CheckCollisions() {
    for (int i = 0; i < ballsList.size(); i++) {
        for (int j = i + 1; j < ballsList.size(); j++) {
            if (areBallsColliding(ballsList.get(i), ballsList.get(j))) {
                handleCollision(ballsList.get(i), ballsList.get(j));
            }
        }
    }
    for (int i = 0; i < ballsList.size(); i++) {  // Add this loop for ball to line collision checks
        for (Line line : branches) {
            if (ballCollidesWithLine(ballsList.get(i), line)) {
                handleBallLineCollision(ballsList.get(i), line);
            }
        }
    }
}

void handleBallLineCollision(Ball ball, Line line) {
  Vec2 lineDir = line.end.minus(line.start).normalized();
  Vec2 normal = new Vec2(-lineDir.y, lineDir.x);
  if (dot(normal, ball.velocity) > 0) {
    normal = new Vec2(lineDir.y, -lineDir.x);
  }
  float velAlongNormal = dot(ball.velocity, normal);
  Vec2 impulse = normal.times(-2 * velAlongNormal);
  ball.velocity.add(impulse);
}
