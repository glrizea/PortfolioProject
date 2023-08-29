-- Covid 19 data exploration 
-- skills used: joins, CTE's, temp tables, windows functions, aggregate functions, creating views, converting data types


-- quering the covid deaths data


SELECT 
	*
FROM 
	portfolio_project_01.dbo.covid_deaths
WHERE 
	continent != ' '
ORDER BY location, date


-- converting data type from varchar to date


ALTER TABLE portfolio_project_01.dbo.covid_deaths
ALTER COLUMN date DATE NULL


-- selecting the data used for the project

SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM 
	portfolio_project_01.dbo.covid_deaths
WHERE 
	continent != ' '
ORDER BY location, date


-- comparing total cases vs total deaths
-- calculating the probability to die of Covid-19 in my home country


SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	ROUND(total_deaths/NULLIF(total_cases,0)*100,3) AS death_percentage
FROM 
	portfolio_project_01.dbo.covid_deaths
WHERE
	location LIKE 'Romania'
ORDER BY location, date


-- converting data type from varchar to float


ALTER TABLE portfolio_project_01.dbo.covid_deaths
ALTER COLUMN total_cases FLOAT NULL

ALTER TABLE portfolio_project_01.dbo.covid_deaths
ALTER COLUMN total_deaths FLOAT NULL


-- comparing total cases vs population
-- calculating the percent of infected population in my country


SELECT 
	location, 
	date, 
	population, 
	total_cases, 
	ROUND((total_cases/population)*100,3) AS infected_population_percent
FROM 
	portfolio_project_01.dbo.covid_deaths
WHERE 
	location LIKE 'Romania'
ORDER BY location, date


-- clasifing the countries with the highest infected population percent


SELECT 
	location, 
	population, 
	MAX(total_cases) AS highest_infections_rate,  
	MAX(total_cases/population)*100 AS infected_population_percent
FROM 
	portfolio_project_01.dbo.covid_deaths
WHERE 
	location != ' '
GROUP BY location, population
ORDER BY infected_population_percent DESC


-- calculating the infected population rate for my home country


SELECT 
	location, 
	population, 
	MAX(total_cases) AS highest_infections_rate,  
	MAX((total_cases/population))*100 AS infected_population_percent
FROM 
	portfolio_project_01.dbo.covid_deaths
WHERE 
	location LIKE 'Romania'
GROUP BY location, population


-- sorting countries by the highest number of deaths caused by Covid-19


SELECT 
	location, 
	MAX(total_deaths) AS total_deaths_number
FROM 
	portfolio_project_01.dbo.covid_deaths
WHERE 
	continent != ' '
GROUP BY location
ORDER BY total_deaths_number DESC


-- breaking things down by continent
-- ordering continents by the highest death count per population


SELECT 
	location, 
	MAX(total_deaths) as total_deaths_count
FROM 
	portfolio_project_01.dbo.covid_deaths
WHERE 
	continent = ' ' 
GROUP BY location
ORDER BY total_deaths_count DESC


-- calculating the global death percentage
-- converting data type from varchar to int using the 'cast' function


SELECT 
	SUM(CAST(new_cases AS int)) AS total_cases, 
	SUM(CAST(new_deaths AS int)) AS total_deaths, 
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM 
	portfolio_project_01.dbo.covid_deaths
WHERE 
	continent != ' ' 
ORDER BY total_cases, total_deaths


-- quering the data from the second table


SELECT 
	*
FROM 
	portfolio_project_01.dbo.covid_vaccinations
ORDER BY 
	location, date


-- converting data type from varchar to date type and float type


ALTER TABLE portfolio_project_01.dbo.covid_vaccinations
ALTER COLUMN date DATE NULL

ALTER TABLE portfolio_project_01.dbo.covid_vaccinations
ALTER COLUMN new_vaccinations float NULL


-- calculating total vaccinated people


SELECT 
	CD.continent, 
	CD.location, 
	CD.date, 
	CD.population, 
	CV.new_vaccinations, 
	SUM(CV.new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.Date) AS total_vaccinated_people
FROM 
	portfolio_project_01.dbo.covid_deaths CD
	JOIN portfolio_project_01.dbo.covid_vaccinations CV ON CD.location = CV.location AND CD.date = CV.date
WHERE 
	CD.continent != ' '
ORDER BY location, date


-- converting data type from varchar to float type


ALTER TABLE portfolio_project_01.dbo.covid_vaccinations
ALTER COLUMN people_vaccinated_per_hundred FLOAT NULL


-- clasifing the countries from Europe with the highest vaccinated population percent


SELECT 
	CD.location, 
	CD.population, 
	MAX(people_vaccinated_per_hundred) AS vaccinated_population_percent
FROM 
	portfolio_project_01.dbo.covid_deaths CD
	JOIN portfolio_project_01.dbo.covid_vaccinations CV ON CD.location = CV.location AND CD.date = CV.date
WHERE 
	CD.location != ' ' AND CD.continent = 'Europe'
GROUP BY CD.location, CD.population
ORDER BY vaccinated_population_percent DESC


-- Using CTE to perform calculation of vaccinated population percent


WITH 
	population_vs_vaccinations 
(
	continent, 
	location, 
	date, 
	population, 
	new_vaccinations, 
	total_vaccinated_people)
AS
(
SELECT 
	CD.continent, 
	CD.location, 
	CD.date, 
	CD.population, 
	CV.new_vaccinations, 
	SUM(CV.new_vaccinations) OVER (PARTITION BY CD.Location ORDER BY CD.location, CD.Date) AS total_vaccinated_people
FROM 
	portfolio_project_01.dbo.covid_deaths CD
	JOIN portfolio_project_01.dbo.covid_vaccinations CV ON CD.location = CV.location AND CD.date = CV.date
WHERE 
	CD.continent != ' '
	)
	SELECT 
		*, 
		(total_vaccinated_people/population)*100 AS vaccination_percent
	FROM 
		population_vs_vaccinations



-- Using Temp Table to perform Calculation on Partition By in previous query


DROP TABLE IF EXISTS #vaccinated_population_percent
CREATE TABLE #vaccinated_population_percent
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vaccinated_people numeric
)

INSERT INTO #vaccinated_population_percent
SELECT 
	CD.continent, 
	CD.location, 
	CD.date, 
	CD.population, 
	CV.new_vaccinations, 
	SUM(CV.new_vaccinations) OVER (PARTITION BY CD.Location ORDER BY CD.location, CD.Date) as vaccinated_people
FROM portfolio_project_01.dbo.covid_deaths CD
	JOIN portfolio_project_01.dbo.covid_vaccinations CV ON CD.location = CV.location AND CD.date = CV.date
WHERE CV.continent != ' '

SELECT 
	*, 
	(vaccinated_people/Population)*100 AS vaccinated_percent
FROM 
	#vaccinated_population_percent


-- Creating View to store data for later visualizations


CREATE OR ALTER VIEW v_vaccinated_population AS
SELECT 
	CD.continent, 
	CD.location, 
	CD.date, 
	CD.population, 
	CV.new_vaccinations, 
	SUM(CV.new_vaccinations) OVER (PARTITION BY CD.Location ORDER BY CD.location, CD.Date) AS vaccinated_people
FROM portfolio_project_01.dbo.covid_deaths CD
	JOIN portfolio_project_01.dbo.covid_vaccinations CV ON CD.location = CV.location AND CD.date = CV.date
WHERE CD.continent != ' '


-- using the previous view to access the data regarding vaccinated people


SELECT
	* 
FROM
	v_vaccinated_population

