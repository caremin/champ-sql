CREATE OR REPLACE VIEW public.contactview_person_fields
AS SELECT person.doc ->> '_id'::text AS uuid,
    person.doc ->> 'phone'::text AS phone,
    person.doc ->> 'alternative_phone'::text AS phone2,
    person.doc ->> 'date_of_birth'::text AS date_of_birth,
    parent.doc ->> 'type'::text AS parent_type
   FROM raw_contacts person
     LEFT JOIN raw_contacts parent ON (person.doc #>> '{parent,_id}'::text[]) = (parent.doc ->> '_id'::text)
  WHERE (person.doc ->> 'type'::text) = 'person'::text;