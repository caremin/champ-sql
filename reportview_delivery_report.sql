CREATE OR REPLACE VIEW public.reportview_delivery_report
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{contact,parent,_id}'::text[] AS hh_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,delivery_details,date_of_delivery}'::text[] AS date_of_delivery,
    reports.doc #>> '{fields,delivery_details,place_of_delivery}'::text[] AS place_of_delivery,
    reports.doc #>> '{fields,delivery_details,other_place}'::text[] AS other_place_of_delivery,
    reports.doc #>> '{fields,delivery_details,number_of_live_births}'::text[] AS number_of_live_birth
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'delivery_report'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;