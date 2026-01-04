//
//  NoteDetailView.swift
//  GlassNote
//
//  Created by jyh on 12/19/25.
//

import SwiftUI
import Combine

struct NoteDetailView: View {
    @ObservedObject var note: Note
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var editingTitle: String = ""
    @State private var isEditingTitle: Bool = false
    @FocusState private var isTitleFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            GlassBackground()
//            DrawView(note: note, context: context)
            VStack(spacing: 0) {
                //MARK: - Header
                header
                
                //MARK: - Content Area (스케치 / 메모 등 도형 같은거 로직 넣는곳)
                contentArea
            }
            .offset(y: -keyboardHeight)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .animation(.easeOut(duration: 0.16), value: keyboardHeight)
            .onReceive(Publishers.keyboardHeight) { height in
                self.keyboardHeight = (height / 2)
            }
        }
        .onAppear {
            editingTitle = note.title ?? "Untitled"
        }
        .onTapGesture {
            hideKeyboard()
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
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
    }
    
    private var contentArea: some View {
        GlassContainer {
            VStack(spacing: 20) {
                DrawView(note: note, context: context)
//                Text("여기에 넣으면 됩니다.")
//                    .font(.system(size: 14))
//                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 10)
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

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
            }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return Merge(willShow, willHide)
            .eraseToAnyPublisher()
    }
}
