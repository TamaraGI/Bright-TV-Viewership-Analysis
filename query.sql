CODE and EDA for BrightTV Analysis
--- Selects all columns from the table, reads from the table name and returns the only the first ten rows----
SELECT *
FROM bright_tv_user_profiles
LIMIT 10;
---Selects only unique (non duplicated values, from the column name gender and in the table Bright tv user profiles)
SELECT DISTINCT gender
FROM bright_tv_user_profiles;
---Return only unique non-duplicated values, case statment used to classify values if null or none then use te unknown or else gender value---
SELECT DISTINCT
  CASE
    WHEN gender IS NULL THEN 'unknown'
    WHEN gender ='None' THEN 'unknown'
    ELSE gender
END AS gender
FROM bright_tv_user_profiles;
---Return only unique non duplicated values, case statement used to classify values if null or none then use the unknown or province value---
SELECT DISTINCT province,
  CASE  
    WHEN province IS NULL THEN 'Unknown'
    WHEN province = 'None' THEN 'Unknown'
    ELSE province
    END AS province
FROM bright_tv_user_profiles;
---Return only unique non duplicated values, case statement used to classify values if null or none then use the unknown or race value---
SELECT DISTINCT race
FROM bright_tv_user_profiles;
SELECT DISTINCT
  CASE 
    WHEN race IN ('Other', 'None') THEN 'Unknown'
    WHEN race IS NULL THEN 'Unknown'
    ELSE race 
  END AS race
FROM bright_tv_user_profiles;
---Selects all the columns from the table and Filters the data to only include rows where UserID is missing (NULL)----
SELECT *
FROM bright_tv_user_profiles
WHERE UserID IS NULL;
----Selects all the columns from the table and Filters the data to only include rows where Age is missing (NULL)-
SELECT *
FROM bright_tv_user_profiles
WHERE age IS NULL;
---For each UserID, count how many rows have that ID, and show the ID itself,Group rows by UserID so we get counts per unique UserID & Only keep groups where the count is more than 1 — meaning duplicate UserIDs----
SELECT count(*) AS row_count,
       UserID
FROM bright_tv_user_profiles
GROUP BY UserID
HAVING count(*) > 1;
--- 'With' this defines a Common Table Expression (CTE) named users — essentially a temporary result set you can use later in your query, CASE This replaces any NULL or 'None' values in province with the string 'Unknown'. Otherwise, it keeps the original province value & For gender and race, missing or placeholder values (NULL, 'None', 'Other') are also replaced with 'Unknown'.
WITH users AS (
  SELECT UserID,
         age,
  CASE  
    WHEN province IS NULL THEN 'Unknown'
    WHEN province = 'None' THEN 'Unknown'
    ELSE province
  END AS province,
  CASE
    WHEN gender IS NULL THEN 'Unknown'
    WHEN gender = 'None' THEN 'Unknown'
    ELSE gender 
  END AS gender,
  CASE 
    WHEN race IN ('Other', 'None') THEN 'Unknown'
    WHEN race IS NULL THEN 'Unknown'
    ELSE race 
  END AS race
FROM bright_tv_user_profiles),

---Defines a Common Table Expression (CTE) named views. This is a temporary named result set you can reference in the main quer, Selects userid if it exists; otherwise falls back to UserID—ensuring a single userid column without nulls, Attempts to convert the string RecordDate2 into a timestamp using the given format.Extracts the time part (hours, minutes, seconds) from the timestamp as a string. TO_DATE-Converts the timestamp to a date (dropping the time part). Extract_format: Extracts the year and month in 'yyyyMM' format as a string---
views AS (SELECT
  COALESCE(userid,UserID) AS userid,
  channel2,
  try_to_timestamp(
    RecordDate2,
    'yyyy/MM/dd HH:mm'
  ) AS record_ts,
  date_format(
    try_to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'),
    'HH:mm:ss'
  ) AS watch_time,
  to_date(
    try_to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm')
  ) AS watch_date,
  date_format(
    try_to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'),
    'yyyyMM'
  ) AS month_id,
  Duration2
FROM bright_tv_viewership)
---Select all columns from both tables in the join, from views- Use the table or CTE named views, alias it as A,Left join- Perform a LEFT JOIN with the users table/CTE, alias it as B & Join condition: match rows where userid in views equals userid in users----
SELECT*
FROM views AS A
LEFT JOIN users AS B
ON A.userid = B.userid;
---To select/view specific columns from two tables or CTEs (aliased as v and u), Usually used after a JOIN, where v and u are aliases for the tables (e.g., views and users).This gives you combined data on viewing behavior (from views) and user demographics (from users)---
SELECT 
  v.userid,
  v.channel2,
  v.record_ts,
  v.watch_time,
  v.watch_date,
  v.month_id,
  v.Duration2,
  u.age,
  u.gender,
  u.province,
  u.race,
 --- Group users into age categories, create a categorical agegroup and facillitate demographic analysis---
  CASE
    WHEN u.age BETWEEN 1 AND 12 THEN 'Kids'
    WHEN u.age BETWEEN 13 AND 19 THEN 'Teenager'
    WHEN u.age BETWEEN 20 AND 35 THEN 'Youth'
    WHEN u.age BETWEEN 36 AND 50 THEN 'Adult'
    WHEN u.age BETWEEN 51 AND 65 THEN 'Senior'
    ELSE 'Elder'
  END AS AgeGroup,
  --- date_format Extracts the time part (hours, minutes, seconds) from the watch_time column (aliased as v),CASE- WHEN: Checks which time range the watch_time falls into and assigns a label accordingly----
  CASE
    WHEN date_format(v.watch_time, 'HH:mm:ss') BETWEEN '00:00:00' AND '03:59:59' THEN 'Early Morning'
    WHEN date_format(v.watch_time, 'HH:mm:ss') BETWEEN '04:00:00' AND '10:59:59' THEN 'Morning'
    WHEN date_format(v.watch_time, 'HH:mm:ss') BETWEEN '11:00:00' AND '18:59:59' THEN 'Afternoon'
    WHEN date_format(v.watch_time, 'HH:mm:ss') BETWEEN '19:00:00' AND '19:59:59' THEN 'Evening'
    ELSE 'Night'
  END AS WatchPeriod
---FROM views AS v: You're selecting from the table or CTE called views, and giving it the alias v to refer to it more easily,LEFT JOIN users AS u: You're doing a left join to the users table or CTE, which is aliased as u. A left join means:
FROM views AS v
LEFT JOIN users AS u
ON v.userid = u.userid;
