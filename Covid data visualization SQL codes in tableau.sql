/*

Queries used for Tableau Project: Final version of tableu is here: https://public.tableau.com/app/profile/alper5134/viz/CovidDashboard_16368104497580/Dashboard1

*/

-- 1. Global total cases, total deaths, death percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ABC.dbo.Death
where continent is not null 
order by 1,2

-- 2. Countinents' total death numbers

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From ABC.dbo.Death
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc


-- 3. Country base population, highest infection number and percent of population infected

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From ABC.dbo.Death
Group by Location, Population
order by PercentPopulationInfected desc


-- 4. Time period of highest infection numbers among countries, with population, and percent of population infected information


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From ABC.dbo.Death
Group by Location, Population, date
order by PercentPopulationInfected desc





-- Additionals -- Not visualized but could have.


-- 1.Total people vaccinated by date

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ABC.dbo.Death dea
Join ABC.dbo.Vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3

-- 2. Alternative -- Global total cases, total deaths, death percentage
-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ABC.dbo.Death
where location = 'World'
order by 1,2



-- 3. PopvsVac 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ABC.dbo.Death dea
Join ABC.dbo.Vac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


