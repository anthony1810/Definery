//
//  WordCardView.swift
//  Definery
//
//  Created by Anthony on 3/1/26.
//

import SwiftUI
import WordFeature

struct WordCardView: View {
    let word: Word

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(word.text)
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                if let phonetic = word.phonetic {
                    Text(phonetic)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            ForEach(word.meanings.prefix(2), id: \.definition) { meaning in
                MeaningRow(meaning: meaning)
            }

            if word.meanings.count > 2 {
                Text("+\(word.meanings.count - 2) more")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

private struct MeaningRow: View {
    let meaning: Meaning

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(meaning.partOfSpeech)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(.secondary.opacity(0.1), in: Capsule())

            Text(meaning.definition)
                .font(.body)
                .foregroundStyle(.primary)

            if let example = meaning.example {
                Text("\"\(example)\"")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .italic()
            }
        }
    }
}

#if DEBUG
#Preview("Single Word") {
    WordCardView(word: .ephemeral)
        .padding()
}

#Preview("Multiple Meanings") {
    WordCardView(word: .melancholy)
        .padding()
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
}
#endif
