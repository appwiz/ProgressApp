//
//  ContentView.swift
//  Progress
//
//  Created by Rohan Deshpande on 7/30/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentDate = Date()
    @State private var noteContent = ""
    @State private var showingDatePicker = false
    @State private var dateInput = ""
    @State private var showingDateInput = false
    
    private var currentNote: Note? {
        let dateKey = Note.dateKey(for: currentDate)
        let request = FetchDescriptor<Note>(
            predicate: #Predicate { $0.dateKey == dateKey }
        )
        return try? modelContext.fetch(request).first
    }
    
    private var taskSummary: (total: Int, done: Int, remaining: Int) {
        let lines = noteContent.components(separatedBy: .newlines)
        var total = 0
        var done = 0
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Check if line contains a markdown task (- [ ] or - [x] or - [X])
            let taskPattern = #"^\s*-\s*\[[ xX]?\]"#
            if trimmedLine.range(of: taskPattern, options: .regularExpression) != nil {
                
                total += 1
                
                // Check if task is done [x] or [X]
                if trimmedLine.range(of: #"^\s*-\s*\[[xX]\]"#, options: .regularExpression) != nil {
                    done += 1
                }
            }
        }
        
        let remaining = total - done
        return (total: total, done: done, remaining: remaining)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Title
                VStack(spacing: 4) {
                    Text("On \(Note.displayDate(for: Note.dateKey(for: currentDate)))")
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                // Text Editor
                TextEditor(text: $noteContent)
                    .padding(.horizontal)
                    .border(Color.gray.opacity(0.5), width: 1)
                    .onChange(of: noteContent) { oldValue, newValue in
                        saveNote()
                    }
                    .onAppear {
                        loadNote()
                    }
                    .onChange(of: currentDate) { oldValue, newValue in
                        loadNote()
                    }
                
                // Task Summary Footer
                VStack {
                    let summary = taskSummary
                    let summaryString = "\(summary.total) total, \(summary.done) done, \(summary.remaining) remain"
                    Text(summaryString)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    // Previous day with day hint inline
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text(dayOfWeek(for: Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 32) // Fixed width to prevent movement
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        previousDay()
                    }
                    
                    // Calendar button
                    Button(action: { showingDatePicker = true }) {
                        Image(systemName: "calendar")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .popover(isPresented: $showingDatePicker) {
                        VStack {
                            DatePicker("Select Date", selection: $currentDate, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .padding()
                            
                            Button("Done") {
                                showingDatePicker = false
                            }
                            .padding()
                        }
                    }
                    
                    // Search button
                    Button(action: { showingDateInput = true }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .alert("Go to Date", isPresented: $showingDateInput) {
                        TextField("YYYYMMDD, YYYY-MM-DD, YYYYMM-DD, or YYYY-MMDD", text: $dateInput)
                        Button("Go") {
                            goToDate()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Enter date in format YYYYMMDD, YYYY-MM-DD, YYYYMM-DD, or YYYY-MMDD")
                    }
                    
                    // Today button
                    Button("Today") {
                        currentDate = Date()
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(6)
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Next day with day hint inline
                    HStack(spacing: 4) {
                        Text(dayOfWeek(for: Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 32) // Fixed width to prevent movement
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        nextDay()
                    }
                }
            }
        }
    }
    
    private func loadNote() {
        if let note = currentNote {
            noteContent = note.content
        } else {
            noteContent = ""
        }
    }
    
    private func saveNote() {
        let dateKey = Note.dateKey(for: currentDate)
        
        // Calculate task summary
        let summary = taskSummary
        let summaryString = "\(summary.total) total, \(summary.done) done, \(summary.remaining) remain"
        
        if let existingNote = currentNote {
            existingNote.content = noteContent
            existingNote.lastModified = Date()
            existingNote.taskSummary = summaryString
        } else if !noteContent.isEmpty {
            let newNote = Note(dateKey: dateKey, content: noteContent)
            newNote.taskSummary = summaryString
            modelContext.insert(newNote)
        }
        
        try? modelContext.save()
    }
    
    private func previousDay() {
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
    }
    
    private func nextDay() {
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
    }
    
    private func goToDate() {
        let cleanInput = dateInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let formatter = DateFormatter()
        
        // Try YYYY-MM-DD format first
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: cleanInput) {
            currentDate = date
            dateInput = ""
            return
        }
        
        // Try YYYYMMDD format
        formatter.dateFormat = "yyyyMMdd"
        if let date = formatter.date(from: cleanInput) {
            currentDate = date
            dateInput = ""
            return
        }
        
        // Try YYYYMM-DD format
        formatter.dateFormat = "yyyyMM-dd"
        if let date = formatter.date(from: cleanInput) {
            currentDate = date
            dateInput = ""
            return
        }
        
        // Try YYYY-MMDD format
        formatter.dateFormat = "yyyy-MMdd"
        if let date = formatter.date(from: cleanInput) {
            currentDate = date
            dateInput = ""
            return
        }
        
        // If no format works, clear the input
        dateInput = ""
    }
    
    private func dayOfWeek(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E" // Short day format (Mon, Tue, etc.)
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Note.self, inMemory: true)
}
