--select *
--from [portfolio project]..CovidDeaths
--order by 3,4

select location,date,total_cases,new_cases,population
from [portfolio project]..CovidDeaths
order by 1,2

--looking for total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
from [portfolio project]..CovidDeaths
where location like '%Egypt%'
order by 1,2

--looking total cases vs population 
select location, date, total_cases, total_deaths,population, (total_cases/population)*100 as percent_population_Infected
from [portfolio project]..CovidDeaths
--where location like '%Egypt%'
order by 1,2

--looking for countries with highest infecation rate compare by population
select location,population,date, max(total_cases) as highestInfecation , max((total_cases/population))*100 as infecationPercent
from [portfolio project]..CovidDeaths
group by location,population,date
order by infecationPercent desc

-- showing countries with hieghest deaths count per population
select location,population, max(cast(total_deaths as int)) as highestDeaths, max((total_deaths/population))*100 as DeathPercent
from [portfolio project]..CovidDeaths
group by location,population
order by DeathPercent desc


-- showing the highest continent deaths
select continent, sum(cast(new_deaths as int)) as highestDeaths
from [portfolio project]..CovidDeaths
Where continent is not null
and location not in ('world','European union','International')
group by continent
order by highestDeaths desc

--Global numbers
select sum(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as DailyDeathPercent
from [portfolio project]..CovidDeaths
where continent is not null
--group by date 
--order by DailyDeathPercent desc
order by 1,2

-- total populations people vaccinations 

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast (vac.new_vaccinations As int)) over (partition by dea.location order by dea.location , dea.date) as rolling_vaccation_people
--(rolling_vaccation_people/dea.population)*100 as vaccination_percent
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
 on dea.date = vac.date
 and dea.location = vac.location
where dea.continent is not null
order by 2,3

--if we need to show vaccination people vs population

with popVSvac (continent,location,date,population,new_vaccinations,rollingVaccicationPeople)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as rollingVaccinationPeople
from [portfolio project]..CovidDeaths dea
join [portfolio project].. CovidVaccinations vac
 on dea.date = vac.date
 and dea.location = vac.location
 where dea.continent is not null
 --order by 1,2
 )
 select *, (rollingVaccicationPeople/population)*100 as vaccinationPercent
 from popVSvac

 -- create view to store data for later visualizations

 Create view vaccinationPercents as
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as rollingVaccinationPeople
from [portfolio project]..CovidDeaths dea
join [portfolio project].. CovidVaccinations vac
    on dea.date = vac.date
    and dea.location = vac.location
 where dea.continent is not null

 select * 
 from vaccinationPercents