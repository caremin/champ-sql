CREATE OR REPLACE VIEW public.combined_imci
AS SELECT screening.report_uuid,
    screening.report_date,
    screening.which_report AS stage,
    screening.hhmem_uuid,
    NULL::text AS continue_update,
    NULL::text AS rhu_attendance,
    screening.child_icmi_all AS symptoms_imci,
    screening.child_icmi_rhuref AS rhuref_imci,
    screening.child_danger_list AS symptoms_danger,
    screening.child_danger_rhuref AS rhuref_danger,
    NULL::text AS rhu_diagnosis,
    NULL::text AS rhu_treatment,
    NULL::text AS rhu_symptoms_status,
    NULL::text AS rhu_treatment_status,
    NULL::text AS appt_date,
    NULL::date AS rhu_appt_date,
        CASE
            WHEN screening.child_icmi_all <> ''::text AND screening.child_danger_list IS NOT NULL THEN 'IMCI & Danger Signs'::text
            WHEN screening.child_icmi_all <> ''::text AND screening.child_danger_list IS NULL THEN 'IMCI Only'::text
            WHEN screening.child_icmi_all = ''::text AND screening.child_danger_list IS NULL THEN 'No IMCI or Danger Signs Observed'::text
            WHEN screening.child_icmi_all = ''::text AND screening.child_danger_list IS NOT NULL THEN 'Danger Signs Only'::text
            ELSE 'unknown'::text
        END AS updated_status,
        CASE
            WHEN screening.child_danger_list IS NOT NULL AND screening.child_danger_rhuref = 'yes'::text THEN 'Requires Immediate Followup - Referred to RHU, Has Danger Signs'::text
            WHEN screening.child_danger_list IS NOT NULL AND screening.child_danger_rhuref = 'no'::text THEN 'Requires Immediate Followup - NOT Referred to RHU, Has Danger Signs'::text
            WHEN (screening.child_icmi_rhuref = 'no'::text OR screening.child_icmi_rhuref IS NULL) AND screening.child_danger_rhuref IS NULL THEN 'Home Treatment - Not Referred, No Danger Signs'::text
            WHEN screening.child_danger_rhuref = 'no'::text AND (screening.child_icmi_rhuref = 'no'::text OR screening.child_icmi_rhuref IS NULL) THEN 'May Require Followup - NOT Referred to RHU, No Danger Signs'::text
            WHEN screening.child_icmi_rhuref = 'yes'::text THEN 'May Require Followup - Referred to the RHU, No Danger Signs'::text
            ELSE 'No Treatment Needed - No Issues Suspected'::text
        END AS updated_treatment,
    date_part('day'::text, CURRENT_DATE::timestamp with time zone - screening.report_date) AS days_since_report
   FROM reportview_screening screening
  WHERE screening.child_icmi_all IS NOT NULL AND screening.child_icmi_all <> ''::text OR screening.child_danger_list IS NOT NULL
UNION ALL
 SELECT report.report_uuid,
    report.report_date,
    report.which_report AS stage,
    report.hhmem_uuid,
    NULL::text AS continue_update,
    report.rhu_visit AS rhu_attendance,
    report.imci_signs AS symptoms_imci,
    report.imci_referral AS rhuref_imci,
    report.imci_danger_signs AS symptoms_danger,
    NULL::text AS rhuref_danger,
    report.rhuvisit_yes_diagnosis AS rhu_diagnosis,
    report.rhuvisit_yes_treatment AS rhu_treatment,
    report.appt_symptom_state AS rhu_symptoms_status,
    report.appt_treatment_state AS rhu_treatment_status,
    report.appointment_req AS appt_date,
    report.appt_req_date::date AS rhu_appt_date,
        CASE
            WHEN report.imci_signs <> ''::text AND report.imci_danger_signs = 'yes'::text THEN 'IMCI & Danger Signs'::text
            WHEN report.imci_signs <> ''::text AND report.imci_danger_signs = 'no'::text THEN 'IMCI Only'::text
            WHEN report.imci_signs = ''::text AND report.imci_danger_signs = 'no'::text THEN 'No IMCI or Danger Signs Observed'::text
            WHEN report.imci_signs = ''::text AND report.imci_danger_signs = 'yes'::text THEN 'Danger Signs Only'::text
            ELSE 'unknown'::text
        END AS updated_status,
        CASE
            WHEN report.appt_symptom_state = 'resolved'::text AND report.appt_treatment_state = 'complete'::text AND (report.imci_signs = ''::text OR report.imci_signs IS NULL) AND report.imci_danger_signs = 'no'::text AND (report.appointment_req = 'no'::text OR report.appointment_req = 'yes'::text AND report.appt_req_date::date = report.report_date::date) THEN 'Treatment Likely Complete - No Symptoms (Discharge)'::text
            WHEN report.appt_symptom_state = 'resolved'::text AND report.appt_treatment_state = 'complete'::text AND (report.imci_signs = ''::text OR report.imci_signs IS NULL) AND report.imci_danger_signs = 'no'::text AND report.appointment_req = 'yes'::text THEN 'Treatment Almost Completed - No Symptoms (RHU Appt Scheduled)'::text
            WHEN report.appt_symptom_state = 'resolved'::text AND report.appt_treatment_state = 'complete'::text AND (report.imci_signs <> ''::text OR report.imci_danger_signs = 'yes'::text) THEN 'Treatment Likely Ongoing - Has Symptoms'::text
            WHEN report.appt_symptom_state = 'ongoing'::text OR report.appt_treatment_state = 'ongoing'::text AND (report.imci_signs <> ''::text OR report.imci_danger_signs = 'yes'::text) THEN 'Treatment Ongoing - Attended RHU, Has Symptoms'::text
            WHEN report.appt_symptom_state = 'ongoing'::text OR report.appt_treatment_state = 'ongoing'::text AND (report.imci_signs = ''::text OR report.imci_signs IS NULL) AND report.imci_danger_signs = 'no'::text THEN 'Treatment Ongoing - Attended RHU, No Symptoms'::text
            WHEN report.rhu_visit = 'no'::text AND report.imci_danger_signs = 'yes'::text THEN 'Requires Immediate Followup - No RHU Visit, Has Danger Signs'::text
            WHEN report.rhu_visit = 'no'::text AND report.imci_danger_signs = 'no'::text THEN 'May Require Followup - No RHU Visit'::text
            ELSE 'Unknown'::text
        END AS updated_treatment,
    date_part('day'::text, CURRENT_DATE::timestamp with time zone - report.report_date) AS days_since_report
   FROM reportview_imci_followup_48h report
