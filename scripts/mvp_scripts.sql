-- 1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
-- select npi, sum(total_claim_count) as total_claims
-- from prescription
-- join prescriber
-- 	using (npi)
-- group by npi
-- order by total_claims desc;
--1881634483 at 99707 claims


-- 1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.
-- select nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, sum(total_claim_count) as total_claims
-- from prescription
-- join prescriber
-- 	using (npi)
-- group by nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
-- order by total_claims desc;



-- 2a. Which specialty had the most total number of claims (totaled over all drugs)?
-- select specialty_description, sum(total_claim_count) as total_claims
-- from prescriber
-- join prescription
-- 	using (npi)
-- group by specialty_description
-- order by total_claims desc;
-- family practice had the most overall claims at 9752347

-- 2b. Which specialty had the most total number of claims for opioids?
-- select specialty_description, sum(total_claim_count) as total_claims
-- from prescriber
-- join prescription
-- 	using (npi)
-- join drug
-- 	using (drug_name)
-- where opioid_drug_flag = 'Y'
-- group by specialty_description
-- order by total_claims desc;
-- Nurse Practitioner had the most claims for opioids at 900845

-- 2c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
-- (select specialty_description, count(drug_name) as presciption_count
-- from prescriber
-- left join prescription
-- 	using (npi)
-- group by specialty_description)
-- except
-- (select specialty_description, count(drug_name)
-- from prescriber
-- left join prescription
-- 	using (npi)
-- where drug_name is not null
-- group by specialty_description);

--Tommy's query
-- select specialty_description, sum(total_claim_count) as total_claim
-- from prescriber
-- left join prescription
-- 	using (npi)
-- group by specialty_description
-- having sum(total_claim_count) is null;

-- 2d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?
-- with opioid_info as (
-- 	select npi, opioid_drug_flag,
-- 		case
-- 			when opioid_drug_flag = 'Y' then total_claim_count
-- 			else 0
-- 		end as opioid_claims
-- 	from prescription
-- 	join drug
-- 		using (drug_name))
-- select specialty_description, round((sum(opioid_claims) / sum(total_claim_count) * 100), 0) as total_opioid
-- from prescription
-- join prescriber
-- 	using (npi)
-- join opioid_info
--  	using (npi)
-- group by specialty_description
-- order by total_opioid desc;

--Madi's query
-- SELECT p.specialty_description,
--  	   ROUND(100.0 * SUM(CASE WHEN d.opioid_drug_flag = 'Y'
--     THEN pr.total_claim_count
--     ELSE 0 END)
-- /   SUM(pr.total_claim_count), 2) AS opioid_percentage
-- FROM prescriber p
-- JOIN prescription pr USING (npi)
-- JOIN drug d ON pr.drug_name = d.drug_name
-- GROUP BY p.specialty_description
-- ORDER BY opioid_percentage DESC;

--Tommy's query
-- select
-- 	specialty_description,
-- 	round(sum(case when opioid_drug_flag = 'Y' then total_claim_count end)/sum(total_claim_count) * 100,2) as percent_opioid
-- from prescriber
-- left join prescription using(npi)
-- left join drug using(drug_name)
-- group by specialty_description
-- order by percent_opioid desc nulls last;

-- with total_opioid_percentage as (
-- 	select npi, count(opioid_drug_flag) / sum (total_claim_count) as op_percentage
-- 	from drug
-- 	join prescription
-- 		using (drug_name)
-- 	group by npi)
-- select specialty_description, round(avg(op_percentage), 2) as avg_op_percentage
-- from prescriber
-- join total_opioid_percentage
-- 	using (npi)
-- group by specialty_description
-- order by avg_op_percentage desc;

-- with total_opioid_percentage as (
-- 	select npi,
-- 	(sum (case when opioid_drug_flag = 'Y' then coalesce(total_claim_count,0) end) / sum (coalesce(total_claim_count,0))) as op_percentage
-- 	from prescription
-- 	join drug
-- 		using (drug_name)
-- 	group by npi)
-- select specialty_description, op_percentage
-- from prescriber
-- join total_opioid_percentage
-- 	using (npi)
-- where op_percentage is not null
-- order by op_percentage desc;

-- select specialty_description, opioid_drug_flag
-- from prescription
-- join drug
-- 	using (drug_name)
-- join prescriber
-- 	using (npi)
-- where specialty_description = 'Case Manager/Care Coordinator';


-- with specialties as (
-- 	select npi, specialty_description
-- 	from prescriber
-- 	group by specialty_description, npi)
-- select specialty_description, count(opioid_drug_flag) / sum (total_claim_count) as op_percentage
-- from drug
-- join prescription
-- 	using (drug_name)
-- join specialties
-- 	using (npi)
-- group by specialty_description
-- order by op_percentage desc;


-- 3a. Which drug (generic_name) had the highest total drug cost?
-- select generic_name, sum(total_drug_cost)::money as total_cost
-- from drug
-- join prescription
-- 	using (drug_name)
-- group by generic_name
-- order by total_cost desc;
-- "INSULIN GLARGINE,HUM.REC.ANLOG" at $104,264,066.35

-- 3b. Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.
-- select generic_name, round(sum(total_drug_cost) / sum(total_day_supply), 2) as highest_cost_per_day
-- from drug
-- join prescription
-- 	using (drug_name)
-- group by generic_name
-- order by highest_cost_per_day desc;
-- "C1 ESTERASE INHIBITOR" at 3495.22 per day



