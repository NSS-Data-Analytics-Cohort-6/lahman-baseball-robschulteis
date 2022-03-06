--What range of years for baseball games played does the provided database cover?
--Answer: 1871-2017

SELECT MIN(YEAR) AS EARLIEST_YEAR,
	MAX(YEAR) AS MOST_RECENT_YEAR
FROM HOMEGAMES

--Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
--Answer: Eddie Gaedel, 1, St. Louis Browns
SELECT DISTINCT p.namefirst,
	   p.namelast,
	   p.height,
	   p.playerid,
	   t.name,
	   a.g_all
FROM people as p
LEFT JOIN appearances as a
ON p.playerid = a.playerid
LEFT JOIN teams as t
ON a.teamid = t.teamid
ORDER BY p.height

/*Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?*/
-- Answer: David Price 
SELECT DISTINCT CONCAT(cast(p.namefirst as text), ' ', cast(p.namelast as text)) AS full_name,
	   SUM(s.salary) AS total_salary,
	   LOWER(c.schoolid)
FROM people as p
LEFT JOIN salaries as s
ON p.playerid = s.playerid
LEFT JOIN collegeplaying as c
ON s.playerid = c.playerid
WHERE s.salary IS NOT NULL AND c.schoolid IS NOT NULL AND LOWER(C.schoolid) LIKE 'vand%'
GROUP BY full_name, c.schoolid
ORDER BY total_salary DESC

/*Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.*/
--Answer: Infield - 59934, Battery - 41424, Outfield - 29560
SELECT 
	CASE WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield'
	WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
	END AS position,
	SUM(po) AS total_putouts
FROM fielding
WHERE yearid = '2016'
GROUP BY position
ORDER BY total_putouts DESC

/*Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
use date part
*/ 
SELECT t.tot_so/t.g as avg_so,
	 	t.decade,
		t.tot_so
FROM
(SELECT (SUM(so) as tot_so,
	   CASE WHEN (DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date))) = 187 THEN '1870s'
	   WHEN DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date)) = 188 THEN '1880s'
	   WHEN DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date)) = 189 THEN '1890s'
	   WHEN DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date)) = 190 THEN '1900s'
	   WHEN DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date)) = 191 THEN '1910s'
	   WHEN DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date)) = 192 THEN '1920s'
	   WHEN DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date)) = 193 THEN '1930s'
	   WHEN DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date)) = 194 THEN '1940s'
	   WHEN DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date)) = 195 THEN '1950s'
	   WHEN DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date)) = 196 THEN '1960s'
	   WHEN DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date)) = 197 THEN '1970s'
	   WHEN DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date)) = 198 THEN '1980s'
	   WHEN DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date)) = 199 THEN '1990s'
	   WHEN DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date)) = 200 THEN '2000s'
	   WHEN DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date)) = 201 THEN '2010s'
	   END AS decade
	   --CAST(CONCAT(yearid,'-01-01') AS date) as date
FROM teams) as t
GROUP BY t.decade, t.avg_so, t.yearid
ORDER BY avg_so DESC;



