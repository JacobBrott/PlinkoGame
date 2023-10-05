class Particle {
  PVector pos, vel, acc;
  float lifespan;
  Particle(PVector l) {
    acc = new PVector(0, 0.05);
    vel = new PVector(random(-1, 1), random(-2, 0));
    pos = l.copy();
    lifespan = 255;
  }

  void run() {
    update();
    display();
  }

  void update() {
    vel.add(acc);
    pos.add(vel);
    lifespan -= 2;
  }

  void display() {
    stroke(255, lifespan);
    fill(255, lifespan);
    ellipse(pos.x, pos.y, 8, 8);
  }

  boolean isDead() {
    return (lifespan < 0.0);
  }
}

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;

  ParticleSystem(PVector position) {
    origin = position.copy();
    particles = new ArrayList<Particle>();
  }

  void addParticle() {
    particles.add(new Particle(origin));
  }

  void run() {
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}
