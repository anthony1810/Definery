//
//  DefinitionMapper.swift
//  WordAPI
//
//  Created by Anthony on 4/1/26.
//

import Foundation
import WordFeature

public enum DefinitionMapper {
    public enum Error: Swift.Error, Equatable {
        case invalidData
        case wordNotFound
        case noDefinitionFound
    }

    private struct WikiResponse: Decodable {
        let parse: ParseResult?
        let error: WikiError?
    }

    private struct ParseResult: Decodable {
        let title: String
        let pageid: Int
        let wikitext: WikiText
    }

    private struct WikiText: Decodable {
        let content: String

        enum CodingKeys: String, CodingKey {
            case content = "*"
        }
    }

    private struct WikiError: Decodable {
        let code: String
        let info: String
    }

    public static func map(
        _ data: Data,
        from response: HTTPURLResponse,
        word: String,
        language: String
    ) throws -> Word {
        guard response.isOK else {
            throw Error.invalidData
        }

        guard let wikiResponse = try? JSONDecoder().decode(WikiResponse.self, from: data) else {
            throw Error.invalidData
        }

        // Check for API error (e.g., missing page)
        if wikiResponse.error != nil {
            throw Error.wordNotFound
        }

        guard let parseResult = wikiResponse.parse else {
            throw Error.invalidData
        }

        let wikitext = parseResult.wikitext.content

        guard !wikitext.isEmpty else {
            throw Error.noDefinitionFound
        }

        let meanings = parseWikitext(wikitext, for: language)

        guard !meanings.isEmpty else {
            throw Error.noDefinitionFound
        }

        return Word(
            id: UUID(),
            text: word,
            language: language,
            phonetic: nil,
            meanings: meanings
        )
    }

    // MARK: - Wikitext Parsing

    private static func parseWikitext(_ wikitext: String, for language: String) -> [Meaning] {
        let languageSection = extractLanguageSection(from: wikitext, language: language)
        guard !languageSection.isEmpty else { return [] }

        return extractMeanings(from: languageSection)
    }

    private static func extractLanguageSection(from wikitext: String, language: String) -> String {
        let languageName = languageCodeToName(language)

        // Match ==Language== section but not ===Level3=== sections
        // Use negative lookbehind/lookahead to ensure exactly 2 = signs
        let pattern = "(?<!=)==\\s*\(languageName)\\s*==(?!=)([\\s\\S]*?)(?:(?<!=)==\\s*[A-Z][a-z]+\\s*==(?!=)|\\z)"

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              let match = regex.firstMatch(
                in: wikitext,
                range: NSRange(wikitext.startIndex..., in: wikitext)
              ),
              let range = Range(match.range(at: 1), in: wikitext) else {
            return ""
        }

        return String(wikitext[range])
    }

    private static func extractMeanings(from section: String) -> [Meaning] {
        var meanings: [Meaning] = []

        // Match ===PartOfSpeech=== followed by definitions (use lookahead to not consume ===)
        let posPattern = "===\\s*([A-Za-z]+)\\s*===([\\s\\S]*?)(?====|\\z)"

        guard let regex = try? NSRegularExpression(pattern: posPattern, options: []) else {
            return []
        }

        let matches = regex.matches(in: section, range: NSRange(section.startIndex..., in: section))

        for match in matches {
            guard let posRange = Range(match.range(at: 1), in: section),
                  let contentRange = Range(match.range(at: 2), in: section) else {
                continue
            }

            let partOfSpeech = String(section[posRange])

            // Skip non-definition sections
            let skipSections = ["Etymology", "Pronunciation", "Alternative forms", "Synonyms",
                               "Antonyms", "Derived terms", "Related terms", "Translations",
                               "See also", "References", "Descendants", "Usage notes", "Quotations"]
            if skipSections.contains(partOfSpeech) {
                continue
            }

            let content = String(section[contentRange])

            if let (definition, example) = extractFirstDefinition(from: content) {
                meanings.append(Meaning(
                    partOfSpeech: partOfSpeech,
                    definition: definition,
                    example: example
                ))
            }
        }

        return meanings
    }

