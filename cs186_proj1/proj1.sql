-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT nameFirst, nameLast, birthYear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT nameFirst, nameLast, birthYear
  FROM people
  WHERE nameFirst LIKE "% %"
  ORDER BY namefirst
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthYear, avg(height), count(*)
  FROM people 
  GROUP BY birthYear
  ORDER BY birthYear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthYear, avg(height), count(*)
  FROM people 
  GROUP BY birthYear
  HAVING avg(height) > 70
  ORDER BY birthYear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT p.nameFirst, p.nameLast, h.playerID, h.yearid
  FROM people p JOIN 
  	   halloffame h ON p.playerID = h.playerID
  WHERE h.inducted = "Y"
  ORDER BY h.yearid DESC, h.playerid
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT p.nameFirst, p.nameLast, h.playerID, s.schoolID, h.yearid
  FROM people p JOIN 
  	   halloffame h ON p.playerID = h.playerID JOIN 
  	   collegeplaying c ON p.playerID = c.playerid JOIN 
  	   schools s ON s.schoolID = c.schoolID
  WHERE h.inducted = "Y" AND s.schoolState = "CA"
  ORDER BY h.yearid DESC, s.schoolID, h.playerID
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT h.playerID, p.nameFirst, p.nameLast, s.schoolID
  FROM people p JOIN 
  	   halloffame h ON p.playerID = h.playerID LEFT JOIN 
  	   collegeplaying c ON p.playerID = c.playerid LEFT JOIN 
  	   schools s ON c.schoolID = s.schoolID
   WHERE h.inducted = "Y"
   ORDER BY h.playerID DESC, s.schoolID
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerID, p.nameFirst, p.nameLast, b.yearid, ((H + H2B + (2 * H3B) + (3 * HR))/(AB * 1.0)) AS slg
  FROM people p JOIN 
  	   batting b ON p.playerID = b.playerID
  WHERE b.AB > 50
  ORDER BY 5 DESC, 4, 1
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT p.playerID, p.nameFirst, p.nameLast, ((sum(H) + sum(H2B) + (2 * sum(H3B)) + (3 * sum(HR)))/(sum(AB) * 1.0)) AS lslg
  FROM people p JOIN 
  	   batting b ON p.playerID = b.playerID
  GROUP BY b.playerID
  HAVING sum(b.AB > 50)
  ORDER BY 4 DESC, 1
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  WITH ets1 AS 
  	(SELECT p.playerID, p.nameFirst, p.nameLast, ((sum(H) + sum(H2B) + (2 * sum(H3B)) + (3 * sum(HR)))/(sum(AB) * 1.0)) AS lslg
  	FROM people p JOIN 
  	   batting b ON p.playerID = b.playerID
  	GROUP BY b.playerID
  	HAVING sum(b.AB > 50)),
  ets2 AS 
  	(SELECT lslg 
  	FROM ets1
  	WHERE playerID = "mayswi01")
  
  SELECT ets1.nameFirst, ets1.nameLast, ets1.lslg
  FROM ets1, ets2
  WHERE ets1.lslg > ets2.lslg
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearID, min(salary), max(salary), avg(salary)
  FROM salaries
  GROUP BY yearID
  ORDER BY yearID
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH ets1 AS 
  	(SELECT min(salaries.salary) as min, CAST((max(salaries.salary) - min(salaries.salary))/10 AS INT) AS range
        FROM salaries
        WHERE yearid = 2016),
    ets2 AS (
        SELECT binids.binid, ets1.min + binids.binid * ets1.range AS low, ets1.min + (binids.binid + 1) * ets1.range AS high
        FROM ets1, binids)

    SELECT ets2.binid, ets2.low, ets2.high, COUNT(*)
    FROM ets2 LEFT JOIN 
    	 salaries ON ets2.low <= salaries.salary 
    	 		  AND (
    	 		  		(ets2.high > salaries.salary) 
    	 		  		OR (
    	 		  				ets2.high = salaries.salary 
    	 		  				AND ets2.binid = 9
    	 		  			)
    	 		  	)
            	AND yearid = '2016'
        GROUP BY ets2.binid
        ORDER BY ets2.binid ASC
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
   WITH ets1 AS (
      SELECT avg(salary) as avg, min(salary) as min, max(salary) as max, yearid
      FROM salaries
      GROUP BY yearid)
      
   SELECT s1.yearid, s1.min - s2.min, s1.max - s2.max, s1.avg - s2.avg
   FROM ets1 as s1 INNER JOIN ets1 as s2 ON s1.yearid - 1 = s2.yearid
   ORDER BY s1.yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT s.playerid, p.namefirst, p.namelast, s.salary, s.yearid
    FROM salaries s JOIN 
    	 people p ON s.playerid = p.playerid 
    WHERE (
    		   s.yearid = 2000 
    		   AND s.salary = (
			    		   		SELECT MAX(salary)
			                    FROM salaries
			                    WHERE salaries.yearid = 2000) 
               AND s.playerid = p.playerid)
       OR (
       		   s.yearid = 2001 
       		   AND salary = (
       		   					SELECT MAX(salary)
                            	FROM salaries
                            	WHERE salaries.yearid = 2001)
               AND s.playerid = p.playerid)
;

-- Question 4v
CREATE VIEW q4v(team, diffAvg) 
AS
  SELECT a.teamid, MAX(s.salary) - MIN(s.salary) AS diffAvg
    FROM allstarfull a JOIN 
    salaries s ON a.playerid = s.playerid 
    		   AND a.yearid = s.yearid
    WHERE s.yearid = 2016
    GROUP BY a.teamid
;

