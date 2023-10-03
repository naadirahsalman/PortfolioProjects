Select *
From CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dyingg if you get COVID in Sri Lanka

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location='Sri Lanka'
order by 1,2 DESC

-- Looking at Total Cases vs Popoulation
-- Shows what % of the Sri Lankan population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
From CovidDeaths
Where location='Sri Lanka'
order by 1,2 

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, population
order by PercentPopulationInfected desc

-- Showing countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Showing continents with Highest Death Count per Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Breaking down global numbers

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not null
Group by Date
order by 1,2 DESC

-- Looking at total population vs vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


-- Using a CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using a TempTable

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Looking at Rate of Deaths vs Rate of Vaccination

With VacsvsDeath (Continent, Location, Date, Population, New_Vaccinations, New_Deaths, RollingPeopleVaccinated, RollingDeaths)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, dea.new_deaths
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
, SUM(cast(new_deaths as int))  OVER (Partition by dea.location Order by dea.location, dea.date) as RollingDeaths
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as RateofVaccinations, (RollingDeaths/Population)*100 as RateofDeaths
From VacsvsDeath



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null




