# UIT Burdwan — Department of Electronics and Communication Engineering (ECE)

Official student and faculty portal for the Department of Electronics and Communication Engineering at the University Institute of Technology, The University of Burdwan.

---

## 🚀 Key Features

### 1. Direct PDF Upload & Supabase Storage
- **Direct Computer Uploads**: Authorized administrators can select and upload PDF documents directly from their computers (up to 25 MB).
- **Dedicated Storage Bucket**: Files are organized securely in the `ece_documents` Supabase Storage bucket under partitioned folders (`notices/`, `routines/`, `study/`, `resources/`).
- **Real-Time Upload Progress**: Visual progress bar tracking upload percentages (0% to 100%) with status indicators.
- **In-Browser PDF Viewer**: Embedded modal previewer with instant "Download PDF" and "Open in New Tab" capabilities.
- **Direct Downloads**: Direct blob downloads with authentic original file names across all browsers.
- **Safe Document Lifecycle**: Replacing or deleting documents automatically cleans up the underlying Supabase Storage file to prevent orphaned storage bloat.

### 2. Dual Resource Architecture
Administrators can choose between two resource types for any item:
- **Option A: Direct PDF Upload** — Select a PDF file, upload to Supabase Storage, and provide instant "View PDF" and "Download PDF" actions.
- **Option B: Add External Link** — Keep Google Drive folders, official university links, and external educational portals with an "Open Link" action.

### 3. Official Department Notice Board
Official department circular and document management system:
- **Prominent Date Badges**: Day, Month, and Year calendar display.
- **Department Memo Numbers**: Official reference numbers (e.g. `Memo No. UIT/ECE/2026/042`).
- **Category Tags & Filtering**: Real-time filtering by category (Notice, Examination, Academic, Routine, Circular).
- **Draft & Published States**: Administrators can prepare drafts before publishing publicly.
- **Live Search**: Instant keyword search across titles, memo numbers, categories, and circular descriptions.

### 4. Department Routines Management
- Organize and publish semester routines (`1st Sem`, `3rd Sem`, `5th Sem`, `7th Sem`, `Exam Routine`, `Lab Timetables`).
- Replace, edit, or delete routines at any time without redeploying code.

### 5. Multi-Resource Study Materials Repository
- Upload multiple lecture notes, question banks, and lab manuals per subject and semester.
- Dual PDF upload and Google Drive link support.

### 6. Admin Control Centre
- Secured via existing Supabase Authentication and Row Level Security (RLS).
- Tabbed management dashboard for Notices, Routines, Study Materials, Primary Links, Announcements, and Admin Users.

---

## 🛠️ Technology Stack

| Layer | Technology |
| :--- | :--- |
| **Frontend Framework** | Vanilla HTML5 / ES6 JavaScript |
| **Styling** | Vanilla CSS (Liquid Glassmorphism & 3D Aurora System) |
| **Bundler & Toolchain** | Vite 8 + Prettier |
| **Database & Auth** | Supabase (PostgreSQL, Realtime & Auth) |
| **Document Storage** | Supabase Storage (`ece_documents` bucket) |
| **Deployment Target** | Vercel |

---

## 📦 Supabase Setup & Migration

To configure Supabase Storage and database tables for direct PDF uploads:

1. Open your [Supabase Dashboard](https://supabase.com/dashboard).
2. Navigate to your project (`jwexadekromjrdgzvrky`).
3. Click on the **SQL Editor** in the left sidebar.
4. Open or copy the contents of [`supabase_setup.sql`](./supabase_setup.sql).
5. Click **Run** to execute the script.

The migration script automatically:
- Creates the public `ece_documents` storage bucket with a 25 MB file limit.
- Establishes Storage Row Level Security (RLS) policies allowing public document downloads and restricting uploads/updates/deletions to verified administrators.
- Adds metadata columns (`memo_no`, `resource_type`, `storage_path`, `file_name`, `file_size`, `is_published`, `publish_date`) to `notices`, `study_links`, and `resources`.
- Creates the `routines` table with complete RLS access controls.

---

## 💻 Local Development

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build optimized production bundle
npm run build

# Preview production build locally
npm run preview
```

---

## 🌐 Vercel Deployment

This project is configured for seamless deployment on Vercel:
- **Build Command**: `npm run build`
- **Output Directory**: `dist`
- **Configuration**: `vercel.json`
- New notices, routines, and study PDFs appear dynamically via Supabase Realtime without requiring Vercel redeployments.
