CREATE OR REPLACE VIEW public.reportview_pregnancy_followup
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{contact,parent,_id}'::text[] AS hh_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,patient_age_in_months}'::text[] AS patient_age_months,
    reports.doc #>> '{fields,patient_age_in_years}'::text[] AS patient_age_years,
    reports.doc #>> '{fields,danger_signs,any_signs}'::text[] AS any_danger_signs,
    reports.doc #>> '{fields,danger_signs,signs}'::text[] AS danger_signs,
    reports.doc #>> '{fields,danger_signs,months_pregnant}'::text[] AS dangersign_months_pregnant,
    reports.doc #>> '{fields,lmp_date_ctx}'::text[] AS last_menstrual_period_date,
    reports.doc #>> '{fields,check_up,remind}'::text[] AS checkup_remind,
    reports.doc #>> '{fields,check_up,prenatal_visit}'::text[] AS checkup_prenatal_visit,
    reports.doc #>> '{fields,check_up,num_prenatal_visit}'::text[] AS prenatal_visit_count,
    reports.doc #>> '{fields,check_up,num_visits_required}'::text[] AS prenatal_visit_required,
    reports.doc #>> '{fields,check_up,num_visits_already_done}'::text[] AS prenatal_visit_already_done,
    reports.doc #>> '{fields,micronutrient,any_micronutrient}'::text[] AS micronutrient_supplementation,
    reports.doc #>> '{fields,micronutrient,reason_action}'::text[] AS micronutrient_reason_action,
    reports.doc #>> '{fields,followup_details,continue}'::text[] AS followup_continue,
    reports.doc #>> '{fields,pregnancy_age_in_months}'::text[] AS pregnancy_age_months,
    reports.doc #>> '{fields,pregnancy_followup_date}'::text[] AS pregnancy_followup_date,
    reports.doc #>> '{fields,edd_format}'::text[] AS est_delivery_date
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'pregnancy_followup'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;