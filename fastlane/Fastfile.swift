// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation


class Fastfile: LaneFile {
    
    //        sh(command: "carthage bootsrap --platform iOS Cosmos stripe-ios FSCalendar FirebaseAnalyticsBinary")
    //        sh(command: "carthage bootsrap --platform iOS --no-use-binaries lottie-ios")
    //        sh(command: "carthage bootsrap --platform iOS --no-build carswaddleui carswaddledata")
            
    //        sh(command: "carthage bootsrap --platform iOS Cosmos stripe-ios FSCalendar FirebaseAnalyticsBinary")
    //        sh(command: "carthage bootsrap --platform iOS --no-use-binaries lottie-ios")
    //        sh(command: "carthage bootsrap --platform iOS --no-build carswaddleui carswaddledata")
    
    // MARK: - Full updates
    
    func bootstrapFrameworksLane() {
        desc("Bootstrap all frameworks")
        sh(command: Command.Carthage.bootstrapThirdParty.command)
        sh(command: Command.Carthage.bootstrapNoBinaries.command)
        sh(command: Command.Carthage.bootstrapFirstParty.command)
    }
    
    func updateFrameworksLane() {
        desc("Update all frameworks")
        sh(command: Command.Carthage.updateThirdParty.command)
        sh(command: Command.Carthage.updateNoBinaries.command)
        sh(command: Command.Carthage.updateFirstParty.command)
    }
    
    // MARK: - Bootstrap portions
    
    func bootstrapCarSwaddleFrameworksLane() {
        desc("Bootstrap first party frameworks")
        sh(command: Command.Carthage.bootstrapFirstParty.command)
    }
    
    func bootstrapThirdPartyFrameworksLane() {
        desc("Bootstrap first party frameworks")
        sh(command: Command.Carthage.bootstrapThirdParty.command)
        sh(command: Command.Carthage.bootstrapNoBinaries.command)
    }
    
    // MARK: - Update portions
    
    func updateCarSwaddleFrameworksLane() {
        desc("Update Car Swaddle party frameworks")
        sh(command: Command.Carthage.updateFirstParty.command)
    }
    
    func updateThirdPartyFrameworksLane() {
        desc("Update third party frameworks")
        sh(command: Command.Carthage.updateThirdParty.command)
        sh(command: Command.Carthage.updateNoBinaries.command)
    }
    
}


// MARK: - Custom

struct Command {
    
    struct Carthage {
        
        let updateType: UpdateType
        let parameters: [Parameter]
        let frameworks: [Framework]
        
        public var command: String {
            return "carthage \(updateType.rawValue) \(parameterString) \(frameworkString)"
        }
        
        private var parameterString: String {
            var parameterString = ""
            for (index, parameter) in parameters.enumerated() {
                if index != 0 {
                    parameterString += " "
                }
                parameterString += "--\(parameter.value)"
            }
            return parameterString
        }
        
        private var frameworkString: String {
            var frameworkString = ""
            for (index, framework) in frameworks.enumerated() {
                if index != 0 {
                    frameworkString += " "
                }
                frameworkString += framework.rawValue
            }
            return frameworkString
        }
        
        enum UpdateType: String {
            case bootstrap
            case update
        }
        
        enum Framework: String {
            case lottie = "lottie-ios"
            case stripe = "stripe-ios"
            case cosmos = "Cosmos"
            case fsCalendar = "FSCalendar"
            case firebaseAnalyticsBinary = "FirebaseAnalyticsBinary"
            case carswaddleUI = "carswaddleui"
            case carswaddleData = "carswaddledata"
        }
        
        enum Parameter {
            case platformiOS
            case noBuild
            case noBinaries
            
            var value: String {
                switch self {
                case .platformiOS: return "platform iOS"
                case .noBuild: return "no-build"
                case .noBinaries: return "no-use-binaries"
                }
            }
        }
        
    }
    
}


extension Command.Carthage {
    
    static let bootstrapThirdParty: Command.Carthage = Command.Carthage(updateType: .bootstrap, parameters: [.platformiOS], frameworks: [.cosmos, .stripe, .fsCalendar, .firebaseAnalyticsBinary])
    static let bootstrapNoBinaries: Command.Carthage = Command.Carthage(updateType: .bootstrap, parameters: [.platformiOS, .noBinaries], frameworks: [.lottie])
    static let bootstrapFirstParty: Command.Carthage = Command.Carthage(updateType: .bootstrap, parameters: [.platformiOS, .noBuild], frameworks: [.carswaddleUI, .carswaddleData])
    
    static let updateThirdParty: Command.Carthage = Command.Carthage(updateType: .update, parameters: [.platformiOS], frameworks: [.cosmos, .stripe, .fsCalendar, .firebaseAnalyticsBinary])
    static let updateNoBinaries: Command.Carthage = Command.Carthage(updateType: .update, parameters: [.platformiOS, .noBinaries], frameworks: [.lottie])
    static let updateFirstParty: Command.Carthage = Command.Carthage(updateType: .update, parameters: [.platformiOS, .noBuild], frameworks: [.carswaddleUI, .carswaddleData])
    
}
