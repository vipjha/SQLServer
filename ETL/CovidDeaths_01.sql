--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--------------------++++++++ 04 - Visual Studio Setup +++++++++++++---------------------
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++




--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--------------------++++++++ 03 - Data Exploration with T-SQL  SQL +++++++++++++---------------------
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-----------------------------------------015 Create views-------------------------------------------
--A View is a vartual table based on the result-set of an SQL statement
--A view contains rows and columns, just like a real table.
--The data in a view comes from one or more table(base tables) in the database


CREATE View Percent_Population_Vaccinated AS
SELECT cd.continent, cd.location,cd.date, cd.population_density, cv.new_vaccinations
,SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location ORDER BY cd.location, cd.Date) as RollingPeopleVaccinated 
FROM CovidData..CovidDeaths cd 
JOIN CovidData..CovidVaccinations cv ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent IS NOT NULL 
--ORDER BY 2,3

SELECT * 
FROM Percent_Population_Vaccinated


-----------------------------------------014 Create temporary tables-------------------------------------------
--Temporary table are tables that exist temporarily on the SQL Server
--Temoroary table are useful for storing the immediate result sets that are accessed multiple times


SELECT cd.continent, cd.location,cd.date, cd.population_density, cv.new_vaccinations
,SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location ORDER BY cd.location, cd.Date) as RollingPeopleVaccinated 
FROM CovidData..CovidDeaths cd 
JOIN CovidData..CovidVaccinations cv ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent IS NOT NULL 
ORDER BY 2,3

Drop Table IF EXISTS #Percent_Population_Vaccinated

CREATE TABLE #Percent_Population_Vaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #Percent_Population_Vaccinated
SELECT cd.continent, cd.location,cd.date, cd.population_density, cv.new_vaccinations
,SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location ORDER BY cd.location, cd.Date) as RollingPeopleVaccinated 
FROM CovidData..CovidDeaths cd 
JOIN CovidData..CovidVaccinations cv ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent IS NOT NULL 
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS Percentage_vaccinated
FROM #Percent_Population_Vaccinated

--------------------------------------------013 Query data with CTE-------------------------------------------
--CTE stands for Common Table Expression
--A CET allows you to define a temporary name result set that is available temporarily in the execution scop of statement such as SELECT, INSERT, UPDATE, DELETE or MERGE.
-- Basic CTE Syntext:     WITH expression_name[(column_name[,...])] AS (CTE_defination) SQL-Satement;

SELECT cd.continent, cd.location,cd.date, cd.population_density, cv.new_vaccinations
,SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location ORDER BY cd.location, cd.Date) as RollingPeopleVaccinated 
FROM CovidData..CovidDeaths cd 
JOIN CovidData..CovidVaccinations cv ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent IS NOT NULL 
ORDER BY 2,3

WITH cte_population_vaccinated(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)

AS

(SELECT cd.continent, cd.location,cd.date, cd.population_density, cv.new_vaccinations
,SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location ORDER BY cd.location, cd.Date) as RollingPeopleVaccinated 
FROM CovidData..CovidDeaths cd 
JOIN CovidData..CovidVaccinations cv ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT * 
FROM cte_population_vaccinated

--------------------------------------012 Number of people vaccinated-------------------------------------------
SELECT cd.continent, cd.location,cd.date, cd.population_density, cv.new_vaccinations
,SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location ORDER BY cd.location, cd.Date) as RollingPeopleVaccinated 
FROM CovidData..CovidDeaths cd 
JOIN CovidData..CovidVaccinations cv ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent IS NOT NULL 
ORDER BY 2,3

--------------------------------------011 Global covid death----------------------------------------------------
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2
---------------------------------010 Continents with highest covid deaths--------------------------------------------
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount --Cast is change the data type
FROM DBO.CovidDeaths 
WHERE continent is not NULL
GROUP BY continent ORDER BY TotalDeathCount desc


---------------------------------009 Countries with highest covid death----------------------------------------------
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount --Cast is change the data type
FROM DBO.CovidDeaths 
WHERE continent is not NULL
GROUP BY Location ORDER BY TotalDeathCount desc

EXEC sp_help CovidDeaths
-----------------------------------008 Countries with highest covid infection----------------------------------------
SELECT Location, population_density, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population_density))*100 as PercentPopulationInfacted
FROM dbo.CovidDeaths
GROUP BY Location, population_density ORDER BY PercentPopulationInfacted desc


------------------------------------007 Percent of population infected with COVID ----------------------------
SELECT Location,Date,population_density,Total_Cases,(Total_Cases/population_density)*100 as Percentage_of_Population_Infacted 
FROM dbo.CovidDeaths WHERE Location like '%united kingdom%' ORDER BY 1,2


------------------------------------006 Possibility of dying from COVID ----------------------------
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths 
Where location like '%united kingdom%' and continent  IS NOT NULL order by 1,2


------------------------------------005 How many continents do we have data for?--------------------
SELECT distinct continent from dbo.CovidDeaths WHERE continent IS NOT NULL

SELECT * 
FROM dbo.CovidDeaths 
WHERE continent IS NOT NULL 
ORDER BY 3, 4 ;

---

SELECT continent FROM dbo.CovidDeaths

--------------------------------Initial Check-------------------------------------------------------
SELECT * 
FROM dbo.CovidDeaths
ORDER BY 3,4;


SELECT * 
FROM dbo.CovidVaccinations
ORDER BY 3,4;