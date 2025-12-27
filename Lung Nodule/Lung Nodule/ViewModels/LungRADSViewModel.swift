import SwiftUI
import Combine

class LungRADSViewModel: ObservableObject {
    @Published var input = LungRADSInput()
    @Published var result: LungRADSResult?
    
    func calculate() {
        result = LungRADSCalculator.calculate(input: input)
    }
    
    func reset() {
        input = LungRADSInput()
        result = nil
    }
}
