CREATE OR REPLACE VIEW public.contactview_participants
AS SELECT person.doc ->> '_id'::text AS hhmem_uuid,
    person.doc ->> 'patient_id'::text AS hhmem_medic_id,
    person.doc ->> 'external_id'::text AS icm_participant_id,
    person.doc ->> 'name'::text AS hhmem_name,
    person.doc ->> 'gender'::text AS hhmem_gender,
    person.doc ->> 'date_of_birth'::text AS hhmem_dob,
    person.doc ->> 'phone'::text AS hhmem_phone,
    person.doc ->> 'reported_date'::text AS hhmem_created_date,
        CASE
            WHEN (parent.doc #>> '{contact,_id}'::text[]) = (person.doc ->> '_id'::text) THEN 'yes'::text
            ELSE 'no'::text
        END AS hh_primcontact,
    parent.doc ->> 'name'::text AS hh_name,
    parent1.doc ->> 'name'::text AS community_name,
    parent2.doc ->> 'name'::text AS minicluster_name,
    parent3.doc ->> 'name'::text AS cluster_name,
    parent4.doc ->> 'name'::text AS branch_name,
    parent5.doc ->> 'name'::text AS area_name,
    chc.doc ->> 'name'::text AS chc_name,
    chc.doc ->> 'external_id'::text AS chc_participant_id,
    chc.doc ->> 'notes'::text AS chc_notes,
    chc.doc ->> 'gender'::text AS chc_gender,
    chc.doc ->> 'date_of_birth'::text AS chc_dob,
    parent.doc ->> '_id'::text AS hh_uuid,
    parent1.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    parent1.doc ->> '_id'::text AS community_uuid,
    parent2.doc ->> '_id'::text AS minicluster_uuid,
    parent3.doc ->> '_id'::text AS cluster_uuid,
    parent4.doc ->> '_id'::text AS branch_uuid,
    parent5.doc ->> '_id'::text AS area_uuid,
    parent1.doc ->> 'external_id'::text AS icm_community_id,
    parent2.doc ->> 'external_id'::text AS icm_minicluster_id,
    parent3.doc ->> 'external_id'::text AS icm_cluster_id,
    parent4.doc ->> 'external_id'::text AS icm_branch_id,
    parent5.doc ->> 'external_id'::text AS icm_area_id,
    parent4.doc ->> 'notes'::text AS branch_number,
        CASE
            WHEN (parent4.doc ->> 'external_id'::text) = 'TEST'::text THEN 'test'::text
            WHEN (parent4.doc ->> 'external_id'::text) = ''::text THEN 'test'::text
            WHEN (parent4.doc ->> 'external_id'::text) IS NULL THEN 'household not found'::text
            WHEN cm.which_report = 'mute'::text THEN 'muted'::text
            WHEN cm.which_report = 'unmute'::text THEN 're-active (unmute)'::text
            ELSE 'active'::text
        END AS hhmem_status,
        CASE
            WHEN cm.muting = 'drop_out'::text THEN 'drop out of sg'::text
            WHEN cm.muting = 'permanent_relocation'::text THEN 'permanent relocation'::text
            WHEN cm.muting = 'temporal_relocation'::text THEN 'temporal relocation'::text
            WHEN cm.muting = 'other'::text THEN concat('other - ', cm.mute_other)
            ELSE cm.muting
        END AS hhmem_status_upd
   FROM raw_contacts person
     LEFT JOIN raw_contacts parent ON (person.doc #>> '{parent,_id}'::text[]) = (parent.doc ->> '_id'::text)
     LEFT JOIN raw_contacts parent1 ON (parent.doc #>> '{parent,_id}'::text[]) = (parent1.doc ->> '_id'::text)
     LEFT JOIN raw_contacts chc ON (parent1.doc #>> '{contact,_id}'::text[]) = (chc.doc ->> '_id'::text)
     LEFT JOIN raw_contacts parent2 ON (parent1.doc #>> '{parent,_id}'::text[]) = (parent2.doc ->> '_id'::text)
     LEFT JOIN raw_contacts parent3 ON (parent2.doc #>> '{parent,_id}'::text[]) = (parent3.doc ->> '_id'::text)
     LEFT JOIN raw_contacts parent4 ON (parent3.doc #>> '{parent,_id}'::text[]) = (parent4.doc ->> '_id'::text)
     LEFT JOIN raw_contacts parent5 ON (parent4.doc #>> '{parent,_id}'::text[]) = (parent5.doc ->> '_id'::text)
     LEFT JOIN contactview_mutestatus cm ON (person.doc ->> '_id'::text) = cm.hhmem_uuid
  WHERE (person.doc ->> 'type'::text) = 'person'::text AND (person.doc ->> 'role'::text) = 'household_member'::text;