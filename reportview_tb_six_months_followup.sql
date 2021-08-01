CREATE OR REPLACE VIEW public.reportview_tb_six_months_followup
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{contact,parent,_id}'::text[] AS hh_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,patient_age_in_months}'::text[] AS patient_age_months,
    reports.doc #>> '{fields,patient_age_in_years}'::text[] AS patient_age_years,
    reports.doc #>> '{fields,patient_gender}'::text[] AS patient_gender,
    reports.doc #>> '{fields,tb_monthly_followup_date}'::text[] AS tb_monthly_flwupdate,
    reports.doc #>> '{fields,g_treatment_01,completed_treatment}'::text[] AS completed_treatment,
    reports.doc #>> '{fields,g_treatment_01,reason_not_completed}'::text[] AS reason_not_completed,
    reports.doc #>> '{fields,g_treatment_01,other_reason}'::text[] AS treatment_other_reason,
    reports.doc #>> '{fields,g_treatment_02,diagnosis_completion}'::text[] AS diagnosis_completion,
    reports.doc #>> '{fields,g_treatment_02,ongoing_treatment}'::text[] AS ongoing_treatment
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'tb_six_months_followup'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;