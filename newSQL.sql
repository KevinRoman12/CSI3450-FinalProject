-- Disable foreign key checks during teardown and rebuild
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS FINAL_PROJECT_TEST;
USE FINAL_PROJECT_TEST;

-- Drop existing tables in teardown order
DROP TABLE IF EXISTS `Attendance`;
DROP TABLE IF EXISTS `Class_Meeting_Instructor`;
DROP TABLE IF EXISTS `Class_Meeting`;
DROP TABLE IF EXISTS `Class`;
DROP TABLE IF EXISTS `Student_Rank`;
DROP TABLE IF EXISTS `Rank_Requirement`;
DROP TABLE IF EXISTS `Instructor`;
DROP TABLE IF EXISTS `Rank`;
DROP TABLE IF EXISTS `Student`;

SET FOREIGN_KEY_CHECKS = 1;

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- Table Structures

CREATE TABLE `Student` (
  `student_id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `date_of_birth` DATE NOT NULL,
  `join_date` DATE NOT NULL,
  PRIMARY KEY (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Rank` (
  `rank_id` INT NOT NULL AUTO_INCREMENT,
  `rank_name` VARCHAR(50) NOT NULL,
  `belt_color` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`rank_id`),
  UNIQUE KEY `rank_name` (`rank_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Instructor` (
  `instructor_student_id` INT NOT NULL,
  `instructor_start_date` DATE NOT NULL,
  `instructor_status` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`instructor_student_id`),
  CONSTRAINT `fk_instructor_student` FOREIGN KEY (`instructor_student_id`) REFERENCES `Student` (`student_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Class` (
  `class_id` INT NOT NULL AUTO_INCREMENT,
  `instructor_student_id` INT NOT NULL,
  `skill_level` VARCHAR(30) NOT NULL,
  `day_of_week` VARCHAR(15) NOT NULL,
  `start_time` TIME NOT NULL,
  `room` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`class_id`),
  KEY `fk_class_instructor` (`instructor_student_id`),
  CONSTRAINT `fk_class_instructor` FOREIGN KEY (`instructor_student_id`) REFERENCES `Instructor` (`instructor_student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Class_Meeting` (
  `class_meeting_id` INT NOT NULL AUTO_INCREMENT,
  `class_id` INT NOT NULL,
  `meeting_date` DATE NOT NULL,
  PRIMARY KEY (`class_meeting_id`),
  KEY `fk_meeting_class` (`class_id`),
  CONSTRAINT `fk_meeting_class` FOREIGN KEY (`class_id`) REFERENCES `Class` (`class_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Class_Meeting_Instructor` (
  `meeting_instructor_id` INT NOT NULL AUTO_INCREMENT,
  `class_meeting_id` INT NOT NULL,
  `instructor_student_id` INT NOT NULL,
  `role` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`meeting_instructor_id`),
  UNIQUE KEY `uq_instructor_meeting` (`class_meeting_id`, `instructor_student_id`),
  KEY `fk_cmi_instructor` (`instructor_student_id`),
  CONSTRAINT `fk_cmi_instructor` FOREIGN KEY (`instructor_student_id`) REFERENCES `Instructor` (`instructor_student_id`),
  CONSTRAINT `fk_cmi_meeting` FOREIGN KEY (`class_meeting_id`) REFERENCES `Class_Meeting` (`class_meeting_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Attendance` (
  `attendance_id` INT NOT NULL AUTO_INCREMENT,
  `student_id` INT NOT NULL,
  `class_meeting_id` INT NOT NULL,
  PRIMARY KEY (`attendance_id`),
  UNIQUE KEY `uq_student_meeting` (`student_id`, `class_meeting_id`),
  KEY `fk_attendance_meeting` (`class_meeting_id`),
  CONSTRAINT `fk_attendance_meeting` FOREIGN KEY (`class_meeting_id`) REFERENCES `Class_Meeting` (`class_meeting_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_attendance_student` FOREIGN KEY (`student_id`) REFERENCES `Student` (`student_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Rank_Requirement` (
  `requirement_id` INT NOT NULL AUTO_INCREMENT,
  `rank_id` INT NOT NULL,
  `requirement_description` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`requirement_id`),
  KEY `fk_requirement_rank` (`rank_id`),
  CONSTRAINT `fk_requirement_rank` FOREIGN KEY (`rank_id`) REFERENCES `Rank` (`rank_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Student_Rank` (
  `student_rank_id` INT NOT NULL AUTO_INCREMENT,
  `student_id` INT NOT NULL,
  `rank_id` INT NOT NULL,
  `date_awarded` DATE NOT NULL,
  PRIMARY KEY (`student_rank_id`),
  KEY `fk_studentrank_student` (`student_id`),
  KEY `fk_studentrank_rank` (`rank_id`),
  CONSTRAINT `fk_studentrank_rank` FOREIGN KEY (`rank_id`) REFERENCES `Rank` (`rank_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_studentrank_student` FOREIGN KEY (`student_id`) REFERENCES `Student` (`student_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Track canceled classes and reasons
CREATE TABLE IF NOT EXISTS canceled_classes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL,
  class_name TEXT NOT NULL,
  canceled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  reason TEXT
);

-- Student notification queue for popups upon login
CREATE TABLE IF NOT EXISTS student_cancellation_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL,
  class_name TEXT NOT NULL,
  reason TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed Initial Data

-- Insert Ranks
INSERT INTO `Rank` (`rank_id`, `rank_name`, `belt_color`) VALUES
(1, 'White Belt', 'White'),
(2, 'Yellow Belt', 'Yellow'),
(3, 'Orange Belt', 'Orange'),
(4, 'Green Belt', 'Green'),
(5, 'Blue Belt', 'Blue'),
(6, 'Purple Belt', 'Purple'),
(7, 'Brown Belt', 'Brown'),
(8, 'Red Belt', 'Red'),
(9, 'Black Belt', 'Black');

-- Insert Initial Students
INSERT INTO `Student` (`student_id`, `first_name`, `last_name`, `date_of_birth`, `join_date`) VALUES
(1, 'Master', 'Sensei', '1980-01-01', '2015-01-01'),
(2, 'John', 'Doe', '2000-05-15', '2023-02-10'),
(3, 'Jane', 'Smith', '1998-08-22', '2023-03-01');

-- Promote Master Sensei to Instructor
INSERT INTO `Instructor` (`instructor_student_id`, `instructor_start_date`, `instructor_status`) VALUES
(1, '2015-01-01', 'Active');

-- Assign Ranks to Students
INSERT INTO `Student_Rank` (`student_rank_id`, `student_id`, `rank_id`, `date_awarded`) VALUES
(1, 1, 9, '2015-01-01'),
(2, 2, 1, '2023-02-10'),
(3, 3, 2, '2023-03-01');

-- Create Initial Base Class
INSERT INTO `Class` (`class_id`, `instructor_student_id`, `skill_level`, `day_of_week`, `start_time`, `room`) VALUES
(1, 1, 'Beginner Martial Arts', 'Monday', '17:00:00', 'Room #1');

-- Create Class Meeting
INSERT INTO `Class_Meeting` (`class_meeting_id`, `class_id`, `meeting_date`) VALUES
(1, 1, CURRENT_DATE());

-- Assign Meeting Instructor
INSERT INTO `Class_Meeting_Instructor` (`meeting_instructor_id`, `class_meeting_id`, `instructor_student_id`, `role`) VALUES
(1, 1, 1, 'Head Instructor');

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;