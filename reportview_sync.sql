CREATE OR REPLACE VIEW public.reportview_sync
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,g_ask,synced}'::text[] AS synced,
    reports.doc #>> '{fields,inputs,source_id}'::text[] AS source_id
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'sync'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;