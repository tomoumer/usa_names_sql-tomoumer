-- 1. How many rows are in the names table?
-- a: 1,957,046

-- SELECT COUNT(*)
-- FROM names;


-- 2. How many total registered people appear in the dataset?
-- a: 351,653,025

-- SELECT SUM(num_registered) AS total_registered
-- FROM names;


-- 3. Which name had the most appearances in a single year in the dataset?
-- a: Linda in 1947

-- SELECT *
-- FROM names
-- WHERE num_registered = (
-- 	SELECT MAX(num_registered) 
-- 	FROM names);
	
-- an easier way to accomplish the same result;

--SELECT *
--FROM names
--ORDER BY num_registered DESC
--LIMIT 1;

-- 4. What range of years are included?
-- a: 1880 to 2018 (138 years)

-- SELECT
-- 	MIN(year) AS min_year,
-- 	MAX(year) AS max_year, 
-- 	MAX(year) - MIN(year) AS year_diff
-- FROM names;


-- 5. What year has the largest number of registrations?
-- a: year 1957 with 4,200,022

-- SELECT
-- 	year,
-- 	SUM(num_registered) as yearly_registered
-- FROM names
-- GROUP BY year
-- ORDER BY yearly_registered DESC
-- LIMIT 1;


-- 6. How many different (distinct) names are contained in the dataset?
-- a: 98400

-- SELECT COUNT(DISTINCT name)
-- FROM names;


-- 7. Are there more males or more females registered?
-- a: males lead with 177,573,793 to 174,079,232 females

-- SELECT
-- 	gender,
-- 	SUM(num_registered) AS total_registered
-- FROM names
-- GROUP BY gender;

-- 8. What are the most popular male and female names overall
-- (i.e., the most total registrations)?
-- a: for F, Mary, for M, James

-- (SELECT name, gender, SUM(num_registered) AS total
-- FROM names
-- WHERE gender = 'M'
-- GROUP BY gender, name
-- ORDER BY total DESC
-- LIMIT 1)
-- UNION
-- (SELECT name, gender, SUM(num_registered) AS total
-- FROM names
-- WHERE gender = 'F'
-- GROUP BY gender, name
-- ORDER BY total DESC
-- LIMIT 1);

-- 9. What are the most popular boy and girl names of the first decade of the 2000s (2000 - 2009)?
-- a: Jacob for boys, Emily for girls
-- note: could use a union here as well

-- SELECT
-- 	name,
-- 	gender,
-- 	SUM(num_registered) AS names_per_gender
-- FROM names
-- WHERE year BETWEEN 2000 AND 2009
-- 	AND gender = 'F' --'F'
-- GROUP BY gender, name
-- ORDER BY names_per_gender DESC
-- LIMIT 1;

-- 10. Which year had the most variety in names (i.e. had the most distinct names)?
-- a: year 2008 with 32,518 names

-- SELECT
-- 	year,
-- 	COUNT(DISTINCT(name)) as distinct_names
-- FROM names
-- GROUP BY year
-- ORDER BY distinct_names DESC
-- LIMIT 5;


-- 11. What is the most popular name for a girl that starts with the letter X?
-- a: Ximena with 26,145

-- SELECT
-- 	name,
-- 	SUM(num_registered) AS total_registered
-- FROM names
-- WHERE gender='F'
-- 	AND name LIKE 'X%'
-- GROUP BY name
-- ORDER BY total_registered DESC
-- LIMIT 1;


--12. How many distinct names appear that start with a 'Q', but whose second letter is not 'u'?
-- a: 46 distinct names

-- SELECT COUNT(DISTINCT(name))
-- FROM names
-- WHERE name LIKE 'Q%'
-- 	AND name NOT LIKE '_u%';


/*
classmate Smita's approach, by telling it to match Q and anything BUT u for second letter, so using regex with SIMILAR TO 
SELECT
	name,
	SUM (num_registered) AS most_q
FROM names
WHERE name SIMILAR TO 'Q[^u]%'
GROUP BY name
ORDER BY most_q DESC;
*/

--13. Which is the more popular spelling between "Stephen" and "Steven"? Use a single query to answer this question.
-- a: Steven wins 1,286,951 to 860,972

-- more compact:
-- SELECT
-- 	name,
-- 	SUM(num_registered) AS total_registered
-- FROM names
-- WHERE name IN('Stephen', 'Steven')
-- GROUP BY name;


-- 14. What percentage of names are "unisex" - that is what percentage of names have been used both for boys and for girls?
-- a: the total (done in two parts) is 10,773 names being unisex, over 98,400 distinct. So 10.95% 

/* my original solution, before knowing about subqueries
SELECT name, COUNT(DISTINCT(gender)) AS num_gender, COUNT(*) AS num_unisex
FROM names
GROUP BY name
HAVING COUNT(DISTINCT(gender)) = 2;

SELECT COUNT(DISTINCT(name))
FROM names;
*/

