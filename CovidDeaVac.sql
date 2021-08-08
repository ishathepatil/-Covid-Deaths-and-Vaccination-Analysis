-- Covid Deaths
select * 
from CovidProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from CovidProject..CovidVaccinations
--order by 3,4


--exploring the covid deaths

select location, date, total_cases, new_cases, total_deaths, population
from CovidProject..CovidDeaths
order by 1,2 

-- total cases vs total deaths 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeaths
from CovidProject..CovidDeaths
--where location = 'India'
order by 1,2 
-- peak = 2.11%

--Total cases vs population

select location,population, MAX(total_cases) as HighiestInfected, MAX((total_cases/population)*100) as PercentageInfected 
from CovidProject..CovidDeaths
--where location = 'India'
--where continent is not null
group by population, location
order by HighiestInfected desc

-- Highiest Death count per population

select location, MAX(cast(total_deaths as int)) as  TotalDeathCount
from CovidProject..CovidDeaths
--where location = 'India'
where continent is not null
group by location
order by TotalDeathCount desc

--by continent

select location, MAX(cast(total_deaths as int)) as  TotalDeathCount
from CovidProject..CovidDeaths
--where location = 'India'
where continent is null
group by location
order by TotalDeathCount desc

-- Conitinents with highiest death count

select continent, MAX(cast(total_deaths as int)) as  TotalDeathCount
from CovidProject..CovidDeaths
--where location = 'India'
where continent is not null
group by continent
order by TotalDeathCount desc

-- global exploration

select  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentageDeaths
from CovidProject..CovidDeaths
--where location = 'India'
where continent is not null
group by date
order by 1,2 desc

-- total deaths and death percentage globally

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentageDeaths
from CovidProject..CovidDeaths
--where location = 'India'
where continent is not null
--group by date
order by 1,2 desc

--Covid Vaccinations 
--joining tables

select *
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

--totol population vs vaccinations

--using CTE

with PopVsVac (continent, location, date, population,new_vaccinations, PeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,
dea.date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location = 'India'
--order by 2,3
)
select *, (PeopleVaccinated /population)*100 as PercentageVaccinated
from PopVsVac

-- temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)


insert into  PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,
dea.date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location = 'India'
--order by 2,3

select *, (PeopleVaccinated /population)*100 as PercentageVaccinated
from PercentPopulationVaccinated

--creating view for visualization

create VIEW PercentVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,
dea.date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.location = 'India'
--order by 2,3

select *
from PercentVaccinated
