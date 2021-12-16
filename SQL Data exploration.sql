select *
from [Portfolio project]..['covid deaths$']
where continent is not null
order by 3,4

--select *
--from [Portfolio project]..['covid vaccinations$']
--order by 3,4

--Select the data we're going to be using

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio project]..['covid deaths$']
where continent is not null
order by 1,2

-- looking at the total cases vs total deaths
-- shows percentage of dying if you contract covid in your country
-- curently in december 2021 there are 1.3% chance of dying in India 

select location, date, total_cases, total_deaths, new_cases, (total_deaths/total_cases)*100 as death_percentage
from [Portfolio project]..['covid deaths$']
where location like '%india%' and continent is not null
order by 1,2

-- Looking at Total cases vs population
-- shows what percentage of population got covid 
-- Till december 2021 2.5% of population is get affected by covid in india 

select location, date, population, total_cases, new_cases, (total_cases/population)*100 as case_percentage
from [Portfolio project]..['covid deaths$']
where location like '%india%' 
order by 1,2

-- looking at countries with highest infection rates compared to population

select location,  population, MAX(total_cases) as Highest_infection_count, MAX((total_cases/population))*100 as case_percentage
from [Portfolio project]..['covid deaths$']
--where location like '%india%'
group by location,population
order by case_percentage desc

-- Showing the countries with the highest death count per population
-- India is in 3rd place after United states and Brazil with the total death counts of 4,76,135 in december 2021

select location, MAX(cast(total_deaths as int)) as total_death_count
from [Portfolio project]..['covid deaths$']
--where location like '%india%'
where continent is not null
group by location
order by total_death_count desc

-- LET'S BREAK THINGS DOWN BY CONTINENT 

-- Showing the continent with highest death count

-- Europe is at the highest continent with the total death count of 14,73,739 in dec 2021
-- Asia is at the second place with the total death count of 12,39,592 in dec 2021

select continent, MAX(cast(total_deaths as int)) as total_death_count
from [Portfolio project]..['covid deaths$']
--where location like '%india%'
where continent is not null
group by continent
order by total_death_count desc   -- this code is right but data is wrong so kindly put 'is null' instead of 'not null' for correct figures

-- GLOBAL NUMBERS

select date, SUM(new_cases) as Totalcases, SUM(cast(new_deaths as int)) as Totaldeaths , (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
from [Portfolio project]..['covid deaths$']
--where location like '%india%'
where  continent is not null
group by date
order by 1,2


-- ON Global level there is 1.95% chance of dying if someone got contract of covid in december 2021

select  SUM(new_cases) as Totalcases, SUM(cast(new_deaths as int)) as Totaldeaths , (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
from [Portfolio project]..['covid deaths$']
--where location like '%india%'
where  continent is not null
--group by date
order by 1,2

--Looking at Total population vs Total vaccinations

-- vaccinations started in india on 16 january 2021 and vaccinated about 1,91,181 people on DAY 1

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , sum(convert(bigint,new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
 --(rollingpeoplevaccinated/population)*100
from [Portfolio project]..['covid deaths$'] dea
join [Portfolio project]..['covid vaccinations$'] vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3          -- use of bigint is the key in this Query



-- USE CTE

-- By the end of december 2021 about 92% of india is vaccinated

with PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , sum(convert(bigint,new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from [Portfolio project]..['covid deaths$'] dea
join [Portfolio project]..['covid vaccinations$'] vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.location like '%india%' and dea.continent is not null
--order by 2,3 
)

select *, (rollingpeoplevaccinated/population)*100 
from PopvsVac


-- TEMP table

DROP table if exists #personpeoplevaccinated
create table #personpeoplevaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations  numeric,
rollingpeoplevaccinated numeric,
)

insert into #personpeoplevaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , sum(convert(bigint,new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [Portfolio project]..['covid deaths$'] dea
join [Portfolio project]..['covid vaccinations$'] vac
    on dea.location = vac.location
    and dea.date = vac.date
--where dea.location like '%india%' --and dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100 
from #personpeoplevaccinated


