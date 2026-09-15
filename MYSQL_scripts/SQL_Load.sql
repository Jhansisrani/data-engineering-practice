use jhansi;

drop table fifa;
create table fifa(
match_id       int primary key auto_increment,
match_Date	   date not null,
Team           varchar(50) not null,
Opponent	   varchar(50) not null,
goal_Scored	   int,
Possession 	   int,
Attempts	   int,
On_Target	   int,
off_Target	   int,
Blocked	       int,
Corners	       int,
Offsides	   int,
Free_Kicks	   int,
Saves	       int,
Pass_Accuracy  int,
Passes	       int,
Dist_Covered   int,
Fouls_Committed int,
Yellow_Card	    int,
Yellow_Red	    int,
Red	            int,
Man_of_Match    boolean,	
first_Goal	    int,
round	        varchar(50),
PSO	            boolean,  
Goals_PSO	    int,
Own_goals	    int,
Own_goal_Time   int
);

load data local infile  '/Users/shans/Downloads/fifa.csv'
into table fifa
fields terminated by ','
lines terminated by '\n'
ignore 1 rows;

show variables like 'secure_file_priv';

load data  infile'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fifa.csv'
into table fifa
fields terminated by ','
lines terminated by '\n'
ignore 1 rows 
(match_Date ,Team ,Opponent,goal_Scored,Possession,Attempts,On_Target,off_Target,Blocked,Corners,Offsides,Free_Kicks,
Saves,Pass_Accuracy ,Passes	,Dist_Covered,Fouls_Committed ,Yellow_Card	,Yellow_Red	,Red,Man_of_Match ,first_Goal,Round,PSO,
Goals_PSO,Own_goals,Own_goal_Time );

# date format s different in sql .so getting as varchar first.
alter table fifa modify column match_date varchar(25);
alter table fifa 
 modify column Man_of_Match CHAR(3),
 modify column  PSO CHAR(3);

 # these two columns has null values,integer doesnt' allow null values by default.so specifying null as my csv has empty values.
alter table fifa 
 modify column Own_goals int null,
 modify column Own_goal_Time int null;
 
 
load data  infile'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fifa.csv'
into table fifa
fields terminated by ','
lines terminated by '\n'
ignore 1 rows 
(@match_Date ,Team ,Opponent,goal_Scored,Possession,Attempts,On_Target,off_Target,Blocked,Corners,Offsides,Free_Kicks,
Saves,Pass_Accuracy ,Passes	,Dist_Covered,Fouls_Committed ,Yellow_Card	,Yellow_Red	,Red,Man_of_Match ,@first_Goal,Round,PSO,
Goals_PSO,@Own_goals,@Own_goal_Time )
set
first_Goal = nullif(trim(@first_Goal),''),
match_Date = str_to_date(@match_date, '%d-%m-%Y'),
Own_goals = nullif(trim(@Own_goals),''),
Own_goal_Time = nullif(trim(@Own_goal_Time),'');



load data  infile'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fifa.csv'
into table fifa
fields terminated by ','
lines terminated by '\n'
ignore 1 rows 
(@match_Date ,Team ,Opponent,goal_Scored,Possession,Attempts,On_Target,off_Target,Blocked,Corners,Offsides,Free_Kicks,
Saves,Pass_Accuracy ,Passes	,Dist_Covered,Fouls_Committed ,Yellow_Card	,Yellow_Red	,Red,Man_of_Match ,@first_Goal,Round,PSO,
Goals_PSO,@Own_goals,@Own_goal_Time )
set
first_Goal = NULLIF(REPLACE(REPLACE(@first_Goal, '\r', ''), '\n', ''), ''),
match_Date = @match_date,
Own_goals = NULLIF(REPLACE(REPLACE(@Own_goals, '\r', ''), '\n', ''), ''),
Own_goal_Time = NULLIF(REPLACE(REPLACE(@Own_goal_Time, '\r', ''), '\n', ''), '');


select * from fifa order by match_id asc;

select count(*) from fifa;

create table fifa1 as select * from fifa;
drop table fi
SET SQL_SAFE_UPDATES = 0;
UPDATE fifa1
SET match_Date = COALESCE(
    STR_TO_DATE(match_Date, '%d-%m-%Y'),
    STR_TO_DATE(match_Date, '%e/%c/%Y'),
    STR_TO_DATE(match_Date, '%Y-%m-%d')
)
WHERE match_Date IS NOT NULL;

select * from fifa1;


UPDATE fifa
SET match_Date = COALESCE(
    STR_TO_DATE(TRIM(REPLACE(REPLACE(match_Date, '\r', ''), '\n', '')), '%d-%m-%Y'),
    STR_TO_DATE(TRIM(REPLACE(REPLACE(match_Date, '\r', ''), '\n', '')), '%e/%c/%Y'),
    STR_TO_DATE(TRIM(REPLACE(REPLACE(match_Date, '\r', ''), '\n', '')), '%Y-%m-%d')
)
WHERE match_Date IS NOT NULL AND match_Date <> '';

