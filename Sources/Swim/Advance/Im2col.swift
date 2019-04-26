import Foundation

public enum Im2ColPadding<T: DataType> {
    case edge
    case constant(T)
}

extension Im2ColPadding where T: ExpressibleByIntegerLiteral {
    public static var zero: Im2ColPadding {
        return constant(0)
    }
    
    public static var one: Im2ColPadding {
        return constant(1)
    }
}

extension Image where P == Intensity {
    @inlinable
    public func im2col(patchWidth: Int,
                       patchHeight: Int,
                       padding: Im2ColPadding<T> = .edge) -> (m: Int, n: Int, matrix: [T]) {
        
        let m = patchWidth*patchHeight
        let n = width*height
        
        var ret: [T]
        switch padding {
        case .constant(let v):
            ret = [T](repeating: v, count: m*n)
        default:
            ret = [T](repeating: T.swimDefaultValue, count: m*n)
        }
        
        let padTop = (patchHeight-1) / 2
        let padLeft = (patchWidth-1) / 2
        
        data.withUnsafeBufferPointer {
            let src = $0.baseAddress!
            ret.withUnsafeMutableBufferPointer {
                var dst = $0.baseAddress!
                
                for dy in -padTop..<patchHeight-padTop {
                    for dx in -padLeft..<patchWidth-padLeft {
                        for y in 0..<height {
                            var yy = y + dy
                            if !(0..<height ~= yy) {
                                switch padding {
                                case .edge:
                                    yy = min(max(yy, 0), height-1)
                                case .constant:
                                    dst += width
                                    continue
                                }
                            }

                            // point leftest pixel
                            let x = min(max(dx, 0), width-1)
                            var sp = src + (yy * width + x)
                            
                            // left padding
                            switch padding {
                            case .edge:
                                let padLeftValue = sp.pointee
                                for _ in 0..<max(-dx, 0) {
                                    dst.pointee = padLeftValue
                                    dst += 1
                                }
                            case .constant:
                                dst += max(-dx, 0)
                            }
                            
                            // copy
                            let count = width - Swift.abs(dx)
                            memcpy(dst, sp, count*MemoryLayout<T>.size)
                            dst += count
                            
                            // right padding
                            switch padding {
                            case .edge:
                                sp += count - 1 // point rightest pixel
                                let padRightValue = sp.pointee
                                for _ in 0..<max(dx, 0) {
                                    dst.pointee = padRightValue
                                    dst += 1
                                }
                            case .constant:
                                dst += max(dx, 0)
                            }
                            
                        }
                    }
                }
            }
        }
        
        return (m, n, ret)
    }
}
