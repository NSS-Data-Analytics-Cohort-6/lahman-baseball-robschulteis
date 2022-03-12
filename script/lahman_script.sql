--1) What range of years for baseball games played does the provided database cover?
--Answer: 1871-2016

SELECT MIN(YEAR) AS EARLIEST_YEAR,
	MAX(YEAR) AS MOST_RECENT_YEAR
FROM HOMEGAMES
--=========================================================================================================================================
--2) Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
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
--=========================================================================================================================================
/* 3) Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?*/
-- Answer: David Price $81,851,296

WITH VANDY (playerid, schoolid) AS
	(SELECT DISTINCT playerid, schoolid
	 FROM collegeplaying
	 WHERE schoolid IS NOT NULL AND LOWER(schoolid) LIKE 'vand%')
,

SUM_SALARY (playerid, tot_salary) AS
	(SELECT DISTINCT playerid, SUM(salary) AS tot_salary
	FROM salaries
	GROUP BY playerid
	ORDER BY tot_salary DESC)

SELECT p.namefirst
	   , p.namelast
	   , v.playerid
	   , s.tot_salary
FROM people as p
INNER JOIN VANDY as v
USING(playerid)
INNER JOIN SUM_SALARY as s
USING(playerid)
GROUP BY p.namefirst, p.namelast, v.playerid, s.tot_salary
ORDER BY s.tot_salary DESC
--=========================================================================================================================================
/* 4) Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.*/

SELECT 
	CASE WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield'
	WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
	END AS position,
	SUM(po) AS total_putouts
FROM fielding
WHERE yearid = '2016'
GROUP BY position
ORDER BY total_putouts DESC;

--=========================================================================================================================================
/* 5) Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?*/

SELECT 
	   ROUND(AVG(so/g),2) as avg_so
	   , ROUND(AVG(hr/g),2) as avg_hr	   
	   , CASE --WHEN (DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date))) = 187 THEN '1870s'
	   	--WHEN DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date)) = 188 THEN '1880s'
	   	--WHEN DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date)) = 189 THEN '1890s'
	   	--WHEN DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date)) = 190 THEN '1900s'
	   	--WHEN DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date)) = 191 THEN '1910s'
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
FROM teams
WHERE yearid >= '1920'
GROUP BY decade
ORDER BY decade DESC;
--=========================================================================================================================================
/* 6) Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.*/
-- Chris Owings
SELECT 
	SUM(sb) * 100.0 / NULLIF(SUM(sb + cs),0) AS percent_success
	, p.namefirst
	, p.namelast
 FROM people as p
 LEFT JOIN batting as b
 ON p.playerid = b.playerid
 GROUP BY p.namefirst, p.namelast, b.sb, b.cs, b.yearid
 HAVING (sb + cs) >= 20 AND yearid = '2016'
 ORDER BY percent_success DESC
--========================================================================================================================================
/* 7) From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?*/
-- SEA, 2001, 116 WINS
-- LAN (DODGERS), 1981, 63 WINS (Shortened Season (through research this was due to the Strike))
-- SLN (CARDS), 2006, 83 WINS

SELECT 
	teamid
	, name
	, w AS total_wins
	, yearid
	, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND wswin = 'N'
GROUP BY teamid, yearid, wswin, name, w
ORDER BY total_wins DESC
--===========================
SELECT 
	teamid
	, name
	, w AS total_wins
	, yearid
	, g
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND wswin = 'Y'
GROUP BY teamid, yearid, wswin, name, g, W
ORDER BY g 
--===========================
SELECT 
	teamid,
	, name
	, w AS total_wins
	, yearid
	, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND wswin = 'Y' AND yearid <> '1981'
