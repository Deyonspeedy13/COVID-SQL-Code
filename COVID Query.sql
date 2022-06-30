--Selecting Data that we will be using 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY location, date

--Comparing Total cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percent
FROM Covid..Covid_Deaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states%'
ORDER BY location, date DESC

--Comparing Total Cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Population_Infected
FROM Covid..Covid_Deaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states%'
ORDER BY location, date DESC

--Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS Largest_Infection_Count, 
MAX((total_cases/population)*100) AS Percent_Pop_Infected
FROM Covid..Covid_Deaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states'
GROUP BY location, population
ORDER BY Percent_Pop_Infected DESC

--Countries with highest deaths per population
SELECT location, population, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count,
MAX((total_deaths/population)*100) AS Death_per_pop
FROM Covid..Covid_Deaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY Total_Death_Count DESC

-- Total Deaths per continent
SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM Covid_Deaths
WHERE continent IS NULL AND location != 'World' AND location  NOT LIKE '%income%'
GROUP BY location
ORDER BY Total_Death_Count DESC

--Global Numbers
SELECT SUM(new_cases) AS total_global_cases, SUM(CAST(new_deaths AS INT)) AS total_global_deaths,
(SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) *100 AS Death_Percent
FROM Covid_Deaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states%'
--GROUP BY date
ORDER BY 1,2 

--Global Numbers per day
SELECT date,SUM(new_cases) AS total_global_cases, SUM(CAST(new_deaths AS INT)) AS total_global_deaths,
(SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) *100 AS Death_Percent
FROM Covid_Deaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states%'
GROUP BY date
ORDER BY 1,2

--Total population vs vaccinations by using a CTE
WITH Pop_vs_Vac (Continent, location, date, population, new_vaccinations, Rolling_People_Vaxxed) AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location
ORDER BY dea.location, dea.date) as Rolling_People_Vaxxed
FROM Covid_Deaths dea
INNER JOIN Covid_Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (Rolling_People_Vaxxed/population)*100
FROM Pop_vs_Vac


--Creating a view for visualization

CREATE VIEW Global_Vaccination
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location
ORDER BY dea.location, dea.date) as Rolling_People_Vaxxed
FROM Covid_Deaths dea
INNER JOIN Covid_Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM Global_Vaccination


--USING THESE QUERIES FOR VISUALIZATIONS 
--Global Death Count per continent 
SELECT location, SUM(CAST(new_deaths AS INT)) AS Total_Deaths
FROM Covid_Deaths
--WHERE location LIKE '%states%'
WHERE continent IS NULL AND 
location NOT IN ('World', 'European Union', 'International') AND
location NOT LIKE '%income%'
GROUP BY location
ORDER BY Total_Deaths DESC

--Global Numbers Total Cases, Deaths, and Death rate
SELECT SUM(new_cases) AS total_global_cases, SUM(CAST(new_deaths AS INT)) AS total_global_deaths,
(SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) *100 AS Death_Percent
FROM Covid_Deaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states%'
--GROUP BY date
ORDER BY 1,2 


--Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS Largest_Infection_Count, 
MAX((total_cases/population)*100) AS Percent_Pop_Infected
FROM Covid..Covid_Deaths
--WHERE continent IS NOT NULL
--WHERE location LIKE '%states'
GROUP BY location, population
ORDER BY Percent_Pop_Infected DESC

--Countries with highest infection rate compared to population
SELECT location, population, date, MAX(total_cases) AS Largest_Infection_Count, 
MAX((total_cases/population)*100) AS Percent_Pop_Infected
FROM Covid..Covid_Deaths
--WHERE continent IS NOT NULL
--WHERE location LIKE '%states'
GROUP BY location, population, date
ORDER BY Percent_Pop_Infected DESC