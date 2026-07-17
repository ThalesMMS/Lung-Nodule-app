import Testing
@testable import Lung_Nodule

@MainActor
struct NumericInputParserTests {
    @Test func parsesFiniteNumbersWithWhitespaceAndCommaDecimal() {
        #expect(NumericInputParser.parseDouble(" 5,5 ") == 5.5)
        #expect(NumericInputParser.parseInt(" 42 ") == 42)
    }

    @Test func rejectsNonFiniteDoubles() {
        #expect(NumericInputParser.parseDouble("NaN") == nil)
        #expect(NumericInputParser.parseDouble("infinity") == nil)
        #expect(NumericInputParser.parseDouble("-infinity") == nil)
    }

    @Test func roundsFiniteMeasurementsAndRejectsNonFiniteValues() {
        #expect(NumericInputParser.roundToNearestMm(8.5) == 9)
        #expect(NumericInputParser.roundToNearestMm(.infinity) == nil)
        #expect(NumericInputParser.roundToNearestMm(.nan) == nil)
    }

    @Test func calculatorsRejectNonFiniteMeasurementText() {
        let fleischner = FleischnerViewModel()
        fleischner.sizeText = "NaN"
        #expect(fleischner.input.sizeMm == nil)

        let lungRADS = LungRADSViewModel()
        lungRADS.sizeText = "infinity"
        #expect(lungRADS.input.sizeMm == nil)
        lungRADS.useVolumeMeasurements = true
        lungRADS.volumeText = "infinity"
        #expect(lungRADS.input.volumeMm3 == nil)

        let brock = BrockViewModel()
        brock.form.age = "65"
        brock.form.noduleSize = "NaN"
        brock.form.noduleCount = "1"
        #expect(brock.result == nil)
    }
}
