import UIKit
import Vision

enum PlateOCR {

    struct Result {
        let bestPlateDisplay: String?
        let bestPlateCanonical: String?
        let allCandidatesDisplay: [String]
        let allCandidatesCanonical: [String]
    }

    static func readBestPlate(from uiImage: UIImage) async -> Result {
        guard let cgImage = uiImage.cgImage else {
            return Result(
                bestPlateDisplay: nil,
                bestPlateCanonical: nil,
                allCandidatesDisplay: [],
                allCandidatesCanonical: []
            )
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.minimumTextHeight = 0.02
        request.recognitionLanguages = ["en-GB", "en-US"]

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])

            let observations: [VNRecognizedTextObservation] = request.results ?? []

            let raw: [String] = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            // Display candidates keep internal spaces (e.g. "FS22 PET")
            let displayCandidates: [String] = raw
                .map { PlateSanitizer.sanitizeForDisplay($0) }
                .filter { !$0.isEmpty }

            // Canonical candidates remove spaces (e.g. "FS22PET") for matching/storage
            let canonicalCandidates: [String] = displayCandidates
                .map { PlateSanitizer.canonicalize($0) }
                .filter { !$0.isEmpty }

            let bestCanonical = PlateMatcher.pickBest(from: canonicalCandidates)

            let bestDisplay: String? = {
                guard let bestCanonical else { return nil }
                if let idx = canonicalCandidates.firstIndex(of: bestCanonical) {
                    return displayCandidates[idx]
                }
                return bestCanonical
            }()

            return Result(
                bestPlateDisplay: bestDisplay,
                bestPlateCanonical: bestCanonical,
                allCandidatesDisplay: displayCandidates,
                allCandidatesCanonical: canonicalCandidates
            )

        } catch {
            return Result(
                bestPlateDisplay: nil,
                bestPlateCanonical: nil,
                allCandidatesDisplay: [],
                allCandidatesCanonical: []
            )
        }
    }
}

enum PlateSanitizer {

    /// Keeps spaces for display, strips other punctuation.
    static func sanitizeForDisplay(_ raw: String) -> String {
        let upper = raw.uppercased()

        // Keep letters, digits, and spaces; drop everything else
        let filtered = upper.filter { $0.isLetter || $0.isNumber || $0 == " " }

        // Collapse multiple spaces into one and trim ends
        let collapsed = filtered
            .split(separator: " ", omittingEmptySubsequences: true)
            .joined(separator: " ")

        return collapsed
    }

    /// Removes spaces for matching/storage
    static func canonicalize(_ display: String) -> String {
        display.filter { $0.isLetter || $0.isNumber }
    }
}

enum PlateMatcher {

    private static let current =
        try! NSRegularExpression(pattern: "^[A-Z]{2}[0-9]{2}[A-Z]{3}$")

    private static let prefix =
        try! NSRegularExpression(pattern: "^[A-Z][0-9]{1,3}[A-Z]{3}$")

    private static let suffix =
        try! NSRegularExpression(pattern: "^[A-Z]{3}[0-9]{1,3}[A-Z]$")

    private static let plateLike =
        try! NSRegularExpression(pattern: "^[A-Z0-9]{2,8}$")

    static func pickBest(from candidates: [String]) -> String? {
        guard !candidates.isEmpty else { return nil }

        let scored: [(String, Int)] = candidates.map { c in
            var score = 0

            if matches(current, c) { score += 200 }
            if matches(prefix, c)  { score += 120 }
            if matches(suffix, c)  { score += 120 }

            if matches(plateLike, c) { score += 40 } else { score -= 50 }

            let hasLetter = c.contains(where: { $0.isLetter })
            let hasDigit  = c.contains(where: { $0.isNumber })

            if hasLetter && hasDigit { score += 35 }
            if hasLetter && !hasDigit { score -= 10 }
            if hasDigit && !hasLetter { score -= 10 }

            switch c.count {
            case 7: score += 20
            case 6: score += 15
            case 5: score += 12
            case 4: score += 4
            case 3: score += 1
            case 2: score += 0
            default: score -= 20
            }

            if hasExcessiveRepetition(c) { score -= 15 }

            return (c, score)
        }

        return scored.sorted(by: { $0.1 > $1.1 }).first?.0
    }

    private static func matches(_ regex: NSRegularExpression, _ text: String) -> Bool {
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.firstMatch(in: text, options: [], range: range) != nil
    }

    private static func hasExcessiveRepetition(_ text: String) -> Bool {
        var maxRun = 1
        var run = 1
        let chars = Array(text)
        guard chars.count > 1 else { return false }

        for i in 1..<chars.count {
            if chars[i] == chars[i - 1] {
                run += 1
                if run > maxRun { maxRun = run }
            } else {
                run = 1
            }
        }
        return maxRun >= 4
    }
}
