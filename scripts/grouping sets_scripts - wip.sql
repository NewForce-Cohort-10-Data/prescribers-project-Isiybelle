-- 1 Write a query which returns the total number of claims for these two groups. Your output should look like this:
-- select specialty_description, sum(total_claim_count) as total_claims
-- from prescriber
-- join prescription
-- 	using (npi)
-- where specialty_description = 'Interventional Pain Management'
-- 	or specialty_description = 'Pain Management'
-- group by specialty_description;


-- 2 Now, let's say that we want our output to also include the total number of claims between these two groups. Combine two queries with the UNION keyword to accomplish this. Your output should look like this:
-- select specialty_description, sum(total_claim_count) as total_claims
-- from prescriber
-- join prescription
-- 	using (npi)
-- where specialty_description = 'Interventional Pain Management'
-- 	or specialty_description = 'Pain Management'
-- group by specialty_description
-- union
-- select null, sum(total_claim_count) as total_claims
-- from prescriber
-- join prescription
-- 	using (npi)
-- where specialty_description = 'Interventional Pain Management'
-- 	or specialty_description = 'Pain Management';


-- 3 Now, instead of using UNION, make use of GROUPING SETS (https://www.postgresql.org/docs/10/queries-table-expressions.html#QUERIES-GROUPING-SETS) to achieve the same output.
select specialty_description
	from prescriber group by grouping sets ((specialty_description))
where specialty_description = 'Interventional Pain Management'
	or specialty_description = 'Pain Management';