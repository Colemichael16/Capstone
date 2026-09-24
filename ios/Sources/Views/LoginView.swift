import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authStore: AuthStore
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("CU email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                    SecureField("Password", text: $password)
                }

                if let errorMessage = authStore.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

                Section {
                    Button {
                        Task { await authStore.login(email: email, password: password) }
                    } label: {
                        if authStore.isAuthenticating {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Sign In").frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(email.isEmpty || password.isEmpty || authStore.isAuthenticating)
                }

                Section {
                    Button("Don't have an account? Sign up") { showingSignUp = true }
                }
            }
            .navigationTitle("CU Alerts")
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
        }
    }
}
