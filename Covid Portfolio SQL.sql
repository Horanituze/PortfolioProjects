/*
Global data on comfirmed covid-deaths from  Jan 01, 2020 until Jan 21, 2024
https://ourworldindata.org/covid-deaths
*/

select *
from PortfolioProject..CovidDeaths
order by 3, 4

select * 
from PortfolioProject..CovidVaccinations
order by 3, 4

-- Select data to be used 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths,
    round((cast(total_deaths as float)/total_cases)*100, 3) DeathPercentage
from PortfolioProject..CovidDeaths
where total_cases is not null --or total_deaths is not null
    and continent is not null
    and location like '%states%'
order by 1,2

-- looking at total cases and population
-- shows percentage of population got covid
select location, date, total_cases,population,
    round((cast(total_cases as float)/population)*100, 3) InfectionRate
from PortfolioProject..CovidDeaths
where total_cases is not null
    and continent is not null
     --and location like '%states%'
order by 1,2

-- countries with highest infection rate compared to population

select location, population, max(total_cases) HighestInfectionCount,
    round((cast(max(total_cases) as float)/population)*100, 3) InfectionRate
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 4 desc

-- showing countries with highest death count per population 

select location, population, max(total_deaths) TotalDeathCount,
    round((cast(max(total_deaths) as float)/population)*100, 3) DeathRate
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 3 desc

-- LET'S BREAK THINGS DOWN BY CONTINENT. 

-- Shwowing continents with the highest death count per population

select continent, max(total_deaths) TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc


-- GLOBAL NUMBERS

select  sum(new_cases) total_Cases, sum(new_deaths) total_deaths,
    round((cast(sum(new_deaths) as float)/sum(new_cases))*100, 3) DeathPercentage
from PortfolioProject..CovidDeaths
where  continent is not null
--group by date
order by 1


-- Looking at Total Population vs location
select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
    , sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.continent = vac.continent
    and dea.[location] = vac.[location]
    and dea.date = vac.date
where dea.continent is not null

-- CTE (Common Table Expression)

with PopvsVac as (
    select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
        , sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) RollingPeopleVaccinated
    from PortfolioProject..CovidDeaths dea
    join PortfolioProject..CovidVaccinations vac
    on dea.continent = vac.continent
        and dea.[location] = vac.[location]
        and dea.date = vac.date
    where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac
order by 2,3


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated

select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
    , sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) RollingPeopleVaccinated
into #PercentPopulationVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.continent = vac.continent
    and dea.[location] = vac.[location]
    and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated


-- Creating View to store data for later visualizationas

create view vw_PercentPopulationVaccinated as 
select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
    , sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.continent = vac.continent
    and dea.[location] = vac.[location]
    and dea.date = vac.date
where dea.continent is not null








