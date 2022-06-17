

SELECT * From CovidDeaths
order by 3,4

--SELECT * FROM CovidVaccinations
--ORDER BY 3, 4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
order by 1, 2


-- Total Cases Vs Total Deaths Cal

SELECT location, date, total_cases,  total_deaths, ( total_deaths/total_cases) * 100 AS DeathPercentage
From CovidDeaths
where location = 'United States'
order by 1, 2


--Total cases vs population ( calulating percentage of pop got covid)
SELECT location, date, total_cases,  population, ( total_cases/population) * 100 AS DeathPercentage
From CovidDeaths
where location = 'United States'
order by 1, 2

-- Countries with highest case compare to population 
SELECT location, max(total_cases) as HighestInfectionCount,  population, MaX(( total_cases/population)) * 100 AS Percentpopulation 
From CovidDeaths
--where location = 'United States'
Group by location, population
order by Percentpopulation desc

-- How many people in died in countries
SELECT location, max(cast(total_deaths as int)) as HighestDeathCount
From CovidDeaths
where continent is not null
Group by location
order by HighestDeathCount desc

-- By continents

SELECT continent, max(cast(total_deaths as int)) as HighestDeathCount
From CovidDeaths
where continent is not null
Group by continent
order by HighestDeathCount desc


--continents with highest death
select continent, MAX(cast(total_deaths as int)) as TotalDeath
From CovidDeaths
where continent is not null
group by continent
order by TotalDeath desc


-- global numbers

SELECT  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death,  sum(cast(new_deaths as int))/Sum(new_cases) * 100 AS DeathPercentage
From CovidDeaths
--where location = 'United States'
where continent is not null
--group by date
order by 1, 2

-- Toal population vs Vaccination 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, new_vaccinations)) OVER (Partition by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea 
join CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3

-- Use CTE

with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, new_vaccinations)) OVER (Partition by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea 
join CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population) * 100
from popvsvac


-- TEMP table

create table #PercentpopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, new_vaccinations)) OVER (Partition by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea 
join CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3



-- Creating view for vissulaization 

Create view  Covid_Deaths as
--continents with highest death
select continent, MAX(cast(total_deaths as int)) as TotalDeath
From CovidDeaths
where continent is not null
group by continent
