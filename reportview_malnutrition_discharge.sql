CREATE OR REPLACE VIEW public.reportview_malnutrition_discharge
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{contact,parent,_id}'::text[] AS hh_uuid,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,patient_gender}'::text[] AS patient_gender,
    reports.doc #>> '{fields,patient_age_in_months}'::text[] AS patientage_months,
    reports.doc #>> '{fields,patient_age_in_years}'::text[] AS patientage_years,
    reports.doc #>> '{fields,details,weeks}'::text[] AS details_weeks,
    reports.doc #>> '{fields,details,weight}'::text[] AS weight,
    reports.doc #>> '{fields,details,wfa_class}'::text[] AS wfa_class,
    reports.doc #>> '{fields,details,wfa_score}'::text[] AS wfa_score,
    reports.doc #>> '{fields,details,discharge_date}'::text[] AS discharge_date
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'malnutrition_discharge'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;