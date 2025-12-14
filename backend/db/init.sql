CREATE TABLE IF NOT EXISTS members (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS trips (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  trip_date DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS media (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO members (name)
SELECT 'Member ' || g FROM generate_series(1,20) g
WHERE NOT EXISTS (SELECT 1 FROM members);

INSERT INTO trips (title, trip_date)
SELECT 'Trip ' || g, CURRENT_DATE + g
FROM generate_series(1,3) g
WHERE NOT EXISTS (SELECT 1 FROM trips);

INSERT INTO media (title)
SELECT 'Media ' || g FROM generate_series(1,5) g
WHERE NOT EXISTS (SELECT 1 FROM media);
