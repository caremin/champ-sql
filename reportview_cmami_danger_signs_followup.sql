CREATE OR REPLACE VIEW public.reportview_cmami_danger_signs_followup
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{contact,parent,_id}'::text[] AS hh_uuid,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,patient_name}'::text[] AS patient_name,
    reports.doc #>> '{fields,patient_gender}'::text[] AS patient_gender,
    reports.doc #>> '{fields,inputs,contact,date_of_birth}'::text[] AS patient_birthdate,
    reports.doc #>> '{fields,patient_age_in_months}'::text[] AS age_in_months,
    reports.doc #>> '{fields,patient_age_in_years}'::text[] AS age_in_years,
    reports.doc #>> '{fields,data,__rhu_visit_done}'::text[] AS patient_rhu_visitation,
    reports.doc #>> '{fields,data,__intervention}'::text[] AS patient_intervention,
    reports.doc #>> '{fields,data,__was_issue_resolved}'::text[] AS patient_issue,
    reports.doc #>> '{fields,data,__diagnosis}'::text[] AS patient_diagnosis,
    reports.doc #>> '{fields,followup_details_2,visit_rhu}'::text[] AS second_visitation,
    reports.doc #>> '{fields,followup_details_2,reason}'::text[] AS visitation_reasons
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'cmami_danger_signs_followup'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;