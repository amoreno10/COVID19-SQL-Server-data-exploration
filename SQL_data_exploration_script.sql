/*

DATA EXPLORATION USING SQL SERVER

Data:
- CovidDeaths.xlsx
- CovidVaccinations.xlsx

*/

-- General view from both tables
SELECT TOP 50 *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT TOP 50 * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--------------------------------------------------------------------------
-- Select the data that will be using
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at total cases vs total deaths
-- Likelihood of dying if getting COVID-19 in my country (EL Salvador)
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%salvador%'
ORDER BY 1,2

-- Looking at total cases vs population
SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,2) AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at max percentage ratio of population infected in each country
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(ROUND((total_cases/population)*100,2)) AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC 

-- Looking at the highest death count in each country
SELECT location, MAX(CAST(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY 2 DESC

-- Looking at the highest death count in each continent
SELECT continent, MAX(CAST(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY 2 DESC

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1

-- Looking at total population vs total vaccinations
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
INNER JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2

-- Using CTE to create the rolling ratio of people vaccinated in a country
WITH PopvsVac (Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) AS (
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2
)
SELECT *, ROUND((RollingPeopleVaccinated/Population)*100,2) as PercentagePeopleVaccinated
FROM PopvsVac

-- Create View of People Vaccinated throughout time to visualize later
CREATE VIEW PercentagePeopleVaccinated AS
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PortfolioProject..PercentagePeopleVaccinated
