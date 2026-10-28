-- ==============================================================================
-- UIT BURDWAN - DEPARTMENT OF ECE PORTAL
-- SUPABASE STORAGE & DATABASE UPGRADE SCRIPT
-- ==============================================================================
-- Run this script in the Supabase Dashboard SQL Editor (https://supabase.com/dashboard)
-- Project: jwexadekromjrdgzvrky
--
-- This script safely:
-- 1. Creates the 'ece_documents' storage bucket with public read access
-- 2. Configures Storage RLS policies for admin uploads, replacements, and deletions
-- 3. Adds metadata columns to 'notices', 'study_links', and 'resources'
-- 4. Creates the 'routines' table with Row Level Security
-- ==============================================================================

-- 1. CREATE STORAGE BUCKET FOR DIRECT PDF UPLOADS
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'ece_documents',
  'ece_documents',
  true,
  26214400, -- 25 MB limit
  ARRAY['application/pdf']
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 26214400,
  allowed_mime_types = ARRAY['application/pdf'];

-- 2. STORAGE RLS POLICIES FOR 'ece_documents'
DO $$
BEGIN
  DROP POLICY IF EXISTS "ECE Public Read Access" ON storage.objects;
  DROP POLICY IF EXISTS "ECE Admin Upload Access" ON storage.objects;
  DROP POLICY IF EXISTS "ECE Admin Update Access" ON storage.objects;
  DROP POLICY IF EXISTS "ECE Admin Delete Access" ON storage.objects;
EXCEPTION
  WHEN OTHERS THEN NULL;
END $$;

-- Policy A: Anyone can view and download academic documents
CREATE POLICY "ECE Public Read Access"
ON storage.objects FOR SELECT
USING (bucket_id = 'ece_documents');

-- Policy B: Only authorized admins can upload new PDFs
CREATE POLICY "ECE Admin Upload Access"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'ece_documents' AND
  EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid())
);

-- Policy C: Only authorized admins can replace / update PDFs
CREATE POLICY "ECE Admin Update Access"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'ece_documents' AND
  EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid())
);

-- Policy D: Only authorized admins can delete PDFs
CREATE POLICY "ECE Admin Delete Access"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'ece_documents' AND
  EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid())
);

-- ==============================================================================
-- 3. UPGRADE 'notices' TABLE FOR KGEC-STYLE NOTICE MANAGEMENT
-- ==============================================================================
ALTER TABLE public.notices ADD COLUMN IF NOT EXISTS memo_no text;
ALTER TABLE public.notices ADD COLUMN IF NOT EXISTS resource_type text DEFAULT 'link';
ALTER TABLE public.notices ADD COLUMN IF NOT EXISTS storage_path text;
ALTER TABLE public.notices ADD COLUMN IF NOT EXISTS file_name text;
ALTER TABLE public.notices ADD COLUMN IF NOT EXISTS file_size bigint;
ALTER TABLE public.notices ADD COLUMN IF NOT EXISTS is_published boolean DEFAULT true;
ALTER TABLE public.notices ADD COLUMN IF NOT EXISTS publish_date timestamptz DEFAULT now();

-- Ensure RLS on notices allows public read and admin write
ALTER TABLE public.notices ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  DROP POLICY IF EXISTS "Public read published notices" ON public.notices;
  DROP POLICY IF EXISTS "Admin insert notices" ON public.notices;
  DROP POLICY IF EXISTS "Admin update notices" ON public.notices;
  DROP POLICY IF EXISTS "Admin delete notices" ON public.notices;
EXCEPTION
  WHEN OTHERS THEN NULL;
END $$;

CREATE POLICY "Public read published notices"
ON public.notices FOR SELECT
USING (
  is_published = true OR 
  EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid())
);

CREATE POLICY "Admin insert notices"
ON public.notices FOR INSERT
TO authenticated
WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid()));

CREATE POLICY "Admin update notices"
ON public.notices FOR UPDATE
TO authenticated
USING (EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid()));

CREATE POLICY "Admin delete notices"
ON public.notices FOR DELETE
TO authenticated
USING (EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid()));