UPDATE fifa
SET match_Date = COALESCE(
    STR_TO_DATE(NULLIF(TRIM(REPLACE(REPLACE(REPLACE(match_Date, '\r', ''), '\n', ''), ' ', '')), ''), '%d-%m-%Y'),
    STR_TO_DATE(NULLIF(TRIM(REPLACE(REPLACE(REPLACE(match_Date, '\r', ''), '\n', ''), ' ', '')), ''), '%e/%c/%Y'),
    STR_TO_DATE(NULLIF(TRIM(REPLACE(REPLACE(REPLACE(match_Date, '\r', ''), '\n', ''), ' ', '')), ''), '%Y-%m-%d')
)
WHERE match_Date IS NOT NULL AND match_Date <> '';

UPDATE fifa
SET match_Date = TRIM(REPLACE(REPLACE(REPLACE(match_Date, '\r', ''), '\n', ''), CHAR(65279), ''))
WHERE match_Date IS NOT NULL;

SELECT match_Date, HEX(match_Date)
FROM fifa1
WHERE match_Date LIKE '%2018%';


SELECT match_Date, HEX(match_Date)
FROM fifa1
WHERE HEX(match_Date) REGEXP '0D|0A|EFBBBF|FEFF';

ALTER TABLE fifa MODIFY match_Date BLOB;

UPDATE fifa
SET match_Date = CONVERT(match_Date USING utf8mb4);

ALTER TABLE fifa MODIFY match_Date VARCHAR(20);

UPDATE fifa
SET match_Date = TRIM(REPLACE(REPLACE(match_Date, '\r', ''), '\n', ''));

UPDATE fifa
SET match_Date = STR_TO_DATE(match_Date, '%d-%m-%Y')
WHERE match_Date LIKE '__-__-____';

UPDATE fifa
SET match_Date = STR_TO_DATE(match_Date, '%e/%c/%Y')
WHERE match_Date LIKE '%/%/%';

-- Step 4d: Convert YYYY-MM-DD
UPDATE fifa1
SET match_Date = STR_TO_DATE(match_Date, '%Y-%m-%d')
WHERE match_Date LIKE '____-__-__';

select * from fifa1;

alter table fifa1 modify column match_date date;

UPDATE fifa
SET match_Date = CASE
    WHEN match_Date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN STR_TO_DATE(match_Date, '%d-%m-%Y')
    WHEN match_Date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$' THEN STR_TO_DATE(match_Date, '%e/%c/%Y')
    WHEN match_Date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN STR_TO_DATE(match_Date, '%Y-%m-%d')
    ELSE NULL
END
WHERE match_Date IS NOT NULL;

SET match_Date = CASE
    WHEN match_Date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN STR_TO_DATE(match_Date, '%d-%m-%Y')
    WHEN match_Date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$' THEN STR_TO_DATE(match_Date, '%e/%c/%Y')
    WHEN match_Date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN STR_TO_DATE(match_Date, '%Y-%m-%d')
    ELSE NULL
END
WHERE match_Date IS NOT NULL;

UPDATE fifa
SET match_Date = STR_TO_DATE(match_Date, '%d-%m-%Y')
WHERE match_Date LIKE '__-__-____';

update fifa
set match_date=case
    when match_date like '__-__-____' then STR_TO_DATE(match_Date, '%d-%m-%Y')
    when match_date like '%/%/%' then STR_TO_DATE(match_Date, '%e/%c/%Y')
    when match_date like '____-__-__' then STR_TO_DATE(match_Date, '%Y-%m-%d')
    else null
end
where match_date is not null;

select age, gender from clevelanda order by age desc limit 10;

select gender, avg(age) as avg_of_age  from clevelanda group by gender;

select
	age, count(*) as age_count;
    
SELECT 
    trestbps, thalach
FROM
    clevelanda;
    
SELECT 
    age, gender
 
from
	clevelanda
where
	age > 40
group by age
having age_count >7
order by age 
limit 2, 10; -- limit From where to start, how many to show

select gender as 'Male & Female', class as 'Heart Diease' from clevelanda;

select Team, Opponent, concat(Team,' vs ',  Opponent) as 'Match' from fifa;
SET thal = CASE 
              WHEN @thal REGEXP '^[0-9]+$' THEN @thal 
              ELSE NULL 
           END;
           
           
            ################################################################################3                       
 # return entire table data with the highest goal and lowest goal for each team
     select * from fifa where team in (select team from fifa where goal_scored in
                (select max(goal_scored) from fifa ) or ( select min(goal_scored) from fifa) group by Team);  
                
                SELECT *
FROM fifa
WHERE Team IN (
    SELECT Team
    FROM fifa
    WHERE goal_scored IN (
        (SELECT MAX(goal_scored) FROM fifa),
        (SELECT MIN(goal_scored) FROM fifa)
    )
    GROUP BY Team
    HAVING COUNT(DISTINCT goal_scored) = 2
)
ORDER BY Team;
  ################################################################################3        
