import XCTest
import Swim

class FourierTransformerVisualTests: XCTestCase {
}

#if canImport(AppKit)

extension FourierTransformerVisualTests {
    func testFFT() {
        let path = testResoruceRoot().appendingPathComponent("lena_512_gray.png")
        let lena = try! Image<Gray, Double>(contentsOf: path).resize(width: 256, height: 256)
        var images: [Image<Gray, Double>] = []
        
        let fft = FourierTransformer.fft(image: lena)
        let shifted = FourierTransformer.shift(image: fft)
        
        do {
            // spectrum
            var spectrum = shifted[channel: 0].powered(2) + shifted[channel: 1].powered(2)
            spectrum.dataConvert { log1p(sqrt($0)) }
            
            let (minSpectrum, maxSpectrum) = spectrum.withUnsafeBufferPointer { ($0.min()!, $0.max()!) }
            images.append((spectrum - minSpectrum) / (maxSpectrum - minSpectrum))
            
            // inverse transform
            images.append(FourierTransformer.ifft(image: fft))
        }
        
        var lowPassFilter = Image<Gray, Double>.zeros(like: shifted)
        lowPassFilter.drawCircle(center: (x: (lowPassFilter.width-1)/2,
                                          y: (lowPassFilter.height-1)/2),
                                 radius: 20,
                                 color: Pixel(gray: 1))
        do { // low pass filter
            var shifted = shifted
            shifted[channel: .gray] *= lowPassFilter
            shifted[channel: .alpha] *= lowPassFilter
            
            // spectrum
            var spectrum = shifted[channel: 0].powered(2) + shifted[channel: 1].powered(2)
            spectrum.dataConvert { log1p(sqrt($0)) }
            
            let (minSpectrum, maxSpectrum) = spectrum.withUnsafeBufferPointer { ($0.min()!, $0.max()!) }
            images.append((spectrum - minSpectrum) / (maxSpectrum - minSpectrum))
            
            // inverse transform
            let fft = FourierTransformer.shift(image: shifted)
            images.append(FourierTransformer.ifft(image: fft))
        }
        
        do { // high pass filter
            var shifted = shifted
            let highPassFilter = 1 - lowPassFilter
            shifted[channel: .gray] *= highPassFilter
            shifted[channel: .alpha] *= highPassFilter
            
            // spectrum
            var spectrum = shifted[channel: 0].powered(2) + shifted[channel: 1].powered(2)
            spectrum.dataConvert { log1p(sqrt($0)) }
            
            let (minSpectrum, maxSpectrum) = spectrum.withUnsafeBufferPointer { ($0.min()!, $0.max()!) }
            images.append((spectrum - minSpectrum) / (maxSpectrum - minSpectrum))
            
            // inverse transform
            let fft = FourierTransformer.shift(image: shifted)
            images.append(FourierTransformer.ifft(image: fft))
        }
        
        // result
        let ns = doubleToNSImage(Image.concatH(images))
        
        XCTAssertTrue(ns.isValid, "break here")
    }
}

#endif
