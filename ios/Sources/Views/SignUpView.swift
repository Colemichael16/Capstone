import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var authStore: AuthStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("CU email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                    SecureField("Password (8+ characters)", text: $password)
                } footer: {
                    Text("Registration requires a @colorado.edu email address.")
                }

                if let errorMessage = authStore.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

                Section {
                    Button {
                        Task {
                            await authStore.register(email: email, password: password, name: name)
                            if authStore.isAuthenticated { dismiss() }
                        }
                    } label: {
                        if authStore.isAuthenticating {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Create Account").frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(name.isEmpty || email.isEmpty || password.count < 8 || authStore.isAuthenticating)
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
