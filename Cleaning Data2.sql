= = USE HI361

select count (*) from dbo.final

USE HI361
select top 1000 * from dbo.final

select id from dbo.final where id is null --- NO

select icd9 from dbo.final where icd9 is null -- NO

-- check for Dxs
select AgeAtDX from dbo.final where AgeAtDX is null -- 846 rows affected

-- check for AgeAtFirstDM
select AgeAtFirstDm from dbo.final where AgeAtFirstDM is null

--how to get rid of those nulls

--remove nulls (use temp tables)
select * 
	into #step1 
	from dbo.final
	where AgeAtDX is not null

-- clean data is in #step 1 table
select top 10000 * from #step1

-- nulls under ID? NO
-- nulls under icd9? NO
-- under AgeAtDX? Yes, but we cleaned those

-- are there patients who come after their day of death to visit a doctor? NO
-- pattern is AgeAtDX > AgeAtDeatg
select * from dbo.final
	where AgeAtDX > AgeAtDeath ---- 3,550 rows

-- example #01 where ageatdx > ageatdeath
-- example #02 

-- how many distinct ids we have
select distinct id
from #step1
where AgeAtDX > AgeAtDeath

select top 10 * from #step1
--cleaning data (weird patterns such as zombies) is a two step process
-- first step, we stored those patterns in a temp table #temp
-- second step, we subtract #temp from total i.e., dbo.final i.e., #clean = dbo.final - #temp

-- step1: find and store zombies into #zombies
select * into #zombies from #step1
where AgeAtDeath < AgeAtDX

select * from #zombies

--step 2: subtract #zombies from #step1 and store the clean data in #step2
-- #step2 = #step1 - #zombies
select *
	into #step2
	from #step1
	where id not in (select id from #zombies)

-- verify #step2
select * from #step2 where AgeAtDX > AgeAtDeath

--check age
select min(AgeAtDX) as minAge
	, max(AgeAtDX) as maxAge
from #step2

--oldest person in the world?
--just have age between 18 and 100

select *
	into #step3
	from #step2
	where AgeAtDX 
	between 18 and 100

--verify #step3
select min(AgeAtDX) as minAge
	, max(AgeAtDX) as maxAge
from #step3

--is it possible to have more than one AgeAtDeath
--cleaning zombies help us remove any AgeAtDeath before admission
--we might have AgeAtDeath after the day of death

-- last step, trying to get rid of multiple AgeAtDeath
-- tip: select the first AgeAtDeath

select id
	, icd9
	, AgeAtDX
	, min(AgeAtFirstDM) as AgeAtFirstDmM
	, min(AgeAtDeath) as AgeAtDeath
into #step4
from #step3
group by id, icd9, AgeAtDX

-- once #step4 is ready, store into dbo.clean
select *
	into dbo.clean
	from #step4

select count(*) from dbo.clean

--At the end, if you want to continue working in this window, you can drop all the temp tables
drop table #step 1,2,3, 4

----End of homework---
---Descriptive statistics----

select count(*) from dbo.clean

select distinct count(*) from dbo.clean

