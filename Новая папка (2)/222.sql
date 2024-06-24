-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Хост: 127.0.0.1:3306
-- Время создания: Июн 24 2024 г., 15:23
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
-- База данных: `222`
--

DELIMITER $$
--
-- Процедуры
--
CREATE DEFINER=`root`@`%` PROCEDURE `BookTickets` (IN `depCountry` VARCHAR(50), IN `arrCountry` VARCHAR(50), IN `totalTickets` INT, IN `childTickets7` INT, IN `childTickets14` INT)   BEGIN
    DECLARE totalPrice DECIMAL(10, 2);

    SET totalPrice = (totalTickets - childTickets7 - childTickets14) * (
        SELECT Price
        FROM Flights
        WHERE DepartureAirportId = (SELECT Id FROM Airports WHERE City = depCountry)
        AND ArrivalAirportId = (SELECT Id FROM Airports WHERE City = arrCountry)
    );

    INSERT INTO Booking (DepartureCountry, ArrivalCountry, TotalTickets, ChildTickets7, ChildTickets14, TotalPrice)
    VALUES (depCountry, arrCountry, totalTickets, childTickets7, childTickets14, totalPrice);
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `CalculateFinalTicketPrice` ()   BEGIN
    DECLARE flightDiscount DECIMAL(10, 2);
    DECLARE flightCommission DECIMAL(10, 2);
    DECLARE finalPrice DECIMAL(10, 2);
    DECLARE ArrivalAirportName VARCHAR(50);
    DECLARE CardNumber VARCHAR(16);
    DECLARE PaymentSystem VARCHAR(50);
    
    SELECT FlightNumber, ArrivalAirportId, CardNumber, PaymentSystem, Price
    INTO @FlightNumber, @ArrivalAirportId, @CardNumber, PaymentSystem, @Price
    FROM Flights
    LIMIT 1;
    
    SELECT Name INTO ArrivalAirportName
    FROM Airports
    WHERE Id = @ArrivalAirportId;
    
    IF ArrivalAirportName = 'City A' AND PaymentSystem = 'МИР' THEN
        SET flightDiscount = 0.15 * @Price;
        SET finalPrice = @Price - flightDiscount;
    ELSEIF (ArrivalAirportName = 'City B' OR ArrivalAirportName = 'City C') AND PaymentSystem = 'VISA' THEN
        SET flightCommission = 0.05 * @Price;
        SET finalPrice = @Price + flightCommission;
    ELSE
        SET finalPrice = @Price;
    END IF;
    
    SELECT @FlightNumber AS FlightNumber, ArrivalAirportName AS ArrivalAirport, @CardNumber AS CardNumber, PaymentSystem AS PaymentSystem, @Price AS InitialPrice, finalPrice AS FinalPrice;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `CalculateTicketPrices` ()   BEGIN
    DECLARE adultPrice DECIMAL(10, 2);
    DECLARE child7to14Price DECIMAL(10, 2);
    DECLARE child0to7Price DECIMAL(10, 2);
    
    SELECT Price INTO adultPrice
    FROM Flights
    LIMIT 1;
    
    SET child7to14Price = 0.7 * adultPrice;
    SET child0to7Price = 0.5 * adultPrice;
    
    SELECT FlightNumber, DepartureAirportId, ArrivalAirportId, adultPrice, child7to14Price, adultPrice, child0to7Price
    FROM Flights
    LIMIT 1;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `GenerateReport` ()   BEGIN
    DECLARE totalTickets INT;
    DECLARE soldTickets INT;
    DECLARE remainingTickets INT;
    DECLARE adultPercentage DECIMAL(5,2);
    DECLARE child7to14Percentage DECIMAL(5,2);
    DECLARE child0to7Percentage DECIMAL(5,2);
    DECLARE totalSalesAmount DECIMAL(10,2);

    -- Общее количество билетов
    SELECT SUM(AvailableTickets) INTO totalTickets FROM Flights;

    -- Количество проданных билетов
    SELECT COUNT(*) INTO soldTickets FROM Sales;

    -- Остаток билетов на конец периода
    SET remainingTickets = totalTickets - soldTickets;

    -- Процентная доля взрослых пассажиров
    SET adultPercentage = (SELECT (COUNT(CASE WHEN AgeCategory = 'Adult' THEN 1 END) / soldTickets) * 100 FROM Sales);

    -- Процентная доля детей с 7 до 14 лет
    SET child7to14Percentage = (SELECT (COUNT(CASE WHEN AgeCategory = 'Child' AND (YEAR(CURDATE()) - YEAR(DATE(SaleDateTime))) BETWEEN 7 AND 14 THEN 1 END) / soldTickets) * 100 FROM Sales);

    -- Процентная доля детей с 0 до 7 лет
    SET child0to7Percentage = (SELECT (COUNT(CASE WHEN AgeCategory = 'Child' AND (YEAR(CURDATE()) - YEAR(DATE(SaleDateTime))) < 7 THEN 1 END) / soldTickets) * 100 FROM Sales);

    -- Общая сумма продаж
    SELECT SUM(Price) INTO totalSalesAmount
    FROM Flights
    JOIN Sales ON Flights.DepartureAirportId = Sales.SaleId;

    -- Вывод результатов
    SELECT totalTickets AS TotalTickets, soldTickets AS SoldTickets, remainingTickets AS RemainingTickets,
           adultPercentage AS AdultPercentage, child7to14Percentage AS Child7to14Percentage, child0to7Percentage AS Child0to7Percentage,
           totalSalesAmount AS TotalSalesAmount;
           
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `GetFlightsWithDurationGreaterThan3Hours` ()   BEGIN
    SELECT FlightNumber, 
           (SELECT Name FROM Airports WHERE Id = DepartureAirportId) AS DepartureAirport,
           (SELECT Name FROM Airports WHERE Id = ArrivalAirportId) AS ArrivalAirport,
           TIMESTAMPDIFF(HOUR, DepartureDateTime, ArrivalDateTime) AS FlightDurationInHours
    FROM Flights
    HAVING FlightDurationInHours > 3;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `Airports`
