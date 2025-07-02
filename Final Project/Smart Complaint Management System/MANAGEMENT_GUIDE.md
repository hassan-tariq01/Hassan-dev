# Smart Complaint Management System - Management Guide

## Overview
This guide explains how to set up and manage the Smart Complaint Management System for the Computer Science Department.

## Initial Setup Process

### Step 1: Database Setup
1. **Run Database Setup**: Go to Batch Management → Click the ⚙️ (Settings) icon
2. **Verify Setup**: Check console logs for successful database initialization
3. **Test Connection**: Click the 🐛 (Bug Report) icon to test database connectivity

### Step 2: Create Sample Data
1. **Add Sample Batches**: Go to Batch Management → Click the 📊 (Add Sample Batches) icon
   - This creates 8 sample batches: CS-2024-A, CS-2024-B, CS-2023-A, CS-2023-B, CS-2022-A, CS-2022-B, CS-2021-A, CS-2021-B

2. **Add Sample Advisors**: Go to Advisor Management → Click the 👤 (Add Sample Advisors) icon
   - This creates 8 sample advisors with default password "password123"
   - Advisors can login with their email and password

3. **Add Sample Students**: Go to Student Management → Click the 👥 (Add Sample Students) icon
   - This creates sample students with default password "password123"
   - Students can login with their email and password

### Step 3: Assign Advisors to Batches
1. **Go to Advisor Assignment**: Admin Dashboard → Advisor Assignment
2. **Select Batch**: Choose a batch from the dropdown
3. **Select Advisor**: Choose an advisor from the dropdown
4. **Assign**: Click "Assign Advisor" button
5. **Repeat**: Assign advisors to all batches

### Step 4: Assign Students to Batches
1. **Go to Student Management**: Admin Dashboard → Student Management
2. **Add Students**: Click the + button to add individual students
3. **Select Batch**: Choose the appropriate batch for each student
4. **Or Use Sample Students**: The sample students are pre-assigned to batches

## Making Batches Usable in the App

### For Students:
- Students must be assigned to a batch to submit complaints
- Students can see their batch and advisor information on their dashboard
- Students can only submit complaints if they have a batch and advisor assigned

### For Advisors:
- Advisors must be assigned to a batch to view and manage complaints
- Advisors can only see complaints from their assigned batch
- Advisors can update complaint status and add comments

### For HOD:
- HOD can view all escalated complaints from all batches
- HOD can resolve escalated complaints

## User Roles and Permissions

### Admin
- **Dashboard**: Overview of all system data
- **Batch Management**: Create, edit, delete batches
- **Advisor Management**: Create, edit, delete advisors
- **Student Management**: Create, edit, delete students
- **Advisor Assignment**: Assign advisors to batches
- **Statistics**: View system statistics

### Batch Advisor
- **Dashboard**: Overview of assigned batch complaints
- **Complaint List**: View and manage complaints from assigned batch
- **Complaint Detail**: View detailed complaint information
- **Actions**: Update status, add comments, escalate to HOD

### HOD (Head of Department)
- **Dashboard**: Overview of escalated complaints
- **Escalated Complaints**: View and manage escalated complaints
- **Complaint Detail**: View detailed complaint information
- **Actions**: Resolve escalated complaints

### Student
- **Dashboard**: Overview of personal complaints
- **Submit Complaint**: Create new complaints
- **Complaint History**: View all submitted complaints
- **Complaint Status**: Track complaint progress

## Workflow

### Complaint Submission Process:
1. **Student submits complaint** → Status: "Submitted"
2. **Advisor reviews complaint** → Status: "In Progress"
3. **Advisor can escalate to HOD** → Status: "Escalated to HOD"
4. **HOD resolves complaint** → Status: "Resolved" or "Rejected"

### Batch Assignment Process:
1. **Admin creates batches** (e.g., CS-2024-A, CS-2024-B)
2. **Admin creates advisors** (e.g., Dr. Sarah Johnson, Prof. Michael Chen)
3. **Admin assigns advisors to batches** (one advisor per batch)
4. **Admin creates students** and assigns them to batches
5. **Students can now submit complaints** that go to their assigned advisor

## Troubleshooting

### Common Issues:

1. **"Student, batch, or advisor information not found"**
   - Solution: Ensure student is assigned to a batch and batch has an advisor

2. **"No complaints found" for advisor**
   - Solution: Ensure advisor is assigned to a batch and students in that batch have submitted complaints

3. **"Cannot submit complaint"**
   - Solution: Check that student has batch_id and batch has advisor_id

4. **Foreign key constraint violations**
   - Solution: Run database setup (⚙️ icon) to ensure proper table structure

### Database Setup Issues:
- Click the ⚙️ (Settings) icon in Batch Management
- Check console logs for detailed error messages
- Ensure all tables exist and have proper relationships

## Sample Data

### Sample Batches:
- CS-2024-A, CS-2024-B
- CS-2023-A, CS-2023-B
- CS-2022-A, CS-2022-B
- CS-2021-A, CS-2021-B

### Sample Advisors:
- Dr. Sarah Johnson (sarah.johnson@university.edu)
- Prof. Michael Chen (michael.chen@university.edu)
- Dr. Emily Davis (emily.davis@university.edu)
- Prof. Robert Wilson (robert.wilson@university.edu)
- Dr. Lisa Brown (lisa.brown@university.edu)
- Prof. David Miller (david.miller@university.edu)
- Dr. James Taylor (james.taylor@university.edu)
- Prof. Amanda Garcia (amanda.garcia@university.edu)

### Default Passwords:
- **Advisors**: password123
- **Students**: password123
- **Admin**: Use the admin credentials you created

## Security Notes

1. **Change Default Passwords**: All sample users have default password "password123"
2. **Email Verification**: Users should verify their email addresses
3. **Role-based Access**: Each user type has specific permissions
4. **Data Privacy**: Only authorized users can access complaint data

## Support

For technical issues:
1. Check console logs for error messages
2. Verify database connectivity
3. Ensure proper user assignments
4. Contact system administrator

---

**Note**: This system is designed for the Computer Science Department with a single department setup. For multi-department usage, modifications would be required. 