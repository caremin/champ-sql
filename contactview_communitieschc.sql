CREATE OR REPLACE VIEW public.contactview_communitieschc
AS SELECT community.doc ->> '_id'::text AS community,
    person.doc ->> '_id'::text AS chc_uuid,
    community.doc ->> 'name'::text AS community_name,
    community.doc ->> 'external_id'::text AS icm_community_id,
    person.doc ->> 'name'::text AS chc_name,
    person.doc ->> 'external_id'::text AS chc_participant_id,
    person.doc ->> 'notes'::text AS chc_notes,
    person.doc ->> 'gender'::text AS chc_gender,
    person.doc ->> 'phone'::text AS chc_phone,
    person.doc ->> 'date_of_birth'::text AS chc_dob,
    person.doc ->> 'patient_id'::text AS chc_patientid,
    parent1.doc ->> 'name'::text AS minicluster_name,
    parent2.doc ->> 'name'::text AS cluster_name,
    parent3.doc ->> 'name'::text AS branch_name,
    parent3.doc ->> 'notes'::text AS branch_number,
    parent4.doc ->> 'name'::text AS base_name,
    parent1.doc ->> '_id'::text AS minicluster_uuid,
    parent2.doc ->> '_id'::text AS cluster_uuid,
    parent3.doc ->> '_id'::text AS branch_uuid,
    parent4.doc ->> '_id'::text AS base_uuid,
    parent1.doc ->> 'external_id'::text AS icm_minicluster_id,
    parent2.doc ->> 'external_id'::text AS icm_cluster_id,
    parent3.doc ->> 'external_id'::text AS icm_branch_id
   FROM raw_contacts community
     LEFT JOIN raw_contacts person ON (community.doc #>> '{contact,_id}'::text[]) = (person.doc ->> '_id'::text)
     LEFT JOIN raw_contacts parent1 ON (community.doc #>> '{parent,_id}'::text[]) = (parent1.doc ->> '_id'::text)
     LEFT JOIN raw_contacts parent2 ON (parent1.doc #>> '{parent,_id}'::text[]) = (parent2.doc ->> '_id'::text)
     LEFT JOIN raw_contacts parent3 ON (parent2.doc #>> '{parent,_id}'::text[]) = (parent3.doc ->> '_id'::text)
     LEFT JOIN raw_contacts parent4 ON (parent3.doc #>> '{parent,_id}'::text[]) = (parent4.doc ->> '_id'::text)
  WHERE (community.doc ->> 'type'::text) = 'contact'::text AND (community.doc ->> 'contact_type'::text) = 'the_community'::text;