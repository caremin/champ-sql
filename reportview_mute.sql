CREATE OR REPLACE VIEW public.reportview_mute
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,mute_details,muting}'::text[] AS muting,
    reports.doc #>> '{fields,mute_details,mute_other}'::text[] AS mute_other,
    reports.doc #>> '{fields,mute_details,mute_reason}'::text[] AS mute_reason
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'mute'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;