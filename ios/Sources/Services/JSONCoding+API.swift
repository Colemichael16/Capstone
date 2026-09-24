import Foundation

/// The backend returns ISO 8601 timestamps with fractional seconds
/// ("2026-01-01T00:00:00.000Z"), which the plain `.iso8601` strategy
/// doesn't parse. Shared by everything that talks to db/ — see
/// shared/api-contract.md.
extension JSONDecoder {
    static var api: JSONDecoder {
        let decoder = JSONDecoder()

        let withFractionalSeconds = ISO8601DateFormatter()
        withFractionalSeconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let withoutFractionalSeconds = ISO8601DateFormatter()
        withoutFractionalSeconds.formatOptions = [.withInternetDateTime]

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = withFractionalSeconds.date(from: string) { return date }
            if let date = withoutFractionalSeconds.date(from: string) { return date }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
        }

        return decoder
    }
}
