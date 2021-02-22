/////
////  FreeMethods.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

import Foundation

typealias Block = () -> Void
typealias ErrorBlock = (Error) -> Void

func inBackground(_ block: @escaping Block) {
    DispatchQueue.global(qos: .default).async(execute: block)
}

func inForeground(_ block: @escaping Block) {
    nextTick(block)
}

func nextTick(_ block: @escaping Block) {
    nextTick(DispatchQueue.main, block: block)
}

func nextTick(_ on: DispatchQueue, block: @escaping Block) {
    on.async(execute: block)
}

func delay(_ duration: TimeInterval, background: Bool = false, block: @escaping Block) {
    let killTimeOffset = Int64(CDouble(duration) * CDouble(NSEC_PER_SEC))
    let killTime = DispatchTime.now() + Double(killTimeOffset) / Double(NSEC_PER_SEC)
    let queue: DispatchQueue = background ? .global(qos: .background) : .main
    queue.asyncAfter(deadline: killTime, execute: block)
}

func cancelableDelay(_ duration: TimeInterval, block: @escaping Block) -> Block {
    let killTimeOffset = Int64(CDouble(duration) * CDouble(NSEC_PER_SEC))
    let killTime = DispatchTime.now() + Double(killTimeOffset) / Double(NSEC_PER_SEC)
    var cancelled = false
    DispatchQueue.main.asyncAfter(deadline: killTime) {
        if !cancelled { block() }
    }
    return { cancelled = true }
}

class Proc {
    private var block: Block
    
    init(_ block: @escaping Block) {
        self.block = block
    }
    
    @objc
    func run() {
        block()
    }
}

@discardableResult
func every(_ timeout: TimeInterval, _ block: @escaping Block) -> Block {
    let proc = Proc(block)
    let timer = Timer.scheduledTimer(timeInterval: timeout, target: proc, selector: #selector(Proc.run), userInfo: nil, repeats: true)
    return {
        timer.invalidate()
    }
}
