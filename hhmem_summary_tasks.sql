CREATE OR REPLACE VIEW public.hhmem_summary_tasks
AS SELECT task_overview.hhmem_uuid,
    task_overview.task_title,
        CASE
            WHEN task_overview.task_title = 'task.anc.pregnancy_danger_signs_followup.title'::text THEN 'pregnancy_danger_signs_followup'::text
            WHEN task_overview.task_title = 'task.anc.pregnancy_followup.title'::text THEN 'pregnancy_followup'::text
            WHEN task_overview.task_title = 'task.child_health.danger_signs.title'::text THEN 'child_health_danger_signs_followup'::text
            WHEN task_overview.task_title = 'task.cmami.danger_signs.title'::text THEN 'cmami_danger_signs_followup'::text
            WHEN task_overview.task_title = 'task.cmami.followup.title'::text THEN 'cmami_followup'::text
            WHEN task_overview.task_title = 'task.cmami.screening.title'::text THEN 'cmami_screening'::text
            WHEN task_overview.task_title = 'task.cmami.with_issues_followup.title'::text THEN 'cmami_with_issues_followup'::text
            WHEN task_overview.task_title = 'task.fp.followup.title'::text THEN 'fp_followup'::text
            WHEN task_overview.task_title = 'task.fp.procedure.title'::text THEN 'fp_procedure_followup'::text
            WHEN task_overview.task_title = 'task.fp.screening_followup.title'::text THEN 'fp_screening_followup'::text
            WHEN task_overview.task_title = 'task.fp.with_issues_followup.title'::text THEN 'fp_with_issues_followup'::text
            WHEN task_overview.task_title = 'task.imci_48_hrs.title'::text THEN 'imci_followup_48h'::text
            WHEN task_overview.task_title = 'task.imci_appointment_followup.title'::text THEN 'imci_appointment_followup'::text
            WHEN task_overview.task_title = 'task.imci_every_2_weeks.title'::text THEN 'imci_followup_every_2w'::text
            WHEN task_overview.task_title = 'task.imci_weekly.title'::text THEN 'imci_followup_weekly'::text
            WHEN task_overview.task_title = 'task.malnutrition_48_hrs.title'::text THEN 'malnutrition_followup_48h'::text
            WHEN task_overview.task_title = 'task.malnutrition_every_2_weeks.title'::text THEN 'malnutrition_followup_every_2w'::text
            WHEN task_overview.task_title = 'task.malnutrition.with_issues_followup.title'::text THEN 'malnutrition_with_issues_followup'::text
            WHEN task_overview.task_title = 'task.pnc.postnatal.screening.title'::text THEN 'postnatal_screening'::text
            WHEN task_overview.task_title = 'task.screening.title'::text THEN 'screening'::text
            WHEN task_overview.task_title = 'task.sync.title'::text THEN 'sync'::text
            WHEN task_overview.task_title = 'tb.followup.6months.title'::text THEN 'tb_six_months_followup'::text
            WHEN task_overview.task_title = 'tb.followup.diagnosis.title'::text THEN 'tb_diagnosis_followup'::text
            WHEN task_overview.task_title = 'tb.follow_up.monthly.title'::text THEN 'tb_monthly_followup'::text
            WHEN task_overview.task_title = 'tb.followup.testing.title'::text THEN 'tb_test_followup'::text
            WHEN task_overview.task_title = 'tb.follow_up.title'::text THEN 'tb_followup'::text
            ELSE 'none'::text
        END AS report_title,
    task_overview.task_overdue_grp,
    count(*) AS count_tasks,
    min(task_overview.task_duedate) AS min_duedate,
    max(task_overview.task_duedate) AS max_duedate,
    min(task_overview.task_enddate) AS min_enddate,
    max(task_overview.task_enddate) AS max_enddate,
    min(task_overview.task_completed_date) AS min_compdate,
    max(task_overview.task_completed_date) AS max_compdate
   FROM ( SELECT tasks.doc ->> '_id'::text AS task_uuid,
            chc.doc ->> '_id'::text AS chc_uuid,
            community.doc ->> '_id'::text AS comm_uuid,
            tasks.doc ->> 'owner'::text AS hhmem_uuid,
            tasks.doc ->> 'state'::text AS task_state,
            (tasks.doc -> 'emission'::text) ->> 'title'::text AS task_title,
            (tasks.doc -> 'emission'::text) ->> 'dueDate'::text AS task_duedate,
            (tasks.doc -> 'emission'::text) ->> 'startDate'::text AS task_startdate,
            (tasks.doc -> 'emission'::text) ->> 'endDate'::text AS task_enddate,
            (tasks.doc -> 'emission'::text) ->> 'deleted'::text AS task_deleted,
            (tasks.doc -> 'emission'::text) ->> 'resolved'::text AS task_resolved,
                CASE
                    WHEN ((tasks.doc -> 'emission'::text) ->> 'resolved'::text) = 'true'::text AND ((tasks.doc -> 'emission'::text) ->> 'deleted'::text) = 'false'::text THEN 'completed'::text
                    WHEN ((tasks.doc -> 'emission'::text) ->> 'resolved'::text) = 'false'::text AND ((tasks.doc -> 'emission'::text) ->> 'deleted'::text) = 'false'::text THEN 'pending'::text
                    WHEN ((tasks.doc -> 'emission'::text) ->> 'resolved'::text) = 'true'::text AND ((tasks.doc -> 'emission'::text) ->> 'deleted'::text) = 'true'::text THEN 'completed-deleted'::text
                    WHEN ((tasks.doc -> 'emission'::text) ->> 'resolved'::text) = 'false'::text AND ((tasks.doc -> 'emission'::text) ->> 'deleted'::text) = 'false'::text THEN 'deleted'::text
                    ELSE 'other'::text
                END AS task_state_grp,
                CASE
                    WHEN (((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'state'::text) = 'Completed'::text THEN to_timestamp((((((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'timestamp'::text)::bigint) / 1000)::double precision)
                    WHEN (((tasks.doc -> 'stateHistory'::text) -> 1) ->> 'state'::text) = 'Completed'::text THEN to_timestamp((((((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'timestamp'::text)::bigint) / 1000)::double precision)
                    WHEN (((tasks.doc -> 'stateHistory'::text) -> 2) ->> 'state'::text) = 'Completed'::text THEN to_timestamp((((((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'timestamp'::text)::bigint) / 1000)::double precision)
                    WHEN (((tasks.doc -> 'stateHistory'::text) -> 3) ->> 'state'::text) = 'Completed'::text THEN to_timestamp((((((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'timestamp'::text)::bigint) / 1000)::double precision)
                    WHEN (((tasks.doc -> 'stateHistory'::text) -> 4) ->> 'state'::text) = 'Completed'::text THEN to_timestamp((((((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'timestamp'::text)::bigint) / 1000)::double precision)
                    WHEN (((tasks.doc -> 'stateHistory'::text) -> 5) ->> 'state'::text) = 'Completed'::text THEN to_timestamp((((((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'timestamp'::text)::bigint) / 1000)::double precision)
                    ELSE NULL::timestamp with time zone
                END AS task_completed_date,
                CASE
                    WHEN (tasks.doc ->> 'state'::text) = 'Draft'::text AND (((tasks.doc -> 'emission'::text) ->> 'dueDate'::text)::date) < CURRENT_DATE THEN 'likely late'::text
                    WHEN (tasks.doc ->> 'state'::text) = 'Ready'::text AND (((tasks.doc -> 'emission'::text) ->> 'dueDate'::text)::date) < CURRENT_DATE THEN 'likely late'::text
                    WHEN (tasks.doc ->> 'state'::text) = 'Draft'::text AND (((tasks.doc -> 'emission'::text) ->> 'dueDate'::text)::date) >= CURRENT_DATE THEN 'pending'::text
                    WHEN (tasks.doc ->> 'state'::text) = 'Ready'::text AND (((tasks.doc -> 'emission'::text) ->> 'dueDate'::text)::date) >= CURRENT_DATE THEN 'pending'::text
                    WHEN (tasks.doc ->> 'state'::text) = 'Completed'::text AND
                    CASE
                        WHEN (((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'state'::text) = 'Completed'::text THEN to_timestamp((((((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'timestamp'::text)::bigint) / 1000)::double precision)
                        WHEN (((tasks.doc -> 'stateHistory'::text) -> 1) ->> 'state'::text) = 'Completed'::text THEN to_timestamp((((((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'timestamp'::text)::bigint) / 1000)::double precision)
                        WHEN (((tasks.doc -> 'stateHistory'::text) -> 2) ->> 'state'::text) = 'Completed'::text THEN to_timestamp((((((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'timestamp'::text)::bigint) / 1000)::double precision)
                        WHEN (((tasks.doc -> 'stateHistory'::text) -> 3) ->> 'state'::text) = 'Completed'::text THEN to_timestamp((((((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'timestamp'::text)::bigint) / 1000)::double precision)
                        WHEN (((tasks.doc -> 'stateHistory'::text) -> 4) ->> 'state'::text) = 'Completed'::text THEN to_timestamp((((((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'timestamp'::text)::bigint) / 1000)::double precision)
                        WHEN (((tasks.doc -> 'stateHistory'::text) -> 5) ->> 'state'::text) = 'Completed'::text THEN to_timestamp((((((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'timestamp'::text)::bigint) / 1000)::double precision)
                        ELSE NULL::timestamp with time zone
                    END <= (((tasks.doc -> 'emission'::text) ->> 'dueDate'::text)::date) THEN 'completed on-time'::text
                    WHEN (tasks.doc ->> 'state'::text) = 'Completed'::text AND
                    CASE
                        WHEN (((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'state'::text) = 'Completed'::text THEN to_timestamp((((((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'timestamp'::text)::bigint) / 1000)::double precision)
                        WHEN (((tasks.doc -> 'stateHistory'::text) -> 1) ->> 'state'::text) = 'Completed'::text THEN to_timestamp((((((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'timestamp'::text)::bigint) / 1000)::double precision)
                        WHEN (((tasks.doc -> 'stateHistory'::text) -> 2) ->> 'state'::text) = 'Completed'::text THEN to_timestamp((((((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'timestamp'::text)::bigint) / 1000)::double precision)
                        WHEN (((tasks.doc -> 'stateHistory'::text) -> 3) ->> 'state'::text) = 'Completed'::text THEN to_timestamp((((((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'timestamp'::text)::bigint) / 1000)::double precision)
                        WHEN (((tasks.doc -> 'stateHistory'::text) -> 4) ->> 'state'::text) = 'Completed'::text THEN to_timestamp((((((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'timestamp'::text)::bigint) / 1000)::double precision)
                        WHEN (((tasks.doc -> 'stateHistory'::text) -> 5) ->> 'state'::text) = 'Completed'::text THEN to_timestamp((((((tasks.doc -> 'stateHistory'::text) -> 0) ->> 'timestamp'::text)::bigint) / 1000)::double precision)
                        ELSE NULL::timestamp with time zone
                    END > (((tasks.doc -> 'emission'::text) ->> 'dueDate'::text)::date) THEN 'completed late'::text
                    WHEN (tasks.doc ->> 'state'::text) = 'Cancelled'::text THEN 'cancelled'::text
                    WHEN ((tasks.doc -> 'emission'::text) ->> 'resolved'::text) = 'false'::text AND ((tasks.doc -> 'emission'::text) ->> 'deleted'::text) = 'false'::text AND (((tasks.doc -> 'emission'::text) ->> 'endDate'::text)::date) <= CURRENT_DATE THEN 'not completed - dissapeared'::text
                    WHEN ((tasks.doc -> 'emission'::text) ->> 'resolved'::text) = 'true'::text AND ((tasks.doc -> 'emission'::text) ->> 'deleted'::text) = 'true'::text THEN 'completed-deleted'::text
                    WHEN ((tasks.doc -> 'emission'::text) ->> 'resolved'::text) = 'false'::text AND ((tasks.doc -> 'emission'::text) ->> 'deleted'::text) = 'false'::text THEN 'deleted'::text
                    ELSE 'unknown'::text
                END AS task_overdue_grp
           FROM raw_tasks tasks
             LEFT JOIN raw_contacts person ON (person.doc ->> '_id'::text) = (tasks.doc ->> 'owner'::text)
             LEFT JOIN raw_contacts community ON (community.doc ->> '_id'::text) = (person.doc #>> '{parent,parent,_id}'::text[])
             LEFT JOIN raw_contacts chc ON (chc.doc ->> '_id'::text) = (community.doc #>> '{contact,_id}'::text[])) task_overview
  GROUP BY task_overview.hhmem_uuid, task_overview.task_title, task_overview.task_overdue_grp
  ORDER BY task_overview.hhmem_uuid, (max(task_overview.task_duedate)) DESC;