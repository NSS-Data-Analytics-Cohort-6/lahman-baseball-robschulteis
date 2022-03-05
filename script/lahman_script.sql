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

SELECT *
FROM fielding
WHERE yearid = '2016';





