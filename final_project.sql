USE pandemic;

-- ================================================================
-- ЗАВДАННЯ 2: НОРМАЛІЗАЦІЯ ДАНИХ
-- ================================================================

-- Вимикаємо безпечний режим для оновлення
SET SQL_SAFE_UPDATES = 0;

-- 1. Створюємо таблицю entities
DROP TABLE IF EXISTS entities;
CREATE TABLE entities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_name VARCHAR(255),
    entity_code VARCHAR(255)
);

-- 2. Заповнюємо її даними
INSERT INTO entities (entity_name, entity_code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;

-- 3. Додаємо колонку entity_id до основної таблиці
-- (Видаляємо її спочатку, якщо вона раптом є, щоб уникнути помилок при повторному запуску)
ALTER TABLE infectious_cases DROP COLUMN entity_id;
ALTER TABLE infectious_cases ADD COLUMN entity_id INT;

-- 4. Оновлюємо основну таблицю (проставляємо ID)
UPDATE infectious_cases ic
JOIN entities e ON ic.Entity = e.entity_name AND ic.Code = e.entity_code
SET ic.entity_id = e.id;

-- 5. Видаляємо зайві стовпчики Entity та Code
ALTER TABLE infectious_cases 
DROP COLUMN Entity,
DROP COLUMN Code;

-- Вмикаємо безпечний режим назад
SET SQL_SAFE_UPDATES = 1;

-- Перевірка кількості рядків
SELECT COUNT(*) as total_rows FROM infectious_cases;


-- ================================================================
-- ЗАВДАННЯ 3: АНАЛІЗ ДАНИХ (Rabies)
-- ================================================================

SELECT 
    e.entity_name,
    e.entity_code,
    AVG(ic.Number_rabies) AS avg_rabies,
    MIN(ic.Number_rabies) AS min_rabies,
    MAX(ic.Number_rabies) AS max_rabies,
    SUM(ic.Number_rabies) AS sum_rabies
FROM infectious_cases ic
JOIN entities e ON ic.entity_id = e.id
WHERE ic.Number_rabies IS NOT NULL AND ic.Number_rabies != ''
GROUP BY e.entity_name, e.entity_code
ORDER BY avg_rabies DESC
LIMIT 10;


-- ================================================================
-- ЗАВДАННЯ 4: РОБОТА З ДАТАМИ
-- ================================================================

SELECT 
    Year,
    MAKEDATE(Year, 1) AS start_of_year, 
    CURDATE() AS current_date_value,
    TIMESTAMPDIFF(YEAR, MAKEDATE(Year, 1), CURDATE()) AS year_difference
FROM infectious_cases
LIMIT 10;


-- ================================================================
-- ЗАВДАННЯ 5: ВЛАСНА ФУНКЦІЯ
-- ================================================================

DROP FUNCTION IF EXISTS CalculateYearDiff;

DELIMITER //

CREATE FUNCTION CalculateYearDiff(input_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE start_date DATE;
    SET start_date = MAKEDATE(input_year, 1);
    RETURN TIMESTAMPDIFF(YEAR, start_date, CURDATE());
END //

DELIMITER ;

-- Використання функції
SELECT 
    Year,
    CalculateYearDiff(Year) AS year_diff_function
FROM infectious_cases
LIMIT 10;