Select * from
PortfolioProject.dbo.CovidDeaths
where continent is NOT NULL 
order by 3,4;

Select * from
PortfolioProject.dbo.CovidVaccination
where continent is NOT NULL 
order by 3,4;

---Select data that we are going to be using
Select location, date, total_cases,new_cases,total_deaths, population
from PortfolioProject.dbo.CovidDeaths
where continent is NOT NULL 
order by 1,2;

-- Looking for total cases vs total death (%)
-- Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location='India' and  continent is NOT NULL 
order by 1,2; 

---- Looking at total cases vs population
---Shows what percentage of population got covid

Select location,date,population,total_cases, (total_Cases/population)*100 AS TotalDeathPercentage
from PortfolioProject..CovidDeaths
where location='India' and  continent is NOT NULL 
order by 1,2;

---- Looking at countries with highest infection rate compared to population

Select location,population,MAX(total_cases) AS HighestInfectionRate, MAX((total_Cases/population))*100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is NOT NULL 
Group by location, population
order by PercentPopulationInfected desc;

-- Showing countries with the Highest Death Count per Population

Select location,population,MAX(cast(total_deaths as int)) AS HighestDeathRate, MAX((total_deaths/population))*100 AS DeathPercentPopulation
from PortfolioProject..CovidDeaths
where continent is NOT NULL 
Group by location, population
order by DeathPercentPopulation desc;

-----Lets break it down per CONTINENT


Select location ,MAX(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is NULL 
Group by location
order by TotalDeathCount desc;

-- Showing continent with the highest death count per population

Select continent,population,MAX(cast(total_deaths as int)) AS HighestDeathRate, MAX((total_deaths/population))*100 AS DeathPercentPopulation
from PortfolioProject..CovidDeaths
where continent is NOT NULL 
Group by continent, population
order by DeathPercentPopulation desc;

--GLOBAL NUMBERS
-- Per day the total cases, total deaths and the deathpercentage
Select date, SUM(new_cases) AS total_Cases, SUM(CAST(new_deaths as int)) AS total_deaths , SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where continent is  NOT NULL 
group by date
order by 1,2;

--GLOBAL NUMBERS
-- Overall total of the total cases, total deaths and the deathpercentage
Select SUM(new_cases) AS total_Cases, SUM(CAST(new_deaths as int)) AS total_deaths , SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where continent is  NOT NULL 
order by 1,2;

-- JOIN the two tables CovidDeaths and CovidVaccination
Select *
from PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccination as vac
ON dea.location=vac.location AND dea.date=vac.date

-----Looking at total population VS vaccination

Select dea.continent,dea.date, dea.location, dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION by dea.location, dea.date) 
AS RollingPeopleVaccinated
,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccination as vac
ON dea.location=vac.location 
AND dea.date=vac.date
where dea.continent is  NOT NULL 
order by 2,3


--- USE CTE ( because you cannot use RollingPeopleVaccinated as soon as you create it)

WITH PopvsVac (Continent, Location, Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(Select dea.continent,dea.date, dea.location, dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION by dea.location, dea.date) 
AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccination as vac
ON dea.location=vac.location 
AND dea.date=vac.date
where dea.continent is  NOT NULL 
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
from PopvsVac


--- TEMP Table
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
date datetime,
location nvarchar(255),
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.date, dea.location, dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION by dea.location, dea.date) 
AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccination as vac
ON dea.location=vac.location 
AND dea.date=vac.date
where dea.continent is  NOT NULL 
--order by 2,3
Select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

----Creating view to store data for later visualizations

Create view PercentPopulationVaccinated AS
Select dea.continent,dea.date, dea.location, dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION by dea.location, dea.date) 
AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccination as vac
ON dea.location=vac.location 
AND dea.date=vac.date
where dea.continent is  NOT NULL 
--order by 2,3