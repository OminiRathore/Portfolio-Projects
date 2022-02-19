select * from PortfolioProject..CovidDeaths where continent is not  null

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you cotract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location = 'India' 
order by 1, 2

--Looking at countries with highest infected rate as compared to population

Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not  null
group by Location, population
order by HighestInfectionCount desc


--Grouping by continent
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount desc

--Global Numbers

Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by DeathPercentage


Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by DeathPercentage




--Finding Percentage of population vaccinated using CTE

--Select location, date, total_vaccinations, new_vaccinations from PortfolioProject..CovidVaccinations order by 1,2

With PopvsVac (continent, location, date, population, new_vaccinations, VaccinationTillDate)
as
(
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint))
over (partition by dth.location order by dth.location, dth.date) as VaccinationTillDate
from PortfolioProject..CovidDeaths dth 
join PortfolioProject..CovidVaccinations vac
on dth.location = vac.location and dth.date = vac.date
where dth.continent is not null
--order by 1,2
)

Select *, cast((VaccinationTillDate/Population)*100 as decimal(38,3)) as VaccinationTillDatePercent
from PopvsVac


--Using TEMP Table

Drop Table if exists #PopvsVac
Create Table #PopvsVac 
(continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 VaccinationTillDate numeric
 )


Insert into #PopvsVac
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint))
over (partition by dth.location order by dth.location, dth.date) as VaccinationTillDate
from PortfolioProject..CovidDeaths dth 
join PortfolioProject..CovidVaccinations vac
on dth.location = vac.location and dth.date = vac.date
where dth.continent is not null
--order by 1,2

Select *, cast((VaccinationTillDate/Population)*100 as decimal(38,3)) as VaccinationTillDatePercent
from #PopvsVac


--Creating view to store data to be used for visualizations

Create view DeathPercent_India
as
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location = 'India' 

Select * from DeathPercent_India

Create view 
GlobalNumbers as
Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null

Select * from GlobalNumbers
