-- 1. How many rows are in the names table?
-- SELECT COUNT(*)
-- FROM names;
-- a: 1,957,046

-- 2. How many total registered people appear in the dataset?
-- SELECT SUM(num_registered) AS total_registered
-- FROM names;
-- a: 351,653,025

-- 3. Which name had the most appearances in a single year in the dataset?
-- SELECT *
-- FROM names
-- WHERE num_registered = (
-- 	SELECT MAX(num_registered) 
-- 	FROM names);
	
-- I also realized I overcomplicated this ... easier:
--SELECT *
--FROM names
--ORDER BY num_registered DESC
--LIMIT 1;
-- a: Linda in 1947

-- 4. What range of years are included?
--SELECT year
--FROM names
--ORDER BY year --DESC
--LIMIT 1;

-- better yet:
-- SELECT MIN(year) AS min_year, MAX(year) AS max_year, MAX(year) - MIN(year) AS year_diff
-- FROM names;
--a: 1880 to 2018 (138 years)

-- 5. What year has the largest number of registrations?
-- SELECT year, SUM(num_registered) as yearly_registered
-- FROM names
-- GROUP BY year
-- ORDER BY yearly_registered DESC
-- LIMIT 1;
-- a: year 1957 with 4,200,022

-- 6. How many different (distinct) names are contained in the dataset?
-- SELECT COUNT(DISTINCT name)
-- FROM names;
-- a: 98400

-- 7. Are there more males or more females registered?
-- SELECT gender, SUM(num_registered) AS total_registered
-- FROM names
-- GROUP BY gender;
-- males lead with 177,573,793 to 174,079,232 females

-- 8. What are the most popular male and female names overall
-- (i.e., the most total registrations)?
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
-- a: for F, Mary, for M, James

-- 9. What are the most popular boy and girl names of the first decade of the 2000s (2000 - 2009)?
-- SELECT name, gender, SUM(num_registered) AS names_per_gender
-- FROM names
-- WHERE year BETWEEN 2000 AND 2009
-- 	AND gender = 'F' --'F'
-- GROUP BY gender, name
-- ORDER BY names_per_gender DESC
-- LIMIT 1;
-- note: could use a union here as well
-- a: Jacob for boys, Emily for girls

-- 10. Which year had the most variety in names (i.e. had the most distinct names)?
-- SELECT year, COUNT(DISTINCT(name)) as distinct_names
-- FROM names
-- GROUP BY year
-- ORDER BY distinct_names DESC
-- LIMIT 5;
-- a: year 2008 with 32,518 names

-- 11. What is the most popular name for a girl that starts with the letter X?
-- SELECT name, SUM(num_registered) AS total_registered
-- FROM names
-- WHERE gender='F'
-- 	AND name LIKE 'X%'
-- GROUP BY name
-- ORDER BY total_registered DESC
-- LIMIT 1;
-- a: Ximena with 26,145

--12. How many distinct names appear that start with a 'Q', but whose second letter is not 'u'?
-- SELECT COUNT(DISTINCT(name))
-- FROM names
-- WHERE name LIKE 'Q%'
-- 	AND name NOT LIKE '_u%';
-- a: 46 distinct names

/*
Smita's code, by telling it to match Q and anything BUT u for second letter, so using regex with SIMILAR TO 
SELECT name, SUM (num_registered) AS most_q
FROM names
WHERE name SIMILAR TO 'Q[^u]%'
GROUP BY name
ORDER BY most_q DESC;
*/

--13. Which is the more popular spelling between "Stephen" and "Steven"? Use a single query to answer this question.
-- SELECT name, SUM(num_registered) AS total_registered
-- FROM names
-- WHERE name='Stephen'
-- 	OR name='Steven'
-- GROUP BY name;

-- more compact:
-- SELECT name, SUM(num_registered) AS total_registered
-- FROM names
-- WHERE name IN('Stephen', 'Steven')
-- GROUP BY name;
-- a: Steven wins 1,286,951 to 860,972

-- 14. What percentage of names are "unisex" - that is what percentage of names have been used both for boys and for girls?
-- SELECT name, COUNT(DISTINCT(gender)) AS num_gender, COUNT(*) AS num_unisex
-- FROM names
-- GROUP BY name
-- HAVING COUNT(DISTINCT(gender)) = 2;

