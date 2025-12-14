# Hospital Management System

A Dart-based Hospital Management System using Object-Oriented Programming principles.

## Overview

This project implements a comprehensive hospital management system with features for managing patients, appointments, doctors, and other hospital operations.

## Features

- Patient registration and management
- Appointment scheduling
- Doctor management
- Check-in system
- Hospital data management

## Prerequisites

- Dart SDK (>=3.0.0 <4.0.0)
- Git for version control

## Installation

1. Clone the repository:
```bash
git clone https://github.com/nhasenpai12-beep/Hospital_Management_System.git
cd Hospital_Management_System
```

2. Install dependencies:
```bash
dart pub get
```

## Running the Application

```bash
dart run lib/main.dart
```

## Running Tests

```bash
dart test
```

## Project Structure

```
Hospital_Management_System/
├── lib/
│   ├── main.dart              # Main application entry point
│   ├── check_in_system.dart   # Check-in system implementation
│   ├── data/                  # Data layer (models, repositories)
│   ├── domain/                # Domain layer (business logic)
│   └── ui/                    # User interface layer
├── test/                      # Test files
├── hospital_data/             # Data storage
└── pubspec.yaml              # Project configuration
```

## Development

### Branch Management

We use a feature-branch workflow. Quick reference guides:
- **New to branching?** Start here: [QUICK_START.md](QUICK_START.md)
- **Need details?** See full guide: [BRANCHING_GUIDE.md](BRANCHING_GUIDE.md)

Quick start for creating a new branch:
```bash
# Make the script executable (first time only)
chmod +x create_branch.sh

# Create and push a new feature branch
./create_branch.sh -s -p feature/your-feature-name
```

### Coding Standards

- Follow Dart style guide
- Use meaningful variable and function names
- Write tests for new features
- Document complex logic

### Contributing

1. Create a feature branch from `main`
2. Make your changes
3. Write/update tests
4. Ensure all tests pass
5. Submit a pull request

See [BRANCHING_GUIDE.md](BRANCHING_GUIDE.md) for detailed branching workflow.

## License

[Add your license information here]

## Contact

[Add contact information or links to issue tracker]
