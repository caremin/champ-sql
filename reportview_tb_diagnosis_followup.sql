CREATE OR REPLACE VIEW public.reportview_tb_diagnosis_followup
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{contact,parent,_id}'::text[] AS hh_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,visit_details_1,rhu_diagnosis}'::text[] AS visit1_rhu_diagnosis,
    reports.doc #>> '{fields,visit_details_1,reason}'::text[] AS visit1_details,
    reports.doc #>> '{fields,visit_details_2,reason}'::text[] AS visit2_attending_reason,
    reports.doc #>> '{fields,visit_details_2,rhu_visit}'::text[] AS visit2_date_attended,
    reports.doc #>> '{fields,visit_details_2,diagnosis}'::text[] AS visit2_diagnosis,
    reports.doc #>> '{fields,visit_details_3,enrolled_dots}'::text[] AS visit3_enrolled_dots,
    reports.doc #>> '{fields,visit_details_3,not_enrolled_dots}'::text[] AS visit3_enrolled_dots_reason,
    reports.doc #>> '{fields,visit_details_3,enrolled_dots_date}'::text[] AS visit3_enrolled_dots_date
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'tb_diagnosis_followup'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;