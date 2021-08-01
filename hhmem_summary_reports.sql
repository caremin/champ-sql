CREATE OR REPLACE VIEW public.hhmem_summary_reports
AS SELECT report_count.hhmem_uuid,
    report_count.which_report,
    min(report_count.report_date) AS first_report,
    max(report_count.report_date) AS last_report,
        CASE
            WHEN max(report_count.report_date) > (CURRENT_DATE - 30) AND max(report_count.report_date) <= (CURRENT_DATE - 15) THEN '2w ago'::text
            WHEN max(report_count.report_date) <= (CURRENT_DATE - 30) THEN '1mo ago'::text
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
  GROUP BY report_count.hhmem_uuid, report_count.which_report
  ORDER BY report_count.hhmem_uuid, (max(report_count.report_date)) DESC;