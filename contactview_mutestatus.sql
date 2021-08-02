CREATE OR REPLACE VIEW public.contactview_mutestatus
AS SELECT DISTINCT ON (all_reports.hhmem_uuid) all_reports.report_uuid,
    all_reports.report_date,
    all_reports.which_report,
    all_reports.hhmem_uuid,
    all_reports.chc_uuid,
    all_reports.patient_id,
    all_reports.muting,
    all_reports.mute_other,
    all_reports.mute_reason
   FROM ( SELECT rm.report_uuid,
            rm.report_date,
            rm.which_report,
            rm.hhmem_uuid,
            rm.chc_uuid,
            rm.patient_id,
            rm.muting,
            rm.mute_other,
            rm.mute_reason
           FROM reportview_mute rm
        UNION ALL
         SELECT ru.report_uuid,
            ru.report_date,
            ru.which_report,
            ru.hhmem_uuid,
            ru.chc_uuid,
            ru.patient_id,
            ru.unmuting,
            ru.unmute_other,
            ru.unmute_reason
           FROM reportview_unmute ru
  ORDER BY 4, 2 DESC) all_reports;