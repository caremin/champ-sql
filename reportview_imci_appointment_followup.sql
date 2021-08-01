CREATE OR REPLACE VIEW public.reportview_imci_appointment_followup
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
    reports.doc #>> '{fields,g_details,attended}'::text[] AS attended_appointment,
    reports.doc #>> '{fields,g_details,diagnosis}'::text[] AS attendee_diagnosis,
    reports.doc #>> '{fields,g_details,treatment_state}'::text[] AS attendee_treatment_state
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'imci_appointment_followup'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;