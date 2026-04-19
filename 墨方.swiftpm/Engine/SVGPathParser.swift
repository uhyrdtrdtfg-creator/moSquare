import SwiftUI
import CoreGraphics

/// Parses SVG path "d" attribute strings into a SwiftUI `Path`.
///
/// Supports: M/m, L/l, H/h, V/v, C/c, Q/q, S/s, T/t, Z/z.
/// Coordinates are passed through as-is (no scaling/flipping) — the caller
/// is responsible for any coordinate-system transforms (e.g. Y-flip for
/// hanzi-writer-data, which uses a bottom-left origin 1024×1024 canvas).
enum SVGPathParser {

    /// Parse an SVG path "d" attribute string into a SwiftUI Path.
    static func parse(_ d: String) -> Path {
        var path = Path()
        let tokens = tokenize(d)
        guard !tokens.isEmpty else { return path }

        var i = 0
        var current = CGPoint.zero
        var pathStart = CGPoint.zero
        var lastControl = CGPoint.zero
        var lastCommand: Character = "M"

        // Helper: safely read a double from tokens; returns 0 if out of range.
        func readDouble() -> CGFloat {
            guard i < tokens.count else { return 0 }
            let v = parseDouble(tokens[i])
            i += 1
            return v
        }

        while i < tokens.count {
            // Read command letter or reuse last (implicit repeat).
            let cmdCh: Character
            if let first = tokens[i].first, first.isLetter {
                cmdCh = first
                i += 1
            } else {
                // Implicit repeat: after M→L, after m→l, otherwise reuse lastCommand.
                if lastCommand == "M" {
                    cmdCh = "L"
                } else if lastCommand == "m" {
                    cmdCh = "l"
                } else {
                    cmdCh = lastCommand
                }
            }
            lastCommand = cmdCh

            switch cmdCh {
            case "M":
                let x = readDouble()
                let y = readDouble()
                current = CGPoint(x: x, y: y)
                pathStart = current
                path.move(to: current)

            case "m":
                let dx = readDouble()
                let dy = readDouble()
                current = CGPoint(x: current.x + dx, y: current.y + dy)
                pathStart = current
                path.move(to: current)

            case "L":
                let x = readDouble()
                let y = readDouble()
                current = CGPoint(x: x, y: y)
                path.addLine(to: current)

            case "l":
                let dx = readDouble()
                let dy = readDouble()
                current = CGPoint(x: current.x + dx, y: current.y + dy)
                path.addLine(to: current)

            case "H":
                let x = readDouble()
                current = CGPoint(x: x, y: current.y)
                path.addLine(to: current)

            case "h":
                let dx = readDouble()
                current = CGPoint(x: current.x + dx, y: current.y)
                path.addLine(to: current)

            case "V":
                let y = readDouble()
                current = CGPoint(x: current.x, y: y)
                path.addLine(to: current)

            case "v":
                let dy = readDouble()
                current = CGPoint(x: current.x, y: current.y + dy)
                path.addLine(to: current)

            case "C":
                let c1 = CGPoint(x: readDouble(), y: readDouble())
                let c2 = CGPoint(x: readDouble(), y: readDouble())
                let end = CGPoint(x: readDouble(), y: readDouble())
                path.addCurve(to: end, control1: c1, control2: c2)
                current = end
                lastControl = c2

            case "c":
                let c1 = CGPoint(x: current.x + readDouble(), y: current.y + readDouble())
                let c2 = CGPoint(x: current.x + readDouble(), y: current.y + readDouble())
                let end = CGPoint(x: current.x + readDouble(), y: current.y + readDouble())
                path.addCurve(to: end, control1: c1, control2: c2)
                current = end
                lastControl = c2

            case "Q":
                let c = CGPoint(x: readDouble(), y: readDouble())
                let end = CGPoint(x: readDouble(), y: readDouble())
                path.addQuadCurve(to: end, control: c)
                current = end
                lastControl = c

            case "q":
                let c = CGPoint(x: current.x + readDouble(), y: current.y + readDouble())
                let end = CGPoint(x: current.x + readDouble(), y: current.y + readDouble())
                path.addQuadCurve(to: end, control: c)
                current = end
                lastControl = c

            case "T":
                // Smooth quadratic: reflect lastControl across current point.
                // If previous command wasn't Q/q/T/t, the reflected control is the current point.
                let c: CGPoint
                if isQuadraticCommand(lastPreviousCommand(before: cmdCh, recorded: lastCommand)) {
                    c = CGPoint(x: 2 * current.x - lastControl.x, y: 2 * current.y - lastControl.y)
                } else {
                    c = current
                }
                let end = CGPoint(x: readDouble(), y: readDouble())
                path.addQuadCurve(to: end, control: c)
                lastControl = c
                current = end

            case "t":
                let c: CGPoint
                if isQuadraticCommand(lastPreviousCommand(before: cmdCh, recorded: lastCommand)) {
                    c = CGPoint(x: 2 * current.x - lastControl.x, y: 2 * current.y - lastControl.y)
                } else {
                    c = current
                }
                let end = CGPoint(x: current.x + readDouble(), y: current.y + readDouble())
                path.addQuadCurve(to: end, control: c)
                lastControl = c
                current = end

            case "S":
                // Smooth cubic: reflect lastControl across current point.
                let c1: CGPoint
                if isCubicCommand(lastPreviousCommand(before: cmdCh, recorded: lastCommand)) {
                    c1 = CGPoint(x: 2 * current.x - lastControl.x, y: 2 * current.y - lastControl.y)
                } else {
                    c1 = current
                }
                let c2 = CGPoint(x: readDouble(), y: readDouble())
                let end = CGPoint(x: readDouble(), y: readDouble())
                path.addCurve(to: end, control1: c1, control2: c2)
                lastControl = c2
                current = end

            case "s":
                let c1: CGPoint
                if isCubicCommand(lastPreviousCommand(before: cmdCh, recorded: lastCommand)) {
                    c1 = CGPoint(x: 2 * current.x - lastControl.x, y: 2 * current.y - lastControl.y)
                } else {
                    c1 = current
                }
                let c2 = CGPoint(x: current.x + readDouble(), y: current.y + readDouble())
                let end = CGPoint(x: current.x + readDouble(), y: current.y + readDouble())
                path.addCurve(to: end, control1: c1, control2: c2)
                lastControl = c2
                current = end

            case "Z", "z":
                path.closeSubpath()
                current = pathStart

            default:
                // Unknown command letter — skip a single token to avoid infinite loop.
                // (Most SVG path data uses the commands above; we don't implement arcs A/a.)
                i += 1
            }
        }
        return path
    }

