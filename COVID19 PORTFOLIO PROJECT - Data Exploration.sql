Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Case vs Total Deaths
--Shows likelihood of dying if you contact covid in your Country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'India'
order by 1,2

--Looking at Total Cases vs Population
--What percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentOfPopulationInfected
From PortfolioProject..CovidDeaths
Where location like 'India'
order by 1,2

--Looking at Countries with highest infection rate compared to population

Select location, date, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentiopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'India'
Group By location, date, population
order by PercentiopulationInfected desc

--Showing countries with highest death count per population

Select location, MAX(Cast(Total_Deaths as Int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths
--Where location like 'India'
Where continent is Not Null
Group By location
order by TotalDeathsCount desc

--Let's Break Things Down By Continents


--Showing the continents with the highest Death Counts per population

Select continent, MAX(Cast(Total_Deaths as Int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths
Where continent is Not Null
Group By continent
order by TotalDeathsCount desc

--Global numbers

Select date, SUM(new_cases) as NewCases, SUM(cast(new_deaths as int)) as NewDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

--Total Death Percentage Globally

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations as vac
Join PortfolioProject..CovidDeaths as dea
	ON vac.location = dea.location
	and vac.date = dea.date
	Where dea.continent is Not Null
	order by 2,3




--Using CTE

With PopVsvac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations as vac
Join PortfolioProject..CovidDeaths as dea
	ON vac.location = dea.location
	and vac.date = dea.date
	Where dea.continent is Not Null
)
Select *, (RollingPeopleVaccinated/population)*100 as RP
From PopVsvac

--Temp Table

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

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations as vac
Join PortfolioProject..CovidDeaths as dea
	ON vac.location = dea.location
	and vac.date = dea.date
	--Where dea.continent is Not Null

	Select *, (RollingPeopleVaccinated/population)*100 as RP
From #PercentPopulationVaccinated


--Creating views to store data for later visualisation

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations as vac
Join PortfolioProject..CovidDeaths as dea
	ON vac.location = dea.location
	and vac.date = dea.date
Where dea.continent is Not Null

SELECT *
FROM PercentPopulationVaccinated