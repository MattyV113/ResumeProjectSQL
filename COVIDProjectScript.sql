ALTER TABLE Portfolio_Project.Covid_Deaths MODIFY total_deaths INT;



-- Shows likelihood if you contract COVID in your country.

SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS 'Death Percentage'
FROM Portfolio_Project.Covid_Deaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

-- Looking at total cases v. population

SELECT Location, date ,Population, total_cases, (total_cases/Population)*100 AS 'Contraction Rate'
FROM Portfolio_Project.Covid_Deaths
WHERE location LIKE '%states%'
ORDER BY 1,2;



-- Looking at Countries with Highest Infection Rates compared to Population

SELECT Location , Population, MAX(total_cases) AS 'Highest Infection Count', MAX((total_cases/Population)*100) AS ContractionRate
FROM Portfolio_Project.Covid_Deaths
GROUP BY Location,Population
ORDER BY ContractionRate DESC;

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX( total_deaths) AS TotalDeathCount
FROM Portfolio_Project.Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;


-- Breaking things down by Continent
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM Portfolio_Project.Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers
SELECT date,SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, 
SUM(new_deaths)/SUM(new_cases)* 100 AS DeathPercentage 
FROM Portfolio_Project.Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) 
OVER (Partition By dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM Portfolio_Project.covid_deaths dea
JOIN Portfolio_Project.covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


-- USE CTE


With  PopvsVac (Continent, Location, date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) 
OVER (Partition By dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM Portfolio_Project.covid_deaths dea
JOIN Portfolio_Project.covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/Population)*100 FROM PopvsVac;



-- Temp Table

SET SESSION sql_mode = ' ';

DROP TABLE IF EXISTS Portfolio_Project.PercentPopulationVaccinated;

CREATE TABLE Portfolio_Project.PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);


INSERT INTO Portfolio_Project.PercentPopulationVaccinated  
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) 
OVER (Partition By dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM Portfolio_Project.covid_deaths dea
JOIN Portfolio_Project.covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM Portfolio_Project.PercentPopulationVaccinated;


-- Creating View to store data for later visual

CREATE VIEW Portfolio_Project.PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) 
OVER (Partition By dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM Portfolio_Project.covid_deaths dea
JOIN Portfolio_Project.covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL; 




