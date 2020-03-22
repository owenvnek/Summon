//
//  SocketIOManager.swift
//  Connection Test
//
//  Created by Owen Vnek on 12/22/19.
//  Copyright © 2019 Nio. All rights reserved.
//

import UIKit
import SocketIO

class SocketIOManager: NSObject {
    
    static let sharedInstance = SocketIOManager()
    
    var socket_manager: SocketManager!
    var socket: SocketIOClient!
    private var connected: Bool
    private var buffer: Queue<BufferUnit>

    override init() {
        connected = false
        buffer = Queue<BufferUnit>()
        super.init()
        create_connection()
    }
    
    func create_connection() {
        let url = "https://summon.owenvnek.life:443" //dev
        socket_manager = SocketManager(socketURL: URL(string: url)!, config: [.log(false), .compress, .reconnects(false)])
        socket = socket_manager.defaultSocket
        socket.on("error", callback: {
            data, ack in
            if let reconnect_data = data[0] as? String {
                if reconnect_data == "Error" {
                    //self.disconnect()
                    print("disconnected")
                }
            }
        })
        socket.on("reconnect", callback: {
            data, ack in
            if let reconnect_data = data[0] as? String {
                if reconnect_data == "Error" {
                    //self.disconnect()
                    print("disconnected")
                }
            }
            self.send_buffer()
        })
        socket.on("connected", callback: {
            data, ack in
            self.connected = true
            self.send_buffer()
        })
        socket.connect()
        send_buffer()
    }
    
    func send_buffer() {
        while !buffer.isEmpty {
            let buffer_unit = buffer.dequeue()!
            socket.emit(buffer_unit.get_event(), buffer_unit.get_data())
        }
    }

    func establishConnection() {
        socket.connect()
    }

    func closeConnection() {
        socket.disconnect()
    }
    
    func attempt_reconnect() {
        socket.setReconnecting(reason: "yes")
    }
    
    func send(event_name: String, items: SocketData...) {
        if socket.status == .connected {
            socket.emit(event_name, with: items)
        } else {
            buffer.enqueue(BufferUnit(event: event_name, data: items))
        }
    }
    
    func listen(event_name: String, call_back: @escaping NormalCallback) {
        socket.on(event_name, callback: call_back)
    }
    
    func disconnect() {
        let view_controller = SummonUserContext.storyboard.instantiateViewController(withIdentifier: "loading_view_controller")
        let window = (UIApplication.shared.windows.filter {$0.isKeyWindow}.first)!
        window.rootViewController = view_controller
    }
    
    func did_connect() -> Bool {
        return connected
    }
    
}

class BufferUnit {
    
    private var event: String
    private var data: [SocketData]
    
    init(event: String, data: [SocketData]) {
        self.event = event
        self.data = data
    }
    
    func get_event() -> String {
        return event
    }
    
    func get_data() -> [SocketData] {
        return data
    }
    
}
