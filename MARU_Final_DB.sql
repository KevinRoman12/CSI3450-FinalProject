-- phpMyAdmin SQL Dump
-- version 5.1.1deb5ubuntu1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Aug 17, 2026 at 05:56 PM
-- Server version: 8.0.46-0ubuntu0.22.04.3
-- PHP Version: 8.2.32

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `MARU_Final_DB`
--

-- --------------------------------------------------------

--
-- Table structure for table `Attendance`
--

CREATE TABLE `Attendance` (
  `attendance_id` int NOT NULL,
  `student_id` int NOT NULL,
  `class_meeting_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Class`
--

CREATE TABLE `Class` (
  `class_id` int NOT NULL,
  `instructor_student_id` int NOT NULL,
  `skill_level` varchar(30) NOT NULL,
  `day_of_week` varchar(15) NOT NULL,
  `start_time` time NOT NULL,
  `room` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Class_Meeting`
--

CREATE TABLE `Class_Meeting` (
  `class_meeting_id` int NOT NULL,
  `class_id` int NOT NULL,
  `meeting_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Class_Meeting_Instructor`
--

CREATE TABLE `Class_Meeting_Instructor` (
  `meeting_instructor_id` int NOT NULL,
  `class_meeting_id` int NOT NULL,
  `instructor_student_id` int NOT NULL,
  `role` varchar(20) NOT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `Instructor`
--

CREATE TABLE `Instructor` (
  `instructor_student_id` int NOT NULL,
  `instructor_start_date` date NOT NULL,
  `instructor_status` varchar(20) NOT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `Rank`
--

CREATE TABLE `Rank` (
  `rank_id` int NOT NULL,
  `rank_name` varchar(50) NOT NULL,
  `belt_color` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Rank_Requirement`
--

CREATE TABLE `Rank_Requirement` (
  `requirement_id` int NOT NULL,
  `rank_id` int NOT NULL,
  `requirement_description` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Student`
--

CREATE TABLE `Student` (
  `student_id` int NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `date_of_birth` date NOT NULL,
  `join_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Student_Rank`
--

CREATE TABLE `Student_Rank` (
  `student_rank_id` int NOT NULL,
  `student_id` int NOT NULL,
  `rank_id` int NOT NULL,
  `date_awarded` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Attendance`
--
ALTER TABLE `Attendance`
  ADD PRIMARY KEY (`attendance_id`),
  ADD UNIQUE KEY `uq_student_meeting` (`student_id`,`class_meeting_id`),
  ADD KEY `fk_attendance_meeting` (`class_meeting_id`);

--
-- Indexes for table `Class`
--
ALTER TABLE `Class`
  ADD PRIMARY KEY (`class_id`),
  ADD KEY `fk_class_instructor` (`instructor_student_id`);

--
-- Indexes for table `Class_Meeting`
--
ALTER TABLE `Class_Meeting`
  ADD PRIMARY KEY (`class_meeting_id`),
  ADD KEY `fk_meeting_class` (`class_id`);

--
-- Indexes for table `Class_Meeting_Instructor`
--
ALTER TABLE `Class_Meeting_Instructor`
  ADD PRIMARY KEY (`meeting_instructor_id`),
  ADD UNIQUE KEY `uq_instructor_meeting` (`class_meeting_id`,`instructor_student_id`),
  ADD KEY `fk_cmi_instructor` (`instructor_student_id`);

--
-- Indexes for table `Instructor`
--
ALTER TABLE `Instructor`
  ADD PRIMARY KEY (`instructor_student_id`);

--
-- Indexes for table `Rank`
--
ALTER TABLE `Rank`
  ADD PRIMARY KEY (`rank_id`),
  ADD UNIQUE KEY `rank_name` (`rank_name`);

--
-- Indexes for table `Rank_Requirement`
--
ALTER TABLE `Rank_Requirement`
  ADD PRIMARY KEY (`requirement_id`),
  ADD KEY `fk_requirement_rank` (`rank_id`);

--
-- Indexes for table `Student`
--
ALTER TABLE `Student`
  ADD PRIMARY KEY (`student_id`);

--
-- Indexes for table `Student_Rank`
--
ALTER TABLE `Student_Rank`
  ADD PRIMARY KEY (`student_rank_id`),
  ADD KEY `fk_studentrank_student` (`student_id`),
  ADD KEY `fk_studentrank_rank` (`rank_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Attendance`
--
ALTER TABLE `Attendance`
  MODIFY `attendance_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Class`
--
ALTER TABLE `Class`
  MODIFY `class_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Class_Meeting`
--
ALTER TABLE `Class_Meeting`
  MODIFY `class_meeting_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Class_Meeting_Instructor`
--
ALTER TABLE `Class_Meeting_Instructor`
  MODIFY `meeting_instructor_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Rank`
--
ALTER TABLE `Rank`
  MODIFY `rank_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Rank_Requirement`
--
ALTER TABLE `Rank_Requirement`
  MODIFY `requirement_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Student`
--
ALTER TABLE `Student`
  MODIFY `student_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Student_Rank`
--
ALTER TABLE `Student_Rank`
  MODIFY `student_rank_id` int NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Attendance`
--
ALTER TABLE `Attendance`
  ADD CONSTRAINT `fk_attendance_meeting` FOREIGN KEY (`class_meeting_id`) REFERENCES `Class_Meeting` (`class_meeting_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_attendance_student` FOREIGN KEY (`student_id`) REFERENCES `Student` (`student_id`) ON DELETE CASCADE;

--
-- Constraints for table `Class`
--
ALTER TABLE `Class`
  ADD CONSTRAINT `fk_class_instructor` FOREIGN KEY (`instructor_student_id`) REFERENCES `Instructor` (`instructor_student_id`);

--
-- Constraints for table `Class_Meeting`
--
ALTER TABLE `Class_Meeting`
  ADD CONSTRAINT `fk_meeting_class` FOREIGN KEY (`class_id`) REFERENCES `Class` (`class_id`) ON DELETE CASCADE;

--
-- Constraints for table `Class_Meeting_Instructor`
--
ALTER TABLE `Class_Meeting_Instructor`
  ADD CONSTRAINT `fk_cmi_instructor` FOREIGN KEY (`instructor_student_id`) REFERENCES `Instructor` (`instructor_student_id`),
  ADD CONSTRAINT `fk_cmi_meeting` FOREIGN KEY (`class_meeting_id`) REFERENCES `Class_Meeting` (`class_meeting_id`) ON DELETE CASCADE;

--
-- Constraints for table `Instructor`
--
ALTER TABLE `Instructor`
  ADD CONSTRAINT `fk_instructor_student` FOREIGN KEY (`instructor_student_id`) REFERENCES `Student` (`student_id`) ON DELETE CASCADE;

--
-- Constraints for table `Rank_Requirement`
--
ALTER TABLE `Rank_Requirement`
  ADD CONSTRAINT `fk_requirement_rank` FOREIGN KEY (`rank_id`) REFERENCES `Rank` (`rank_id`) ON DELETE CASCADE;

--
-- Constraints for table `Student_Rank`
--
ALTER TABLE `Student_Rank`
  ADD CONSTRAINT `fk_studentrank_rank` FOREIGN KEY (`rank_id`) REFERENCES `Rank` (`rank_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_studentrank_student` FOREIGN KEY (`student_id`) REFERENCES `Student` (`student_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
