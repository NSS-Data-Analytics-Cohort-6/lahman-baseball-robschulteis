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


/*Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?*/

SELECT 
	   ROUND(AVG(so/g),2) as avg_so,
	   ROUND(AVG(hr/g),2) as avg_hr,	   
	   CASE --WHEN (DATE_PART('decade', CAST(CONCAT(yearid,'-01-01') AS date))) = 187 THEN '1870s'
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
	   --CAST(CONCAT(yearid,'-01-01') AS date) as date
FROM teams
WHERE yearid >= '1920'
GROUP BY decade
ORDER BY decade DESC;

/*Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.*/
-- Chris Owings
SELECT 
	SUM(sb) * 100.0 / NULLIF(SUM(sb + cs),0) AS percent_success,
	p.namefirst,
	p.namelast
 FROM people as p
 LEFT JOIN batting as b
 ON p.playerid = b.playerid
 GROUP BY p.namefirst, p.namelast, b.sb, b.cs, b.yearid
 HAVING (sb + cs) >= 20 AND yearid = '2016'
 ORDER BY percent_success DESC

/*From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?*/
-- SEA, 2001, 116 WINS
-- LAN (DODGERS), 1981, 63 WINS (Shortened Season (through research this was due to the Strike))
-- SLN (CARDS), 2006, 83 WINS

/*SELECT 
	teamid,
	name,
	w AS total_wins,
	yearid,
	wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND wswin = 'N'
GROUP BY teamid, yearid, wswin, name, w
ORDER BY total_wins DESC*/

/*SELECT 
	teamid,
	name,
	SUM(w) AS total_wins,
	yearid,
	g
FROM teams
WHERE yearid = 1981
GROUP BY teamid, yearid, wswin, name, g
ORDER BY g DESC*/

/*SELECT 
	teamid,
	name,
	w AS total_wins,
	yearid,
	wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND wswin = 'Y' AND yearid <> '1981'
GROUP BY teamid, yearid, wswin, name, w
ORDER BY total_wins*/

/*SELECT 
	teamid,
	name,
	SUM(w) AS total_wins,
	yearid,
	wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND wswin = 'Y' AND yearid <> '1981'
GROUP BY teamid, yearid, wswin, name
ORDER BY total_wins*/

	WITH ws_win (win_champ, yearid) as 
		(SELECT 
			--teamid,
			--name,
			w as win_champ,
			yearid
			--wswin
		FROM teams
		WHERE yearid BETWEEN 1970 AND 2016 and wswin = 'Y'
		GROUP BY yearid, win_champ)
	,
	max_wins_year (max_win_season, yearid) as  
		(SELECT
			--name,
			MAX(MAX(w)) OVER(PARTITION BY (yearid)) as max_win_season,
			yearid
		FROM teams
		 WHERE yearid BETWEEN 1970 AND 2016
		 GROUP BY yearid)

SELECT w.yearid, CASE WHEN cast(w.win_champ as int) = cast(m.max_win_season as int) THEN 1 END AS tot_
	FROM ws_win w
	INNER JOIN max_wins_year m
	on cast(w.win_champ as int) = cast(m.max_win_season as int) AND w.yearid = m.yearid
	GROUP BY m.yearid, w.win_champ, w.yearid, m.max_win_season
	ORDER BY w.yearid

/*Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.*/
	--TOP 5 LAN,SLN,TOR,SFN
	--BOT 5 TBA, OAK, CLE, MIA, CHA
	SELECT 
	 	p.park_name,
	 	h.team,
	 	--SUM(SUM(h.games)) OVER(PARTITION BY h.team) AS tot_games,
	 	ROUND(SUM(h.attendance)/ NULLIF(SUM(h.games),0),2) AS avg_attendance
	 FROM homegames AS h 
	 INNER JOIN parks AS p
	 ON h.park = p.park
	 WHERE year = 2016
	 GROUP BY h.team, h.games, p.park_name
	 HAVING SUM(games) >= 10
	 ORDER BY avg_attendance
	 LIMIT 5
	)	
	
/*Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.*/
	
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

--Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

WITH career_high_stats(playerid, namefirst, namelast, yearid, years_played, career_high_hr) AS	
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