UNION ALL
 SELECT report.report_uuid,
    report.report_date,
    report.which_report AS stage,
    report.hhmem_uuid,
    report.cont_followup AS continue_update,
    NULL::text AS rhu_attendance,
    report.imci_signs AS symptoms_imci,
    report.imci_referral AS rhuref_imci,
    NULL::text AS symptoms_danger,
    NULL::text AS rhuref_danger,
    NULL::text AS rhu_diagnosis,
    NULL::text AS rhu_treatment,
    report.symptom_state AS rhu_symptoms_status,
    report.treatment_state AS rhu_treatment_status,
    NULL::text AS appt_date,
    NULL::date AS rhu_appt_date,
        CASE
            WHEN report.imci_signs <> ''::text THEN 'IMCI Signs'::text
            WHEN report.imci_signs = ''::text THEN 'No IMCI Signs Observed'::text
            WHEN report.cont_followup = 'no'::text THEN 'Unknown - Followup Rescheduled'::text
            ELSE 'unknown'::text
        END AS updated_status,
        CASE
            WHEN report.cont_followup = 'yes'::text AND report.symptom_state = 'resolved'::text AND report.treatment_state = 'complete'::text AND (report.imci_signs = ''::text OR report.imci_signs IS NULL) THEN 'Treatment Likely Complete - No Symptoms (Discharge)'::text
            WHEN report.cont_followup = 'yes'::text AND report.symptom_state = 'resolved'::text AND report.treatment_state = 'complete'::text AND report.imci_signs <> ''::text THEN 'Treatment Likely Ongoing - Has Symptoms'::text
            WHEN report.cont_followup = 'yes'::text AND (report.symptom_state = 'ongoing'::text OR report.treatment_state = 'ongoing'::text) AND report.imci_signs <> ''::text AND report.imci_referral = 'yes'::text THEN 'Treatment Ongoing - Has Symptoms, RHU Referral'::text
            WHEN report.cont_followup = 'yes'::text AND (report.symptom_state = 'ongoing'::text OR report.treatment_state = 'ongoing'::text) AND report.imci_signs <> ''::text AND (report.imci_referral = 'no'::text OR report.imci_referral IS NULL) THEN 'Treatment Ongoing - Has Symptoms, No RHU Referral'::text
            WHEN report.cont_followup = 'yes'::text AND (report.symptom_state = 'ongoing'::text OR report.treatment_state = 'ongoing'::text) AND report.imci_signs = ''::text THEN 'Treatment Ongoing - No Symptoms'::text
            WHEN report.cont_followup = 'no'::text AND report.imci_signs <> ''::text THEN 'Requires Immediate Followup - No RHU Visit, Has Danger Signs'::text
            WHEN report.cont_followup = 'no'::text AND report.imci_signs IS NULL THEN 'Requires Followup - No RHU Visit, Symptoms Unknown'::text
            WHEN report.cont_followup = 'no'::text AND report.imci_signs = ''::text THEN 'Requires Followup - No RHU Visit, Symptoms Unknown'::text
            ELSE 'Unknown'::text
        END AS updated_treatment,
    date_part('day'::text, CURRENT_DATE::timestamp with time zone - report.report_date) AS days_since_report
   FROM reportview_imci_followup_weekly report
UNION ALL
 SELECT report.report_uuid,
    report.report_date,
    report.which_report AS stage,
    report.hhmem_uuid,
    'yes'::text AS continue_update,
    NULL::text AS rhu_attendance,
    NULL::text AS symptoms_imci,
    NULL::text AS rhuref_imci,
    NULL::text AS symptoms_danger,
    NULL::text AS rhuref_danger,
    NULL::text AS rhu_diagnosis,
    NULL::text AS rhu_treatment,
    NULL::text AS rhu_symptoms_status,
    NULL::text AS rhu_treatment_status,
    NULL::text AS appt_date,
    report.date_resolved::date AS rhu_appt_date,
    'Recovered'::text AS updated_status,
    'Discharged'::text AS updated_treatment,
    date_part('day'::text, CURRENT_DATE::timestamp with time zone - report.report_date) AS days_since_report
   FROM reportview_imci_recovery report;