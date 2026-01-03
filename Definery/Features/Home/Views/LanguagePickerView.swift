//
//  LanguagePickerView.swift
//  Definery
//
//  Created by Anthony on 3/1/26.
//

import SwiftUI

struct LanguagePickerView: View {
    let selected: Locale.LanguageCode
    let onSelect: (Locale.LanguageCode) -> Void

    private let supportedLanguages: [(code: Locale.LanguageCode, name: String, flag: String)] = [
        (.english, "English", "🇺🇸"),
        (.spanish, "Spanish", "🇪🇸"),
        (.italian, "Italian", "🇮🇹"),
        (.german, "German", "🇩🇪"),
        (.french, "French", "🇫🇷"),
        (.chinese, "Chinese", "🇨🇳"),
        (.portuguese, "Portuguese", "🇧🇷")
    ]

    var body: some View {
        Menu {
            ForEach(supportedLanguages, id: \.code) { language in
                Button {
                    onSelect(language.code)
                } label: {
                    HStack {
                        Text("\(language.flag) \(language.name)")
                        if language.code == selected {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(flagFor(selected))
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
        }
    }

    private func flagFor(_ code: Locale.LanguageCode) -> String {
        supportedLanguages.first { $0.code == code }?.flag ?? "🌐"
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        Text("Content")
            .navigationTitle("Definery")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    LanguagePickerView(selected: .english) { _ in }
                }
            }
    }
}
#endif
