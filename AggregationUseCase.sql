﻿use [ AggregationPracticeModule ]

CREATE TABLE Instructors ( 
    InstructorID INT PRIMARY KEY, 
    FullName VARCHAR(100), 
    Email VARCHAR(100), 
    JoinDate DATE 
); 
CREATE TABLE Categories ( 
    CategoryID INT PRIMARY KEY, 
    CategoryName VARCHAR(50) 
); 
CREATE TABLE Courses ( 
    CourseID INT PRIMARY KEY, 
    Title VARCHAR(100), 
    InstructorID INT, 
    CategoryID INT, 
    Price DECIMAL(6,2), 
    PublishDate DATE, 
    FOREIGN KEY (InstructorID) REFERENCES Instructors(InstructorID), 
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID) 
); 
 
CREATE TABLE Students ( 
    StudentID INT PRIMARY KEY, 
    FullName VARCHAR(100), 
    Email VARCHAR(100), 
    JoinDate DATE 
); 
 
CREATE TABLE Enrollments ( 
    EnrollmentID INT PRIMARY KEY, 
    StudentID INT, 
    CourseID INT, 
    EnrollDate DATE, 
    CompletionPercent INT, 
    Rating INT CHECK (Rating BETWEEN 1 AND 5), 
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID), 
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) 
); 
 
 -- Instructors 
INSERT INTO Instructors VALUES 
(1, 'Sarah Ahmed', 'sarah@learnhub.com', '2023-01-10'), 
(2, 'Mohammed Al-Busaidi', 'mo@learnhub.com', '2023-05-21'); -- Categories 
INSERT INTO Categories VALUES 
(1, 'Web Development'), 
(2, 'Data Science'), 
(3, 'Business'); -- Courses 
INSERT INTO Courses VALUES 
(101, 'HTML & CSS Basics', 1, 1, 29.99, '2023-02-01'), 
(102, 'Python for Data Analysis', 2, 2, 49.99, '2023-03-15'), 
(103, 'Excel for Business', 2, 3, 19.99, '2023-04-10'), 
(104, 'JavaScript Advanced', 1, 1, 39.99, '2023-05-01'); -- Students 
INSERT INTO Students VALUES 
(201, 'Ali Salim', 'ali@student.com', '2023-04-01'), 
(202, 'Layla Nasser', 'layla@student.com', '2023-04-05'), 
(203, 'Ahmed Said', 'ahmed@student.com', '2023-04-10'); -- Enrollments 
INSERT INTO Enrollments VALUES 
(1, 201, 101, '2023-04-10', 100, 5), 
(2, 202, 102, '2023-04-15', 80, 4), 
(3, 203, 101, '2023-04-20', 90, 4), 
(4, 201, 102, '2023-04-22', 50, 3), 
(5, 202, 103, '2023-04-25', 70, 4), 
(6, 203, 104, '2023-04-28', 30, 2), 
(7, 201, 104, '2023-05-01', 60, 3);

--Part 1: Real App Use Cases
--E-learning Platforms (e.g., Udemy or Coursera)
	--Average Rating per Course:
	SELECT CourseID, AVG(Rating) AS AvgRating
	FROM Enrollments
	GROUP BY CourseID;

	--Course Completion Rate:
	SELECT CourseID, AVG(CompletionPercent) AS CompletionRate
	FROM Enrollments
	GROUP BY CourseID;

	--Most Enrolled Courses per Category:
	SELECT c.CategoryID, COUNT(e.EnrollmentID) AS TotalEnrollments
	FROM Enrollments e
	JOIN Courses c ON e.CourseID = c.CourseID
	GROUP BY c.CategoryID;

--Use Case 2: Food Delivery Platforms (e.g., Talabat or Uber Eats)
	--Monthly Earnings per Restaurant:
	--Use SUM(OrderAmount) and GROUP BY RestaurantID, MONTH(OrderDate) (not shown in schema, but similar structure).

	--Average Food Rating:
	--Use AVG(Rating) grouped by FoodItemID or MenuID.

--Use Case 3: E-commerce Platforms (e.g., Amazon)
	--Total Number of Orders per Customer:
	--Count orders in an Orders table grouped by CustomerID.

	--Top-Selling Products per Category:
	--Use SUM(QuantitySold) grouped by ProductID and CategoryID.

--Use Case 4: Video Platforms (e.g., YouTube)
	--Views per Channel:
	--Use SUM(Views) grouped by ChannelID.

	--Most-Watched Videos by Category:
	--MAX(Views) or ORDER BY Views DESC LIMIT 1 within each category.

--Use Case 5: Admin Dashboards:
SELECT c.InstructorID, COUNT(e.EnrollmentID) AS TotalEnrollments
FROM Enrollments e
JOIN Courses c ON e.CourseID = c.CourseID
GROUP BY c.InstructorID
ORDER BY TotalEnrollments DESC;

