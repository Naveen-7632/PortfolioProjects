select *
from [Portfolio Project]..CovidDeaths
order by 3,4

select *
from [Portfolio Project]..CovidVaccinations
order by 3,4

--select the data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in india

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location = 'India'
order by 2

alter table [Portfolio Project]..CovidDeaths
alter column total_cases float(24);

alter table [Portfolio Project]..CovidDeaths
alter column total_deaths float(24);


--looking at total_cases vs population
--shows the percentage of population who falls for covid
select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
from [Portfolio Project]..CovidDeaths
where location = 'India'
order by 2

--looking at the country with higher infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as CovidPercentage
from [Portfolio Project]..CovidDeaths
Group by location, population
order by CovidPercentage desc

-- Showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not null and new_cases <> 0
Group by date
order by 1,2

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not null and new_cases <> 0
--Group by date
order by 1,2

-- Looking at Total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- TEMP Table
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 