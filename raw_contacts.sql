CREATE OR REPLACE VIEW public.raw_contacts
AS SELECT couchdb.doc
   FROM couchdb
  WHERE (couchdb.doc ->> 'type'::text) = ANY (ARRAY['contact'::text, 'person'::text]);