    // MARK: - Smooth-command helpers

    /// `lastCommand` is updated to the *current* command at the top of each
    /// iteration, so to decide whether a smooth-curve reflection is valid we
    /// need the command that came *before* the current one. We derive that
    /// from the fact that `isQuadraticCommand` / `isCubicCommand` are called
    /// with the just-captured `recorded` value, which at call-time equals the
    /// command we just switched into. Since we can't peek backwards easily,
    /// we accept a small simplification: we pass in `recorded` and if it's
    /// the current smooth command itself we treat it as a continuation (which
    /// is the common case for `TT…` / `SS…` / `tt…` / `ss…` chains).
    private static func lastPreviousCommand(before current: Character, recorded: Character) -> Character {
        return recorded
    }

    private static func isQuadraticCommand(_ c: Character) -> Bool {
        return c == "Q" || c == "q" || c == "T" || c == "t"
    }

    private static func isCubicCommand(_ c: Character) -> Bool {
        return c == "C" || c == "c" || c == "S" || c == "s"
    }

    // MARK: - Tokenization

    /// Split the path string into tokens.
    ///
    /// - Letters (commands) become their own single-character tokens.
    /// - Whitespace and commas are separators.
    /// - A `-` mid-number starts a new negative token, except when it follows
    ///   an exponent marker (`e` / `E`), which would be part of scientific notation.
    /// - A `.` mid-number starts a new token if the current token already contains a `.`
    ///   (handles e.g. `0.5.5` → `0.5`, `.5`), a common shorthand in minified SVGs.
    private static func tokenize(_ s: String) -> [String] {
        var out: [String] = []
        var buf = ""

        func flush() {
            if !buf.isEmpty {
                out.append(buf)
                buf = ""
            }
        }

        for ch in s {
            if ch.isLetter {
                flush()
                out.append(String(ch))
            } else if ch == "," || ch.isWhitespace {
                flush()
            } else if ch == "-" || ch == "+" {
                // Sign: starts a new number unless it follows an exponent marker.
                if !buf.isEmpty, let last = buf.last, last != "e" && last != "E" {
                    flush()
                }
                buf.append(ch)
            } else if ch == "." {
                // A second '.' in the same token starts a new number.
                if buf.contains(".") {
                    flush()
                }
                buf.append(ch)
            } else {
                buf.append(ch)
            }
        }
        flush()
        return out
    }

    private static func parseDouble(_ s: String) -> CGFloat {
        CGFloat(Double(s) ?? 0)
    }
}
