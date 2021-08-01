CREATE OR REPLACE VIEW public.reportview_fp_with_issues_followup
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
    reports.doc #>> '{fields,fp_referral_followup_date}'::text[] AS referral_followup_date,
    reports.doc #>> '{fields,followup_details_1,continue}'::text[] AS continue_followup,
    reports.doc #>> '{fields,followup_details_1,reschedule}'::text[] AS reschedule_followup,
    reports.doc #>> '{fields,followup_details_2,visit_rhu}'::text[] AS visit_rhu,
    reports.doc #>> '{fields,followup_details_2,reason}'::text[] AS reason_unattended_rhu,
    reports.doc #>> '{fields,followup_details_3,issues_resolved}'::text[] AS issues_resolved,
    reports.doc #>> '{fields,followup_details_3,why_not_resolved}'::text[] AS issues_status,
    reports.doc #>> '{fields,followup_details_3,visit_date}'::text[] AS visit_rhu_date,
    reports.doc #>> '{fields,followup_details_3,intervention}'::text[] AS intervention,
    reports.doc #>> '{fields,followup_details_3,diagnosis}'::text[] AS final_diagnosis
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'fp_with_issues_followup'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;