GROUP BY teamid, yearid, wswin, name, w
ORDER BY total_wins
--=====================================================================
	WITH ws_win (win_champ, yearid) as 
		(SELECT 
			w as win_champ
		 	, yearid
		FROM teams
		WHERE yearid BETWEEN 1970 AND 2016 and wswin = 'Y'
		GROUP BY yearid, win_champ)
	,
	max_wins_year (max_win_season, yearid) as  
		(SELECT
			MAX(MAX(w)) OVER(PARTITION BY (yearid)) as max_win_season
			, yearid
		FROM teams
		 WHERE yearid BETWEEN 1970 AND 2016
		 GROUP BY yearid)
	,
	 max_win_ws_count (count) AS 
		(SELECT COUNT(DISTINCT w.yearid) AS count
		FROM ws_win w
		INNER JOIN max_wins_year m
		on cast(w.win_champ as int) = cast(m.max_win_season as int) AND w.yearid = m.yearid
		GROUP BY m.yearid, w.win_champ, w.yearid, m.max_win_season
		ORDER BY w.yearid)
	
select COUNT(*) AS Count, ROUND((cast(count(*)as decimal)/46)*100,2) AS perct
FROM max_win_ws_count 
--=======================================================================================================================================

/* 8) Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.*/
	--TOP 5 LAN,SLN,TOR,SFN
	--BOT 5 TBA, OAK, CLE, MIA, CHA
	SELECT 
	 	p.park_name
	 	, h.team
	 	, ROUND(SUM(CAST(h.attendance as decimal))/ NULLIF(SUM(CAST(h.games as decimal)),0),0) AS avg_attendance
	 FROM homegames AS h 
	 INNER JOIN parks AS p
	 ON h.park = p.park
	 WHERE year = 2016
	 GROUP BY h.team, h.games, p.park_name
	 HAVING SUM(games) >= 10
	 ORDER BY avg_attendance DESC
	 LIMIT 5 
		
	SELECT 
	 	p.park_name
	 	, h.team
	 	, ROUND(SUM(CAST(h.attendance as decimal))/ NULLIF(SUM(CAST(h.games as decimal)),0),0) AS avg_attendance
	 FROM homegames AS h 
	 INNER JOIN parks AS p
	 ON h.park = p.park
	 WHERE year = 2016
	 GROUP BY h.team, h.games, p.park_name
	 HAVING SUM(games) >= 10
	 ORDER BY avg_attendance
	 LIMIT 5 
--=========================================================================================================================================	
/* 9) Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.*/
	
	WITH NL (playerid, namefirst, namelast, teamid, name, awardid, lgid) AS
		(SELECT a.playerid
				, p.namefirst
				, p.namelast
				, m.teamid
				, t.name
				, a.awardid
				, a.lgid
		FROM people AS p
		INNER JOIN awardsmanagers AS a
		ON p.playerid = a.playerid
		INNER JOIN managers AS m
		ON a.playerid = m.playerid AND a.yearid = m.yearid
		INNER JOIN teams AS t 
		ON m.teamid = t.teamid AND m.yearid = t.yearid
		WHERE awardid = 'TSN Manager of the Year' AND a.lgid = 'NL'
		GROUP BY a.playerid, p.namefirst, p.namelast, m.teamid, t.name, a.awardid, a.lgid
		ORDER BY a.playerid)
	,
	
	AL (playerid, namefirst, namelast, teamid, name, awardid, lgid) AS
		(SELECT a.playerid
				, p.namefirst
				, p.namelast
				, m.teamid
				, t.name
				, a.awardid
				, a.lgid
		FROM people AS p
		INNER JOIN awardsmanagers AS a
		ON p.playerid = a.playerid
		INNER JOIN managers as m
		ON a.playerid = m.playerid AND a.yearid = m.yearid
		INNER JOIN teams as t 
		ON m.teamid = t.teamid AND m.yearid = t.yearid
		WHERE awardid = 'TSN Manager of the Year' AND a.lgid = 'AL'
		GROUP BY a.playerid, p.namefirst, p.namelast, m.teamid, t.name, a.awardid, a.lgid
		ORDER BY a.playerid)

