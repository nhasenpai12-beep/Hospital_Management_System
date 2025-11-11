# Hospital Management System

A streamlined hospital patient admission system built with Dart that automates patient triage, doctor assignment, and bed allocation based on symptoms and medical conditions.

## Core Features

### Automated Patient Admission
- **Intelligent Triage**: 3-level priority system (Urgent, Moderate, Routine)
- **Doctor Matching**: Assigns patients to specialists based on symptoms
- **Bed Management**: Allocates appropriate rooms (ER, Examination, Ward)
- **Data Persistence**: All admissions saved to structured JSON files

### 💾 Data Persistence
- **Automatic Data Storage**: All patient data, assignments, and medical records are saved to JSON files
- **Complete Record Keeping**: Stores patient information, doctor assignments, room allocations, and medical entries
- **Analytics Reports**: Generates system analytics including triage breakdown, specialization distribution, and room occupancy

### 🏥 Comprehensive Domain Model
- **Patient Management**: Full patient records with demographics, allergies, and medical history
- **Staff Management**: Doctors, nurses, and staff with specializations and departments
- **Room & Ward Management**: Multiple room types (emergency, consultation, examination, patient rooms, operating)
- **Medical Records**: Complete medical history tracking with diagnoses, treatments, and prescriptions
- **Emergency Cases**: Triage-based emergency case management
- **Billing System**: Insurance integration and billing management

## How It Works

### Intelligent Assignment Algorithm

The system uses a sophisticated matching algorithm:

1. **Symptom Analysis**: Extracts keywords from patient symptoms and diagnosis
2. **Specialization Matching**: Maps symptoms to appropriate medical specializations
   - Example: "chest pain" → Cardiologist
   - Example: "fracture" → Orthopedic Surgeon
   - Example: "fever, cough" → Internal Medicine/Pediatrics

3. **Severity Assessment**: Determines triage level based on condition
   - 🔴 **Red (Critical)**: Heart attack, stroke, severe bleeding → Emergency room
   - 🟡 **Yellow (Moderate)**: Fractures, high fever → Patient or examination room
   - 🟢 **Green (Minor)**: Cold, checkup → Consultation room

4. **Resource Allocation**: Assigns available doctors and rooms based on matches

### Supported Specializations

The system recognizes and routes to:
- Cardiology (heart conditions)
- Orthopedics (bones, fractures, joints)
- Pediatrics (children)
- Neurology (brain, headaches, seizures)
- Internal Medicine (general conditions)
- Emergency Medicine (trauma, accidents)
- And many more...

## Usage

### Running the Automated System

```bash
# Process patients automatically
dart run lib/automated_system.dart
```

This will:
1. Initialize hospital resources (doctors, rooms, wards)
2. Process incoming patient data
3. Automatically assign doctors and beds
4. Save all data to `hospital_data/` directory
5. Generate analytics report

### Running with UI

```bash
# Interactive menu system (requires login)
dart run lib/main.dart

# Default credentials:
# Username: admin, Password: admin123
# Username: doctor1, Password: doc123
```

### Running Tests

```bash
dart test
```

## Data Storage

All data is saved to the `hospital_data/` directory:

- `patient_[ID].json` - Patient demographic data
- `assignment_[ID]_[timestamp].json` - Doctor and room assignments
- `medical_record_[ID].json` - Complete medical history
- `summary_[timestamp].json` - System analytics

### Example Output

```
Patient 1/3
  Name: Maria Garcia (Age: 47)
  Symptoms: chest pain, shortness of breath
  � Priority: URGENT
  → Doctor: Dr. Michael Brown
  → Room: ER-1

Admission Summary:
  Total admissions: 3
  Priority levels:
    🔴 Urgent: 1
    🟡 Moderate: 2
  Room occupancy: 3/6 (50%)
```

## Project Structure

```
lib/
├── automated_system.dart              # Main automated processing system
├── main.dart                          # UI-based entry point
├── domain/                            # Domain models
│   ├── patient.dart
│   ├── staff.dart
│   ├── room.dart
│   ├── medical_record.dart
│   ├── emergency.dart
│   ├── billing.dart
│   └── ...
├── data/
│   ├── services/
│   │   ├── intelligent_assignment_service.dart  # AI assignment logic
│   │   ├── data_persistence_service.dart        # Data storage
│   │   └── auth_service.dart
│   └── repositories/
│       ├── patient_repository.dart
│       └── medical_record_repository.dart
└── ui/                                # User interface (optional)
    └── menu.dart

test/                                  # Unit tests
hospital_data/                         # Generated data files
```

## Key Components

### IntelligentAssignmentService
- Analyzes symptoms and diagnosis
- Matches patients to appropriate specialists
- Assesses severity and triage level
- Allocates rooms based on condition

### DataPersistenceService
- Saves patient data to JSON files
- Stores assignment records
- Generates analytics reports
- Maintains complete audit trail

### AutomatedHospitalSystem
- Orchestrates the entire process
- Manages hospital resources
- Processes patient queue
- Generates system reports

## Requirements

- Dart SDK 3.0.0 or higher
- No external dependencies for core functionality

## Benefits

✅ **Zero Manual Intervention**: Processes patients automatically
✅ **Intelligent Matching**: AI-powered doctor assignment
✅ **Complete Audit Trail**: All data saved permanently
✅ **Scalable**: Handles multiple patients simultaneously
✅ **Flexible**: Easy to add new specializations and conditions
✅ **Analytics**: Built-in reporting and statistics

## Future Enhancements

- Machine learning for improved assignment accuracy
- Real-time patient monitoring
- Integration with external medical systems
- Appointment scheduling optimization
- Medication management and tracking
