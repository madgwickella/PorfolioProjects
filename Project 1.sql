SELECT *
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--select *
--FROM PortfolioProject1..covidvaccinations
----order by 3,4

-- Select data that we are going to be using 

SELECT Continent, DATE, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
ORDER BY 1,2 


-- Looking at total cases vs total deaths
-- Shows likeilhood of dying if you contract covid in your country
SELECT LOCATION, DATE, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE LOCATION like '%New Zealand%'
and continent is not null
ORDER BY 1,2 


--looking at total cases vs population
-- shows what percentage of population got covid
SELECT Location, Date, total_cases,population, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject1..CovidDeaths
WHERE Location like '%New Zealand%'
and continent is not null
ORDER BY 1,2 

--looking at countries with heighest infection rate compared to population
SELECT Continent, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject1..CovidDeaths
--WHERE LOCATION like '%New Zealand%'
WHERE continent is not null
GROUP BY Continent, Population
ORDER BY PercentagePopulationInfected desc


--Showing countries with the highest death count per population
SELECT Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
--WHERE LOCATION like '%New Zealand%'
GROUP BY Continent
ORDER BY TotalDeathCount desc

--Break down by continent


--Showing the continents with the highest death count per population
SELECT Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
GROUP BY Continent
ORDER BY TotalDeathCount desc



--Global# 
SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE Continent is not null
GROUP BY Date
ORDER BY 1,2

--World total cases, deaths & % of deaths
SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE Continent is not null
--GROUP BY Date
ORDER BY 1,2


--looking at Total Population vs Vaccinations 

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by deaths.location) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths Deaths 
--,(RollingPeopleVaccinated/population)*100
Join PortfolioProject1..covidvac vac
	on deaths.location = vac.location
	and deaths.date = vac.date
WHERE deaths.continent is not null
ORDER BY 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by deaths.location) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths Deaths 
--,(RollingPeopleVaccinated/population)*100
Join PortfolioProject1..CovidVac vac
	On deaths.location = vac.location
	and deaths.date = vac.date
WHERE deaths.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



--temp table

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)



INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by deaths.location) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths Deaths 
--,(RollingPeopleVaccinated/population)*100
Join PortfolioProject1..CovidVac vac
	On deaths.location = vac.location
	and deaths.date = vac.date
WHERE deaths.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--alterations
DROP table if exists #PercenatPopulationVaccinated
Create table #PercenatPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)



INSERT INTO #PercenatPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by deaths.location) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths Deaths 
--,(RollingPeopleVaccinated/population)*100
Join PortfolioProject1..CovidVac vac
	On deaths.location = vac.location
	and deaths.date = vac.date
--WHERE deaths.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercenatPopulationVaccinated


-- creating view to store data for later visualtisations

Create View PercentagePopulationVaccinated 
as 
	SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
	, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by deaths.location) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
	FROM PortfolioProject1..CovidDeaths Deaths 
	Join PortfolioProject1..covidvac vac
	on deaths.location = vac.location
	and deaths.date = vac.date
	WHERE deaths.continent is not null
	--ORDER BY 2,3

select *
From PercentagePopulationVaccinated