--Part 2: Different Uses of Aggregation 
--1. Difference Between GROUP BY and ORDER BY:
	--GROUP BY:
	--Used to aggregate rows into groups based on one or more columns.
	--Typically used with aggregate functions like COUNT(), SUM(), AVG(), etc.
	--Example: Get total sales per category.

	--ORDER BY:
	--Used to sort the result set by one or more columns or expressions.
	--Doesn’t affect grouping — only the display order.

--2. Why Use HAVING Instead of WHERE with Aggregates?
	--WHERE filters rows before aggregation.
	--HAVING filters groups after aggregation has occurred.
	--Example:
	-- Incorrect (will throw error if AVG used in WHERE):
	SELECT CategoryID, AVG(Price)
	FROM Courses
	WHERE AVG(Price) > 50  -- ❌ Invalid

	-- Correct:
	SELECT CategoryID, AVG(Price)
	FROM Courses
	GROUP BY CategoryID
	HAVING AVG(Price) > 50;  -- ✅ Valid

--3. Common Mistakes with Aggregation Queries
	--Using aggregate functions in WHERE clause.
	--Not including all non-aggregated columns in GROUP BY.
	--Assuming COUNT(*) counts non-null values only (it counts all rows).
	--Using COUNT(DISTINCT col) incorrectly, especially in multi-column contexts.
	--Forgetting to alias aggregates (AS TotalRevenue) for readability.
	--Overusing GROUP BY when not needed (e.g. with only one result row).

--4. When to Use COUNT(DISTINCT ...), AVG(...), SUM(...) Together
	--E-commerce Example:
	SELECT 
	  CustomerID,
	  COUNT(DISTINCT OrderID) AS TotalOrders,
	  SUM(TotalAmount) AS TotalSpent,
	  AVG(TotalAmount) AS AverageOrderValue
	FROM Orders
	GROUP BY CustomerID;

	--Learning Platforms:
	SELECT 
	  CourseID,
	  COUNT(DISTINCT StudentID) AS UniqueEnrollees,
	  AVG(CompletionPercent) AS AvgCompletion,
	  SUM(CASE WHEN CompletionPercent = 100 THEN 1 ELSE 0 END) AS Completions
	FROM Enrollments
	GROUP BY CourseID;

--5. Performance Impact of GROUP BY and Index Optimization
	--GROUP BY can be resource-intensive, especially on large datasets.
	--Without indexes, the database must scan the entire table, which slows down performance.
	--How Indexes Help:
	--Indexes on GROUP BY columns can speed up grouping.
	--Composite indexes (e.g. (CategoryID, CourseID)) are useful when grouping by multiple columns.
	--Indexes also improve HAVING, ORDER BY, and join operations.
	--Tips:
	--Use covering indexes (indexes that include all columns used in the query).
	--Avoid grouping on columns with high cardinality (like unique IDs) if possible.
	--Use materialized views or pre-aggregated tables for frequently grouped reports.

----------------------------Beginner Level ----------------------------

--1. Count total number of students. 
SELECT COUNT(*) AS TotalStudents FROM Students;

--2. Count total number of enrollments. 
SELECT COUNT(*) AS TotalEnrollments FROM Enrollments;

--3. Find average rating of each course. 
SELECT CourseID, AVG(Rating) AS AverageRating FROM Enrollments GROUP BY CourseID;

--4. Total number of courses per instructor. 
SELECT InstructorID, COUNT(*) AS TotalCourses FROM Courses GROUP BY InstructorID;

--5. Number of courses in each category. 
SELECT CategoryID, COUNT(*) AS CourseCount FROM Courses GROUP BY CategoryID;

--6. Number of students enrolled in each course. 
SELECT CourseID, COUNT(StudentID) AS StudentCount FROM Enrollments GROUP BY CourseID;

--7. Average course price per category. 
SELECT CategoryID, AVG(Price) AS AveragePrice FROM Courses GROUP BY CategoryID;

--8. Maximum course price. 
SELECT MAX(Price) AS MaxCoursePrice FROM Courses;

--9. Min, Max, and Avg rating per course. 
SELECT CourseID, 
       MIN(Rating) AS MinRating, 
       MAX(Rating) AS MaxRating, 
       AVG(Rating) AS AvgRating
FROM Enrollments GROUP BY CourseID;

--10. Count how many students gave rating = 5. 
SELECT COUNT(*) AS FiveStarRatings FROM Enrollments WHERE Rating = 5;

----------------------------Intermediate Level ----------------------------

--1. Average completion per course. 
SELECT CourseID, AVG(CompletionPercent) AS AvgCompletion FROM Enrollments GROUP BY CourseID;

--2. Students enrolled in more than 1 course. 
SELECT StudentID, COUNT(*) AS CourseCount FROM Enrollments GROUP BY StudentID HAVING COUNT(*) > 1;

