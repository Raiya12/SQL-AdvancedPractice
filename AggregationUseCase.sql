use [ AggregationPracticeModule ]

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

