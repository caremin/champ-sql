CREATE OR REPLACE VIEW public.reportview_malnutrition_2w
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,patient_name}'::text[] AS patient_name,
    reports.doc #>> '{fields,patient_gender}'::text[] AS patient_gender,
    reports.doc #>> '{fields,inputs,contact,date_of_birth}'::text[] AS patient_birthdate,
    reports.doc #>> '{fields,inputs,contact,parent,parent,contact,name}'::text[] AS patient_parent_name,
    reports.doc #>> '{fields,inputs,contact,parent,parent,contact,phone}'::text[] AS patient_parent_phone,
    reports.doc #>> '{fields,g_followup,weight}'::text[] AS rhu_weight,
    reports.doc #>> '{fields,g_followup,issues}'::text[] AS issues_concern,
    reports.doc #>> '{fields,g_followup,attending_rhu}'::text[] AS rhu_attendance,
    reports.doc #>> '{fields,g_followup,complaint}'::text[] AS complaints_with_treatment,
    reports.doc #>> '{fields,g_followup,wfa_class}'::text[] AS malnutr_status,
    reports.doc #>> '{fields,g_followup,wfa_score}'::text[] AS malnutr_score,
    reports.doc #>> '{fields,malnutrition_referral_given}'::text[] AS malnutr_referral_given,
    to_date(
        CASE
            WHEN (reports.doc #>> '{fields,visit_date_format}'::text[]) = ''::text THEN NULL::text
            ELSE reports.doc #>> '{fields,visit_date_format}'::text[]
        END, 'DD-MM-YYYY'::text) AS visit_date,
    reports.doc #>> '{fields,malnutrition_every_2w_followup_date}'::text[] AS malnutrition_followup_date,
    reports.doc #>> '{fields,patient_age_in_days}'::text[] AS patient_age_in_days,
    reports.doc #>> '{fields,patient_age_in_weeks}'::text[] AS patient_age_in_weeks,
    reports.doc #>> '{fields,patient_age_in_years}'::text[] AS patient_age_in_years,
    reports.doc #>> '{fields,patient_age_in_months}'::text[] AS patient_age_in_months,
    reports.doc #>> '{fields,data,meta,__source_id}'::text[] AS data_source_id,
    reports.doc #>> '{fields,data,meta,__household_uuid}'::text[] AS household_uuid
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'malnutrition_followup_every_2w'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;