//
//  main.swift
//  macOSBatteryManager
//
//  Created by Alaneuler Erving on 2022/10/22.
//

import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
