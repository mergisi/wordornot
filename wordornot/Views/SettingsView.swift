//
//  SettingsView.swift
//  wordornot
//
//  Created by mustafa ergisi on 8/10/25.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("soundEffectsEnabled") private var soundEffectsEnabled: Bool = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled: Bool = true
    
    @State private var showMail = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    var body: some View {
        ZStack {
            Color.primaryDark.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    header
                    gameSettings
                    supportSection
                    aboutSection
                }
                .padding(.horizontal, AppLayout.padding)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showMail) {
            MailView(isShowing: $showMail, result: $mailResult, subject: "Word or Nah Support", toRecipients: ["support@wordornah.app"], body: defaultSupportBody())
        }
    }
    
    private var header: some View {
        HStack {
            Button("Back") { dismiss() }
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text("SETTINGS")
                .font(AppTypography.title)
                .foregroundColor(.white)
            Spacer().frame(width: 44)
        }
    }
    
    private var gameSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("GAME SETTINGS").font(AppTypography.caption).foregroundColor(.purpleAccent)
            toggleRow(title: "Sound Effects", isOn: $soundEffectsEnabled)
            toggleRow(title: "Vibration", isOn: $vibrationEnabled)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: AppLayout.cornerRadius).fill(Color.secondaryDark))
    }
    
    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title).foregroundColor(.white)
            Spacer()
            Toggle("", isOn: isOn).labelsHidden()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.06)))
    }
    
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SUPPORT").font(AppTypography.caption).foregroundColor(.purpleAccent)
            navRow(title: "How to Play", systemImage: "questionmark.circle") { showHowToPlay() }
            navRow(title: "Contact Support", systemImage: "envelope") { contactSupport() }
            navRow(title: "Rate App", systemImage: "star.fill") { rateApp() }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: AppLayout.cornerRadius).fill(Color.secondaryDark))
    }
    
    private var aboutSection: some View {
        VStack(spacing: 8) {
            Text("Word or Nah").font(.headline).foregroundColor(.white)
            Text("Version 1.0.0").font(AppTypography.caption).foregroundColor(.white.opacity(0.7))
            Text("Made with ❤️ for word lovers").font(AppTypography.caption).foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: AppLayout.cornerRadius).fill(Color.white.opacity(0.06)))
    }
    
    private func navRow(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage).foregroundColor(.white.opacity(0.9))
                Text(title).foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.white.opacity(0.5))
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.06)))
        }
    }
    
    private func showHowToPlay() {
        // Present HowToPlay on top via new window/sheet from root
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        keyWindow?.rootViewController?.present(UIHostingController(rootView: HowToPlayView()), animated: true)
    }
    
    private func contactSupport() {
        if MFMailComposeViewController.canSendMail() {
            showMail = true
        } else {
            let address = "support@wordornah.app"
            if let url = URL(string: "mailto:\\(address)") { UIApplication.shared.open(url) }
        }
    }
    
    private func rateApp() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id000000000?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
    
    private func defaultSupportBody() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
        return "\n\n---\nApp: Word or Nah\nVersion: \(version) (\(build))\niOS: \(UIDevice.current.systemVersion)\nDevice: \(UIDevice.current.model)\n"
    }
}

// MARK: - Mail Composer Wrapper
struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?
    var subject: String
    var toRecipients: [String]
    var body: String
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setSubject(subject)
        vc.setToRecipients(toRecipients)
        vc.setMessageBody(body, isHTML: false)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailView
        init(parent: MailView) { self.parent = parent }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let error = error { parent.result = .failure(error) }
            else { parent.result = .success(result) }
            parent.isShowing = false
            controller.dismiss(animated: true)
        }
    }
}

#Preview {
    SettingsView()
}


