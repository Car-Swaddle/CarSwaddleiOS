//
//  LocalDomain.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 6/23/21.
//  Copyright © 2021 CarSwaddle. All rights reserved.
//

import Foundation

#if targetEnvironment(simulator)
let localDomain = "127.0.0.1"
#else
let localDomain = "Kyles-MacBook-Pro.local"
#endif

/*
 
 Go to mac System Preferences -> Sharing
 
 See on that screen it says:
 
 "Computers on your local network can access your computer at:"
 
 Below that is the name you should set to `localDomain` for the else case. Simulator should be 127.0.0.1.
 
 */
