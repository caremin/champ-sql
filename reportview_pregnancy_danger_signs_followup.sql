CREATE OR REPLACE VIEW public.reportview_pregnancy_danger_signs_followup
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{contact,parent,_id}'::text[] AS hh_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,patient_age_in_months}'::text[] AS patient_age_months,
    reports.doc #>> '{fields,patient_age_in_years}'::text[] AS patient_age_years,
    reports.doc #>> '{fields,followup_details_1,has_visited_rhu}'::text[] AS followup1_visited_rhu,
    reports.doc #>> '{fields,followup_details_2,diagnosis}'::text[] AS followup2_diagnosis,
    reports.doc #>> '{fields,followup_details_2,rhu_visit}'::text[] AS followup2_rhuvisit_date,
    reports.doc #>> '{fields,followup_details_2,intervention}'::text[] AS followup2_intervention,
    reports.doc #>> '{fields,followup_details_3,issue_resolved}'::text[] AS followup3_issues_resolved,
    reports.doc #>> '{fields,fp_follow_task_date}'::text[] AS fp_followup_taskdate
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'pregnancy_danger_signs_followup'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;