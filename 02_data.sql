-- 01_schema.sql: создание таблиц (DDL), PostgreSQL
-- Фрагмент ER-диаграммы туристического агентства: 4 таблицы

DROP TABLE IF EXISTS booking_tour CASCADE;
DROP TABLE IF EXISTS booking      CASCADE;
DROP TABLE IF EXISTS tour         CASCADE;
DROP TABLE IF EXISTS users        CASCADE;

CREATE TABLE users (
    user_id         SERIAL PRIMARY KEY,
    email           VARCHAR(255) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    first_name      VARCHAR(100) NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    phone           VARCHAR(30),
    date_of_birth   DATE,
    passport_number VARCHAR(30),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE tour (
    tour_id          SERIAL PRIMARY KEY,
    title            VARCHAR(200) NOT NULL,
    description      TEXT,
    country          VARCHAR(100) NOT NULL,
    city             VARCHAR(100),
    duration_days    INT NOT NULL CHECK (duration_days > 0),
    base_price       NUMERIC(10,2) NOT NULL CHECK (base_price >= 0),
    start_date       DATE NOT NULL,
    end_date         DATE NOT NULL,
    max_participants INT NOT NULL CHECK (max_participants > 0),
    status           VARCHAR(20) NOT NULL DEFAULT 'PUBLISHED',
    CHECK (end_date >= start_date)
);

CREATE TABLE booking (
    booking_id   SERIAL PRIMARY KEY,
    user_id      INT NOT NULL REFERENCES users(user_id),
    booking_type VARCHAR(20) NOT NULL DEFAULT 'TOUR',
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status       VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
    currency     CHAR(3) NOT NULL DEFAULT 'EUR'
);

-- Связь M:N между бронированием и туром
CREATE TABLE booking_tour (
    booking_id         INT NOT NULL REFERENCES booking(booking_id) ON DELETE CASCADE,
    tour_id            INT NOT NULL REFERENCES tour(tour_id),
    participants_count INT NOT NULL CHECK (participants_count > 0),
    unit_price         NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (booking_id, tour_id)
);