-- SELECT COUNT(DISTINCT(name))
-- FROM names;
-- a: the total (done in two parts) is 10,773 names being unisex, over 98,400 distinct. So 10.95% 
-- redoing the same above, with NEW and IMPROVED SQL knowledge (thx DataCamp)
-- SELECT
-- 	(SELECT COUNT(*)
-- 	  FROM (SELECT name
-- 	  		FROM names
-- 	  		GROUP BY name
-- 	  		HAVING COUNT(DISTINCT gender ) = 2) AS sub) /
-- 	  CAST( COUNT(DISTINCT name) AS DOUBLE PRECISION) AS perc_unisex
-- FROM names

-- aand another way of doing it:
-- SELECT 
-- 	(SELECT COUNT(DISTINCT name)
-- 	FROM names
-- 	WHERE gender='F'
-- 		AND name IN (SELECT DISTINCT name
-- 					FROM names
-- 					WHERE gender='M')) * 100.0 /
-- 	COUNT(DISTINCT name) AS perc_unisex
-- FROM names

/* Asha's code and Rohit, using
SELECT ROUND(sum(unisex_names) * 100.0 /count(*), 2)
FROM (
SELECT name, CASE WHEN COUNT(DISTINCT(gender)) > 1  THEN 1
END AS unisex_names
FROM names
GROUP BY name) as sub1
*/

-- another way, though not very efficient Michael showed us, by doing inner join
-- SELECT COUNT(DISTINCT name)
-- FROM names n1
-- INNER JOIN names n2
-- USING(name)
-- WHERE n1.gender='F'
-- 	AND n2.gender='M'

-- 15. How many names have made an appearance in every single year since 1880?
-- SELECT name, COUNT(DISTINCT(year)) as num_years
-- FROM names
-- GROUP BY name
-- HAVING COUNT(DISTINCT year) = 139;
-- a: 921 names

/* Ajay code:
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
-- SELECT name, COUNT(DISTINCT(year)) as num_years
-- FROM names
-- GROUP BY name
-- HAVING COUNT(DISTINCT year) = 1;
-- a: 21123

-- 17. How many names only appeared in the 1950s?
-- SELECT name
-- FROM names
-- GROUP BY name
-- HAVING MIN(year) >= 1950 AND
-- 	MAX(year) <= 1959;
-- a: 661 names I believe...

/* Ajay code:
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
-- SELECT name
-- FROM names
-- GROUP BY name
-- HAVING MIN(year) >= 2010;
-- a: 11,270 names!

-- 19. Find the names that have not been used in the longest.
-- SELECT name, MAX(year) AS name_last_appearance
-- FROM names
-- GROUP BY name
-- ORDER BY name_last_appearance;
-- a: Zilpah and Roll last appeared in 1881!

-- 20. Come up with a question that you would like to answer using this dataset.
-- Then write a query to answer this question.
-- SELECT *
-- FROM names
-- WHERE name='Tomo';

-- ========== ADDITIONAL QUESTIONS
-- 1. Find the longest name contained in this dataset. What do you notice about the long names?
-- SELECT name, CHAR_LENGTH(name) AS name_length
-- FROM names
-- ORDER BY name_length DESC
-- LIMIT 5;
-- a: It appears the longest names are 15 chars long and that's because they have multiple names strung together

-- 2. How many names are palindromes (i.e. read the same backwards and forwards, such as Bob and Elle)?
-- SELECT LOWER(name) as name_lower, REVERSE(LOWER(name)) as name_reversed
-- FROM names
-- WHERE LOWER(name) = REVERSE(LOWER(name))
-- GROUP BY name;
-- a: 137 names are palindromes

-- 3. Find all names that contain no vowels (for this question, we'll count a,e,i,o,u, and y as vowels).
-- (Hint: you might find this page helpful: https://www.postgresql.org/docs/8.3/functions-matching.html)
-- SELECT name
-- FROM names
-- WHERE LOWER(name) NOT SIMILAR TO '%(a|e|i|o|u|y)%'
-- GROUP BY name;
-- a: 43 names don't have vowels in them

-- 4. How many double-letter names show up in the dataset? Double-letter means the same letter repeated back-to-back, like Matthew or Aaron. Are there any triple-letter names?
-- SELECT name
-- FROM names
-- WHERE name SIMILAR TO '%%'


