CREATE OR REPLACE VIEW public.reportview_fp_followup
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
    reports.doc #>> '{fields,visit_details_1,rhu_visit}'::text[] AS rhu_visit_date,
    reports.doc #>> '{fields,visit_details_1,use_fp}'::text[] AS decided_using_fp,
    reports.doc #>> '{fields,followup_details_1,continue}'::text[] AS cont_flwup_today,
    reports.doc #>> '{fields,followup_details_1,reschedule}'::text[] AS resched_flwup_date,
    reports.doc #>> '{fields,visit_details_2,fp_type}'::text[] AS fp_type_method,
    reports.doc #>> '{fields,followup_details_2,visit_rhu}'::text[] AS followup2_rhu_visit,
    reports.doc #>> '{fields,followup_details_2,reason}'::text[] AS not_attending_reason,
    reports.doc #>> '{fields,visit_details_3,fp_appointment}'::text[] AS another_fp_appointment,
    reports.doc #>> '{fields,visit_details_3,next_appointment}'::text[] AS next_appointment_date,
    reports.doc #>> '{fields,visit_details_4,fp_procedure}'::text[] AS fp_procedure,
    reports.doc #>> '{fields,visit_details_4,no_fp_procedure}'::text[] AS fp_state_reason,
    reports.doc #>> '{fields,visit_details_5,issues}'::text[] AS issues_concerns,
    reports.doc #>> '{fields,visit_details_7,referral}'::text[] AS rhu_referral_given
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'fp_followup'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;