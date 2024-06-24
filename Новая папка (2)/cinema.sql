-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Хост: 127.0.0.1:3306
-- Время создания: Апр 23 2024 г., 11:50
-- Версия сервера: 8.0.30
-- Версия PHP: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `cinema`
--

DELIMITER $$
--
-- Функции
--
CREATE DEFINER=`root`@`%` FUNCTION `CalculateAverageTicketPrice` (`movie_id` INT) RETURNS DECIMAL(10,2)  BEGIN
    DECLARE avg_price DECIMAL(10, 2);
    
    SELECT AVG(price) INTO avg_price
    FROM Tickets
    JOIN Screenings ON Tickets.screening_id = Screenings.screening_id
    WHERE Screenings.movie_id = movie_id;

    RETURN avg_price;
END$$

CREATE DEFINER=`root`@`%` FUNCTION `CalculateTotalRevenue` (`startDate` DATE, `endDate` DATE) RETURNS DECIMAL(10,2)  BEGIN
    DECLARE total_revenue DECIMAL(10, 2);

    SELECT SUM(amount) INTO total_revenue
    FROM Sales
    WHERE sale_date BETWEEN startDate AND endDate;

    RETURN total_revenue;
END$$

CREATE DEFINER=`root`@`%` FUNCTION `calculate_bolnich` (`salary` DECIMAL(10,2), `start_date` DATE, `end_date` DATE) RETURNS DECIMAL(10,2)  BEGIN
    DECLARE d_earn DECIMAL(10, 2);
    DECLARE tot_days INT;
    DECLARE bolnich_payment DECIMAL(10, 2);
    
    -- рассчитываем среднедневной заработок
    SET d_earn = salary / 29.3; 
    
    -- рассчитываем общее количество дней в больничном
    SET tot_days = DATEDIFF(end_date, start_date) + 1;
    
    -- рассчитываем размер больничных
    SET bolnich_payment = d_earn * tot_days;
    
    RETURN bolnich_payment;
END$$

CREATE DEFINER=`root`@`%` FUNCTION `calculate_vacation` (`salary` DECIMAL(10,2), `start_date` DATE, `end_date` DATE) RETURNS DECIMAL(10,2)  BEGIN
    DECLARE d_earn DECIMAL(10, 2);
    DECLARE tot_days INT;
    DECLARE vacation_payment DECIMAL(10, 2);
    
    -- рассчитываем среднедневной заработок
    SET d_earn = salary / 29.3; 
    
    -- рассчитываем общее количество дней в отпуске
    SET tot_days = DATEDIFF(end_date, start_date) + 1;
    
    -- рассчитываем размер отпускных
    SET vacation_payment = d_earn * tot_days;
    
    RETURN vacation_payment;
END$$

CREATE DEFINER=`root`@`%` FUNCTION `CountOrdersForCustomer` (`customer_id` INT) RETURNS INT  BEGIN
    DECLARE order_count INT;

    SELECT COUNT(order_id) INTO order_count
    FROM Orders
    WHERE customer_id = customer_id;

    RETURN order_count;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `Actors`
--

