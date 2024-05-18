//
//  CircleChart.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 17.05.2024.
//

import UIKit

class CircleChart: UIView {

    private let lineWidth: CGFloat = 20.0

    var usedMemoryColor: UIColor = .systemBlue
    var freeMemoryColor: UIColor = .systemPink

    private var progressLayer: CAShapeLayer!
    private var freeMemoryLayer: CAShapeLayer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCircle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCircle() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2

        let startAngle = -CGFloat.pi / 2
        let endAngle = 3 * CGFloat.pi / 2

        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        // Создаем слой для занятой памяти
        progressLayer = CAShapeLayer()
        progressLayer.path = circlePath.cgPath
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeColor = usedMemoryColor.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)

        // Создаем слой для свободной памяти
        freeMemoryLayer = CAShapeLayer()
        freeMemoryLayer.path = circlePath.cgPath
        freeMemoryLayer.lineWidth = lineWidth
        freeMemoryLayer.strokeColor = freeMemoryColor.cgColor
        freeMemoryLayer.fillColor = UIColor.clear.cgColor
        freeMemoryLayer.strokeEnd = 1
        layer.addSublayer(freeMemoryLayer)
    }

    func updateCircleChart(usedMemory: CGFloat, totalMemory: CGFloat) {
        let progress = usedMemory / totalMemory
        progressLayer.strokeEnd = progress
        freeMemoryLayer.strokeStart = progress
    }
}
