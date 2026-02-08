//
//  LanguageSegmentedPicker.swift
//  Definery
//
//  Created by Anthony on 2/2/26.
//

import SwiftUI

struct LanguageSegmentedPicker: View {
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(supportedLanguages, id: \.code) { language in
                    pillButton(for: language)
                }
            }
            .padding(.horizontal, 4)
        }
        .animation(.easeInOut(duration: 0.2), value: selected)
    }

    private func pillButton(for language: (code: Locale.LanguageCode, name: String, flag: String)) -> some View {
        let isSelected = selected == language.code

        return Button {
            onSelect(language.code)
        } label: {
            HStack(spacing: 4) {
                Text(language.flag)
                Text(language.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? Color.white : Color.secondary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    struct PreviewWrapper: View {
        @State private var selected: Locale.LanguageCode = .english

        var body: some View {
            VStack {
                LanguageSegmentedPicker(selected: selected) { code in
                    selected = code
                }
                .padding()

                Spacer()
            }
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }

    return PreviewWrapper()
}
#endif
