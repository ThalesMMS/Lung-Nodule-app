import XCTest

final class Lung_NoduleUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    @MainActor
    func testSwitchesBetweenCalculators() {
        let lungRADS = app.buttons["calculator.lung-rads"]
        lungRADS.tap()
        waitForSelection(of: lungRADS)

        let fleischner = app.buttons["calculator.fleischner"]
        fleischner.tap()
        waitForSelection(of: fleischner)
    }

    @MainActor
    func testEnteringNoduleSizeUpdatesRecommendation() {
        let sizeField = element("fleischner.size")
        XCTAssertTrue(sizeField.waitForExistence(timeout: 3))
        sizeField.tap()
        sizeField.typeText("8")

        let result = element("fleischner.result")
        let updated = expectation(
            for: NSPredicate(format: "value CONTAINS %@", "6-12 months"),
            evaluatedWith: result
        )
        wait(for: [updated], timeout: 3)
    }

    @MainActor
    func testOpensCommonIssuesDetail() {
        let info = app.buttons["mode.info"]
        XCTAssertTrue(info.waitForExistence(timeout: 3))
        info.tap()

        let eligibility = app.buttons["Eligibility"]
        XCTAssertTrue(eligibility.waitForExistence(timeout: 3))
        eligibility.tap()

        XCTAssertTrue(element("fleischner.eligibility.detail").waitForExistence(timeout: 3))
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    private func waitForSelection(of element: XCUIElement) {
        let selected = expectation(
            for: NSPredicate(format: "value == %@", "Selected"),
            evaluatedWith: element
        )
        wait(for: [selected], timeout: 3)
    }
}
