/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


SELECT
	*
 FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--Selecting the data to be used
SELECT
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
 FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Showing the likelihood of dying after contracting Covid-19 in Poland
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS DeathPercentage
 FROM PortfolioProject..CovidDeaths
WHERE location = 'Poland' 
AND continent IS NOT NULL
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what % of population got Covid
SELECT
	location,
	date,
	total_cases,
	population,
	(total_cases/population)*100 AS InfectedPopulationPercentage
 FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


--Looking at countries with highest Infection Rate : Population ratio
SELECT
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population))*100 AS InfectedPopulationPercentage
 FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC

 
 --Looking at countries with highest death count per population
SELECT
	location,
	MAX(CAST(total_deaths AS int)) AS TotalDeathCount
 FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC


--BREAKING THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population
SELECT
	continent,
	MAX(CAST(total_deaths AS int)) AS TotalDeathCount
 FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

SELECT
	location,
	MAX(CAST(total_deaths AS int)) AS TotalDeathCount
 FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC


--GLOBAL NUMBERS
SELECT
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS int)) AS total_deaths,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
 FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
ORDER BY 1,2


--Total Population vs Vaccinations
--% of Population that has recieved at least one Covid Vaccine
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) 
		OVER (Partition by dea.Location 
			ORDER BY dea.location, CAST(dea.Date AS datetime)) AS RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated) AS
	(
	SELECT 
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS bigint)) 
			OVER (Partition by dea.Location 
				ORDER BY dea.location, CAST(dea.Date AS datetime)) AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths AS dea
	JOIN PortfolioProject..CovidVaccinations AS vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	)
SELECT 
	*,
	(RollingPeopleVaccinated/population)*100 AS PercPopVacc
 FROM PopvsVac


--Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
	(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) 
		OVER (Partition by dea.Location 
			ORDER BY dea.location, CAST(dea.Date AS datetime)) AS RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT 
	*,
	(RollingPeopleVaccinated/population)*100 AS PercPopVacc
 FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations
USE PortfolioProject;
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) 
		OVER (Partition by dea.Location 
			ORDER BY dea.location, CAST(dea.Date AS datetime)) AS RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


USE PortfolioProject;
GO
CREATE VIEW DeathPercPoland AS
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS DeathPercentage
 FROM PortfolioProject..CovidDeaths
WHERE location = 'Poland' 
AND continent IS NOT NULL


USE PortfolioProject;
GO
CREATE VIEW GlobalDeathPerc AS
SELECT
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS int)) AS total_deaths,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
 FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL


USE PortfolioProject;
GO
CREATE VIEW VaccPopPerc AS
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) 
		OVER (Partition by dea.Location 
			ORDER BY dea.location, CAST(dea.Date AS datetime)) AS RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL