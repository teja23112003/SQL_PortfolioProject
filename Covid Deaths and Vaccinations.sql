select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


--Looking at Total cases Vs Total deaths

Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1,2


-- Total cases Vs Population

Select Location, date, total_cases, population, 
(cast(total_cases as float)/cast(population as bigint))*100 as PercentageOfPopulationInfected
from PortfolioProject..CovidDeaths
order by 1,2


-- Showing Countries with Highest Infection Rate compared to Population

Select Location, population, max(total_cases) as HighestInfectionCount, 
max(cast(total_cases as float)/cast(population as bigint))*100 as PercentageOfPopulationInfected
from PortfolioProject..CovidDeaths
group by Location, population
order by PercentageOfPopulationInfected desc


-- Showing Countries with Highest Death Count 

Select Location, max(total_deaths) as HighestDeathCount
from PortfolioProject..CovidDeaths
group by Location
order by HighestDeathCount desc


--Showing Continent with Highest Death Count

Select continent, max(total_deaths) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc


-- Covid Cases and Deaths Globally

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths



-- Looking at Total Population vs Vaccinations
-- USING CTE

With PopvsVac  (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- USING TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later Visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated
