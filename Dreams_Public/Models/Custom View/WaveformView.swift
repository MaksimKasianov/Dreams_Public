import UIKit

class WaveformView: UIView {
    fileprivate(set) var _amplitude: CGFloat = 0.3

    public var waveColor: UIColor = .primary_500
    public var numberOfWaves = 8
    public var lineWidth: CGFloat = 2.0
    public var idleAmplitude: CGFloat = 0.0
    public var density: CGFloat = 5
    public var spacing: CGFloat = 4.0

    @IBInspectable public var amplitude: CGFloat {
        get {
            return _amplitude
        }
    }

    public func updateWithLevel(_ level: CGFloat) {
        _amplitude = fmax(level, idleAmplitude)
        setNeedsDisplay()
    }

    override open func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.clear(bounds)
        backgroundColor?.set()
        context.fill(rect)
        
        for waveNumber in 1...4 {
            drawWave(context: context, waveNumber: waveNumber, reverse: false)
            drawWave(context: context, waveNumber: waveNumber, reverse: true)
        }
    }

    func drawWave(context: CGContext, waveNumber: Int, reverse: Bool) {
        let halfHeight = bounds.height
        let width = bounds.width
        let columnWidth = (width - (CGFloat(numberOfWaves) * spacing)) / CGFloat(numberOfWaves)
        
        let progress: CGFloat = CGFloat(waveNumber) / CGFloat(numberOfWaves)
        let normedAmplitude = min((1.0 - progress) * amplitude, 1)
        
        waveColor.withAlphaComponent(waveColor.cgColor.alpha).set()
                
        var columnRect: CGRect
        
        if reverse {
            let columnX = width - CGFloat(waveNumber) * (columnWidth + spacing)
            let scaling = -pow(1 / (width / 2) * abs(columnX - width / 2), 2) + 1
            let columnHeight = scaling * normedAmplitude * halfHeight
            
            columnRect = CGRect(x: columnX, y: bounds.height / 2 - columnHeight / 2, width: columnWidth, height: columnHeight)
        } else {
            let columnX = CGFloat(waveNumber) * (columnWidth + spacing)
            let posX = CGFloat(waveNumber - 1) * (columnWidth + spacing)
            
            let scaling = -pow(1 / (width / 2) * abs(columnX - width / 2), 2) + 1
            let columnHeight = scaling * normedAmplitude * halfHeight
            
            //print(scaling)
            columnRect = CGRect(x: posX, y: bounds.height / 2 - columnHeight / 2, width: columnWidth, height: columnHeight)
        }
        
        let path = UIBezierPath(roundedRect: columnRect, cornerRadius: columnWidth / 2)
        path.fill()
    }
}
