//
//  NoteDetailView.swift
//  GlassNote
//
//  Created by jyh on 12/19/25.
//

import SwiftUI

struct NoteDetailView: View {
    @ObservedObject var note: Note
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var editingTitle: String = ""
    @State private var isEditingTitle: Bool = false
    @FocusState private var isTitleFocused: Bool
    
    var body: some View {
        ZStack {
            GlassBackground()
            
            VStack(spacing: 0) {
                //MARK: - Header
                header
                
                //MARK: - Content Area (스케치 / 메모 등 도형 같은거 로직 넣는곳)
                contentArea
            }
        }
        .onAppear {
            editingTitle = note.title ?? "Untitled"
        }
    }
}

//MARK: - view
extension NoteDetailView {
    
    private var header: some View {
        HStack(spacing: 16) {
            //back 버튼
            GlassToolButton(systemName: "chevron.left", title: "Back", isSelected: false) {
                saveNote()
                dismiss()
            }
            
            Spacer()
            
            //title 영역
            if isEditingTitle {
                TextField("Note Title", text: $editingTitle)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .focused($isTitleFocused)
                    .onSubmit {
                        finishEditingTitle()
                    }
                    .frame(maxWidth: 200)
            } else {
                Text(editingTitle)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .onTapGesture {
                        isEditingTitle = true
                        isTitleFocused = true
                    }
            }
            
            Spacer()
            
            //저장 버튼
            GlassToolButton(systemName: "square.and.arrow.down", title: "Save", isSelected: true) {
                saveNote()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var contentArea: some View {
        GlassContainer {
            VStack(spacing: 20) {
                DrawView()
//                Text("여기에 넣으면 됩니다.")
//                    .font(.system(size: 14))
//                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

//MARK: - actions
extension NoteDetailView {
    
    //제목 수정 완료 트리거
    private func finishEditingTitle() {
        isEditingTitle = false
        isTitleFocused = false
        note.title = editingTitle
        saveNote()
    }
    
    //노트 코어 데이터 저장
    private func saveNote() {
        note.title = editingTitle
        note.updatedAt = Date()
        
        do {
            try context.save()
        } catch {
            print("저장 실패: \(error)")
        }
    }
}
