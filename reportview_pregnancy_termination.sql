CREATE OR REPLACE VIEW public.reportview_pregnancy_termination
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{contact,parent,_id}'::text[] AS hh_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,lmp_date_ctx}'::text[] AS last_menstrual_period_date,
    reports.doc #>> '{fields,pregnancy_termination,months_pregnant}'::text[] AS months_pregnant,
    reports.doc #>> '{fields,pregnancy_termination,termination_reason}'::text[] AS termination_reason,
    reports.doc #>> '{fields,pregnancy_termination,date_of_termination}'::text[] AS date_of_termination
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'pregnancy_termination'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;