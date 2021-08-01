CREATE OR REPLACE VIEW public.contactview_miniclusters
AS SELECT places.doc ->> 'name'::text AS minicluster_name,
    parent1.doc ->> 'name'::text AS cluster_name,
    parent2.doc ->> 'name'::text AS branch_name,
    parent2.doc ->> 'notes'::text AS branch_number,
    parent3.doc ->> 'name'::text AS base_name,
    places.doc ->> '_id'::text AS minicluster_uuid,
    parent1.doc ->> '_id'::text AS cluster_uuid,
    parent2.doc ->> '_id'::text AS branch_uuid,
    parent3.doc ->> '_id'::text AS base_uuid,
    places.doc ->> 'external_id'::text AS icm_minicluster_id,
    parent1.doc ->> 'external_id'::text AS icm_cluster_id,
    parent2.doc ->> 'external_id'::text AS icm_branch_id,
    parent3.doc ->> 'external_id'::text AS icm_base_id
   FROM raw_contacts places
     LEFT JOIN raw_contacts parent1 ON (places.doc #>> '{parent,_id}'::text[]) = (parent1.doc ->> '_id'::text)
     LEFT JOIN raw_contacts parent2 ON (parent1.doc #>> '{parent,_id}'::text[]) = (parent2.doc ->> '_id'::text)
     LEFT JOIN raw_contacts parent3 ON (parent2.doc #>> '{parent,_id}'::text[]) = (parent3.doc ->> '_id'::text)
  WHERE (places.doc ->> 'type'::text) = 'contact'::text AND (places.doc ->> 'contact_type'::text) = 'mentor'::text;