-- 4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. Hint: You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/
-- select drug_name,
-- 	case
-- 		when opioid_drug_flag = 'Y' then 'opioid'
-- 		when antibiotic_drug_flag = 'Y' then 'antibiotic'
-- 		else 'neither'
-- 	end as drug_type
-- from drug;

-- 4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
-- with drug_separation as (
-- 	select drug_name,
-- 		case
-- 			when opioid_drug_flag = 'Y' then 'opioid'
-- 			when antibiotic_drug_flag = 'Y' then 'antibiotic'
-- 			else 'neither'
-- 		end as drug_type
-- 	from drug)
-- select 
-- 	sum (case when drug_type = 'opioid' then total_drug_cost end)::money as opioid_costs,
-- 	sum (case when drug_type = 'antibiotic' then total_drug_cost end)::money as antibiotic_costs
-- from prescription
-- join drug_separation
-- 	using (drug_name);

--Madi's answer
-- SELECT
--     CASE
--         WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
--         WHEN d.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
--     END AS drug_type,
--     SUM(p.total_drug_cost)::MONEY AS total_spent
-- FROM prescription p
-- JOIN drug d ON p.drug_name = d.drug_name
-- WHERE d.opioid_drug_flag = 'Y' OR d.antibiotic_drug_flag = 'Y'
-- GROUP BY drug_type
-- ORDER BY total_spent DESC;

-- select
-- 	sum (case when opioid_drug_flag = 'Y' then total_drug_cost end)::money as opioid_costs,
-- 	sum (case when antibiotic_drug_flag = 'Y' then total_drug_cost end):: money as antibiotic_costs
-- from prescription
-- join drug
-- 	using (drug_name);


-- 5a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.
-- select state, count(distinct cbsa)
-- from cbsa
-- join fips_county
-- 	using (fipscounty)
-- where state = 'TN'
-- group by state;


-- 5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
-- select cbsaname, sum(population) as total_pop
-- from cbsa
-- join population
-- 	using (fipscounty)
-- group by cbsaname
-- order by total_pop desc;
-- Nashville-Davidson--Murfreesboro--Franklin, TN has the most at 1830410, Morristown, TN has the least at 116352

-- 5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
-- with non_cbsa_counties as (
-- 	select fipscounty
-- 	from population
-- 	except
-- 	select fipscounty
-- 	from cbsa)
-- select county, population
-- from fips_county
-- join population
-- 	using (fipscounty)
-- join non_cbsa_counties
-- 	using (fipscounty)
-- order by population desc;
-- SEVIER at 95523

--Tommy's query
-- select county, population
-- from fips_county
-- join population
-- 	using (fipscounty)
-- where fipscounty not in (select fipscounty from cbsa)
-- order by population desc;

-- Victoria's query
-- SELECT county, population.population
-- FROM fips_county
-- inner join population
--         ON fips_county.fipscounty = population.fipscounty
-- left JOIN cbsa
--         ON fips_county.fipscounty = cbsa.fipscounty
-- WHERE cbsa.fipscounty is null
-- ORDER BY population.population desc;


-- 6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
-- select drug_name, total_claim_count
-- from prescription
-- where total_claim_count >= 3000;

-- 6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
-- select drug_name, total_claim_count, opioid_drug_flag
-- from prescription
-- join drug
-- 	using (drug_name)
-- where total_claim_count >= 3000;

-- select drug_name, total_claim_count,
-- 	case
-- 		when opioid_drug_flag = 'Y' then 'Y'
-- 		when long_acting_opioid_drug_flag = 'Y' then 'Y'
-- 		else 'N'
-- 	end as opioid
-- from prescription
-- join drug
-- 	using (drug_name)
-- where total_claim_count >= 3000;

-- 6c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
-- select nppes_provider_first_name, nppes_provider_last_org_name, drug_name, total_claim_count, opioid_drug_flag
-- from prescription
-- join drug
-- 	using (drug_name)
-- join prescriber
-- 	using (npi)
-- where total_claim_count >= 3000;

-- select nppes_provider_first_name, nppes_provider_last_org_name, drug_name, total_claim_count,
-- 	case
-- 		when opioid_drug_flag = 'Y' then 'Y'
-- 		when long_acting_opioid_drug_flag = 'Y' then 'Y'
-- 		else 'N'
-- 	end as opioid
-- from prescription
-- join drug
-- 	using (drug_name)
-- join prescriber
-- 	using (npi)
-- where total_claim_count >= 3000;


-- The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. Hint: The results from all 3 parts will have 637 rows.

-- 7a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
-- select npi, drug_name
-- from prescriber
-- cross join drug
-- where specialty_description = 'Pain Management'
-- 	and nppes_provider_city = 'NASHVILLE'
-- 	and opioid_drug_flag = 'Y';


-- 7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
-- select npi, drug.drug_name, coalesce(total_claim_count,0) as total_claims
-- from prescriber
-- cross join drug
-- left join prescription
-- 	using (npi, drug_name)
-- where specialty_description = 'Pain Management'
-- 	and nppes_provider_city = 'NASHVILLE'
-- 	and opioid_drug_flag = 'Y'
-- order by total_claims desc;

-- 7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
-- select npi, drug.drug_name, coalesce(total_claim_count,0) as total_claims
-- from prescriber
-- cross join drug
-- left join prescription
-- 	using (npi, drug_name)
-- where specialty_description = 'Pain Management'
-- 	and nppes_provider_city = 'NASHVILLE'
-- 	and opioid_drug_flag = 'Y'
-- order by total_claims desc;