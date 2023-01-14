//
//  HelperProtocol.swift
//  privilege-helper-demo
//
//  Created by Alaneuler Erving on 2023/1/14.
//

import Foundation

@objc(HelperProtocol)
public protocol HelperProtocol {
  @objc func execteCmd(cmdPath: String, args: [String], completion: @escaping (String) -> Void)
}
