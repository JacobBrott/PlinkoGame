// Vector Library
// CSCI 5611 Vector 2 Library [Particle Systems]
// Stephen J. Guy <sjguy@umn.edu>

public class Vec2 {
    public float x, y;
    public Vec2(float x, float y) {
        this.x = x;
        this.y = y;
    }
    public Vec2 copy() {
    return new Vec2(this.x, this.y);
}
    public float distSquared(Vec2 v) {
        float dx = x - v.x;
        float dy = y - v.y;
        return dx * dx + dy * dy;
    }
    public String toString() {
        return "(" + x + "," + y + ")";
    }
    public float length() {
        return sqrt(x * x + y * y);
    }
    public float mag() {
        return length();
    }
    public Vec2 plus(Vec2 rhs) {
        return new Vec2(x + rhs.x, y + rhs.y);
    }
    public void add(Vec2 rhs) {
        x += rhs.x;
        y += rhs.y;
    }
    public Vec2 minus(Vec2 rhs) {
        return new Vec2(x - rhs.x, y - rhs.y);
    }
    public void subtract(Vec2 rhs) {
        x -= rhs.x;
        y -= rhs.y;
    }
    public Vec2 times(float rhs) {
        return new Vec2(x * rhs, y * rhs);
    }
    public void mul(float rhs) {
        x *= rhs;
        y *= rhs;
    }
    public void clampToLength(float maxL) {
        float magnitude = length();
        if (magnitude > maxL) {
            x *= maxL / magnitude;
            y *= maxL / magnitude;
        }
    }
    public void setToLength(float newL) {
        float magnitude = length();
        x *= newL / magnitude;
        y *= newL / magnitude;
    }
    public void normalize() {
        float magnitude = length();
        x /= magnitude;
        y /= magnitude;
    }
    public Vec2 normalized() {
        float magnitude = length();
        return new Vec2(x / magnitude, y / magnitude);
    }
    public Vec2 reflect(Vec2 normal) {
        normal = normal.normalized();
        return this.minus(normal.times(2 * dot(this, normal)));
    }
    public float distanceTo(Vec2 rhs) {
        float dx = rhs.x - x;
        float dy = rhs.y - y;
        return sqrt(dx * dx + dy * dy);
    }
}

Vec2 interpolate(Vec2 a, Vec2 b, float t) {
    return a.plus((b.minus(a)).times(t));
}

float interpolate(float a, float b, float t) {
    return a + ((b - a) * t);
}

float dot(Vec2 a, Vec2 b) {
    return a.x * b.x + a.y * b.y;
}

Vec2 projAB(Vec2 a, Vec2 b) {
    return b.times(dot(a, b));
}
float pointToLineSegmentDistance(Vec2 point, Vec2 start, Vec2 end) {
    float l2 = dot(start.minus(end), start.minus(end));
    if (l2 == 0.0) return point.distanceTo(start);
    float t = dot(point.minus(start), end.minus(start)) / l2;
    t = Math.max(0, Math.min(1, t));
    Vec2 projection = start.plus(end.minus(start).times(t));
    return point.distanceTo(projection);
}
