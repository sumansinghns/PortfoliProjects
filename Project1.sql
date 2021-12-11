SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,
         4;


SELECT *
FROM PortfolioProject.dbo.CovidVaccination
WHERE continent IS NOT NULL
ORDER BY 3,
         4;

---Select data that we are going to be using

SELECT LOCATION, date, total_cases,
                       new_cases,
                       total_deaths,
                       population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,
         2;

-- Looking for total cases vs total death (%)
-- Shows the likelihood of dying if you contract covid in your country

SELECT LOCATION, date, total_cases,
                       total_deaths,
                       (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE LOCATION='India'
  AND continent IS NOT NULL
ORDER BY 1,
         2;

---- Looking at total cases vs population
---Shows what percentage of population got covid

SELECT LOCATION,date,population,
                     total_cases,
                     (total_Cases/population)*100 AS TotalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE LOCATION='India'
  AND continent IS NOT NULL
ORDER BY 1,
         2;

---- Looking at countries with highest infection rate compared to population

SELECT LOCATION,
       population,
       MAX(total_cases) AS HighestInfectionRate,
       MAX((total_Cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY LOCATION,
         population
ORDER BY PercentPopulationInfected DESC;

-- Showing countries with the Highest Death Count per Population

SELECT LOCATION,
       population,
       MAX(cast(total_deaths AS int)) AS HighestDeathRate,
       MAX((total_deaths/population))*100 AS DeathPercentPopulation
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY LOCATION,
         population
ORDER BY DeathPercentPopulation DESC;

-----Lets break it down per CONTINENT

SELECT LOCATION,
       MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY LOCATION
ORDER BY TotalDeathCount DESC;

-- Showing continent with the highest death count per population

SELECT continent,
       population,
       MAX(cast(total_deaths AS int)) AS HighestDeathRate,
       MAX((total_deaths/population))*100 AS DeathPercentPopulation
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent,
         population
ORDER BY DeathPercentPopulation DESC;

--GLOBAL NUMBERS
-- Per day the total cases, total deaths and the deathpercentage

SELECT date, SUM(new_cases) AS total_Cases,
             SUM(CAST(new_deaths AS int)) AS total_deaths,
             SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,
         2;

--GLOBAL NUMBERS
-- Overall total of the total cases, total deaths and the deathpercentage

SELECT SUM(new_cases) AS total_Cases,
       SUM(CAST(new_deaths AS int)) AS total_deaths,
       SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,
         2;

-- JOIN the two tables CovidDeaths and CovidVaccination

SELECT *
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccination AS vac ON dea.location=vac.location
AND dea.date=vac.date -----Looking at total population VS vaccination

SELECT dea.continent,
       dea.date,
       dea.location,
       dea.population,
       vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location,
                                                                    dea.date) AS RollingPeopleVaccinated,
                                                      (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccination AS vac ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,
         3 --- USE CTE ( because you cannot use RollingPeopleVaccinated as soon as you create it)
 WITH PopvsVac (Continent,
                LOCATION, Date,Population,
                               new_vaccinations,
                               RollingPeopleVaccinated) AS
  (SELECT dea.continent,
          dea.date,
          dea.location,
          dea.population,
          vac.new_vaccinations,
          SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location,
                                                                       dea.date) AS RollingPeopleVaccinated --,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
   JOIN PortfolioProject..CovidVaccination AS vac ON dea.location=vac.location
   AND dea.date=vac.date
   WHERE dea.continent IS NOT NULL --order by 2,3
)
SELECT *,
       (RollingPeopleVaccinated/population)*100
FROM PopvsVac --- TEMP Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (Continent nvarchar(255), date datetime,
                                                                         LOCATION nvarchar(255),
                                                                                  population numeric, new_vaccinations numeric, RollingPeopleVaccinated numeric)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,
       dea.date,
       dea.location,
       dea.population,
       vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location,
                                                                    dea.date) AS RollingPeopleVaccinated --,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccination AS vac ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL --order by 2,3

  SELECT *,
         (RollingPeopleVaccinated/population)*100
  FROM #PercentPopulationVaccinated ----Creating view to store data for later visualizations

  CREATE VIEW PercentPopulationVaccinated AS
  SELECT dea.continent,
         dea.date,
         dea.location,
         dea.population,
         vac.new_vaccinations,
         SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location,
                                                                      dea.date) AS RollingPeopleVaccinated --,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
  JOIN PortfolioProject..CovidVaccination AS vac ON dea.location=vac.location
  AND dea.date=vac.date WHERE dea.continent IS NOT NULL --order by 2,3