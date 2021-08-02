CREATE OR REPLACE VIEW public.reportview_tb_test_followup
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
    reports.doc #>> '{fields,diagnosis_followup_date}'::text[] AS diagnosis_followup_date,
    reports.doc #>> '{fields,g_visit,visit_rhu}'::text[] AS visit_rhu,
    reports.doc #>> '{fields,g_visit,reason_no_visit}'::text[] AS reason_no_visit,
    reports.doc #>> '{fields,g_test,test_date}'::text[] AS date_of_testing,
    reports.doc #>> '{fields,g_test,test_done}'::text[] AS test_done,
    reports.doc #>> '{fields,g_test,facility_name}'::text[] AS facility_name,
    reports.doc #>> '{fields,g_test,test_facility}'::text[] AS facility,
    reports.doc #>> '{fields,g_test,diagnosis_needed}'::text[] AS aptmnt_for_diagnosis,
    reports.doc #>> '{fields,g_test,diagnosis_appointment_date}'::text[] AS diagnosis_aptmnt_date
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'tb_test_followup'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;