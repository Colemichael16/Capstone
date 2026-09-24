import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var authStore: AuthStore

    var body: some View {
        NavigationStack {
            List {
                if let user = authStore.currentUser {
                    Section {
                        LabeledContent("Name", value: user.name)
                        LabeledContent("Email", value: user.email)
                    }
                }

                Section {
                    Button("Sign Out", role: .destructive) {
                        authStore.logout()
                    }
                }
            }
            .navigationTitle("Account")
        }
    }
}
