--In order to have our data which is csv file of excel, we used import flat data function to database, while doing so we altered each type of column individually to make our work easier.
--We got our data from: https://ourworldindata.org/covid-deaths on 11/11/2021

--Let's check what is the first file for
select * from ABC.dbo.Death

--Let's check what is the second file for
select * from ABC.dbo.Vac

--Let's see how many rows we have in file One
select count( location)
from ABC.dbo.Death

--Let's see how many distinct location we have in file One
select count( distinct location)
from ABC.dbo.Death

--Let's see how  different countries we have
select distinct location
from ABC.dbo.Death
order by 1

--Alternatively --Let's see how  different countries we have
select location
from ABC.dbo.Death
group by location
order by 1

--Let's check the crucial tabs that we are interested in
select location, date, total_cases, new_cases, total_deaths, population
from ABC.dbo.Death
order by 2, 1

--Total cases vs total deaths - max to min
select location, date, total_cases, new_cases, total_deaths, total_deaths/total_cases*100 as Death_Percentage
from ABC.dbo.Death
order by 6 desc

--Let's check the issue in United states, we are not sure if with the search name so use like function
select location, date, total_cases, new_cases, total_deaths, total_deaths/total_cases*100 as Death_Percentage
from ABC.dbo.Death
where location like '%state%'
order by 6 desc

--Let's check Turkey
select location,  date, total_cases, new_cases, total_deaths, total_deaths/nullif(total_cases, 0)*100 as Death_percentage
from ABC.dbo.Death
where location like 'turkey'  -- There is no difference in -t and -T
order by 6 desc

--Total cases vs total deaths - max to min
select location, date, population, total_cases, total_cases/population *100 as Case_in_population_percentage
from ABC.dbo.Death
order by 5 desc
--WOW LOOK at montenegro

--Looking at the countries with highest inflection rate compared to population

select location, population, max(total_cases) as Highest_inf_rate, max((total_cases)/population *100) as Percent_Population_Infected
group by location, population
from ABC.dbo.Death
-- as  seen we have to be careful of the order of the functions

select location, population, max(total_cases) as Highest_inf_rate, max((total_cases)/population *100) as Percent_Population_Infected
from ABC.dbo.Death
group by location, population
order by Percent_Population_Infected desc

--Showing the counties with the highest death count per population
select location, population, max(total_deaths) as Total_Population_Dead
from ABC.dbo.Death
group by location, population
order by Total_Population_Dead desc

--HOW TO CHANGE TYPE OF THE VARIABLE
select location, population, max(total_deaths) as Total_Population_Dead
from ABC.dbo.Death
group by location, population
order by Total_Population_Dead desc
--our data was correct this is why it did not change
--our data has world, continent names and etc, to avoid that we should alter the coding


--Showing the only COUNTRIES with the highest death count per population
select location, population, max(total_deaths) as Total_Population_Dead
from ABC.dbo.Death
where continent is not null
group by location, population
order by Total_Population_Dead desc

--Showing continents with highest death count per population

select continent, max(total_deaths) as Total_Population_Dead
from ABC.dbo.Death
where continent is not null
group by continent
order by Total_Population_Dead desc


--LET'S SEE WHICH CONTINENT HAS HOW MANY DEATH IN POPULATION
select location, max(total_deaths) as Total_Population_Dead
from ABC.dbo.Death
where continent is null
group by location
order by Total_Population_Dead desc

--global numbers


select  date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from ABC.dbo.Death
where continent is not null
group by date --Problem: Column 'ABC.dbo.Death.total_cases' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
--we cannot just group by date bec a lot more is in select
order by 1,2


--lets have the total cases by summing up new cases and new dates for total_deaths
--now group by WORKS!
select  date, sum(new_cases) as totall_cases, sum(new_deaths) as totall_deaths
from ABC.dbo.Death
where continent is not null
group by date
order by 1,2

--let's see what is dying for the ones that has the case
select  date, sum(new_cases) as totall_cases, sum(new_deaths) as totall_deaths, sum(new_deaths)/sum(new_cases)*100 as Deathh_percentage_in_cases
from ABC.dbo.Death
where continent is not null
group by date
order by 1,2

--MOST IMPORTANTLY
--to see the total numbers what we do is to get rid of group by and select date
select   sum(new_cases) as totall_cases, sum(new_deaths) as totall_deaths, sum(new_deaths)/sum(new_cases)*100 as Deathh_percentage_in_cases
from ABC.dbo.Death
where continent is not null
order by 1,2

--JOIN FUNCTION
--let's combine and merge the 2 file together
--we'll combine them on location and date columns
select *
from ABC.dbo.Death DEA
join ABC.dbo.Vac VAC
	on DEA.location = VAC.location
	and DEA.date = VAC.date

--Looking at total population vs vaccination
select DEA.continent, dea.location, DEA.date, dea.population, VAC.new_vaccinations
from ABC.dbo.Death DEA
join ABC.dbo.Vac VAC
	on DEA.location = VAC.location
	and DEA.date = VAC.date
order by 1,2,3
--BUT here we have also continents, so let's get the countries only by getting rid of continens
 
 select DEA.continent, dea.location, DEA.date, dea.population, VAC.new_vaccinations
