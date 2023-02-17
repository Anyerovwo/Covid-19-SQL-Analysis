/****** This project's main aim is to use SQL to analyze the Coronavirus(Covid-19) Death  ******/


--- To get the view of the Table

SELECT *   
  FROM [Portfolio_SQL-Project].dbo.[covid-death]
  WHERE continent is not null
  ORDER BY 1, 2

 --- SELECT *   
 --- FROM [Portfolio_SQL-Project].dbo.covidvasination
---  ORDER BY 1,2

--- Select Data that we need for the Project.

SELECT location, date, total_cases, new_cases, total_deaths, population
 FROM [Portfolio_SQL-Project].dbo.[covid-death]
 ORDER BY 1,2

 --- Total cases vs Total deaths
 --- Showing likelyhood of dying if you contract Covid-19 in you Country

 SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
 FROM [Portfolio_SQL-Project].dbo.[covid-death]
 WHERE location LIKE '%Nigeria%'
 ORDER BY 1,2


 --- Looking at total cases vs population
 --- Show percentage of population that contracted covid-19

 SELECT location, date, total_cases, population, (total_cases / population) * 100 AS DeathPercentage
 FROM [Portfolio_SQL-Project].dbo.[covid-death]
 WHERE location LIKE '%State%'
 ORDER BY 1,2

 --- Country with highest infection rate compare to population

 SELECT location, max(total_cases) AS HighestInfectedRate, population, MAX((total_cases / population)) * 100 AS PercentagePopulationInfected
 FROM [Portfolio_SQL-Project].dbo.[covid-death]
 --- WHERE location LIKE '%State%'
 GROUP BY population, location
 ORDER BY PercentagePopulationInfected desc

 --- Country with highest Death rate

 SELECT location, max(total_deaths) AS HighesDeathRate
 FROM [Portfolio_SQL-Project].dbo.[covid-death]
 --- WHERE location LIKE '%State%'
 WHERE continent is not null
 GROUP BY location
 ORDER BY HighesDeathRate desc


 --- Total Death rate by continent
 --- showing continent with the highest death rate by population

 SELECT continent, max(total_deaths) AS HighesDeathRate
 FROM [Portfolio_SQL-Project].dbo.[covid-death]
 --- WHERE location LIKE '%State%'
 WHERE continent is not null
 GROUP BY continent
 ORDER BY HighesDeathRate desc

 SELECT location, max(total_deaths) AS HighesDeathRate
 FROM [Portfolio_SQL-Project].dbo.[covid-death]
 --- WHERE location LIKE '%State%'
  WHERE continent is null
 GROUP BY location
 ORDER BY HighesDeathRate desc

 --- Total daily contacted cases and deaths rate by each day

 SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
 (SUM(new_deaths) / SUM(new_cases))* 100 AS DeathPercentage--- max(total_deaths) AS HighesDeathRate
 FROM [Portfolio_SQL-Project].dbo.[covid-death]
 --- WHERE location LIKE '%State%'
 WHERE continent is not null
 GROUP BY date
 ORDER BY 1,2 desc

 --- Total case of covid-19 and Deaths RATE Globally
 
 SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
 (SUM(new_deaths) / SUM(new_cases))* 100 AS DeathPercentage--- max(total_deaths) AS HighesDeathRate
 FROM [Portfolio_SQL-Project].dbo.[covid-death]
 --- WHERE location LIKE '%State%'
 WHERE continent is not null
 ORDER BY 1,2 desc


 --- Let join the two table together

 SELECT *
 FROM [Portfolio_SQL-Project].dbo.[covid-death] dea
 JOIN [Portfolio_SQL-Project].dbo.[covidvasination] vac
 on dea.location = vac.location
 AND dea.date = vac.date

 --- What is the total amount of people that has been vaccinated

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 FROM [Portfolio_SQL-Project].dbo.[covid-death] dea
 JOIN [Portfolio_SQL-Project].dbo.[covidvasination] vac
 on dea.location = vac.location
 AND dea.date = vac.date
  WHERE dea.continent is not null
 ORDER BY 2,3 

 --- What is the total amount of people that has been vaccinated and update by each day

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS UpdatedPeopleVaccinated
 FROM [Portfolio_SQL-Project].dbo.[covid-death] dea
 JOIN [Portfolio_SQL-Project].dbo.[covidvasination] vac
 on dea.location = vac.location
 AND dea.date = vac.date
  WHERE dea.continent is not null
 ORDER BY 2,3


 --- To get the actual people vaccinated
--- use CTE 

WITH PopvsVac (continent, location, date, population, new_vaccinations,UpdatedPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS UpdatedPeopleVaccinated
 FROM [Portfolio_SQL-Project].dbo.[covid-death] dea
 JOIN [Portfolio_SQL-Project].dbo.[covidvasination] vac
 on dea.location = vac.location
 AND dea.date = vac.date
  WHERE dea.continent is not null
 --- ORDER BY 2,3
 )
 SELECT *, (UpdatedPeopleVaccinated / population) * 100 AS TotalPercentVaccinated
 FROM PopvsVac


 --- If we want to know the MAX

 --- TEMP TABLE

 DROP TABLE IF exists #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 continent nvarchar(50),
 location nvarchar(50),
 date date,
 population numeric(18,0),
 new_vaccinations nvarchar(50),
 UpdatedPeopleVaccinated numeric(18,0)
 )


 Insert into #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS UpdatedPeopleVaccinated
 FROM [Portfolio_SQL-Project].dbo.[covid-death] dea
 JOIN [Portfolio_SQL-Project].dbo.[covidvasination] vac
 on dea.location = vac.location
 AND dea.date = vac.date
  ---WHERE dea.continent is not null
 --- ORDER BY 2,3
  SELECT *, (UpdatedPeopleVaccinated / population) * 100 AS TotalPercentVaccinated
 FROM #PercentPopulationVaccinated


 --- Creating a view to store Data for visualization

 Create View PercentPopulationVaccinated AS
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS UpdatedPeopleVaccinated
 FROM [Portfolio_SQL-Project].dbo.[covid-death] dea
 JOIN [Portfolio_SQL-Project].dbo.[covidvasination] vac
 on dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent is not null
 --- ORDER BY 2,3

 SELECT *
 FROM PercentPopulationVaccinated

 Create View HighesDeathRate AS
  SELECT location, max(total_deaths) AS HighesDeathRate
 FROM [Portfolio_SQL-Project].dbo.[covid-death]
 --- WHERE location LIKE '%State%'
 WHERE continent is not null
 GROUP BY location
 ---ORDER BY HighesDeathRate desc

 SELECT *
 FROM HighesDeathRate

