//
//  FileSelete.swift
//  GlassNote
//
//  Created by jyh on 11/28/25.
//

import SwiftUI
import CoreData

struct FileSelete: View {
    // Core Data Fetch -> 이게 제일 빡셈 항상 업데이트 해야 합니다.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.updatedAt, ascending: false)],
        animation: .easeInOut
    )
    private var notes: FetchedResults<Note>
    
    @Environment(\.managedObjectContext) private var context
    @State private var showNewNote = false
    @State private var selectedNote: Note? = nil
    
    var body: some View {
        ZStack {
            
            GlassBackground()
            
            VStack(spacing: 20) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(notes) { note in
                            LiquidGlassNoteCard(note: note)
                                .onTapGesture {
                                    selectedNote = note
                                }
                        }
                        
                        if notes.isEmpty {
                            emptyState
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
        }
        .sheet(isPresented: $showNewNote) {
            createNewNote()
        }
        .fullScreenCover(item: $selectedNote) { note in
            NoteDetailView(note: note)
        }
    }
}

extension FileSelete {
    
    //MARK: - header
    private var header: some View {
        HStack {
            Text("Your Notes")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // New note button (Liquid style)
            GlassToolButton(systemName: "plus.circle", title: "New", isSelected: true) {
                showNewNote = true
            }
            .frame(width: 120, height: 38)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
    
    //MARK: - empty view
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.65))
            Text("No Notes Yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            Text("Create your first note to get started!")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.top, 60)
    }
    
    //MARK: - core data
    private func createNewNote() -> some View {
        VStack {
            Text("Create New Note")
                .font(.title3)
                .padding()
            
            Button("Create") {
                let newNote = Note(context: context)
                newNote.id = UUID()
                newNote.title = "New Note"
                newNote.previewText = ""
                newNote.updatedAt = Date()
                try? context.save()
                
                showNewNote = false
            }
            .padding()
        }
    }
}
