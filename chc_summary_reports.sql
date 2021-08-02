CREATE OR REPLACE VIEW public.chc_summary_reports
AS SELECT report_count.chc_uuid,
    report_count.chc_id,
    report_count.which_report,
    count(DISTINCT report_count.hhmem_uuid) AS unique_hhmem,
    min(report_count.report_date) AS first_report,
    max(report_count.report_date) AS last_report,
        CASE
            WHEN max(report_count.report_date) > (CURRENT_DATE - 30) AND max(report_count.report_date) <= (CURRENT_DATE - 15) THEN 'delayed 2w'::text
            WHEN max(report_count.report_date) <= (CURRENT_DATE - 30) THEN 'delayed 1mo'::text
            ELSE 'recent'::text
        END AS chc_report_sync,
    count(*) AS count_report
   FROM ( SELECT reports.doc ->> '_id'::text AS report_uuid,
            to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
            reports.doc ->> 'form'::text AS which_report,
            reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
            reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
            person.doc ->> 'patient_id'::text AS chc_id
           FROM raw_reports reports
             LEFT JOIN raw_contacts person ON (person.doc ->> '_id'::text) = (reports.doc #>> '{contact,_id}'::text[])
          WHERE (reports.doc #>> '{fields,patient_uuid}'::text[]) <> ''::text) report_count
  GROUP BY report_count.chc_uuid, report_count.chc_id, report_count.which_report
  ORDER BY report_count.chc_uuid, report_count.chc_id, report_count.which_report;