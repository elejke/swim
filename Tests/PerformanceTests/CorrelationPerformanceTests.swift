import XCTest
import Swim

class CorrelationPerformanceTests: XCTestCase {

    func testSSD() {
        let image1 = Image<Intensity, Double>(width: 1920, height: 1080, value: 0)
        let image2 = Image<Intensity, Double>(width: 1920, height: 1080, value: 0)
        
        measure {
            for _ in 0..<100 {
                let d = Correlation.ssd(image1, image2)
                XCTAssertEqual(d, 0)
            }
        }
    }

    func testSAD() {
        let image1 = Image<Intensity, Double>(width: 1920, height: 1080, value: 0)
        let image2 = Image<Intensity, Double>(width: 1920, height: 1080, value: 0)
        
        measure {
            for _ in 0..<100 {
                let d = Correlation.sad(image1, image2)
                XCTAssertEqual(d, 0)
            }
        }
    }
    
    func testNCC() {
        let image1 = Image<Intensity, Double>(width: 1920, height: 1080, value: 0.01)
        let image2 = Image<Intensity, Double>(width: 1920, height: 1080, value: 0.01)
        
        measure {
            for _ in 0..<100 {
                let d = Correlation.ncc(image1, image2)
                XCTAssertEqual(d, 1)
            }
        }
    }
    
    func testZNCC() {
        let image1 = Image<Intensity, Double>(width: 1920, height: 1080, value: 0.01)
        let image2 = Image<Intensity, Double>(width: 1920, height: 1080, value: 0.02)
        
        measure {
            for _ in 0..<100 {
                let d = Correlation.zncc(image1, image2)
                XCTAssertEqual(d, 1, accuracy: 1e-3)
            }
        }
    }
}
