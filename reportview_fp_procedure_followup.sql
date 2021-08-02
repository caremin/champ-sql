CREATE OR REPLACE VIEW public.reportview_fp_procedure_followup
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{contact,parent,_id}'::text[] AS hh_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,patient_gender}'::text[] AS patient_gender,
    reports.doc #>> '{fields,patient_age_in_months}'::text[] AS patient_age_months,
    reports.doc #>> '{fields,patient_age_in_years}'::text[] AS patient_age_years,
    reports.doc #>> '{fields,procedure_details,procedure}'::text[] AS procedure_status,
    reports.doc #>> '{fields,procedure_details,reason}'::text[] AS procedure_status_reason,
    reports.doc #>> '{fields,procedure_details_1,issues}'::text[] AS procedure_issues,
    reports.doc #>> '{fields,procedure_details_3,referral}'::text[] AS rhu_referral_given,
    reports.doc #>> '{fields,procedure_details_3,referral_followup}'::text[] AS rhu_referral_followup
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'fp_procedure_followup'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;