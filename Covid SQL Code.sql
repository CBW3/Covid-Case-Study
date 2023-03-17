--Checking if Import Correctly
Select *
From [Portfolio Project ]..CovidDeaths
Order By 3,4

--Checking if Import Correctly
Select *
From [Portfolio Project ]..CovidVaccinations
Order By 3,4

--Selecting Data, Ordering by Location & Date

Select location, date, total_cases, new_cases, total_deaths, population 
From [Portfolio Project ]..CovidDeaths
Order By 1,2

----Exploratory Data Analysis Total Cases vs Total Deaths in Percentage Terms for America
--Likelihood of Dying if You Get Covid in US
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project ]..CovidDeaths
Where location like '%states%'
Order By 1,2

----Exploring Relationship Between Total Cases & Population 
--Likelihood of Contracting Covid Disease in US
Select location, date, Population, total_cases, (total_cases/population)*100 as CovidPercentage
From [Portfolio Project ]..CovidDeaths
Where location like '%states%'
Order By 1,2

--Exploring Countries with Highest Infection Rates Relative to Population 
Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidPercentage
From [Portfolio Project ]..CovidDeaths
Group By Location, Population 
Order By CovidPercentage Desc

--Exploring Death Rates by Countries 
Select location, MAX(total_deaths) as DeathCount
From [Portfolio Project ]..CovidDeaths
Group By Location, Population 
Order By DeathCount Desc

--Problems with DataTypes, Looking to Fix
Select location, MAX(cast(total_deaths as int)) as DeathCount
From [Portfolio Project ]..CovidDeaths
Group By Location, Population 
Order By DeathCount Desc

--Fixed but Location has World & Continent Data, I Want Individual Countries 
Select *
From [Portfolio Project ]..CovidDeaths
Where continent is not null
Order By 1,2

--Running Query to Get DeathCounts Again
Select location, MAX(cast(total_deaths as int)) as DeathCount
From [Portfolio Project ]..CovidDeaths
Where continent is not null
Group By Location
Order By DeathCount Desc

--Actually, I want to explore continent data too
Select continent, MAX(cast(total_deaths as int)) as DeathCount
From [Portfolio Project ]..CovidDeaths
Where continent is not null
Group By continent
Order By DeathCount Desc

--Encountered Issue, NA Counts are only counting US, Running Query to Fix 
Select location, MAX(cast(total_deaths as int)) as DeathCount
From [Portfolio Project ]..CovidDeaths
Where continent is null
Group By location
Order By DeathCount Desc

--Exploring Covid by Global Lens per day
Select date, SUM(new_cases) 
From [Portfolio Project ]..CovidDeaths
Where continent is not null
Group By date
Order By 1,2

--Further Global EDA
Select date, SUM(new_cases), SUM(new_deaths)
From [Portfolio Project ]..CovidDeaths
Where continent is not null
Group By date
Order By 1,2

--Problem with Data Type, Running New Query to Fix
Select date, SUM(new_cases), SUM(cast(new_deaths as int))
From [Portfolio Project ]..CovidDeaths
Where continent is not null
Group By date
Order By 1,2

---Exploring Global Death Percentages per Day
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project ]..CovidDeaths
Where continent is not null
Group By date
Order By 1,2

--Exploring Global Death Percentages as a Whole 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project ]..CovidDeaths
Where continent is not null
Order By 1,2

--Revisiting Vaccinations Table
Select *
From [Portfolio Project ]..CovidVaccinations

--Joining Deaths & Vaccinations Tables Together 
Select *
From [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

--Exploring Total Population & Vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
Order By 1,2,3

--I want new vaccinations to add up over time rather than just per day counts for each country
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(new_vaccinations) Over (Partition By dea.location)
From [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
Order By 1,2,3

--damnit, another data type error, running query to fix
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition By dea.location)
From [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
Order By 1,2,3

--Okay, I did something wrong, Reconsidering Query to get rolling counts
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition By dea.location Order By dea.location, dea.date) as RollingVac
From [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
Order By 1,2,3

--Exploring Vaccination Rates Over Time by Country 
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingVac)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition By dea.location Order By dea.location, dea.date) as RollingVac
From [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
)
Select *
From PopvsVac

--Exploring Vaccination Rates Over Time by County Cont. 
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingVac)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition By dea.location Order By dea.location, dea.date) as RollingVac
From [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
)
Select *, (RollingVac/population)*100
From PopvsVac

