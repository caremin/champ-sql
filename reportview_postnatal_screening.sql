CREATE OR REPLACE VIEW public.reportview_postnatal_screening
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{contact,parent,_id}'::text[] AS hh_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,nutrition_details_2,weight}'::text[] AS weight,
    reports.doc #>> '{fields,nutrition_details_2,know_height}'::text[] AS know_height,
    reports.doc #>> '{fields,nutrition_details_3,bmi}'::text[] AS bmi,
    reports.doc #>> '{fields,nutrition_details_3,classify_bmi}'::text[] AS classify_bmi,
    reports.doc #>> '{fields,nutrition_details_3,classify_bmi_label}'::text[] AS classify_bmi_label,
    reports.doc #>> '{fields,nutrition_details_3,classification}'::text[] AS classification,
    reports.doc #>> '{fields,nutrition_details_5,rhu_given}'::text[] AS rhu_given
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'postnatal_screening'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;