--

CREATE TABLE `Airports` (
  `Id` int NOT NULL,
  `Name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `City` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Airports`
--

INSERT INTO `Airports` (`Id`, `Name`, `City`) VALUES
(1, 'Airport A', 'City A'),
(2, 'Airport B', 'City B'),
(3, 'Airport C', 'City C');

-- --------------------------------------------------------

--
-- Структура таблицы `Booking`
--

CREATE TABLE `Booking` (
  `DepartureCountry` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ArrivalCountry` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `TotalTickets` int DEFAULT NULL,
  `ChildTickets7` int DEFAULT NULL,
  `ChildTickets14` int DEFAULT NULL,
  `TotalPrice` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Booking`
--

INSERT INTO `Booking` (`DepartureCountry`, `ArrivalCountry`, `TotalTickets`, `ChildTickets7`, `ChildTickets14`, `TotalPrice`) VALUES
('City A', 'City B', 5, 1, 2, '200.00'),
('City B', 'City C', 3, 0, 1, '300.00'),
('City A', 'City B', 5, 1, 2, '200.00'),
('City B', 'City C', 3, 0, 1, '300.00'),
('City A', 'City B', 5, 1, 2, '200.00'),
('City B', 'City C', 3, 0, 1, '300.00');

-- --------------------------------------------------------

--
-- Структура таблицы `Flights`
--

CREATE TABLE `Flights` (
  `FlightNumber` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `DepartureAirportId` int DEFAULT NULL,
  `DepartureDateTime` datetime DEFAULT NULL,
  `ArrivalAirportId` int DEFAULT NULL,
  `ArrivalDateTime` datetime DEFAULT NULL,
  `Price` decimal(10,2) DEFAULT NULL,
  `AvailableTickets` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Flights`
--

INSERT INTO `Flights` (`FlightNumber`, `DepartureAirportId`, `DepartureDateTime`, `ArrivalAirportId`, `ArrivalDateTime`, `Price`, `AvailableTickets`) VALUES
('FL123', 1, '2022-09-15 08:00:00', 2, '2022-09-15 11:30:00', '100.00', 100),
('FL456', 2, '2022-09-16 10:00:00', 3, '2022-09-16 14:30:00', '150.00', 80);

-- --------------------------------------------------------

--
-- Структура таблицы `Sales`
--

CREATE TABLE `Sales` (
  `SaleId` int NOT NULL,
  `SaleDateTime` datetime DEFAULT NULL,
  `BuyerName` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `AgeCategory` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CardNumber` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `PaymentSystem` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `Sales`
--

INSERT INTO `Sales` (`SaleId`, `SaleDateTime`, `BuyerName`, `AgeCategory`, `CardNumber`, `PaymentSystem`) VALUES
(1, '2022-09-14 15:00:00', 'Alice', 'Adult', '1234567812345678', 'Visa'),
(2, '2022-09-15 10:30:00', 'Bob', 'Child', '8765432187654321', 'MasterCard');

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `Airports`
--
ALTER TABLE `Airports`
  ADD PRIMARY KEY (`Id`);

--
-- Индексы таблицы `Flights`
--
ALTER TABLE `Flights`
  ADD PRIMARY KEY (`FlightNumber`),
  ADD KEY `DepartureAirportId` (`DepartureAirportId`),
  ADD KEY `ArrivalAirportId` (`ArrivalAirportId`);

--
-- Индексы таблицы `Sales`
--
ALTER TABLE `Sales`
  ADD PRIMARY KEY (`SaleId`);

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `Flights`
--
ALTER TABLE `Flights`
  ADD CONSTRAINT `flights_ibfk_1` FOREIGN KEY (`DepartureAirportId`) REFERENCES `Airports` (`Id`),
  ADD CONSTRAINT `flights_ibfk_2` FOREIGN KEY (`ArrivalAirportId`) REFERENCES `Airports` (`Id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
