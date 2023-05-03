SELECT *
FROM [MY Portfolio]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4
--SELECT *
--FROM [MY Portfolio]..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to using
SELECT Location, date, total_cases, new_cases, total_deaths, population_density
FROM [MY Portfolio]..CovidDeaths
ORDER BY 1,2
--looking at total cases vs total deaths
-- show likelihood of dying if you contract covid in your country
SELECT 
    Location,  date,  CAST(total_cases AS float) AS total_cases_float, CAST(total_deaths AS float) AS total_deaths_float, (CAST(total_deaths AS float) / NULLIF(CAST(total_cases AS float), 0)) * 100 AS DeathPercentage
FROM [MY Portfolio]..CovidDeathsNew
WHERE LOCATION LIKE '%Vietnam%'
ORDER BY 1,2

--looking at total cases vs population
SELECT Location, date, CAST(total_cases AS float) AS total_cases_float, CAST(population AS float) As population, (CAST(total_cases AS float) / NULLIF(CAST(population AS float), 0)) * 100 AS CasePerPopulation
FROM [MY Portfolio]..CovidDeathsNew
WHERE LOCATION LIKE '%Vietnam%'
ORDER BY 1,2
-- looking at country with highest infection rate compare to population
SELECT Location, MAX(CAST(total_cases AS float)) AS highestInfectionCount, CAST(population AS float) As population, MAX((CAST(total_cases AS float) / NULLIF(CAST(population AS float), 0))) * 100 AS PercentPopulationInfected
FROM [MY Portfolio]..CovidDeathsNew
--WHERE LOCATION LIKE '%Vietnam%'
GROUP BY location,population
ORDER BY PercentPopulationInfected desc
-- showing country with the highest death count per population
SELECT Location, MAX(CAST(total_deaths as bigint)) as TotalDeathCount
FROM [MY Portfolio]..CovidDeathsNew
-- if continent is null the result can be the TotalDeathCount of the whole continent or the count of other criterias
WHERE continent is not null
GROUP BY location
ORDER BY totalDeathCount DESC

-- LETS BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(CAST(total_deaths as bigint)) as TotalDeathCount
FROM [MY Portfolio]..CovidDeathsNew
-- if continent is null the result can be the TotalDeathCount of the whole continent or the count of other criterias
WHERE continent is not null
GROUP BY continent
ORDER BY totalDeathCount DESC

-- showing the continent with the highest death count per population
SELECT continent, MAX(CAST(total_deaths as bigint)) as TotalDeathCount
FROM [MY Portfolio]..CovidDeathsNew
-- if continent is null the result can be the TotalDeathCount of the whole continent or the count of other criterias
WHERE continent is not null
GROUP BY continent
ORDER BY totalDeathCount DESC

-- global numbers
SELECT  SUM(CAST(new_cases AS float)) AS new_cases_float, SUM(CAST(new_deaths AS float)) AS new_deaths_float, (SUM(CAST(new_deaths AS float)) / NULLIF(SUM(CAST(new_cases AS float)), 0)) * 100 AS DeathPercentage
FROM [MY Portfolio]..CovidDeathsNew 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;
-- ANOTHER WAY TO CALCULATE GLOBAL NUMBERS
SELECT 
    'Global' AS Location,
    NULL AS date,  
    SUM(CAST(new_cases AS float)) AS new_cases_float, 
    SUM(CAST(new_deaths AS float)) AS new_deaths_float, 
    (SUM(CAST(new_deaths AS float)) / NULLIF(SUM(CAST(new_cases AS float)), 0)) * 100 AS DeathPercentage
FROM [MY Portfolio]..CovidDeathsNew 
WHERE continent IS NOT NULL;


-- IT'S TIME FOR THE SECOND TABLE( VACINATIONS)

SELECT *
FROM [MY Portfolio]..CovidDeathsNew dea
JOIN [MY Portfolio]..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
   --looking at total population vs vacination( how many people in the world got vacinated)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- we cant use a column we just created to devided by the population=> create temp-table
--,(RollingPeopleVaccinated/population)*100
FROM [MY Portfolio]..CovidDeathsNew dea
JOIN [MY Portfolio]..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE  dea.continent is not null
ORDER BY 1,2

--USE CTE
WITH PopvsVac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- we cant use a column we just created to devided by the population=> create temp-table
--,(RollingPeopleVaccinated/population)*100
FROM [MY Portfolio]..CovidDeathsNew dea
JOIN [MY Portfolio]..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE  dea.continent is not null
--ORDER BY 1,2
)
SELECT *,(rollingpeoplevaccinated/population)*100
FROM PopvsVac
--WHERE location like '%vietnam%'

--TEMP TABLE
--DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- we cant use a column we just created to devided by the population=> create temp-table
--,(RollingPeopleVaccinated/population)*100
FROM [MY Portfolio]..CovidDeathsNew dea
JOIN [MY Portfolio]..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE  dea.continent is not null
--ORDER BY 1,2


SELECT *,(rollingpeoplevaccinated/population)*100
FROM #PercentPopulationVaccinated
--WHERE location like '%vietnam%'

--creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- we cant use a column we just created to devided by the population=> create temp-table
--,(RollingPeopleVaccinated/population)*100
FROM [MY Portfolio]..CovidDeathsNew dea
JOIN [MY Portfolio]..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE  dea.continent is not null
--ORDER BY 1,2

SELECT *
FROM PercentPopulationVaccinated


