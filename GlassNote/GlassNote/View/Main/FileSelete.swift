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
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.updatedAt, ascending: false)],animation: .easeInOut)
    private var notes: FetchedResults<Note>
    
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @State private var canDelete: Bool = false
    @State private var selectedNote: Note? = nil
    @State private var isCloudOn: Bool = false
    
    var body: some View {
        ZStack {
            GlassBackground()
            VStack(spacing: 20) {
                header
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(notes, id: \.objectID) { note in
                            Button(action: {
                                if canDelete {
                                    context.perform {
                                        context.delete(note)
                                        try? context.save()
                                    }
                                } else {
                                    selectedNote = note
                                }
                            }) {
                                LiquidGlassNoteCard(note: note, canDelete: canDelete)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
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
        .fullScreenCover(item: $selectedNote) { note in
            NoteDetailView(note: note)
        }
        .onAppear {
            isCloudOn = UserDefaults.standard.bool(forKey: KeyConstants.UserDefaults.icloud.rawValue)
        }
    }
}

extension FileSelete {
    
    //MARK: - header
    private var header: some View {
        HStack {
            Text("Notes")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            if canDelete {
                GlassToolButton(systemName: "circle.fill", title: "Done", isSelected: true,action: {
                    canDelete = false
                })
            } else {
                Menu {
                    if notes.count == 0 {
                        GlassToolButton(systemName: "plus.circle", title: "New", isSelected: true, action: {
                            context.perform {
                                let newNote = Note(context: context)
                                newNote.id = UUID()
                                newNote.title = "New Note"
                                newNote.previewText = ""
                                newNote.updatedAt = Date()
                                try? context.save()
                            }
                        })
                    } else if !appState.subState {
                        GlassToolButton(systemName: "crown", title: "Subscribe \(networkMonitor.isConnected ? "" : "(No Network)")", isSelected: true, action: {
                            if networkMonitor.isConnected {
                                appState.currentView = .login
                            }
                        })
                    } else {
                        GlassToolButton(systemName: "plus.circle", title: "New", isSelected: true, action: {
                            context.perform {
                                let newNote = Note(context: context)
                                newNote.id = UUID()
                                newNote.title = "New Note"
                                newNote.previewText = ""
                                newNote.updatedAt = Date()
                                try? context.save()
                            }
                        })
                        
                        GlassOnOffButton(systemName: "icloud", title: "iCloud \(isCloudOn ? "(ON)" : "(OFF)")", isSelected: true, isOn: isCloudOn, action: {
                            let isSync = UserDefaults.standard.bool(forKey: KeyConstants.UserDefaults.icloud.rawValue)
                            isCloudOn = !isSync
                            UserDefaults.standard.set(isCloudOn, forKey: KeyConstants.UserDefaults.icloud.rawValue)
                            PersistenceController.shared.setupContainer()
                        })
                    }
                    GlassToolButton(systemName: "xmark", title: "Delete", isSelected: true, action :{
                        canDelete = true
                    })
                    
                } label: {
                    GlassToolButton(systemName: "ellipsis.circle", title: "Menu", isSelected: true) {}
                }
            }
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
                context.perform {
                    let newNote = Note(context: context)
                    newNote.id = UUID()
                    newNote.title = "New Note"
                    newNote.previewText = ""
                    newNote.updatedAt = Date()
                    try? context.save()
                }
            }
            .padding()
        }
    }
}