--3. Revenue per course. 
SELECT e.CourseID, SUM(c.Price) AS TotalRevenue FROM Enrollments e JOIN Courses c ON e.CourseID = c.CourseID GROUP BY e.CourseID;

--4. Instructor name + distinct students. 
SELECT i.FullName AS InstructorName, COUNT(DISTINCT e.StudentID) AS UniqueStudents
FROM Instructors i
JOIN Courses c ON i.InstructorID = c.InstructorID
JOIN Enrollments e ON c.CourseID = e.CourseID
GROUP BY i.FullName;

--5. Average enrollments per category. 
SELECT CategoryID, AVG(EnrollCount * 1.0) AS AvgEnrollments
FROM (
    SELECT CategoryID, COUNT(e.EnrollmentID) AS EnrollCount
    FROM Courses
    JOIN Enrollments e ON Courses.CourseID = e.CourseID
    GROUP BY Courses.CourseID, CategoryID
) AS sub
GROUP BY CategoryID;

--6. Average course rating by instructor. 
SELECT i.FullName AS InstructorName, AVG(e.Rating) AS AvgRating
FROM Instructors i
JOIN Courses c ON i.InstructorID = c.InstructorID
JOIN Enrollments e ON c.CourseID = e.CourseID
GROUP BY i.FullName;

--7. Top 3 courses by enrollments. 
SELECT TOP 3 CourseID, COUNT(*) AS EnrollmentCount
FROM Enrollments
GROUP BY CourseID
ORDER BY EnrollmentCount DESC;

--8. Average days to complete 100% (mock logic). 
SELECT CourseID, AVG(DATEDIFF(DAY, EnrollDate, GETDATE())) AS AvgDaysToComplete
FROM Enrollments
WHERE CompletionPercent = 100
GROUP BY CourseID;

--9. % students who completed each course. 
SELECT CourseID,
       COUNT(CASE WHEN CompletionPercent = 100 THEN 1 END) * 100.0 / COUNT(*) AS CompletionRate
FROM Enrollments
GROUP BY CourseID;

--10. Courses published per year.
SELECT YEAR(PublishDate) AS Year, COUNT(*) AS CoursesPublished
FROM Courses
GROUP BY YEAR(PublishDate)
ORDER BY Year;

----------------------------Advanced Level ----------------------------
  
--1. Student with most completed courses. 
SELECT TOP 1 StudentID, COUNT(*) AS CompletedCourses
FROM Enrollments
WHERE CompletionPercent = 100
GROUP BY StudentID
ORDER BY CompletedCourses DESC;

--2. Instructor earnings from enrollments. 
SELECT i.InstructorID, i.FullName, SUM(c.Price) AS TotalEarnings
FROM Instructors i
JOIN Courses c ON i.InstructorID = c.InstructorID
JOIN Enrollments e ON c.CourseID = e.CourseID
GROUP BY i.InstructorID, i.FullName;

--3. Category avg rating (≥ 4). 
SELECT c.CategoryID, AVG(e.Rating) AS AvgRating
FROM Enrollments e
JOIN Courses c ON e.CourseID = c.CourseID
GROUP BY c.CategoryID
HAVING AVG(e.Rating) >= 4;

--4. Students rated below 3 more than once. 
SELECT StudentID, COUNT(*) AS LowRatings
FROM Enrollments
WHERE Rating < 3
GROUP BY StudentID
HAVING COUNT(*) > 1;

--5. Course with lowest average completion. 
SELECT TOP 1 CourseID, AVG(CompletionPercent) AS AvgCompletion
FROM Enrollments
GROUP BY CourseID
ORDER BY AvgCompletion ASC;

--6. Students enrolled in all courses by instructor 1.
-- Step 1: Total number of courses by Instructor 1
WITH InstructorCourses AS (
    SELECT CourseID
    FROM Courses
    WHERE InstructorID = 1
),
StudentCourseCounts AS (
    SELECT e.StudentID, COUNT(DISTINCT e.CourseID) AS EnrolledInCourses
    FROM Enrollments e
    JOIN InstructorCourses ic ON e.CourseID = ic.CourseID
    GROUP BY e.StudentID
),
CourseTotal AS (
    SELECT COUNT(*) AS TotalCourses FROM InstructorCourses
)
SELECT s.StudentID
FROM StudentCourseCounts s, CourseTotal ct
WHERE s.EnrolledInCourses = ct.TotalCourses;

--7. Duplicate ratings check. 
SELECT StudentID, CourseID, COUNT(*) AS RatingCount
FROM Enrollments
GROUP BY StudentID, CourseID
HAVING COUNT(*) > 1;

--8. Category with highest avg rating.
SELECT TOP 1 c.CategoryID, AVG(e.Rating) AS AvgRating
FROM Enrollments e
JOIN Courses c ON e.CourseID = c.CourseID
GROUP BY c.CategoryID
ORDER BY AvgRating DESC;
