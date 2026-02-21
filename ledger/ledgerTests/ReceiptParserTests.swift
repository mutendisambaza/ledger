import XCTest
@testable import ledger

final class ReceiptParserTests: XCTestCase {
    private var parser: ReceiptParser!

    override func setUp() {
        super.setUp()
        parser = ReceiptParser()
    }

    override func tearDown() {
        parser = nil
        super.tearDown()
    }

    func testParsesUSDTotal() {
        let message = makeMessage(
            from: "Store <receipts@example.com>",
            subject: "Your receipt",
            body: "Order total: USD 19.99"
        )

        let parsed = parser.parse(message: message)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.amountCents, 1999)
        XCTAssertEqual(parsed?.currency, "USD")
    }

    func testParsesCADWithCAPrefix() {
        let message = makeMessage(
            from: "Cafe <billing@example.com>",
            subject: "Receipt",
            body: "Grand Total: CA$12.45"
        )

        let parsed = parser.parse(message: message)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.amountCents, 1245)
        XCTAssertEqual(parsed?.currency, "CAD")
    }

    func testParsesCADWithCodePrefix() {
        let message = makeMessage(
            from: "Shop <billing@example.com>",
            subject: "Invoice",
            body: "Amount charged: CAD 42.10"
        )

        let parsed = parser.parse(message: message)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.amountCents, 4210)
        XCTAssertEqual(parsed?.currency, "CAD")
    }

    func testParsesCADWithCSignPrefix() {
        let message = makeMessage(
            from: "Transit <billing@example.com>",
            subject: "Receipt",
            body: "Total charged to card: C$7.80"
        )

        let parsed = parser.parse(message: message)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.amountCents, 780)
        XCTAssertEqual(parsed?.currency, "CAD")
    }

    func testPrefersOrderTotalOverTip() {
        let message = makeMessage(
            from: "Restaurant <billing@example.com>",
            subject: "Receipt",
            body: "Tip: $7.00\nOrder total: $45.00\nTax: $2.00"
        )

        let parsed = parser.parse(message: message)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.amountCents, 4500)
    }

    func testPrefersOrderTotalOverDiscount() {
        let message = makeMessage(
            from: "Shop <billing@example.com>",
            subject: "Order receipt",
            body: "Discount: $15.00\nSubtotal: $52.99\nOrder Total: $59.88"
        )

        let parsed = parser.parse(message: message)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.amountCents, 5988)
    }

    func testDecodesHTMLEntitiesBeforeParsing() {
        let message = makeMessage(
            from: "Store <billing@example.com>",
            subject: "Receipt",
            body: "Total&amp;nbsp;Charged: &#36;33.21"
        )

        let parsed = parser.parse(message: message)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.amountCents, 3321)
    }

    func testReturnsNilForEmptyBody() {
        let message = makeMessage(
            from: "Store <billing@example.com>",
            subject: "Receipt",
            body: ""
        )

        XCTAssertNil(parser.parse(message: message))
    }

    func testReturnsNilForMalformedBody() {
        let message = makeMessage(
            from: "Store <billing@example.com>",
            subject: "Receipt",
            body: "No numbers here. just text and symbols ###"
        )

        XCTAssertNil(parser.parse(message: message))
    }

    func testExtractsNetflixMerchantFromDomain() {
        let message = makeMessage(
            from: "Netflix <info@netflix.com>",
            subject: "Your payment confirmation",
            body: "Charged to your card: USD 17.99"
        )

        let parsed = parser.parse(message: message)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.merchant, "Netflix")
        XCTAssertEqual(parsed?.amountCents, 1799)
    }

    func testExtractsSpotifyMerchantFromDomain() {
        let message = makeMessage(
            from: "Spotify Billing <no-reply@spotify.com>",
            subject: "Receipt",
            body: "Amount due: CAD 11.29"
        )

        let parsed = parser.parse(message: message)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.merchant, "Spotify")
        XCTAssertEqual(parsed?.amountCents, 1129)
    }

    func testParsesAmazonMarketplaceWithLineItems() {
        let message = makeMessage(
            from: "Amazon.ca <auto-confirm@amazon.com>",
            subject: "Your Amazon.ca order",
            body: "Item A: CAD 10.00\nItem B: CAD 5.00\nOrder Total: CAD 16.95"
        )

        let parsed = parser.parse(message: message)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.merchant, "Amazon")
        XCTAssertEqual(parsed?.amountCents, 1695)
    }

    private func makeMessage(from: String, subject: String, body: String) -> GmailMessage {
        let payload = GmailPayload(
            headers: [
                GmailHeader(name: "From", value: from),
                GmailHeader(name: "Subject", value: subject)
            ],
            body: GmailBody(data: nil, size: body.count),
            parts: [
                GmailPart(mimeType: "text/plain", body: GmailBody(data: encodeBase64URL(body), size: body.count), parts: nil)
            ]
        )

        return GmailMessage(
            id: UUID().uuidString,
            snippet: body,
            payload: payload,
            internalDate: "1700000000000"
        )
    }

    private func encodeBase64URL(_ value: String) -> String {
        let base64 = Data(value.utf8).base64EncodedString()
        return base64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
