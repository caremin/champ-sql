CREATE OR REPLACE VIEW public.reportview_unmute
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,unmute_details,unmuting}'::text[] AS unmuting,
    reports.doc #>> '{fields,unmute_details,unmute_other}'::text[] AS unmute_other,
    reports.doc #>> '{fields,unmute_details,unmute_reason}'::text[] AS unmute_reason
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'unmute'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;