    private static func extractFirstDefinition(from content: String) -> (definition: String, example: String?)? {
        let lines = content.components(separatedBy: .newlines)

        var definition: String?
        var example: String?

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Definition line starts with # (but not #: or #*)
            if trimmed.hasPrefix("#") && !trimmed.hasPrefix("#:") && !trimmed.hasPrefix("#*") {
                if definition == nil {
                    let defText = String(trimmed.dropFirst()).trimmingCharacters(in: .whitespaces)
                    definition = cleanWikitext(defText)
                }
            }

            // Example line starts with #:
            if trimmed.hasPrefix("#:") && example == nil && definition != nil {
                let exampleText = String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                example = extractExample(from: exampleText)
            }

            // Once we have both, we can stop
            if definition != nil && example != nil {
                break
            }
        }

        guard let def = definition, !def.isEmpty else { return nil }
        return (def, example)
    }

    private static func cleanWikitext(_ text: String) -> String {
        var result = text

        // Remove wiki links [[word]] -> word, [[word|display]] -> display
        let linkPattern = "\\[\\[([^\\]\\|]+\\|)?([^\\]]+)\\]\\]"
        if let regex = try? NSRegularExpression(pattern: linkPattern, options: []) {
            result = regex.stringByReplacingMatches(
                in: result,
                range: NSRange(result.startIndex..., in: result),
                withTemplate: "$2"
            )
        }

        // Remove bold/italic markers
        result = result.replacingOccurrences(of: "'''", with: "")
        result = result.replacingOccurrences(of: "''", with: "")

        // Remove {{lb|en|...}} label templates - extract just the labels
        let labelPattern = "\\{\\{lb\\|[a-z]+\\|([^}]+)\\}\\}"
        if let regex = try? NSRegularExpression(pattern: labelPattern, options: []) {
            result = regex.stringByReplacingMatches(
                in: result,
                range: NSRange(result.startIndex..., in: result),
                withTemplate: "($1)"
            )
        }

        // Remove {{ng|...}} non-gloss templates - keep content
        let ngPattern = "\\{\\{ng\\|([^}]+)\\}\\}"
        if let regex = try? NSRegularExpression(pattern: ngPattern, options: []) {
            result = regex.stringByReplacingMatches(
                in: result,
                range: NSRange(result.startIndex..., in: result),
                withTemplate: "$1"
            )
        }

        // Remove other templates {{...}} that we don't understand
        let templatePattern = "\\{\\{[^}]+\\}\\}"
        if let regex = try? NSRegularExpression(pattern: templatePattern, options: []) {
            result = regex.stringByReplacingMatches(
                in: result,
                range: NSRange(result.startIndex..., in: result),
                withTemplate: ""
            )
        }

        // Clean up extra whitespace
        result = result.replacingOccurrences(of: "  ", with: " ")
        result = result.trimmingCharacters(in: .whitespaces)

        return result
    }

    private static func extractExample(from text: String) -> String? {
        var result = text

        // Handle {{ux|en|Example text}}
        let uxPattern = "\\{\\{ux\\|[a-z]+\\|([^}]+)\\}\\}"
        if let regex = try? NSRegularExpression(pattern: uxPattern, options: []),
           let match = regex.firstMatch(in: result, range: NSRange(result.startIndex..., in: result)),
           let range = Range(match.range(at: 1), in: result) {
            result = String(result[range])
        }

        // Handle {{zh-x|Chinese|English translation}}
        let zhxPattern = "\\{\\{zh-x\\|([^|]+)\\|([^}]+)\\}\\}"
        if let regex = try? NSRegularExpression(pattern: zhxPattern, options: []),
           let match = regex.firstMatch(in: result, range: NSRange(result.startIndex..., in: result)),
           let chineseRange = Range(match.range(at: 1), in: result),
           let translationRange = Range(match.range(at: 2), in: result) {
            let chinese = String(result[chineseRange])
            let translation = String(result[translationRange])
            result = "\(chinese) - \(cleanWikitext(translation))"
        }

        // Clean remaining wiki markup
        result = cleanWikitext(result)

        return result.isEmpty ? nil : result
    }

    private static func languageCodeToName(_ code: String) -> String {
        switch code {
        case "en": return "English"
        case "es": return "Spanish"
        case "fr": return "French"
        case "de": return "German"
        case "it": return "Italian"
        case "pt", "pt-br": return "Portuguese"
        case "zh": return "Chinese"
        case "ja": return "Japanese"
        case "ko": return "Korean"
        default: return "English"
        }
    }
}
