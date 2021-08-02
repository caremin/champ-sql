CREATE OR REPLACE VIEW public.reportview_child_health_danger_signs_followup
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{contact,parent,_id}'::text[] AS hh_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,followup_details_2,visit_rhu}'::text[] AS followup_visit_rhu,
    reports.doc #>> '{fields,followup_details_2,reason}'::text[] AS followup_reaason,
    reports.doc #>> '{fields,patient_gender}'::text[] AS patient_gender,
    reports.doc #>> '{fields,patient_age_in_years}'::text[] AS patient_age_years,
    reports.doc #>> '{fields,patient_age_in_months}'::text[] AS patient_age_months,
    reports.doc #>> '{fields,data,__diagnosis}'::text[] AS diagnosis,
    reports.doc #>> '{fields,data,__intervention}'::text[] AS intervention,
    reports.doc #>> '{fields,data,__was_issue_resolved}'::text[] AS was_issues_resolved
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'child_health_danger_signs_followup'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;