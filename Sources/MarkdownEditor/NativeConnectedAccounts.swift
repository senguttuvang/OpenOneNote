import AppKit
import SwiftUI
import OneNoteGraph

@MainActor struct NativeAccountPopover: View {
    @Bindable var shell: NativeShellState
    @State private var confirmSignOut = false
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                NativeAccountAvatar(account: shell.session.account)
                VStack(alignment: .leading, spacing: 3) {
                    Text(shell.session.account?.name ?? "Microsoft account").fontWeight(.semibold)
                    Text(shell.session.account?.email ?? "Not signed in").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }.padding(16)
            HStack {
                Text("Connected Services").font(.system(size: 12, weight: .semibold)); Spacer()
                Button { shell.accountPopover = false; shell.showCloud(.storage) } label: { Image(systemName: "plus") }.accessibilityLabel("Add a service")
            }.padding(.horizontal, 12).padding(.vertical, 5).background(.primary.opacity(0.06))
            if let account = shell.session.account {
                serviceRow("OneDrive", subtitle: account.email, symbol: "cloud.fill") { shell.accountPopover = false; shell.showCloud(.notebooks); shell.browserLocation = "drive" }
                serviceRow("SharePoint", subtitle: account.email, symbol: "building.2.fill") { shell.accountPopover = false; shell.showCloud(.notebooks); shell.browserLocation = "sites" }
            } else {
                Text(shell.session.accountError ?? "Sign in to open your OneNote notebooks.").foregroundStyle(.secondary).padding(16)
            }
            Divider()
            Button(shell.session.account == nil ? "Sign In" : "Manage Storage Accounts", systemImage: shell.session.account == nil ? "person.crop.circle" : "cloud.badge.gearshape") {
                shell.accountPopover = false; shell.showCloud(.storage)
            }.padding(12)
            if shell.session.account != nil {
                Button("Sign Out", systemImage: "rectangle.portrait.and.arrow.right") { confirmSignOut = true }.padding(12).disabled(shell.session.busy)
            }
        }.frame(width: 336).buttonStyle(.plain).task { await shell.session.restoreAccount() }
            .confirmationDialog("Sign out of Microsoft? Notes saved on this Mac will be kept.", isPresented: $confirmSignOut, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) { shell.session.signOut(); shell.accountPopover = false }
            }
    }
    private func serviceRow(_ name: String, subtitle: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) { Image(systemName: symbol).foregroundStyle(.cyan).font(.title2).frame(width: 32); VStack(alignment: .leading) { Text(name); Text(subtitle).font(.caption).foregroundStyle(.secondary) }; Spacer(); Image(systemName: "chevron.right").font(.caption) }.padding(.horizontal, 16).padding(.vertical, 10)
        }
    }
}

struct NativeAccountAvatar: View {
    let account: MicrosoftAccount?
    var body: some View {
        Text(account?.initials.isEmpty == false ? account!.initials : "").font(.system(size: 12, weight: .medium))
            .frame(width: 32, height: 32).background(.purple, in: Circle()).foregroundStyle(.white)
            .overlay { if account == nil { Image(systemName: "person.fill").foregroundStyle(.white) } }.accessibilityHidden(true)
    }
}

@MainActor struct NativeStorageAccounts: View {
    @Bindable var shell: NativeShellState
    var closeWindow: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var notice: String?
    private func close() { if let closeWindow { closeWindow() } else { dismiss() } }
    var body: some View {
        VStack(spacing: 0) {
            HStack { Text("Storage Accounts"); Spacer(); Button("Done") { close() }.keyboardShortcut(.cancelAction) }.padding(16)
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Connected Accounts").font(.system(size: 26)).frame(maxWidth: .infinity)
                    if let account = shell.session.account {
                        accountRow("OneDrive", detail: account.email, symbol: "cloud.fill")
                        accountRow("SharePoint", detail: account.email, symbol: "building.2.fill")
                        if !account.storageConnected {
                            Text("Connect storage to browse OneDrive folders and SharePoint sites. Your existing linked notebooks remain available.").foregroundStyle(.secondary)
                            Button("Connect Storage…") { connect() }.disabled(shell.session.busy)
                        }
                    } else {
                        Text("No storage accounts connected.").foregroundStyle(.secondary).frame(maxWidth: .infinity)
                    }
                    Text("Add Storage Account").font(.system(size: 26)).frame(maxWidth: .infinity).padding(.top, 12)
                    add("OneDrive", detail: "Add your personal account", symbol: "cloud.fill") {
                        notice = "Personal Microsoft accounts aren’t available in this build. Your existing notes are preserved."
                    }
                    add("OneDrive for Business", detail: "Add your work or school account", symbol: "cloud.fill") { connect() }
                    add("SharePoint", detail: "Add a SharePoint site", symbol: "building.2.fill") {
                        if shell.session.account?.storageConnected == true { shell.browserLocation = "sites"; shell.showCloud(.notebooks) }
                        else { connect() }
                    }
                    if shell.session.busy { HStack { ProgressView().controlSize(.small); Text("Connecting…") } }
                    if let notice { Text(notice).foregroundStyle(.secondary) }
                    if let error = shell.session.accountError { Text(error).foregroundStyle(.secondary) }
                }.padding(.horizontal, 64).padding(.vertical, 24)
            }
        }.frame(width: 580, height: 700).task { await shell.session.restoreAccount() }
    }
    private func connect() {
        guard let controller = shell.window?.contentViewController else { notice = "The account window is unavailable. Please reopen it."; return }
        notice = nil; shell.session.login(controller: controller, connectStorage: true)
    }
    private func accountRow(_ title: String, detail: String, symbol: String) -> some View {
        HStack(spacing: 20) { Image(systemName: symbol).font(.title2).foregroundStyle(.cyan).frame(width: 32); VStack(alignment: .leading, spacing: 3) { Text(title); Text(detail).font(.caption).foregroundStyle(.secondary) }; Spacer() }.padding(.vertical, 12)
    }
    private func add(_ title: String, detail: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) { HStack(spacing: 20) { Image(systemName: symbol).foregroundStyle(.cyan).font(.title2).frame(width: 32); VStack(alignment: .leading, spacing: 3) { Text(title); Text(detail).font(.caption).foregroundStyle(.secondary) }; Spacer() }.padding(16).frame(maxWidth: .infinity).background(.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 10)) }.buttonStyle(.plain)
    }
}
