-- 03_queries.sql: SELECT-запросы по заданию


-- 1. Агрегатная функция (COUNT, SUM, AVG)
-- Общая статистика по неотменённым бронированиям

SELECT
    COUNT(*)          AS bookings_count,
    SUM(total_amount) AS total_sum,
    AVG(total_amount) AS avg_booking
FROM booking
WHERE status <> 'CANCELLED';



-- 2. JOIN между тремя таблицами + GROUP BY + агрегатная функция
-- Количество проданных мест и выручка по каждому туру
-- (tour -> booking_tour -> booking), отменённые брони не учитываются
SELECT
    t.tour_id,
    t.title,
    SUM(bt.participants_count)                 AS seats_sold,
    SUM(bt.participants_count * bt.unit_price) AS tour_revenue
FROM tour t
JOIN booking_tour bt ON bt.tour_id   = t.tour_id
JOIN booking b       ON b.booking_id = bt.booking_id
WHERE b.status <> 'CANCELLED'
GROUP BY t.tour_id, t.title
ORDER BY tour_revenue DESC;



-- 3. Вложенный запрос (подзапрос в WHERE)
-- Туры, цена которых выше средней цены по всем турам

SELECT title, country, base_price
FROM tour
WHERE base_price > (SELECT AVG(base_price) FROM tour)
ORDER BY base_price DESC;



-- 4. Вложенный запрос с IN
-- Клиенты, у которых есть подтверждённое бронирование тура в Таиланд
SELECT user_id, first_name, last_name, email
FROM users
WHERE user_id IN (
    SELECT b.user_id
    FROM booking b
    JOIN booking_tour bt ON bt.booking_id = b.booking_id
    JOIN tour t          ON t.tour_id     = bt.tour_id
    WHERE t.country = 'Таиланд'
      AND b.status = 'CONFIRMED'
);



-- 5. Условный оператор CASE + JOIN + GROUP BY
-- Категория клиента по сумме потраченных средств

SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name AS customer,
    SUM(b.total_amount)                AS total_spent,
    CASE
        WHEN SUM(b.total_amount) >= 4000 THEN 'VIP'
        WHEN SUM(b.total_amount) >= 2000 THEN 'Постоянный'
        ELSE                                  'Новый'
    END AS customer_category
FROM users u
JOIN booking b ON b.user_id = u.user_id
WHERE b.status <> 'CANCELLED'
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_spent DESC;



-- 6. CASE + GROUP BY
-- Категоризация туров по цене и количество туров в каждой категории

SELECT
    CASE
        WHEN base_price < 1000 THEN 'Эконом'
        WHEN base_price < 2000 THEN 'Стандарт'
        ELSE                        'Премиум'
    END AS price_category,
    COUNT(*)        AS tours_count,
    AVG(base_price) AS avg_price
FROM tour
GROUP BY price_category
ORDER BY avg_price;
