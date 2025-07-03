Smart Complaint Management System (SCMS)

 Hassan-FA22_BSE-028
This repo is for Flutter tasks.

1. Project Overview
The Smart Complaint Management System (SCMS) is a comprehensive, role-based platform for managing complaints within an educational institution. It digitizes the complaint process, from submission to resolution, and provides dashboards, analytics, and communication tools for all stakeholders.

2. Objectives
Digitize the complaint process for efficiency and transparency.

Empower students to raise issues and track progress.

Streamline advisor and HOD workflows for complaint resolution.

Enable administrators to monitor, analyze, and improve complaint handling.

Ensure data security, privacy, and compliance with institutional policies.

3. Stakeholders & User Roles
 3.1 Students
Register/login using institutional credentials.

Submit complaints with title, description, category, and optional attachments.

View complaint status, timeline, and history.

Receive notifications on status changes or advisor/HOD responses.

 3.2 Advisors
View all complaints assigned to their batch(es).

Filter/sort complaints by status, date, or student.

Update complaint status (e.g., In Progress, Resolved).

Add resolution notes or request more info.

Escalate unresolved complaints to HOD.

 3.3 HODs
View all department complaints.

Assign/reassign advisors.

Resolve or reject escalated complaints.

Generate and export department-level reports.

 3.4 Administrators
Manage users, departments, and batches.

Assign roles, reset passwords.

View institution-wide analytics and generate reports.

Configure system settings and manage RLS policies.

4. Functional Scope
Includes:

 Authentication & Role-Based Access (via Supabase)

 Complaint Submission & Lifecycle Tracking

 Dashboards for Each Role

 Notification System

 File Attachments

 Reporting & Analytics

 Search, Filter, and Export

 Supabase RLS for security

5. Out of Scope
Real-time chat

3rd-party ticketing integration

Offline or multi-language support

6. Technical Scope
Frontend
Flutter (Web + Mobile)

State Management (Provider/Riverpod/Bloc)

Backend
Supabase (PostgreSQL + Auth + Storage)

RLS-based access control

Deployment
Web: Firebase Hosting/Vercel

Mobile: Google Play Store, Apple App Store

7. Assumptions & Constraints
All users use institutional email.

Supabase RLS is correctly configured.

Latest stable versions of Flutter & Supabase.

8. Deliverables
Flutter source code (web & mobile)

Supabase backend schema & RLS

Deployment scripts

Documentation (User/Admin Guides)

QA test cases

9. Success Criteria
Seamless complaint tracking across roles.

Role-based access & secure data.

Responsive, user-friendly UI.

Exportable reports and analytics.

 Screenshots
 Admin Login & Dashboard
<p float="left"> <img src="https://github.com/user-attachments/assets/f8faa16a-c900-4e88-9858-2cd258b93505" width="200"/> <img src="https://github.com/user-attachments/assets/ce8a6fdc-974e-4b85-ba0b-65428d625091" width="200"/> <img src="https://github.com/user-attachments/assets/a901982-27c2-429d-90aa-7f2862720aa4" width="200"/> <img src="https://github.com/user-attachments/assets/b3a2ecf5-c066-439f-96be-6e14a164f767" width="200"/> <img src="https://github.com/user-attachments/assets/425ba37f-b9a9-461e-aa78-d0c397b6e781" width="200"/> <img src="https://github.com/user-attachments/assets/2a36bfd3-9104-4686-bb93-f52670dbf1bb" width="200"/> <img src="https://github.com/user-attachments/assets/80ebc0d3-6ada-47c5-ad70-5f541c5b3840" width="200"/> <img src="https://github.com/user-attachments/assets/3c52e7cc-76c0-4451-8c28-101eaeae963c" width="200"/> <img src="https://github.com/user-attachments/assets/3ad918f8-b056-4fa8-aedc-f0ad612661d8" width="200"/> <img src="https://github.com/user-attachments/assets/c2a5634a-8cde-44b7-ba9e-773023fbcb1a" width="200"/> <img src="https://github.com/user-attachments/assets/76edd347-3ee7-4391-88be-576f7c436235" width="200"/> <img src="https://github.com/user-attachments/assets/eaf966b5-c33b-4cca-bd81-123c99ffc1f4" width="200"/> <img src="https://github.com/user-attachments/assets/f702ba79-1a12-489b-8280-ce45054edf86" width="200"/> </p>
 HOD Login & Dashboard
<p float="left"> <img src="https://github.com/user-attachments/assets/92097cf3-ef33-40d2-b100-d7377e70b45f" width="200"/> <img src="https://github.com/user-attachments/assets/848881f3-7dc3-4116-8db2-917f4170997e" width="200"/> <img src="https://github.com/user-attachments/assets/3fc145d6-5d95-477e-8a33-2330696a06dc" width="200"/> <img src="https://github.com/user-attachments/assets/aaa92814-ecbf-454a-808e-e3d612f635a4" width="200"/> <img src="https://github.com/user-attachments/assets/03121f14-bc02-4b95-ae56-504ec" width="200"/> <img src="https://github.com/user-attachments/assets/347f202b-f0e6-4651-bf60-b929bd1c72d5" width="200"/> </p>
 Batch Advisor View
<p float="left"> <img src="https://github.com/user-attachments/assets/ef43d35b-60ac-46c3-a497-21901008fca2" width="200"/> <img src="https://github.com/user-attachments/assets/c8b3e20b-9d6d-4175-b98d-48d13be940c2" width="200"/> <img src="https://github.com/user-attachments/assets/ab420499-ad74-455d-8b8e-62bb8045025e" width="200"/> <img src="https://github.com/user-attachments/assets/1ca167ae-46e8-471d-a769-46b69c718bf7" width="200"/> <img src="https://github.com/user-attachments/assets/11c3b9b7-5c85-4287-8172-47e1e8d317ac" width="200"/> <img src="https://github.com/user-attachments/assets/9612abdf-d645-4cfd-954c-769a1712d794" width="200"/> </p>
 Student Login & Dashboard
<p float="left"> <img src="https://github.com/user-attachments/assets/b877eafb-4dc7-47ad-a501-72458b336311" width="200"/> <img src="https://github.com/user-attachments/assets/c044b380-3392-47c1-8e9f-b3482cc6f6ec" width="200"/> <img src="https://github.com/user-attachments/assets/259176e1-c5b4-401e-adf1-00606170c928" width="200"/> <img src="https://github.com/user-attachments/assets/405109e8-cf29-4966-8f3a-16cb0c545c16" width="200"/> </p>
