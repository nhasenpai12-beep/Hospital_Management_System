#!/bin/bash

# Test run script for hospital management system
echo "Starting Hospital Management System Test Run..."
echo ""

# Run the system with automated input
{
  echo "1"                                    # Check In New Patient
  echo "Emily Rodriguez"                      # Patient Name
  echo "555-9876"                            # Phone Number
  echo "1992-03-22"                          # Date of Birth
  echo "O-"                                  # Blood Type
  echo "Latex, Aspirin"                      # Allergies
  echo "Carlos Rodriguez 555-9877"           # Emergency Contact
  echo "Severe headache, nausea, fever"      # Symptoms
  echo "Possible migraine or infection"      # Diagnosis
  echo ""                                    # Press Enter
  echo "3"                                   # View Today's Admissions
  echo ""                                    # Press Enter
  echo "2"                                   # Search Existing Patient
  echo "Emily"                               # Search query
  echo ""                                    # Press Enter
  echo "4"                                   # View Hospital Status
  echo ""                                    # Press Enter
  echo "9"                                   # Exit
} | dart run lib/check_in_system.dart

echo ""
echo "Test run completed!"
