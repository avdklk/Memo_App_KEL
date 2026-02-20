//
//  NetworkMonitor.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 2/19/26.
//
import Foundation
import Network

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue.global()

    // 현재 연결 여부
    @Published private(set) var isConnected: Bool = false
    
    // 연결 타입 (wifi, cellular 등)
    private(set) var connectionType: NWInterface.InterfaceType?

    private init() {
        monitor = NWPathMonitor()
    }

    // 모니터링 시작
    func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            self?.getConnectionType(path)
            
            if path.status == .satisfied {
                print("연결됨: \(path.debugDescription)")
            } else {
                print("연결 안 됨")
            }
        }
    }

    // 모니터링 중지
    func stopMonitoring() {
        monitor.cancel()
    }

    // 상세 연결 타입 확인
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .wiredEthernet
        } else {
            connectionType = .other
        }
    }
}
