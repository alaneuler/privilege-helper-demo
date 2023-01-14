//
//  AppDelegate.swift
//  privilege-helper-demo
//
//  Created by Alaneuler Erving on 2023/1/9.
//

import Cocoa

/// Used as DTO
struct Result {
  var output = "default"
}

class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let remoteWrapper = RemoteHelper.INSTANCE.getRemote()
    var result = Result()
    if let helperProtocol = remoteWrapper {
      helperProtocol.execteCmd(cmdPath: "/usr/bin/whoami", args: [],
                              completion: {output in
        result.output = output
      })
      // TODO: remove sleep code
      sleep(1)
      fputs(result.output, stdout)
    }
    exit(0)
  }
  
  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
