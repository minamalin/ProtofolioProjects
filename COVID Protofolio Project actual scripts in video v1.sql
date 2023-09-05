
SELECT *
FROM ProtfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
order by 3,4


--Total cases vs total deats
-- Shows the liklihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths ,(cast(total_deaths as float)/cast(total_cases as float))*100 AS death_Percentage
FROM ProtfolioProject..CovidDeaths$
WHERE location LIKE '%Saudi%' 
AND continent IS NOT NULL
ORDER BY 1,2;
 

 -- Looking at the total cases vs population
 -- Shows what percentage of poulation got Covid

SELECT location, date, population,  total_cases,(total_cases/population)*100 AS PrecentPopulationInfected
FROM ProtfolioProject..CovidDeaths$
WHERE location LIKE '%Saudi%'
AND continent IS NOT NULL
ORDER BY 1,2;


-- Country with the highest infection rate compared to population 

SELECT location, population,  MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PrecentPopulationInfected
FROM ProtfolioProject..CovidDeaths$
-- WHERE location LIKE '%Saudi%'
WHERE continent IS NOT NULL
GROUP BY population, location
ORDER BY PrecentPopulationInfected desc

-- Let's break things down by continenet 


-- Countries with the highest death count per population 

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM ProtfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc


-- Showing the continent with the highest death count
 
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM ProtfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

 -- Global numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths as INT)) / SUM(new_cases) *100 as DeathPercentage
FROM ProtfolioProject..CovidDeaths$ 
WHERE continent IS NOT NULL 
AND new_cases !=0 
AND new_deaths != 0
GROUP BY date
ORDER BY 1,2;

-- More global numbers
SELECT SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS int)) AS total_new_deaths, SUM(CAST(new_deaths as INT)) / SUM(new_cases) *100 as DeathPercentage
FROM ProtfolioProject..CovidDeaths$ 
WHERE continent IS NOT NULL 
AND new_cases !=0 
AND new_deaths != 0
ORDER BY 1,2;



 --Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM ProtfolioProject..CovidVaccination$ vac
JOIN ProtfolioProject..CovidDeaths$ dea
ON vac.location = dea.location
AND vac.date = dea.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

-- Using window function to add up the vaccination numbers

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100 AS
FROM ProtfolioProject..CovidVaccination$ vac 
JOIN ProtfolioProject..CovidDeaths$ dea
ON vac.location = dea.location
AND vac.date = dea.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3


-- Use CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) 
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100 AS
FROM ProtfolioProject..CovidVaccination$ vac 
JOIN ProtfolioProject..CovidDeaths$ dea
ON vac.location = dea.location
AND vac.date = dea.date
WHERE dea.continent IS NOT NULL )

SELECT *, (RollingPeopleVaccinated/ population)*100
FROM PopvsVac


-- TEMP TABLE
DROP TABLE if exists #PercentPoulationVaccinated
CREATE TABLE #PercentPoulationVaccinated(
Continent nchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPoulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM ProtfolioProject..CovidVaccination$ vac 
JOIN ProtfolioProject..CovidDeaths$ dea
ON vac.location = dea.location
AND vac.date = dea.date
WHERE dea.continent IS NOT NULL 

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPoulationVaccinated



-- Creating view to store data for later visualizations

create view PercentPoulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100 AS
FROM ProtfolioProject..CovidVaccination$ vac 
JOIN ProtfolioProject..CovidDeaths$ dea
ON vac.location = dea.location
AND vac.date = dea.date
WHERE dea.continent IS NOT NULL
--order by 2,3


