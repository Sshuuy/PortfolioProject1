--SELECT location,date,total_cases,new_cases,total_deaths,population
--FROM dbo.CovidDeaths
--order by 3,4

--SELECT *
--FROM dbo.CovidDeaths
--where continent is not null


SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
where location = 'Nigeria'
order by 1,2

--Percentage of populatio that got covid
SELECT location,date,total_cases, population, (total_cases/population)*100 as PercentageofCovid
FROM dbo.CovidDeaths
where location = 'Nigeria'
order by 1,2

--Countries with highest covid rate
SELECT location, max(total_cases) as CovidNumber, population, Max((total_cases/population))*100 as Percentageofpopolation 
FROM dbo.CovidDeaths
--where location = 'Nigeria'
Group by location,population
order by Percentageofpopolation desc

--Countries with Highest death Rate
SELECT location, max(cast(total_deaths as int)) as DeathCount
FROM dbo.CovidDeaths
--where location = 'Nigeria'
Where  continent is not null
group by location
order by DeathCount desc

--Contintent with the Highest Death Rate
SELECT continent, max(cast(total_deaths as int)) as DeathCount
FROM dbo.CovidDeaths
--where location = 'Nigeria'
Where  continent is not null
group by continent
order by DeathCount desc


--Global Numbers
SELECT sum(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Toatal_deaths, Sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage 
FROM dbo.CovidDeaths
--where location = 'Nigeria'
where continent is not null
--group by date
order by 1,2

--Query the total population that has vacinated
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVacinnation.new_vaccinations
FROM dbo.CovidDeaths
 join dbo.CovidVacinnation
on dbo.CovidDeaths.location = dbo.CovidVacinnation.location
and dbo.CovidDeaths.date = dbo.CovidVacinnation.date
where CovidDeaths.continent is not null
order by 1,2,3

--Total Population Vs Vaccinations
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVacinnation.new_vaccinations,
  SUM( CONVERT (int, CovidVacinnation.new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date )
  as RollingPeopleVacinated

FROM dbo.CovidDeaths
 join dbo.CovidVacinnation
on dbo.CovidDeaths.location = dbo.CovidVacinnation.location
and dbo.CovidDeaths.date = dbo.CovidVacinnation.date
where CovidDeaths.continent is  not null
order by 2,3

-- Using CTE
with PopVSVac ( Continent, Location, Date, Population,new_vacinnations, RollingPeopleVacinated)
as
(
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVacinnation.new_vaccinations,
  SUM( CONVERT (int, CovidVacinnation.new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date )
  as RollingPeopleVacinated

FROM dbo.CovidDeaths
 join dbo.CovidVacinnation
on dbo.CovidDeaths.location = dbo.CovidVacinnation.location
and dbo.CovidDeaths.date = dbo.CovidVacinnation.date
where CovidDeaths.continent is  not null
--order by 2,3
)
Select *, (RollingPeopleVacinated/Population) * 100
from PopVSVac

--temp table
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVacinated numeric
)

Insert into #PercentagePopulationVaccinated
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVacinnation.new_vaccinations,
  SUM( Convert( bigint,CovidVacinnation.new_vaccinations) ) over (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date )
  as RollingPeopleVacinated

FROM dbo.CovidDeaths
 join dbo.CovidVacinnation
on dbo.CovidDeaths.location = dbo.CovidVacinnation.location
and dbo.CovidDeaths.date = dbo.CovidVacinnation.date
where CovidDeaths.continent is not null
--order by 2,3
Select *, (RollingPeopleVacinated/Population) * 100
from #PercentagePopulationVaccinated

--CREATING VIEWS TO STORE DATA
Create view PercentagePopulationVaccinated as 
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVacinnation.new_vaccinations,
  SUM( Convert( bigint,CovidVacinnation.new_vaccinations) ) over (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date )
  as RollingPeopleVacinated

FROM dbo.CovidDeaths
 join dbo.CovidVacinnation
on dbo.CovidDeaths.location = dbo.CovidVacinnation.location
and dbo.CovidDeaths.date = dbo.CovidVacinnation.date
where CovidDeaths.continent is not null
--order by 2,3

create view Globaldata as
SELECT sum(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Toatal_deaths, Sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage 
FROM dbo.CovidDeaths
--where location = 'Nigeria'
where continent is not null
--group by date
--order by 1,2

Create view PercentageGotCovid as 
SELECT location,date,total_cases, population, (total_cases/population)*100 as DeathPercentage
FROM dbo.CovidDeaths
--where location = 'Nigeria'
--order by 1,2