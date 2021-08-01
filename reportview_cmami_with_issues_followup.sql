CREATE OR REPLACE VIEW public.reportview_cmami_with_issues_followup
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{contact,parent,_id}'::text[] AS hh_uuid,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,patient_gender}'::text[] AS patient_gender,
    reports.doc #>> '{fields,inputs,contact,date_of_birth}'::text[] AS patient_birthdate,
    reports.doc #>> '{fields,patient_age_in_months}'::text[] AS age_in_months,
    reports.doc #>> '{fields,patient_age_in_years}'::text[] AS age_in_years,
    reports.doc #>> '{fields,followup_details_1,continue}'::text[] AS ff1_details,
    reports.doc #>> '{fields,followup_details_2,visit_rhu}'::text[] AS ff2_visit_rhu,
    reports.doc #>> '{fields,followup_details_3,diagnosis}'::text[] AS ff3_diagnosis,
    reports.doc #>> '{fields,followup_details_3,visit_date}'::text[] AS ff3_visit_date,
    reports.doc #>> '{fields,followup_details_3,internvention}'::text[] AS ff3_intervention,
    reports.doc #>> '{fields,followup_details_3,issues_resolved}'::text[] AS ff3_issues_resolved
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'cmami_with_issues_followup'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;