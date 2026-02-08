//
//  WordCardView.swift
//  Definery
//
//  Created by Anthony on 3/1/26.
//

import SwiftUI
import WordFeature

struct WordCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    let word: Word

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(word.text)
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                if let phonetic = word.phonetic {
                    Text(phonetic)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            ForEach(word.meanings.prefix(2), id: \.self) { meaning in
                MeaningRow(meaning: meaning)
            }

            if word.meanings.count > 2 {
                Text("+\(word.meanings.count - 2) more")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .shadow(
            color: colorScheme == .light ? .black.opacity(0.08) : .clear,
            radius: 8,
            y: 4
        )
    }
}

// MARK: - MeaningRow

private struct MeaningRow: View {
    let meaning: Meaning

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(meaning.partOfSpeech.capitalized)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(badgeColor(for: meaning.partOfSpeech))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    badgeColor(for: meaning.partOfSpeech).opacity(0.12),
                    in: Capsule()
                )

            Text(meaning.definition)
                .font(.callout)
                .foregroundStyle(.primary)

            if let example = meaning.example {
                Text("\"\(example)\"")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
    }

    private func badgeColor(for partOfSpeech: String) -> Color {
        switch partOfSpeech.lowercased() {
        case "noun": .blue
        case "verb": .orange
        case "adjective": .green
        case "adverb": .purple
        case "pronoun": .teal
        case "preposition": .indigo
        default: .gray
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Single Word") {
    WordCardView(word: .ephemeral)
        .padding()
        .preferredColorScheme(.dark)
}

#Preview("Multiple Meanings") {
    WordCardView(word: .melancholy)
        .padding()
        .preferredColorScheme(.dark)
}

#Preview("Word List") {
    ScrollView {
        LazyVStack(spacing: 12) {
            ForEach(Word.mocks) { word in
                WordCardView(word: word)
            }
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
#endif
