//
//  SwiftUIView.swift
//  ch1
//
//  Created by Aliah on 11/05/1448 AH.
//

import SwiftUI

// The result the validation function returns
enum BioResult {
    case valid
    case empty

    var message: String? {
        switch self {
        case .valid: return nil
        case .empty: return "Bio can't be empty"
        }
    }
}

struct SwiftUIView: View {
    @State private var isAvailable = true
    @State private var bio = "Princess of my own story 👑"
    @State private var draftBio = "Princess of my own story 👑"
    @State private var errorMessage: String? = nil

    // Receives the bio, decides if it's valid, returns the result
    func validateBio(_ text: String) -> BioResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? .empty : .valid
    }

    // Called by the app: uses the result to handle an empty bio
    func saveBio() {
        let result = validateBio(draftBio)

        switch result {
        case .valid:
            bio = draftBio.trimmingCharacters(in: .whitespacesAndNewlines)
            errorMessage = nil
        case .empty:
            errorMessage = result.message
            draftBio = bio // restore the last valid bio
        }
    }

    func profileImageName() -> String {
        isAvailable ? "princesa" : "princesaAway"
    }

    func toggleAvailability() {
        withAnimation(.easeInOut) {
            isAvailable.toggle()
        }
    }

    var body: some View {
        VStack(spacing: 24) {

            VStack(spacing: 12) {
                Image(profileImageName())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                Text("aliah, 21")
                    .font(.title)
                    .fontWeight(.semibold)
            }

            Toggle("متوفر", isOn: $isAvailable)
                .padding(.horizontal)

            Button("غيّر الحالة") {
                toggleAvailability()
            }

            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                Text("about")
                    .font(.headline)

                Text(bio)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.pink.opacity(0.2))
                    .cornerRadius(12)

                // Edit the bio
                TextField("Write your bio", text: $draftBio)
                    .textFieldStyle(.roundedBorder)

                // Show the error when the bio is empty
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }

                Button("Save bio") {
                    saveBio()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding(.top, 40)
    }
}

#Preview {
    SwiftUIView()
}
