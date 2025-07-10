package main

import (
	"testing"
	"os"
)

func TestWizExerciseFileExists(t *testing.T) {
	// Test that wizexercise.txt exists
	if _, err := os.Stat("wizexercise.txt"); os.IsNotExist(err) {
		t.Error("wizexercise.txt file does not exist")
	}
}

func TestMainFunction(t *testing.T) {
	// Simple test to ensure main package compiles
	// This is a basic test that can be expanded
	t.Log("Main package compiles successfully")
} 