SELECT AL.namefirst AS first_name, AL.namelast AS last_name, AL.name as AL_team, NL.name AS NL_team
FROM NL
INNER JOIN AL
ON NL.playerid = AL.playerid

-- 10) Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

WITH career_high_stats(playerid, namefirst, namelast, yearid, career_high_hr) AS	
	(SELECT  b.playerid
			, p.namefirst
			, p.namelast
			, b.yearid
			, MAX(b.hr) OVER(PARTITION BY b.playerid) AS career_high_hr
	FROM batting AS b
	LEFT JOIN people AS p
	USING (playerid)
	GROUP BY b.playerid, p.namefirst, p.namelast, b.yearid, p.finalgame, p.debut, b.hr
	ORDER BY b.hr DESC)
,

HR (playerid, yearid, hr) AS 
	(SELECT playerid
			, yearid
			, hr
	FROM batting
	WHERE yearid = 2016 AND hr >=1)
,

year_count (years_played, playerid) AS
	(SELECT COUNT(DISTINCT(yearid)) as years_played, playerid
	FROM batting
	GROUP BY playerid
	HAVING COUNT(DISTINCT(yearid)) >= 10)

SELECT 
	c.playerid
	, c.namefirst
	, c.namelast
	, c.yearid
	, HR.hr
	, y.years_played
FROM career_high_stats as c
INNER JOIN HR
USING(playerid, yearid)
INNER JOIN year_count as y
ON HR.playerid = y.playerid
WHERE HR.hr = c.career_high_hr
GROUP BY c.playerid, c.namefirst, c.namelast, c.yearid, HR.hr, y.years_played

--====================================================================================================
/*WITH career_high_stats(playerid, namefirst, namelast, yearid, years_played, career_high_hr) AS	
	(SELECT  b.playerid
			, p.namefirst
			, p.namelast
			, b.yearid
			,  DATE_PART('year', p.finalgame::date) - DATE_PART('year', p.debut::date) AS years_played
			, MAX(b.hr) OVER(PARTITION BY b.playerid) AS career_high_hr
	FROM batting AS b
	LEFT JOIN people AS p
	USING (playerid)
	GROUP BY b.playerid, p.namefirst, p.namelast, b.yearid, p.finalgame, p.debut, b.hr
	HAVING DATE_PART('year', p.finalgame::date) - DATE_PART('year', p.debut::date) >= 10 --this was
	ORDER BY b.hr DESC)
,
HR (playerid, yearid, hr) AS
	(SELECT playerid
			, yearid
			, hr
	FROM batting
	WHERE yearid = 2016 AND hr >=1)
SELECT
	c.playerid
	, c.namefirst
	, c.namelast
	, c.yearid
	, HR.hr
	, c.years_played
FROM career_high_stats as c
LEFT JOIN HR
USING(playerid, yearid)
WHERE HR.hr = c.career_high_hr
GROUP BY c.playerid, c.namefirst, c.namelast, c.yearid, HR.hr, c.years_played
ORDER BY years_played*/

/*Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.*/

SELECT t.name
	   , s. yearid
	   --, SUM(CAST(S.salary AS DECIMAL))
	   , ROUND(AVG(AVG(CAST(s.salary as decimal))) OVER(PARTITION BY teamid),2) as avg_salary_per_year
	   , ROUND(t.w/AVG(t.w) OVER(PARTITION BY yearid)*100,2) as perc_of_avg
FROM salaries as s 
JOIN teams as t
USING(teamid, yearid)
WHERE s.yearid >= 2000
GROUP BY s.teamid, t.name, s.yearid, t.w
ORDER BY s.yearid DESC, avg_salary_per_year DESC

SELECT yearid, AVG(SUM(salary)) OVER(PARTITION BY yearid)
FROM salaries
GROUP BY yearid, teamid
ORDER BY yearid DESC

SELECT teamid, yearid
, SUM(SUM(salary)) OVER(PARTITION BY teamid)
FROM salaries 
GROUP BY yearid, teamid

