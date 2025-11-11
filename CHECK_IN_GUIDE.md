# Hospital Patient Check-In System - Quick Start

## What Is This?

An **interactive hospital reception system** where patients can be registered and checked in at the front desk. The system:

- ✅ Collects patient information (name, contact, allergies, etc.)
- ✅ Records symptoms and reason for visit
- ✅ Automatically assigns the right doctor based on symptoms
- ✅ Assigns appropriate room (ER, Examination, Ward)
- ✅ Saves all patient data to files
- ✅ Provides real-time hospital status

## How to Use

### Start the Check-In System

```bash
dart run lib/check_in_system.dart
```

### Main Menu Options

```
1. Check In New Patient    - Register a new patient arrival
2. Search Existing Patient - Find patient records
3. View Today's Admissions - See all check-ins today
4. View Hospital Status    - Room availability, occupancy
5. View Available Doctors  - List doctors on duty
6. Exit                    - Close the system
```

## Check-In Process Example

### 1. Select "Check In New Patient"

### 2. Enter Patient Information:
```
Patient Name: John Smith
Email: john.smith@email.com
Phone Number: 555-1234
Date of Birth: 1985-06-15
Blood Type: O+
Known Allergies: Penicillin
Emergency Contact: Jane Smith - 555-5678
```

### 3. Medical Information:
```
Chief Complaint / Symptoms: chest pain, shortness of breath
Initial Diagnosis: Possible cardiac issue
```

### 4. System Processes:
```
✅ CHECK-IN COMPLETE
═══════════════════════════════════════════════════
Patient ID: P234567
Name: John Smith
Age: 40 years
Blood Type: O+
Allergies: Penicillin

ASSIGNMENT:
  Priority: 🔴 URGENT
  Doctor: Dr. Michael Brown
  Specialization: Cardiologist
  Room: ER-1
═══════════════════════════════════════════════════
```

## Features

### Intelligent Triage
The system automatically determines priority:
- 🔴 **URGENT** - Critical conditions (chest pain, difficulty breathing, etc.)
- 🟡 **Moderate** - Requires attention (fractures, high fever, etc.)
- 🟢 **Routine** - Non-emergency (checkup, cold, minor issues)

### Smart Doctor Assignment
Matches patients to specialists based on symptoms:
- Chest pain → Cardiologist
- Broken bone → Orthopedic Surgeon
- Child with fever → Pediatrician
- General illness → Internal Medicine

### Room Allocation
Assigns appropriate location:
- **ER-1, ER-2** - Emergency cases
- **EXAM-1, EXAM-2, EXAM-3** - Examinations
- **WARD-101, WARD-102, WARD-103** - Admissions

### Data Storage
Everything is saved to `hospital_data/`:
- Patient demographics
- Medical records
- Check-in details
- Assignment information

## Hospital Status View

Check real-time hospital information:

```
ROOM STATUS:
  Total rooms: 8
  Occupied: 3
  Available: 5
  Occupancy rate: 38%

Emergency Rooms: 1/2 available
Examination Rooms: 3/3 available
Ward Rooms: 1/3 available

DOCTORS ON DUTY: 4

TODAY'S STATISTICS:
  Total check-ins: 5
  🔴 Urgent: 1
  🟡 Moderate: 2
  🟢 Routine: 2
```

## Search Patient Records

Find existing patients by name or ID:

```
Enter patient name or ID: Smith

📋 Search Results (2 found):

ID: P234567
Name: John Smith
Age: 40 years
Blood Type: O+
Contact: 555-1234
Allergies: Penicillin
```

## Doctors on Duty

View available specialists:

```
Dr. Sarah Johnson
  Department: Pediatrics
  Specialization: Pediatrician
  Contact: 555-1001

Dr. Michael Brown
  Department: Cardiology
  Specialization: Cardiologist
  Contact: 555-1002

Dr. Emily Chen
  Department: Orthopedics
  Specialization: Orthopedic Surgeon
  Contact: 555-1003

Dr. Robert Williams
  Department: Internal Medicine
  Specialization: Internal Medicine Specialist
  Contact: 555-1004
```

## Comparison: Check-In vs Automated

### Check-In System (Current)
- ✅ Interactive - Staff enters patient info
- ✅ Real-time - Process patients as they arrive
- ✅ Flexible - Can handle walk-ins
- ✅ Reception workflow - Like a real hospital desk

### Automated System (Alternative)
```bash
dart run lib/automated_system.dart
```
- Processes batch of pre-defined patients
- No interaction needed
- Good for testing or bulk processing

## Choose Your System

**Use Check-In System when:**
- You want interactive patient registration
- Simulating a real hospital reception desk
- Processing patients one-by-one as they arrive

**Use Automated System when:**
- You want to process multiple patients quickly
- Testing the system with sample data
- No manual input needed

## Both Systems Save Data

All patient information is stored in `hospital_data/` regardless of which system you use!

## Run Tests

```bash
dart test
```

All tests pass! ✅
