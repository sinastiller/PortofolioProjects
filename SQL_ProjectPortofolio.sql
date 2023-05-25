Select *
from PortofolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--from PortofolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths
where continent is not null
order by 1,2

-- total cases vs total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortofolioProject..CovidDeaths
where location like 'Germany'
order by 1,2

-- total cases vs population
Select location, date, population, total_cases, (total_cases/population)*100 as cases_percentage
from PortofolioProject..CovidDeaths
where location like 'Germany'
order by 1,2

-- countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as highest_infection_count, (MAX(total_cases)/population)*100 as cases_percentage
from PortofolioProject..CovidDeaths
--where location like 'Germany'
group by location, population
order by cases_percentage desc

-- countries with highest death rate compared to population
Select location, MAX(cast(total_deaths as int)) as highest_death_count
from PortofolioProject..CovidDeaths
--where location like 'Germany'
where continent is not null
group by location, population
order by highest_death_count desc

--by continent
Select continent, MAX(cast(total_deaths as int)) as highest_death_count
from PortofolioProject..CovidDeaths
--where location like 'Germany'
where continent is not null
group by continent
order by highest_death_count desc

-- correct way
--Select location, MAX(cast(total_deaths as int)) as highest_death_count
--from PortofolioProject..CovidDeaths
----where location like 'Germany'
--where continent is null
--group by location
--order by highest_death_count desc

-- global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) as death_percentage
from PortofolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) as death_percentage
from PortofolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
With PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null)
--order by 2,3
Select *, (rolling_people_vaccinated/population)*100
from PopvsVac


-- Temp table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select *, (rolling_people_vaccinated/population)*100
from #PercentPopulationVaccinated


-- creating views

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated