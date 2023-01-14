//
//  RemoteHelper.swift
//  privilege-helper-demo
//
//  Created by Alaneuler Erving on 2023/1/14.
//

import Foundation
import ServiceManagement

class RemoteHelper {
  static let INSTANCE = RemoteHelper()
  
  /// The only entrance for this class.
  func getRemote() -> HelperProtocol? {
    let connection = getConnection()
    if connection == nil {
      return nil
    }
    
    let helper = connection!.remoteObjectProxy as? HelperProtocol
    if let helper {
      return helper
    }
    return nil
  }
  
  private func getConnection() -> NSXPCConnection? {
    if !FileManager.default.fileExists(atPath: Constants.PRIVILEGE_HELPER_PATH) {
      installHelper()
    }
    return createConnection()
  }
  
  private func createConnection() -> NSXPCConnection {
    let connection = NSXPCConnection(machServiceName: Constants.DOMAIN, options: .privileged)
    connection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
    connection.exportedInterface = NSXPCInterface(with: RemoteApplicationProtocol.self)
    connection.exportedObject = self
    connection.resume()
    return connection
  }
  
  private func installHelper() {
    // Create an AuthorizationItem to specify we want to bless a privileged Helper.
    let authItem = kSMRightBlessPrivilegedHelper.withCString { authorizationString in
      AuthorizationItem(name: authorizationString, valueLength: 0, value: nil, flags: 0)
    }
    
    // It's required to pass a pointer to the call of the AuthorizationRights.init function.
    let pointer = UnsafeMutablePointer<AuthorizationItem>.allocate(capacity: 1)
    pointer.initialize(to: authItem)
    defer {
      pointer.deinitialize(count: 1)
      pointer.deallocate()
    }
    
    var authRef: AuthorizationRef?
    var authRights = AuthorizationRights(count: 1, items: pointer)
    let flags: AuthorizationFlags = [.interactionAllowed, .extendRights, .preAuthorize]
    let authStatus = AuthorizationCreate(&authRights, nil, flags, &authRef)
    if authStatus != errAuthorizationSuccess {
      Logger.error("Auth for installing helper failed: \(SecCopyErrorMessageString(authStatus, nil) ?? "Unknown error" as CFString)")
      return
    }
    
    // Try to install the helper and to load the daemon with authorization.
    var error: Unmanaged<CFError>?
    if SMJobBless(kSMDomainSystemLaunchd, Constants.DOMAIN as CFString, authRef, &error) == false {
      Logger.error("Install helper failed: \(error!.takeRetainedValue().localizedDescription)")
      return
    }
    
    // Helper successfully installed, release the authorization.
    AuthorizationFree(authRef!, [])
  }
}