CREATE TABLE `Actors` (
  `actor_id` int NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nationality` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Actors`
--

INSERT INTO `Actors` (`actor_id`, `name`, `nationality`) VALUES
(1, 'Tom Hanks', 'American'),
(2, 'Meryl Streep', 'American'),
(3, 'Leonardo DiCaprio', 'American');

-- --------------------------------------------------------

--
-- Структура таблицы `bolnich`
--

CREATE TABLE `bolnich` (
  `bolnich_id` int NOT NULL,
  `employee_id` int DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `bolnich`
--

INSERT INTO `bolnich` (`bolnich_id`, `employee_id`, `start_date`, `end_date`) VALUES
(1, 1, '2022-07-01', '2022-07-10'),
(2, 2, '2022-08-15', '2022-08-30'),
(3, 3, '2022-09-05', '2022-09-15');

-- --------------------------------------------------------

--
-- Структура таблицы `Customers`
--

CREATE TABLE `Customers` (
  `customer_id` int NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Customers`
--

INSERT INTO `Customers` (`customer_id`, `name`, `email`, `phone_number`) VALUES
(1, 'Alice Johnson', 'alice@example.com', '123-456-7890'),
(2, 'Bob Smith', 'bob@example.com', '456-789-1234'),
(3, 'Charlie Brown', 'charlie@example.com', '789-123-4567'),
(4, 'Billy Brown', 'Billy@mail.com', '234-234-2345');

-- --------------------------------------------------------

--
-- Структура таблицы `Directors`
--

CREATE TABLE `Directors` (
  `director_id` int NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nationality` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `movie_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Directors`
--

INSERT INTO `Directors` (`director_id`, `name`, `nationality`, `movie_id`) VALUES
(1, 'Steven Spielberg', 'American', NULL),
(2, 'Quentin Tarantino', 'American', NULL),
(3, 'Martin Scorsese', 'American', NULL);

-- --------------------------------------------------------

--
-- Структура таблицы `Employees`
--

CREATE TABLE `Employees` (
  `employee_id` int NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `department` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `salary` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Employees`
--

INSERT INTO `Employees` (`employee_id`, `name`, `department`, `position`, `salary`) VALUES
(1, 'Иванов Иван Иванович', 'IT', 'Программист', '50000.00'),
(2, 'Петров Петр Петрович', 'HR', 'HR-специалист', '40000.00'),
(3, 'Сидоров Сидор Сидорович', 'Финансы', 'Бухгалтер', '45000.00'),
(4, 'Козлова Елена Александровна', 'Маркетинг', 'Менеджер по маркетингу', '48000.00'),
(5, 'Смирнова Анна Петровна', 'Продажи', 'Менеджер по продажам', '47000.00');

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `employee_bolnich`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `employee_bolnich` (
`Идентификатор` int
,`ФИО` varchar(100)
,`Оклад` decimal(10,2)
,`Размер больничных` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `employee_vacation`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `employee_vacation` (
`Идентификатор` int
,`ФИО` varchar(100)
,`Сумма отпускных` decimal(10,2)
,`НДФЛ 13%` decimal(13,4)
,`К выплате без НДФЛ` decimal(14,4)
);

-- --------------------------------------------------------

--
-- Структура таблицы `Genres`
--

CREATE TABLE `Genres` (
  `genre_id` int NOT NULL,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `movie_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Genres`
--

INSERT INTO `Genres` (`genre_id`, `name`, `movie_id`) VALUES
(1, 'Action', NULL),
(2, 'Comedy', NULL),
(3, 'Thriller', NULL);

-- --------------------------------------------------------

--
-- Структура таблицы `MovieRatings`
--

CREATE TABLE `MovieRatings` (
  `rating_id` int NOT NULL,
  `movie_id` int DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `rating` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `MovieRatings`
--

INSERT INTO `MovieRatings` (`rating_id`, `movie_id`, `customer_id`, `rating`) VALUES
(1, 1, 1, 5),
(2, 2, 2, 4),
(3, 3, 3, 5);

-- --------------------------------------------------------

--
-- Структура таблицы `Movies`
--

CREATE TABLE `Movies` (
  `movie_id` int NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `genre` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duration` int DEFAULT NULL,
  `director` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `release_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Movies`
--

INSERT INTO `Movies` (`movie_id`, `title`, `genre`, `duration`, `director`, `release_date`) VALUES
(1, 'The Shawshank Redemption', 'Drama', 142, 'Frank Darabont', '1994-10-14'),
(2, 'Inception', 'Sci-Fi', 148, 'Christopher Nolan', '2010-07-16'),
(3, 'The Godfather', 'Crime', 175, 'Francis Ford Coppola', '1972-03-24');

-- --------------------------------------------------------

--
-- Структура таблицы `Orders`
--

CREATE TABLE `Orders` (
  `order_id` int NOT NULL,
  `customer_id` int DEFAULT NULL,
  `ticket_id` int DEFAULT NULL,
  `order_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Orders`
--

INSERT INTO `Orders` (`order_id`, `customer_id`, `ticket_id`, `order_date`) VALUES
(1, 1, 1, '2022-10-01'),
(2, 2, 2, '2022-10-02'),
(3, 3, 3, '2022-10-03');

--
-- Триггеры `Orders`
--
DELIMITER $$
CREATE TRIGGER `OrdersDelete` AFTER DELETE ON `Orders` FOR EACH ROW INSERT INTO OrdersHistory (historyid, orderid, operationtype, operationdate)
VALUES (NULL, OLD.order_id, 'DELETE', NOW())
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `OrdersInsert` AFTER INSERT ON `Orders` FOR EACH ROW INSERT INTO OrdersHistory (historyid, orderid, operationtype, operationdate)
VALUES (NULL, NEW.order_id, 'INSERT', NOW())
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `OrdersUpdate` AFTER UPDATE ON `Orders` FOR EACH ROW INSERT INTO OrdersHistory (historyid, orderid, operationtype, operationdate)
VALUES (NULL, NEW.order_id, 'UPDATE', NOW())
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Orders_Delete` AFTER DELETE ON `Orders` FOR EACH ROW INSERT INTO OrdersHistory (order_id, operation_type, operation_date)
VALUES (OLD.order_id, 'DELETE', NOW())
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Orders_Insert` AFTER INSERT ON `Orders` FOR EACH ROW INSERT INTO OrdersHistory (order_id, operation_type, operation_date)
VALUES (NEW.order_id, 'INSERT', NOW())
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Orders_Update` AFTER UPDATE ON `Orders` FOR EACH ROW INSERT INTO OrdersHistory (order_id, operation_type, operation_date)
VALUES (NEW.order_id, 'UPDATE', NOW())
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `OrdersHistory`
--

CREATE TABLE `OrdersHistory` (
  `history_id` int NOT NULL,
  `order_id` int DEFAULT NULL,
  `operation_type` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `operation_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `Promotions`
--

CREATE TABLE `Promotions` (
  `promo_id` int NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Promotions`
--

INSERT INTO `Promotions` (`promo_id`, `name`, `description`, `start_date`, `end_date`) VALUES
(1, 'Summer Movie Marathon', 'Watch 3 movies for the price of 2!', '2022-07-01', '2022-09-30'),
(2, 'Student Discount', 'Get 20% off with student ID!', '2022-10-01', '2022-12-31'),
(3, 'Family Bundle', 'Family of 4 gets free popcorn!', '2022-11-01', '2022-11-30');

-- --------------------------------------------------------

--
-- Структура таблицы `Reviews`
--

CREATE TABLE `Reviews` (
  `review_id` int NOT NULL,
  `movie_id` int DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `review_text` text COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Reviews`
--

INSERT INTO `Reviews` (`review_id`, `movie_id`, `customer_id`, `review_text`) VALUES
(1, 1, 1, 'One of the best movies I have ever seen.'),
(2, 2, 2, 'Mind-bending plot with great performances.'),
(3, 3, 3, 'A classic masterpiece.');

-- --------------------------------------------------------

--
-- Структура таблицы `Roles`
--

CREATE TABLE `Roles` (
  `role_id` int NOT NULL,
  `actor_id` int DEFAULT NULL,
  `movie_id` int DEFAULT NULL,
  `character_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Roles`
--

INSERT INTO `Roles` (`role_id`, `actor_id`, `movie_id`, `character_name`) VALUES
(1, 1, 1, 'Andy Dufresne'),
(2, 2, 2, 'Cobb'),
(3, 3, 3, 'Michael Corleone');

-- --------------------------------------------------------

--
-- Структура таблицы `Sales`
--

CREATE TABLE `Sales` (
  `sale_id` int NOT NULL,
  `screening_id` int DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `sale_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Sales`
--

INSERT INTO `Sales` (`sale_id`, `screening_id`, `amount`, `sale_date`) VALUES
(1, 1, '125.00', '2022-10-01'),
(2, 2, '150.00', '2022-10-02'),
(3, 3, '100.00', '2022-10-03');

-- --------------------------------------------------------

--
-- Структура таблицы `Schedules`
--

CREATE TABLE `Schedules` (
  `schedule_id` int NOT NULL,
  `theater_id` int DEFAULT NULL,
  `movie_id` int DEFAULT NULL,
  `day` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Schedules`
--

INSERT INTO `Schedules` (`schedule_id`, `theater_id`, `movie_id`, `day`, `start_time`, `end_time`) VALUES
(1, 1, 1, 'Monday', '18:00:00', '20:30:00'),
(2, 2, 2, 'Tuesday', '15:00:00', '17:28:00'),
(3, 3, 3, 'Wednesday', '20:00:00', '23:15:00');

-- --------------------------------------------------------

--
-- Структура таблицы `Screenings`
--

CREATE TABLE `Screenings` (
  `screening_id` int NOT NULL,
  `movie_id` int DEFAULT NULL,
  `theater_id` int DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Screenings`
--

INSERT INTO `Screenings` (`screening_id`, `movie_id`, `theater_id`, `start_time`, `end_time`) VALUES
(1, 1, 1, '2022-10-01 18:00:00', '2022-10-01 20:30:00'),
(2, 2, 2, '2022-10-02 15:00:00', '2022-10-02 17:28:00'),
(3, 3, 3, '2022-10-03 20:00:00', '2022-10-03 23:15:00');

-- --------------------------------------------------------

--
-- Структура таблицы `Theaters`
--

CREATE TABLE `Theaters` (
  `theater_id` int NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `capacity` int DEFAULT NULL,
  `location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Theaters`
--

INSERT INTO `Theaters` (`theater_id`, `name`, `capacity`, `location`) VALUES
(1, 'Theater 1', 100, 'New York'),
(2, 'Theater 2', 150, 'Los Angeles'),
(3, 'Theater 3', 120, 'Chicago');

-- --------------------------------------------------------

--
-- Структура таблицы `Tickets`
--

CREATE TABLE `Tickets` (
  `ticket_id` int NOT NULL,
  `screening_id` int DEFAULT NULL,
  `seat_number` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Tickets`
--

INSERT INTO `Tickets` (`ticket_id`, `screening_id`, `seat_number`, `price`) VALUES
(1, 1, 'A1', '12.50'),
(2, 2, 'B5', '15.00'),
(3, 3, 'C8', '10.75'),
(4, 1, 'A5', '12.50');

-- --------------------------------------------------------

--
-- Структура таблицы `vacations`
--

CREATE TABLE `vacations` (
  `vacation_id` int NOT NULL,
  `employee_id` int DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `vacations`
--

INSERT INTO `vacations` (`vacation_id`, `employee_id`, `start_date`, `end_date`) VALUES
(1, 1, '2022-07-01', '2022-07-10'),
(2, 2, '2022-08-15', '2022-08-30'),
(3, 3, '2022-09-05', '2022-09-15');

-- --------------------------------------------------------

--
-- Структура для представления `employee_bolnich`
--
DROP TABLE IF EXISTS `employee_bolnich`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `employee_bolnich`  AS SELECT `e`.`employee_id` AS `Идентификатор`, `e`.`name` AS `ФИО`, `e`.`salary` AS `Оклад`, `calculate_bolnich`(`e`.`salary`,`b`.`start_date`,`b`.`end_date`) AS `Размер больничных` FROM (`employees` `e` join `bolnich` `b` on((`e`.`employee_id` = `b`.`employee_id`)))  ;

-- --------------------------------------------------------

--
-- Структура для представления `employee_vacation`
--
DROP TABLE IF EXISTS `employee_vacation`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `employee_vacation`  AS SELECT `e`.`employee_id` AS `Идентификатор`, `e`.`name` AS `ФИО`, `calculate_vacation`(`e`.`salary`,`v`.`start_date`,`v`.`end_date`) AS `Сумма отпускных`, (`calculate_vacation`(`e`.`salary`,`v`.`start_date`,`v`.`end_date`) * 0.13) AS `НДФЛ 13%`, (`calculate_vacation`(`e`.`salary`,`v`.`start_date`,`v`.`end_date`) - (`calculate_vacation`(`e`.`salary`,`v`.`start_date`,`v`.`end_date`) * 0.13)) AS `К выплате без НДФЛ` FROM (`employees` `e` join `vacations` `v` on((`e`.`employee_id` = `v`.`employee_id`)))  ;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `Actors`
--
ALTER TABLE `Actors`
  ADD PRIMARY KEY (`actor_id`);

--
-- Индексы таблицы `bolnich`
--
ALTER TABLE `bolnich`
  ADD PRIMARY KEY (`bolnich_id`),
  ADD KEY `employee_id` (`employee_id`);

--
-- Индексы таблицы `Customers`
--
ALTER TABLE `Customers`
  ADD PRIMARY KEY (`customer_id`);

--
-- Индексы таблицы `Directors`
--
ALTER TABLE `Directors`
  ADD PRIMARY KEY (`director_id`),
  ADD KEY `movie_id` (`movie_id`);

--
-- Индексы таблицы `Employees`
--
ALTER TABLE `Employees`
  ADD PRIMARY KEY (`employee_id`);

--
-- Индексы таблицы `Genres`
--
ALTER TABLE `Genres`
  ADD PRIMARY KEY (`genre_id`),
  ADD KEY `movie_id` (`movie_id`);

--
-- Индексы таблицы `MovieRatings`
--
ALTER TABLE `MovieRatings`
  ADD PRIMARY KEY (`rating_id`),
  ADD KEY `movie_id` (`movie_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Индексы таблицы `Movies`
--
ALTER TABLE `Movies`
  ADD PRIMARY KEY (`movie_id`);

--
-- Индексы таблицы `Orders`
--
ALTER TABLE `Orders`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `customer_id` (`customer_id`),
  ADD KEY `ticket_id` (`ticket_id`);

--
-- Индексы таблицы `OrdersHistory`
--
ALTER TABLE `OrdersHistory`
  ADD PRIMARY KEY (`history_id`);

--
-- Индексы таблицы `Promotions`
--
ALTER TABLE `Promotions`
  ADD PRIMARY KEY (`promo_id`);

--
-- Индексы таблицы `Reviews`
--
ALTER TABLE `Reviews`
  ADD PRIMARY KEY (`review_id`),
  ADD KEY `movie_id` (`movie_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Индексы таблицы `Roles`
--
ALTER TABLE `Roles`
  ADD PRIMARY KEY (`role_id`),
  ADD KEY `actor_id` (`actor_id`),
  ADD KEY `movie_id` (`movie_id`);

--
-- Индексы таблицы `Sales`
--
ALTER TABLE `Sales`
  ADD PRIMARY KEY (`sale_id`),
  ADD KEY `screening_id` (`screening_id`);

--
-- Индексы таблицы `Schedules`
--
ALTER TABLE `Schedules`
  ADD PRIMARY KEY (`schedule_id`),
  ADD KEY `theater_id` (`theater_id`),
  ADD KEY `movie_id` (`movie_id`);

--
-- Индексы таблицы `Screenings`
--
ALTER TABLE `Screenings`
  ADD PRIMARY KEY (`screening_id`),
  ADD KEY `movie_id` (`movie_id`),
  ADD KEY `theater_id` (`theater_id`);

--
-- Индексы таблицы `Theaters`
--
ALTER TABLE `Theaters`
  ADD PRIMARY KEY (`theater_id`);

--
-- Индексы таблицы `Tickets`
--
ALTER TABLE `Tickets`
  ADD PRIMARY KEY (`ticket_id`),
  ADD KEY `screening_id` (`screening_id`);

--
-- Индексы таблицы `vacations`
--
ALTER TABLE `vacations`
  ADD PRIMARY KEY (`vacation_id`),
  ADD KEY `employee_id` (`employee_id`);

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `bolnich`
--
ALTER TABLE `bolnich`
  ADD CONSTRAINT `bolnich_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `Employees` (`employee_id`);

--
-- Ограничения внешнего ключа таблицы `Directors`
--
ALTER TABLE `Directors`
  ADD CONSTRAINT `directors_ibfk_1` FOREIGN KEY (`movie_id`) REFERENCES `Movies` (`movie_id`);

--
-- Ограничения внешнего ключа таблицы `Genres`
--
ALTER TABLE `Genres`
  ADD CONSTRAINT `genres_ibfk_1` FOREIGN KEY (`movie_id`) REFERENCES `Movies` (`movie_id`);

--
-- Ограничения внешнего ключа таблицы `MovieRatings`
--
ALTER TABLE `MovieRatings`
  ADD CONSTRAINT `movieratings_ibfk_1` FOREIGN KEY (`movie_id`) REFERENCES `Movies` (`movie_id`),
  ADD CONSTRAINT `movieratings_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `Customers` (`customer_id`);

--
-- Ограничения внешнего ключа таблицы `Orders`
--
ALTER TABLE `Orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `Customers` (`customer_id`),
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`ticket_id`) REFERENCES `Tickets` (`ticket_id`);

--
-- Ограничения внешнего ключа таблицы `Reviews`
--
ALTER TABLE `Reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`movie_id`) REFERENCES `Movies` (`movie_id`),
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `Customers` (`customer_id`);

--
-- Ограничения внешнего ключа таблицы `Roles`
--
ALTER TABLE `Roles`
  ADD CONSTRAINT `roles_ibfk_1` FOREIGN KEY (`actor_id`) REFERENCES `Actors` (`actor_id`),
  ADD CONSTRAINT `roles_ibfk_2` FOREIGN KEY (`movie_id`) REFERENCES `Movies` (`movie_id`);

--
-- Ограничения внешнего ключа таблицы `Sales`
--
ALTER TABLE `Sales`
  ADD CONSTRAINT `sales_ibfk_1` FOREIGN KEY (`screening_id`) REFERENCES `Screenings` (`screening_id`);

--
-- Ограничения внешнего ключа таблицы `Schedules`
--
ALTER TABLE `Schedules`
  ADD CONSTRAINT `schedules_ibfk_1` FOREIGN KEY (`theater_id`) REFERENCES `Theaters` (`theater_id`),
  ADD CONSTRAINT `schedules_ibfk_2` FOREIGN KEY (`movie_id`) REFERENCES `Movies` (`movie_id`);

--
-- Ограничения внешнего ключа таблицы `Screenings`
--
ALTER TABLE `Screenings`
  ADD CONSTRAINT `screenings_ibfk_1` FOREIGN KEY (`movie_id`) REFERENCES `Movies` (`movie_id`),
  ADD CONSTRAINT `screenings_ibfk_2` FOREIGN KEY (`theater_id`) REFERENCES `Theaters` (`theater_id`);

--
-- Ограничения внешнего ключа таблицы `Tickets`
--
ALTER TABLE `Tickets`
  ADD CONSTRAINT `tickets_ibfk_1` FOREIGN KEY (`screening_id`) REFERENCES `Screenings` (`screening_id`);

--
-- Ограничения внешнего ключа таблицы `vacations`
--
ALTER TABLE `vacations`
  ADD CONSTRAINT `vacations_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `Employees` (`employee_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
