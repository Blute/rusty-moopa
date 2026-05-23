-- Minimal Moopa-shaped schema for RustCFML compatibility SQL tests.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE public.moo_role (
  created_by uuid,
  created_at timestamptz(6) DEFAULT now(),
  name varchar(255),
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  last_updated_at timestamptz(6) DEFAULT now(),
  last_updated_by uuid,
  label varchar(255) GENERATED ALWAYS AS (COALESCE(name::text, id::text)) STORED,
  PRIMARY KEY (id)
);

INSERT INTO public.moo_role (name) VALUES
  ('Admin'),
  ('Agent'),
  ('Viewer'),
  ('Sysadmin');
