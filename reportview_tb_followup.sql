CREATE OR REPLACE VIEW public.reportview_tb_followup
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{contact,parent,_id}'::text[] AS hh_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,g_continue,continue}'::text[] AS continue_followup_today,
    reports.doc #>> '{fields,g_continue,reschedule}'::text[] AS reschedule_date,
    reports.doc #>> '{fields,test_followup_date}'::text[] AS followup_date,
    reports.doc #>> '{fields,g_visit,visit_rhu}'::text[] AS visit_rhu,
    reports.doc #>> '{fields,g_visit,reason_no_visit}'::text[] AS reason_visit_rhu,
    reports.doc #>> '{fields,g_date,visit_date}'::text[] AS visit_rhu_date,
    reports.doc #>> '{fields,g_date,test_needed}'::text[] AS need_appointment,
    reports.doc #>> '{fields,g_date,test_appointment_date}'::text[] AS appointment_date,
    reports.doc #>> '{fields,g_test,test_date}'::text[] AS testing_date,
    reports.doc #>> '{fields,g_test,test_done}'::text[] AS done_testing,
    reports.doc #>> '{fields,g_test,test_other}'::text[] AS other_testing_specify,
    reports.doc #>> '{fields,g_test,test_facility}'::text[] AS testing_facility,
    reports.doc #>> '{fields,g_test,facility_name}'::text[] AS facility_name,
    reports.doc #>> '{fields,g_test,diagnosis_needed}'::text[] AS test_diagnosis_needed,
    reports.doc #>> '{fields,g_test,diagnosis_appointment_date}'::text[] AS diagnosis_appointment_date,
    reports.doc #>> '{fields,g_diagnosis,rhu_visit}'::text[] AS diagnosis_visit_date,
    reports.doc #>> '{fields,g_diagnosis,diagnosis}'::text[] AS visit_diagnosis_status,
    reports.doc #>> '{fields,g_enrol,enrolled_dots}'::text[] AS enrolled_dots,
    reports.doc #>> '{fields,g_enrol,not_enrolled_dots}'::text[] AS enrolling_reasons,
    reports.doc #>> '{fields,g_enrol,enrolled_dots_date}'::text[] AS date_enrolled_dots
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'tb_followup'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;