from ABC.dbo.Death DEA
join ABC.dbo.Vac VAC
	on DEA.location = VAC.location
	and DEA.date = VAC.date
where continent is not null --tablo ismini girmedigimiz icin hata verdi
order by 1,2,3

--dogrusu:
 select DEA.continent, dea.location, DEA.date, dea.population, VAC.new_vaccinations
from ABC.dbo.Death DEA
join ABC.dbo.Vac VAC
	on DEA.location = VAC.location
	and DEA.date = VAC.date
where DEA.continent is not null --tablo ismini girmedigimiz icin hata verdi
order by 2,3

--CHANGING THE TYPE OF VARIABLE
--1st way
--cast(VAC.new_vaccinations as int)
--2nd way
--convert(int, VAC.new_vaccinations )
--We will have new vaccination per day
select DEA.continent, dea.location, DEA.date, dea.population, VAC.new_vaccinations, sum(convert(int,VAC.new_vaccinations)) over (partition by dea.location)
from ABC.dbo.Death DEA
join ABC.dbo.Vac VAC
	on DEA.location = VAC.location
	and DEA.date = VAC.date
where DEA.continent is not null 
order by 2,3
--ERROR: Arithmetic overflow error converting expression to data type int. Warning: Null value is eliminated by an aggregate or other SET operation.
-- Solution is to use bigint instead of int

select DEA.continent, dea.location, DEA.date, dea.population, VAC.new_vaccinations, sum(convert(bigint,VAC.new_vaccinations)) over (partition by dea.location)
from ABC.dbo.Death DEA
join ABC.dbo.Vac VAC
	on DEA.location = VAC.location
	and DEA.date = VAC.date
where DEA.continent is not null 
order by 2,3
--Cool, BUT (no column name) is same for each country, which supposed to be aggregate! , so as a soluton we should use order by function for location and date

select DEA.continent, dea.location, DEA.date, dea.population, VAC.new_vaccinations, sum(convert(bigint,VAC.new_vaccinations))  over (partition by dea.location order by  dea.location, dea.date) as Aggregate_vac_by_rolling_date
--by order by funtion we could have aggregate sum in (Aggregate_vac_by_rolling_date)
from ABC.dbo.Death DEA
join ABC.dbo.Vac VAC
	on DEA.location = VAC.location
	and DEA.date = VAC.date
where DEA.continent is not null 
order by 2,3

--let's add population and population in new vac
select DEA.continent, dea.location, DEA.date, dea.population, VAC.new_vaccinations, sum(convert(bigint,VAC.new_vaccinations))  over (partition by dea.location order by  dea.location, dea.date) as Aggregate_vac_by_rolling_date
--by order by funtion we could have aggregate sum in (Aggregate_vac_by_rolling_date)
from ABC.dbo.Death DEA
join ABC.dbo.Vac VAC
	on DEA.location = VAC.location
	and DEA.date = VAC.date
where DEA.continent is not null 
order by 2,3

-- 1-USING CTE
--in order to have a rolling function for given purpose
with PopvsVac (Continent, location, date, population, New_vaccination, Aggregate_vac_by_rolling_date) --with statement's declaration should be same with select's
as
(
select DEA.continent, dea.location, DEA.date, dea.population, VAC.new_vaccinations, sum(convert(bigint,VAC.new_vaccinations))  over (partition by dea.location order by  dea.location, dea.date) as Aggregate_vac_by_rolling_date
from ABC.dbo.Death DEA
join ABC.dbo.Vac VAC
	on DEA.location = VAC.location
	and DEA.date = VAC.date
where DEA.continent is not null 
--order by 2,3
)
select *, (Aggregate_vac_by_rolling_date/Population)*100 as rolling_vac_in_pop_perc-- here we roll the rolling_vac_in_pop_perc
from PopvsVac

-- 2-USING TEMP TABLE
--in order to have a rolling function for given purpose

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
Aggregate_vac_by_rolling_date numeric
)

insert into #PercentPopulationVaccinated
select DEA.continent, dea.location, DEA.date, dea.population, VAC.new_vaccinations
, sum(convert(bigint,VAC.new_vaccinations))  over (partition by dea.location order by  dea.location, dea.date) as Aggregate_vac_by_rolling_date
from ABC.dbo.Death DEA
join ABC.dbo.Vac VAC
	on DEA.location = VAC.location
	and DEA.date = VAC.date
where DEA.continent is not null 
--order by 2,3

select *, (Aggregate_vac_by_rolling_date/Population)*100 as agregate_PercentPopulationVaccinated
from #PercentPopulationVaccinated

--Creating view to store data for visualizations

Create view test1 as
select DEA.continent, dea.location, DEA.date, dea.population, VAC.new_vaccinations
, sum(convert(bigint,VAC.new_vaccinations))  over (partition by dea.location order by  dea.location, dea.date) as Aggregate_vac_by_rolling_date
from ABC.dbo.Death DEA
join ABC.dbo.Vac VAC
	on DEA.location = VAC.location
	and DEA.date = VAC.date
where DEA.continent is not null 
--order by 2,3

