Select *
From PortfolioProject..CovidDeaths
order by 3,4

Select *
From PortfolioProject..CovidVaccinations
order by 3,4

--select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by population DESC


--What percentage of Finnish population got Covid
Select Location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Finland%' 
order by 1,2


--Looking at countries with Highest Infection Rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where population != 0 and continent <> '' 
Group by Location, population
order by PercentPopulationInfected DESC


--Showing Countries with Highest Death Count Per Population
--Note1: need to cast total_deaths into integer type becaues they are wrongly recognized as Nvarchar
--Note2: as the continent collumns have empty string so i gonna make a condition for the querry to exclude those
Select Location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent <> '' 
Group by Location
order by TotalDeathCount DESC


--LET BREAK THINGS DOWN BY CONTINENT (not by income classes)
Select Location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent = '' and location not in ('Upper middle income','High income', 'Low income','international') 
Group by Location
order by TotalDeathCount DESC

--Showing the continents with the highest death count per population
Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent <> '' 
Group by continent
order by TotalDeathCount DESC

--GLOBAL NUMBERS BY DATE
Select date, SUM(new_cases)as tota_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent <> '' and new_cases <> 0   
Group by date
order by date

--GLOBAL NUMBERS IN TOTAL
Select  SUM(new_cases)as tota_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent <> '' and new_cases <> 0  and new_deaths <> 0  

 
--Looking at Total Population vs NEW vaccinations per date
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent <> ''
--order by 1,2,3

--Looking at Total Population vs Total Vaccinations (add up the new vaccinations) using the "Partition by" Location AND date 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent <> ''
order by 2,3

--Use CTE
with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent <> ''
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac
Where Population <> 0

--Use TEMPORARY TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent <> ''

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated
Where Population <> 0


--Creating View to store data for later visualizations
DROP VIEW if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent <> ''


Select * 
From PercentPopulationVaccinated