-- same as above, but improved by using subqueries:

-- SELECT
-- 	(SELECT COUNT(*)
-- 	  FROM (SELECT name
-- 	  		FROM names
-- 	  		GROUP BY name
-- 	  		HAVING COUNT(DISTINCT gender ) = 2) AS sub) /
-- 	  CAST( COUNT(DISTINCT name) AS DOUBLE PRECISION) AS perc_unisex
-- FROM names

-- and another way of doing it:

-- SELECT 
-- 	(SELECT COUNT(DISTINCT name)
-- 	FROM names
-- 	WHERE gender='F'
-- 		AND name IN (SELECT DISTINCT name
-- 					FROM names
-- 					WHERE gender='M')) * 100.0 /
-- 	COUNT(DISTINCT name) AS perc_unisex
-- FROM names

/* a classmate Asha's code and ta Rohit's
SELECT ROUND(sum(unisex_names) * 100.0 /count(*), 2)
FROM (
SELECT name, CASE WHEN COUNT(DISTINCT(gender)) > 1  THEN 1
END AS unisex_names
FROM names
GROUP BY name) as sub1
*/

-- another way, (not very efficient) Michael showed us, by doing inner join
-- SELECT COUNT(DISTINCT name)
-- FROM names n1
-- INNER JOIN names n2
-- USING(name)
-- WHERE n1.gender='F'
-- 	AND n2.gender='M'

-- 15. How many names have made an appearance in every single year since 1880?
-- a: 921 names

-- SELECT name, COUNT(DISTINCT(year)) as num_years
-- FROM names
-- GROUP BY name
-- HAVING COUNT(DISTINCT year) = 139;

/* classmate Ajay's code:
SELECT COUNT(name)
FROM
(
	SELECT DISTINCT name
	FROM names
	GROUP BY name
	HAVING COUNT(DISTINCT year) = (SELECT COUNT(DISTINCT year) FROM names)
) AS Sub1
*/

-- 16. How many names have only appeared in one year?
-- a: 21123

-- SELECT
-- 	name,
-- 	COUNT(DISTINCT(year)) as num_years
-- FROM names
-- GROUP BY name
-- HAVING COUNT(DISTINCT year) = 1;


-- 17. How many names only appeared in the 1950s?
-- a: 661 names I believe...

-- SELECT name
-- FROM names
-- GROUP BY name
-- HAVING MIN(year) >= 1950 AND
-- 	MAX(year) <= 1959;


/* classmate Ajay's code:
WITH outside_names AS
SELECT COUNT( DISTINCT Name)
FROM names
WHERE name NOT IN
(
	SELECT DISTINCT Name
	FROM names
	WHERE year <  1950 OR year > 1959
)
*/

-- 18. How many names made their first appearance in the 2010s?
-- a: 11,270 names!

-- SELECT name
-- FROM names
-- GROUP BY name
-- HAVING MIN(year) >= 2010;


-- 19. Find the names that have not been used in the longest.
-- a: Zilpah and Roll last appeared in 1881!

-- SELECT
-- 	name,
-- 	MAX(year) AS name_last_appearance
-- FROM names
-- GROUP BY name
-- ORDER BY name_last_appearance;


-- 20. Come up with a question that you would like to answer using this dataset.
-- Then write a query to answer this question.

-- SELECT *
-- FROM names
-- WHERE name='Tomo';

-- ========== ADDITIONAL QUESTIONS
-- 1. Find the longest name contained in this dataset. What do you notice about the long names?
-- a: It appears the longest names are 15 chars long and that's because they have multiple names strung together

-- SELECT name, CHAR_LENGTH(name) AS name_length
-- FROM names
-- ORDER BY name_length DESC
-- LIMIT 5;


-- 2. How many names are palindromes (i.e. read the same backwards and forwards, such as Bob and Elle)?
-- a: 137 names are palindromes

-- SELECT
-- 	LOWER(name) as name_lower,
-- 	REVERSE(LOWER(name)) as name_reversed
-- FROM names
-- WHERE LOWER(name) = REVERSE(LOWER(name))
-- GROUP BY name;


-- 3. Find all names that contain no vowels (for this question, we'll count a,e,i,o,u, and y as vowels).
-- (Hint: you might find this page helpful: https://www.postgresql.org/docs/8.3/functions-matching.html)
-- a: 43 names don't have vowels in them

-- SELECT name
-- FROM names
-- WHERE LOWER(name) NOT SIMILAR TO '%(a|e|i|o|u|y)%'
-- GROUP BY name;


-- 4. How many double-letter names show up in the dataset? Double-letter means the same letter repeated back-to-back, like Matthew or Aaron. Are there any triple-letter names?
-- a: did not finish this yet!

-- SELECT name
-- FROM names
-- WHERE name SIMILAR TO '%%'


