use [Training&JobApplicationSystem ]

-- Trainees Table 
CREATE TABLE Trainees ( 
TraineeID INT PRIMARY KEY, 
FullName VARCHAR(100), 
Email VARCHAR(100), 
Program VARCHAR(50), 
GraduationDate DATE 
); 
-- Job Applicants Table 
CREATE TABLE Applicants ( 
ApplicantID INT PRIMARY KEY, 
FullName VARCHAR(100), 
Email VARCHAR(100), 
Source VARCHAR(20), -- e.g., "Website", "Referral" 
AppliedDate DATE 
); 
--Sample Data -- Insert into Trainees 
INSERT INTO Trainees VALUES 
(1, 'Layla Al Riyami', 'layla.r@example.com', 'Full Stack .NET', '2025-04-30'), 
(2, 'Salim Al Hinai', 'salim.h@example.com', 'Outsystems', '2025-03-15'), 
(3, 'Fatma Al Amri', 'fatma.a@example.com', 'Database Admin', '2025-05-01'); -- Insert into Applicants 

INSERT INTO Applicants VALUES 
(101, 'Hassan Al Lawati', 'hassan.l@example.com', 'Website', '2025-05-02'), 
(102, 'Layla Al Riyami', 'layla.r@example.com', 'Referral', '2025-05-05'), -- same person as trainee 
(103, 'Aisha Al Farsi', 'aisha.f@example.com', 'Website', '2025-04-28');

--1. List all unique people who either trained or applied for a job. 
	--o Show their full names and emails. 
	--o Use UNION (not UNION ALL) to avoid duplicates. 
SELECT FullName, Email FROM Trainees UNION SELECT FullName, Email FROM Applicants;

--2. Now use UNION ALL. What changes in the result? 
	--o Explain why one name appears twice. 
SELECT FullName, Email FROM Trainees UNION ALL SELECT FullName, Email FROM Applicants;

--3. Find people who are in both tables. 
	--o You must use INTERSECT if supported, or simulate it using INNER JOIN on Email. 
SELECT FullName, Email FROM Trainees INTERSECT SELECT FullName, Email FROM Applicants;

--4. Try DELETE FROM Trainees WHERE Program = 'Outsystems'. 
	--o Check if the table structure still exists. 
DELETE FROM Trainees WHERE Program = 'Outsystems';

--5. Try TRUNCATE TABLE Applicants. 
	--o What happens to the data? Can you roll it back? 
TRUNCATE TABLE Applicants;

--6. Try DROP TABLE Applicants. 
	--o What happens if you run a SELECT after that?
Drop TABLE Applicants;

--What is a SQL Transaction?
--A SQL transaction is a sequence of one or more SQL statements executed as a single unit of work. The key idea is that either all statements succeed, or none of them are applied.

--Task :Rollback
BEGIN TRANSACTION;

INSERT INTO Applicants VALUES (104, 'Majid Al Raisi', 'majid.r@example.com', 'Referral', '2025-05-26');
INSERT INTO Applicants VALUES (104, 'Duplicate Applicant', 'duplicate@example.com', 'Website', '2025-05-26');

-- Manually ROLLBACK after seeing the error
ROLLBACK;


BEGIN TRANSACTION;
--6. Add logic:

BEGIN TRY
    INSERT INTO Applicants VALUES 
        (104, 'Zahra Al Amri', 'zahra.a@example.com', 'Referral', '2025-05-10'),
        (104, 'Error User', 'error@example.com', 'Website', '2025-05-11'); -- Duplicate ID
    COMMIT; -- Only commits if no error occurs
END TRY
BEGIN CATCH
    ROLLBACK; -- Reverts all changes if a duplicate or any other error occurs
    PRINT 'Transaction failed. Rolled back due to error: ' + ERROR_MESSAGE();
END CATCH;