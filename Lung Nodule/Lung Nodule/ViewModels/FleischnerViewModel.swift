import SwiftUI
import Combine

class FleischnerViewModel: ObservableObject {
    @Published var input = FleischnerInput()
    @Published var result: FleischnerRecommendation?
    
    func calculate() {
        result = FleischnerCalculator.calculate(input: input)
    }
    
    func reset() {
        input = FleischnerInput()
        result = nil
    }
}
