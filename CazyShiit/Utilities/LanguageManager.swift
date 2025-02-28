import SwiftUI
import Foundation

// MARK: - Language
struct Language: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let code: String
    let flag: String
    
    static let supported: [Language] = [
        Language(name: "English", code: "en", flag: "🇺🇸"),
        Language(name: "हिंदी", code: "hi", flag: "🇮🇳"),
        Language(name: "বাংলা", code: "bn", flag: "🇧🇩"),
        Language(name: "ગુજરાતી", code: "gu", flag: "🇮🇳"),
        Language(name: "मराठी", code: "mr", flag: "🇮🇳"),
        Language(name: "తెలుగు", code: "te", flag: "🇮🇳"),
        Language(name: "தமிழ்", code: "ta", flag: "🇮🇳"),
        Language(name: "ಕನ್ನಡ", code: "kn", flag: "🇮🇳"),
        Language(name: "മലയാളം", code: "ml", flag: "🇮🇳")
    ]
}

// MARK: - LocalizedStringKey Extension
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}

// MARK: - Language Manager
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.code, forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            Bundle.setLanguage(currentLanguage.code)
            objectWillChange.send()
        }
    }
    
    init() {
        let savedLanguageCode = UserDefaults.standard.string(forKey: "AppleLanguages") ?? "en"
        currentLanguage = Language.supported.first { $0.code == savedLanguageCode } ?? Language.supported[0]
    }
}

// MARK: - Bundle Extension for Language Support
private var bundleKey: UInt8 = 0

class BundleEx: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
              let bundle = Bundle(path: path) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, BundleEx.self)
        }
        
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            print("Failed to get path for language: \(language)")
            return
        }
        
        objc_setAssociatedObject(Bundle.main, &bundleKey, path, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

// MARK: - Language Selection View
struct LanguageSelectionView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLanguage: Language
    
    init() {
        _selectedLanguage = State(initialValue: LanguageManager.shared.currentLanguage)
    }
    
    var body: some View {
        NavigationView {
            List(Language.supported) { language in
                HStack {
                    Text(language.flag)
                        .font(.title)
                    
                    Text(language.name)
                        .font(.body)
                    
                    Spacer()
                    
                    if language.code == selectedLanguage.code {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedLanguage = language
                    languageManager.currentLanguage = language
                    dismiss()
                }
            }
            .navigationTitle("Select Language".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
} 