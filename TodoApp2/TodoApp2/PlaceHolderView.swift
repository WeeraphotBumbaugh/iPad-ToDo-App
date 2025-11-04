//
//  PlaceHolderView.swift
//  TodoAppTask
//
//  Created by Gabriela Sanchez on 01/11/25.
//

import SwiftUI


struct PlaceHolderView: View {
    let title: String
    let icon: String
    
    @State private var tasks = [
        TaskItem(title: "Upload Assigment to Canvas", isCompleted: false),
        TaskItem(title: "Implement Login View", isCompleted: false),
        TaskItem(title: "Go groceries shopping", isCompleted: true)
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
                // Task - Checkmark - Task title
                List($tasks) { $task in
                    HStack(spacing: 15) {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(task.isCompleted ? .green : .secondary)
                            .onTapGesture {
                                withAnimation {
                                    task.isCompleted.toggle()
                                }
                            }
                        
                    }
                    .padding(.vertical, 4)
                }
                .navigationTitle(title)
            }
        }
    }
}
