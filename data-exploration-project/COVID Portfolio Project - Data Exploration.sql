/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Loocking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
FROM CovidDeaths
WHERE LOCATION = 'Philippines'
ORDER BY 1,2

-- Looking at Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)*100 PercentPopulationInfected
FROM CovidDeaths
WHERE LOCATION = 'Philippines'
ORDER BY 1,2

-- Locing at Countries Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) HighestInfectionCount, MAX((total_cases/population)*100) PercentPopulationInfected
FROM CovidDeaths
--WHERE LOCATION = 'Philippines'
GROUP BY location, population
ORDER BY 4 DESC

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(total_deaths) TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC

-- Break things down by continent

-- Showing continents with the highest death count per population

SELECT Continent, MAX(total_deaths) TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY Continent
ORDER BY 2 DESC

-- Global numbers

SELECT SUM(new_cases) TotalNewCases, SUM(new_deaths) TotalNewDeaths, (SUM(new_deaths)/SUM(new_cases))*100 DeathPercentage
FROM CovidDeaths
WHERE continent is not null
AND new_cases != 0
--GROUP BY date
--ORDER BY 3 desc

-- Looking at Total Popualtion vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated, 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Use CTE

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

-- Temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255)
,Location nvarchar(255)
,Date datetime
,Population numeric
,New_Vaccination numeric
,RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualziations

CREATE VIEW PercentPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPeopleVaccinated

-- Global Numbers View
CREATE VIEW CpvodGlobalNumbers AS
SELECT SUM(new_cases) TotalNewCases, SUM(new_deaths) TotalNewDeaths, (SUM(new_deaths)/SUM(new_cases))*100 DeathPercentage
FROM CovidDeaths
WHERE continent is not null
AND new_cases != 0

-- Infection Rate
CREATE VIEW InfectionRate AS
SELECT Location, Population, MAX(total_cases) HighestInfectionCount, MAX((total_cases/population)*100) PercentPopulationInfected
FROM CovidDeaths
--WHERE LOCATION = 'Philippines'
GROUP BY location, population


-- Death Percentage
CREATE VIEW DeathPercentage AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
FROM CovidDeaths

-- Infected Percentage
CREATE VIEW InfectedPercentage AS
SELECT location, date, total_cases, population, (total_cases/population)*100 PercentPopulationInfected
FROM CovidDeaths