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
  SELECT namefirst, namelast , birthyear FROM people WHERE weight > 300 -- replace this line
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear FROM people WHERE namefirst LIKE '% %' ORDER BY namefirst ASC, namelast ASC
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) as avgheight, COUNT(*) as count FROM people GROUP BY birthyear ORDER BY birthyear ASC
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
SELECT birthyear, AVG(height) as avgheight, COUNT(*) as count FROM people GROUP BY birthyear HAVING avgheight > 70 ORDER BY birthyear ASC
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT p.namefirst, p.namelast, h.playerid, h.yearid
  FROM people as p INNER JOIN halloffame as h ON p.playerid = h.playerid
  WHERE h.inducted = 'Y'
  ORDER BY h.yearid DESC, h.playerid ASC
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
    SELECT p.namefirst, p.namelast, p.playerid, s.schoolid, h.yearid
    FROM (people as p INNER JOIN halloffame as h on p.playerid = h.playerid) INNER JOIN (schools as s INNER JOIN collegeplaying as c ON s.schoolid = c.schoolid)
    ON p.playerid = c.playerid
    WHERE h.inducted = 'Y' AND s.schoolstate = 'CA'
    ORDER BY h.yearid DESC, s.schoolid ASC, p.playerid ASC
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT p.playerid, p.namefirst, p.namelast, c.schoolid
    FROM (people as p INNER JOIN halloffame as h on p.playerid = h.playerid) LEFT OUTER JOIN collegeplaying as c ON p.playerid = c.playerid
    WHERE h.inducted = 'Y'
    ORDER BY p.playerid DESC, c.schoolid ASC
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerid, p.namefirst, p.namelast, b.yearid, (b.H + b.H2B + 2 * b.H3B + 3 * b.HR) / cast(b.AB as float) as slg
      FROM people as p INNER JOIN batting as b ON p.playerid = b.playerid
        WHERE b.AB > 50
        ORDER BY slg DESC, b.yearid, p.playerid ASC
        limit 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
    SELECT p.playerid, p.namefirst, p.namelast, SUM(b.H + b.H2B + 2 * b.H3B + 3 * b.HR) / cast(SUM(b.AB) as float) as lslg
    FROM people as p INNER JOIN batting as b ON p.playerid = b.playerid
    GROUP BY p.playerid
    HAVING SUM(b.AB > 50)
    ORDER BY lslg DESC, p.playerid ASC
    limit 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
    WITH LSLG AS (SELECT p.playerid, p.namefirst, p.namelast, SUM(b.H + b.H2B + 2 * b.H3B + 3 * b.HR) / cast(SUM(b.AB) as float) as lslg
        FROM people as p INNER JOIN batting as b ON p.playerid = b.playerid
        GROUP BY p.playerid
        HAVING SUM(b.AB > 50)),
    MAY AS (SELECT LSLG.lslg FROM LSLG WHERE LSLG.playerid = 'mayswi01')

    SELECT LSLG.namefirst, LSLG.namelast, LSLG.lslg FROM LSLG, MAY WHERE LSLG.lslg > MAY.lslg
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
    SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
    FROM salaries
    GROUP BY yearid
    ORDER BY yearid ASC
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH R AS (
    SELECT MIN(salaries.salary) as min, CAST((MAX(salaries.salary) - MIN(salaries.salary))/10 AS INT) AS range
        FROM salaries
        WHERE yearid = '2016'),
    BIN AS (
        SELECT binids.binid, R.min + binids.binid * R.range AS low, R.min + (binids.binid + 1) * R.range AS high
        FROM R, binids)

    SELECT BIN.binid, BIN.low, BIN.high, COUNT(*)
    FROM BIN LEFT JOIN salaries
        ON BIN.low <= salaries.salary AND ((BIN.high > salaries.salary) OR (BIN.high = salaries.salary AND BIN.binid = 9))
            AND yearid = '2016'
        GROUP BY BIN.binid
        ORDER BY BIN.binid ASC
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  WITH S AS (
      SELECT AVG(salary) as avg, MIN(salary) as min, MAX(salary) as max, yearid
      FROM salaries
      GROUP BY yearid
  )
      SELECT s1.yearid, s1.min - s2.min, s1.max - s2.max, s1.avg - s2.avg
      FROM S as s1 INNER JOIN S as s2 ON s1.yearid - 1 = s2.yearid
      ORDER BY s1.yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
    SELECT s.playerid, p.namefirst, p.namelast, s.salary, s.yearid
    FROM salaries as s INNER JOIN people as p
    WHERE (s.yearid = 2000 AND s.salary = (SELECT MAX(salary)
                                           FROM salaries
                                           WHERE salaries.yearid = 2000) AND s.playerid = p.playerid)
       OR
        (s.yearid = 2001 AND salary = (SELECT MAX(salary)
                            FROM salaries
                            WHERE salaries.yearid = 2001) AND s.playerid = p.playerid)
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
    SELECT allstarfull.teamid, MAX(salaries.salary) - MIN(salaries.salary)
    FROM allstarfull INNER JOIN salaries
                                  ON allstarfull.playerid = salaries.playerid AND allstarfull.yearid = salaries.yearid
    WHERE salaries.yearid = 2016
    GROUP BY allstarfull.teamid
;

