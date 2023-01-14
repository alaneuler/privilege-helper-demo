//
//  DemoPrivilegeHelper.swift
//  me.alaneuler.DemoPrivilegeHelper
//
//  Created by Alaneuler Erving on 2023/1/14.
//

import Foundation

class DemoPrivilegeHelper: NSObject, NSXPCListenerDelegate, HelperProtocol {
  /// Besides the implementation of the HelperProtocol
  /// This class also need to implement the NSXPCListenerDelegate
  /// and hold an instance of NSXPCListener to listen for incoming connections
  let listener: NSXPCListener
  func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
    newConnection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
    newConnection.remoteObjectInterface = NSXPCInterface(with: RemoteApplicationProtocol.self)
    newConnection.exportedObject = self
      
    newConnection.resume()
    return true
  }
  
  override init() {
    self.listener = NSXPCListener(machServiceName: Constants.DOMAIN)
    super.init()
    self.listener.delegate = self
  }
  
  /// The entry point for DemoPrivilegeHelper.
  func run() {
    Logger.info("Starting DemoPrivilegeHelper...")
    // Start listening on new connections.
    self.listener.resume()
    // Prevent the terminal application to exit.
    RunLoop.current.run()
  }
  
  func execteCmd(cmdPath: String, args: [String], completion: @escaping (String) -> Void) {
    let output = executeCmd(cmdPath: cmdPath, args: args)
    Logger.info("Execute \(cmdPath) with output: \(output)")
    completion(output)
  }
  
  func executeCmd(cmdPath: String, args: [String]) -> String {
    let proc = Process()
    let pipe = Pipe()
    
    proc.launchPath = cmdPath
    proc.arguments = args
    proc.standardOutput = pipe
    proc.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: String.Encoding.utf8)!
  }
}
