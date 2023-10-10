SELECT continent, location, date,population, total_cases
FROM CovidDeaths WHERE location = 'china'
Order by 1,3

--SELECT *
--FROM CovidVaccinations
--WHERE continent  is not null
--Order by 3, 4

SELECT
	location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Total Cases vs Total Deaths 
SELECT
	location,
	date,
	total_cases,
	total_deaths, 
	(CAST(total_deaths as float)/total_cases) *100 as DeathPercentage 
FROM CovidDeaths
WHERE Location = 'India' 
order by 1,2


--Population and Covid
SELECT
	location,
	date,
	total_cases,
	population, 
	ROUND((CAST (total_cases as float)/population)*100,6) as Percentage
FROM CovidDeaths
WHERE Location = 'India'
order by 1,2

--Countries with Highest Infection rate
SELECT
	Location,
	Population,
	MAX(total_cases) as HighestInfectionCount,
	Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
    Where continent is not null
	Group by Location, Population
	order by PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
	WHERE continent is not null
	Group by location
	order by TotalDeathCount desc

-- Continent with Highest Death
SELECT
	Location,
	MAX(total_deaths) as TotalDeathCount
	From CovidDeaths 
	WHERE(
		continent is null
		AND location in('Asia','Europe', 'North America', 'South America', 'Africa','Oceania')
	)
	Group by Location
	order by TotalDeathCount DESC
	
--Continents with Highest death percentage count per population
SELECT
	Location,
	Population,
	MAX(total_deaths) as TotalDeathCount,
	MAX(total_deaths/population)*100 as TotalDeathPercentage 
FROM CovidDeaths 
	WHERE(
		continent is null
		AND location in('Asia', 'Europe', 'North America', 'South America', 'Africa', 'Oceania')
		)
	Group by Location, population
	order by TotalDeathCount DESC

-- GLOBAL NUMBERS
SELECT
	SUM(new_cases),
	SUM(new_deaths),
	SUM(New_deaths)/SUM(new_cases)*100 as DeathPercentage 
FROM CovidDeaths 
WHERE continent is not null
order by 1,2

--Looking at Total Population vs Vaccination

SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations, 
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USING CTE

WITH PopvsVav(
	Continent,
	Location,
	Date,
	Population,
	New_vaccinations,
	RollingPeopleVaccinated)
		AS
		(
		SELECT
			dea.continent,
			dea.location,
			dea.date,
			dea.population,
			vac.new_vaccinations,
			SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
		FROM CovidDeaths dea
		JOIN CovidVaccinations vac
			On dea.location = vac.location
			and dea.date = vac.date
		WHERE dea.continent is not null
		--AND dea.location = 'Albania'
		--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population) *100
FROM PopvsVav



--TEMP TABLE
DROP TABLE IF EXISTS #PercentVaccinated
CREATE TABLE #PercentVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
INSERT INTO #PercentVaccinated
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population) *100
FROM #PercentVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW one AS
	SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	FROM CovidDeaths dea
	JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

Select * from One