-- ==============================================================================
-- 4. UPGRADE 'study_links' FOR STUDY MATERIALS (PDF & EXTERNAL LINKS)
-- ==============================================================================
ALTER TABLE public.study_links ADD COLUMN IF NOT EXISTS resource_type text DEFAULT 'link';
ALTER TABLE public.study_links ADD COLUMN IF NOT EXISTS storage_path text;
ALTER TABLE public.study_links ADD COLUMN IF NOT EXISTS file_name text;
ALTER TABLE public.study_links ADD COLUMN IF NOT EXISTS file_size bigint;
ALTER TABLE public.study_links ADD COLUMN IF NOT EXISTS semester text;
ALTER TABLE public.study_links ADD COLUMN IF NOT EXISTS description text;

ALTER TABLE public.study_links ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  DROP POLICY IF EXISTS "Public read study links" ON public.study_links;
  DROP POLICY IF EXISTS "Admin insert study links" ON public.study_links;
  DROP POLICY IF EXISTS "Admin update study links" ON public.study_links;
  DROP POLICY IF EXISTS "Admin delete study links" ON public.study_links;
EXCEPTION
  WHEN OTHERS THEN NULL;
END $$;

CREATE POLICY "Public read study links"
ON public.study_links FOR SELECT
USING (true);

CREATE POLICY "Admin insert study links"
ON public.study_links FOR INSERT
TO authenticated
WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid()));

CREATE POLICY "Admin update study links"
ON public.study_links FOR UPDATE
TO authenticated
USING (EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid()));

CREATE POLICY "Admin delete study links"
ON public.study_links FOR DELETE
TO authenticated
USING (EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid()));

-- ==============================================================================
-- 5. UPGRADE 'resources' (PRIMARY DEPARTMENT DOCUMENTS)
-- ==============================================================================
ALTER TABLE public.resources ADD COLUMN IF NOT EXISTS resource_type text DEFAULT 'link';
ALTER TABLE public.resources ADD COLUMN IF NOT EXISTS storage_path text;
ALTER TABLE public.resources ADD COLUMN IF NOT EXISTS file_name text;
ALTER TABLE public.resources ADD COLUMN IF NOT EXISTS file_size bigint;

ALTER TABLE public.resources ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  DROP POLICY IF EXISTS "Public read resources" ON public.resources;
  DROP POLICY IF EXISTS "Admin insert/update resources" ON public.resources;
EXCEPTION
  WHEN OTHERS THEN NULL;
END $$;

CREATE POLICY "Public read resources"
ON public.resources FOR SELECT
USING (true);

CREATE POLICY "Admin insert/update resources"
ON public.resources FOR ALL
TO authenticated
USING (EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid()));

-- ==============================================================================
-- 6. CREATE 'routines' TABLE (DEPARTMENT ROUTINES MANAGEMENT)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.routines (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  semester text,
  description text,
  resource_type text DEFAULT 'pdf', -- 'pdf' or 'link'
  link text,
  storage_path text,
  file_name text,
  file_size bigint,
  is_published boolean DEFAULT true,
  created_by uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.routines ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  DROP POLICY IF EXISTS "Public read routines" ON public.routines;
  DROP POLICY IF EXISTS "Admin insert routines" ON public.routines;
  DROP POLICY IF EXISTS "Admin update routines" ON public.routines;
  DROP POLICY IF EXISTS "Admin delete routines" ON public.routines;
EXCEPTION
  WHEN OTHERS THEN NULL;
END $$;

CREATE POLICY "Public read routines"
ON public.routines FOR SELECT
USING (
  is_published = true OR 
  EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid())
);

CREATE POLICY "Admin insert routines"
ON public.routines FOR INSERT
TO authenticated
WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid()));

CREATE POLICY "Admin update routines"
ON public.routines FOR UPDATE
TO authenticated
USING (EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid()));

CREATE POLICY "Admin delete routines"
ON public.routines FOR DELETE
TO authenticated
USING (EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid()));

-- ==============================================================================
-- 7. REFRESH REALTIME PUBLICATION
-- ==============================================================================
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.notices;
  ALTER PUBLICATION supabase_realtime ADD TABLE public.study_links;
  ALTER PUBLICATION supabase_realtime ADD TABLE public.resources;
  ALTER PUBLICATION supabase_realtime ADD TABLE public.routines;
EXCEPTION
  WHEN OTHERS THEN NULL;
END $$;
