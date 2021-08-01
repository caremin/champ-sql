CREATE OR REPLACE VIEW public.combined_malnutrtion_reportcnt
AS SELECT screening_count.id AS hhmem_uuid,
    screening_count.screening_status_current,
    screening_count.screening_status_previous,
    report_count.mal_screening,
    report_count.mal_48hfollowup,
    report_count.mal_2wfollowup,
    report_count.mal_issues,
    report_count.mal_discharge
   FROM ( SELECT crosstab.id,
            crosstab.screening_status_current,
            crosstab.screening_status_previous
           FROM crosstab('select 
hhmem_uuid as id,
ROW_NUMBER () OVER (
		PARTITION BY hhmem_uuid
		ORDER BY
			cm.report_date) as screening_count,
cm.malnutr_status
from combined_malnutrition cm 
WHERE cm.malnutr_stage = ''screening''::text 
ORDER BY cm.hhmem_uuid, cm.report_date desc'::text, 'select distinct order_screening.screening_count from (select 
hhmem_uuid as id,
ROW_NUMBER () OVER (
		PARTITION BY hhmem_uuid
		ORDER BY
			cm.report_date) as screening_count,
cm.malnutr_status
from combined_malnutrition cm 
WHERE cm.malnutr_stage = ''screening''::text ORDER BY cm.hhmem_uuid, cm.report_date desc) order_screening
where order_screening.screening_count <= 2
order by order_screening.screening_count'::text) crosstab(id text, screening_status_current text, screening_status_previous text)) screening_count
     LEFT JOIN ( SELECT crosstab.id,
            crosstab.mal_screening,
            crosstab.mal_48hfollowup,
            crosstab.mal_2wfollowup,
            crosstab.mal_issues,
            crosstab.mal_discharge
           FROM crosstab('select 
hhmem_uuid as id,
cm.malnutr_stage as screening_count,
count(*)
from combined_malnutrition cm
group by hhmem_uuid, malnutr_stage'::text, 'select distinct cm.malnutr_stage 
from combined_malnutrition cm 
order by cm.malnutr_stage desc'::text) crosstab(id text, mal_screening text, mal_issues text, mal_2wfollowup text, mal_48hfollowup text, mal_discharge text)) report_count ON report_count.id = screening_count.id;