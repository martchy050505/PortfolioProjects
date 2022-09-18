Select *
From Portfolio_Project_1_Covid19..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From Portfolio_Project_1_Covid19..CovidVaccinations
--order by 3,4

-- Select the data we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project_1_Covid19..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths
-- Shows probability of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project_1_Covid19..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From Portfolio_Project_1_Covid19..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From Portfolio_Project_1_Covid19..CovidDeaths
Group by Location, Population
order by PercentagePopulationInfected

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio_Project_1_Covid19..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Showing continents with highest death count per population 

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio_Project_1_Covid19..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS - TOTAL DEATHS TOTAL CASES

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathsPercentage 
From Portfolio_Project_1_Covid19..CovidDeaths
where continent is not null
--Group by date
order by 1,2

-- Looking at Total Population vs Total Vaccinations

-- USE CTE

With PopulationVsVaccination (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio_Project_1_Covid19..CovidDeaths dea
Join Portfolio_Project_1_Covid19..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopulationVsVaccination


-- TEMP TABLE 

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio_Project_1_Covid19..CovidDeaths dea
Join Portfolio_Project_1_Covid19..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for VISUALISATIONS

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio_Project_1_Covid19..CovidDeaths dea
Join Portfolio_Project_1_Covid19..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select*
From PercentPopulationVaccinated