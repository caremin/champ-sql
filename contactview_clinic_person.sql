CREATE OR REPLACE VIEW public.contactview_clinic_person
AS SELECT raw_contacts.doc ->> '_id'::text AS uuid,
    raw_contacts.doc ->> 'name'::text AS name,
    raw_contacts.doc ->> 'type'::text AS type,
    raw_contacts.doc #>> '{parent,_id}'::text[] AS family_uuid,
    raw_contacts.doc ->> 'phone'::text AS phone,
    raw_contacts.doc ->> 'alternative_phone'::text AS phone2,
    raw_contacts.doc ->> 'date_of_birth'::text AS date_of_birth,
    cmeta.type AS parent_type
   FROM raw_contacts
     LEFT JOIN contactview_metadata cmeta ON (raw_contacts.doc #>> '{parent,_id}'::text[]) = cmeta.uuid
  WHERE (raw_contacts.doc ->> 'type'::text) = 'person'::text AND (raw_contacts.doc ->> '_id'::text IN ( SELECT contactview_metadata.contact_uuid
           FROM contactview_metadata
          WHERE contactview_metadata.type = 'clinic'::text));