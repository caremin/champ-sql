CREATE OR REPLACE VIEW public.reportview_tb_monthly_followup
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{contact,parent,_id}'::text[] AS hh_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,followup_details_01,continue}'::text[] AS continue_followup_today,
    reports.doc #>> '{fields,followup_details_01,reschedule}'::text[] AS reschedule_date_followup,
    reports.doc #>> '{fields,followup_details_02,months}'::text[] AS months_of_treatment,
    reports.doc #>> '{fields,followup_details_02,comply_with_treatment}'::text[] AS complying_with_treatment,
    reports.doc #>> '{fields,followup_details_03,reason}'::text[] AS reasons_not_complying
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'tb_monthly_followup'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;