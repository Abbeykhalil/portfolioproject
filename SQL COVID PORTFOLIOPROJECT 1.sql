
select *
from [Covid19 Portfolio Project1]..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from [Covid19 Portfolio Project1]..['CovidVaccination$']
--order by 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING

select Location, date, total_cases, new_cases, total_deaths, population
from [Covid19 Portfolio Project1]..CovidDeaths$
where continent is not null
order by 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--Shows the likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Covid19 Portfolio Project1]..CovidDeaths$
where location like '%nigeria%'
and where continent is not null
order by 1,2

--LOOKING AT TOTAL CASES VS POPULATION
--Shows what percentage of population got covid

select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from [Covid19 Portfolio Project1]..CovidDeaths$
--where location like '%nigeria%'
order by 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from [Covid19 Portfolio Project1]..CovidDeaths$
--where location like '%nigeria%'
Group by Location, population
order by PercentPopulationInfected desc

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Covid19 Portfolio Project1]..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Covid19 Portfolio Project1]..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--THE CONTINENT WITH THE HIGHEST DEATH COUNT

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Covid19 Portfolio Project1]..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
  (new_cases)*100 as DeathPercentage
from [Covid19 Portfolio Project1]..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
Group by date
order by 1,2


select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
  (new_cases)*100 as DeathPercentage
from [Covid19 Portfolio Project1]..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
--Group by date
order by 1,2

--LOOKNG AT TOTAL POPULATION VS VACCINATIONS

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
  as Rollingpeoplevaccinated
--,    (Rollingpeoplevaccinated/population)*100
from [Covid19 Portfolio Project1]..CovidDeaths$ dea
join [Covid19 Portfolio Project1]..['CovidVaccination$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with popvsVac (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
  as Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
from [Covid19 Portfolio Project1]..CovidDeaths$ dea
join [Covid19 Portfolio Project1]..['CovidVaccination$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Rollingpeoplevaccinated/population)*100
from popvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
  as Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
from [Covid19 Portfolio Project1]..CovidDeaths$ dea
join [Covid19 Portfolio Project1]..['CovidVaccination$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (Rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated




--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATON


Create View PopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
  as Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
from [Covid19 Portfolio Project1]..CovidDeaths$ dea
join [Covid19 Portfolio Project1]..['CovidVaccination$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PopulationVaccinated
