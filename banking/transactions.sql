-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.4.10-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping data for table essentialmode.transaction_history: ~33 rows (approximately)
/*!40000 ALTER TABLE `transaction_history` DISABLE KEYS */;
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(1, 'steam:11000010f170a89', 'personal', -242000, 'transfer', '5', '1', '', '2021-11-21 15:17:53');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(2, 'steam:11000010f170a89', 'organisation', 242000, 'transfer', '5', '1', '', '2021-11-21 15:17:53');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(3, 'steam:11000010f170a89', 'personal', -20000, 'transfer', '5', '3', '', '2021-11-21 15:41:47');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(4, 'steam:11000010f170a89', 'business', 20000, 'transfer', '5', '3', '', '2021-11-21 15:41:47');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(5, 'steam:11000010f170a89', 'business', -24819000, 'transfer', '4', '3', 'Loan Return', '2021-11-21 18:01:12');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(6, 'steam:11000010f170a89', 'business', 24819000, 'transfer', '4', '3', 'Loan Return', '2021-11-21 18:01:12');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(7, 'steam:11000010f170a89', 'business', -221000, 'transfer', '4', '1', 'Donation', '2021-11-21 18:13:25');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(8, 'steam:11000010f170a89', 'organisation', 221000, 'transfer', '4', '1', 'Donation', '2021-11-21 18:13:25');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(9, 'steam:11000010f170a89', 'personal', -1000, 'withdraw', '5', NULL, 'Withdrew $1,000 cash.', '2021-11-23 20:33:13');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(195, 'steam:11000010f170a89', 'personal', 100000, 'transfer', '5', '6', '', '2021-11-27 16:44:59');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(196, 'steam:11000010f170a89', 'personal', -100000, 'transfer', '5', '6', '', '2021-11-27 16:44:59');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(197, 'steam:11000010f170a89', 'personal', -1000, 'transfer', '5', '5', '', '2021-11-27 17:51:01');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(198, 'steam:11000010f170a89', 'personal', 1000, 'transfer', '5', '5', '', '2021-11-27 17:51:01');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(199, 'steam:11000010f170a89', 'personal', -1000, 'transfer', '5', '3', '', '2021-11-27 17:51:35');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(200, 'steam:11000010f170a89', 'business', 1000, 'transfer', '5', '3', '', '2021-11-27 17:51:35');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(201, 'steam:11000010f170a89', 'personal', -1000, 'transfer', '5', '3', '', '2021-11-27 17:55:34');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(202, 'steam:11000010f170a89', 'business', 1000, 'transfer', '5', '3', '', '2021-11-27 17:55:34');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(203, 'steam:11000010f170a89', 'personal', -100, 'transfer', '5', '5', '', '2021-11-27 17:57:02');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(204, 'steam:11000010f170a89', 'personal', 100, 'transfer', '5', '5', '', '2021-11-27 17:57:02');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(205, 'steam:11000010f170a89', 'personal', -100, 'transfer', '5', '1', '', '2021-11-27 17:57:30');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(206, 'steam:11000010f170a89', 'organisation', 100, 'transfer', '5', '1', '', '2021-11-27 17:57:30');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(207, 'steam:11000010f170a89', 'personal', -1000, 'transfer', '5', '4', '', '2021-11-27 18:05:25');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(208, 'steam:11000010f170a89', 'business', 1000, 'transfer', '5', '4', '', '2021-11-27 18:05:25');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(209, 'steam:11000010f170a89', 'personal', -100, 'transfer', '5', '5', '', '2021-11-27 18:59:22');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(210, 'steam:11000010f170a89', 'personal', 100, 'transfer', '5', '5', '', '2021-11-27 18:59:22');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(211, 'steam:11000010f170a89', 'personal', 100, 'deposit', NULL, '5', '', '2021-11-27 19:05:39');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(212, 'steam:11000010f170a89', 'personal', 500, 'deposit', NULL, '5', '', '2021-11-27 19:05:48');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(213, 'steam:11000010f170a89', 'personal', -1000000, 'transfer', '5', '3', '', '2021-11-27 19:09:48');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(214, 'steam:11000010f170a89', 'business', 1000000, 'transfer', '5', '3', '', '2021-11-27 19:09:48');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(215, 'steam:11000010f170a89', 'personal', -1200000, 'transfer', '5', '3', '', '2021-11-27 19:13:44');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(216, 'steam:11000010f170a89', 'business', 1200000, 'transfer', '5', '3', '', '2021-11-27 19:13:44');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(221, 'steam:11000010f170a89', 'business', -54800, 'transfer', '3', '5', '', '2021-11-28 13:05:54');
INSERT INTO `transaction_history` (`id`, `identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`, `date`) VALUES
	(222, 'steam:11000010f170a89', 'personal', 54800, 'transfer', '3', '5', '', '2021-11-28 13:05:54');
/*!40000 ALTER TABLE `transaction_history` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
