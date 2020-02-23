// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
    
    func updateCarSwaddleFrameworksLane() {
        desc("Update first party frameworks")
        sh(command: "carthage update --platform iOS --no-build carswaddleui carswaddledata")
    }
    
    func updateThirdPartyFrameworksLane() {
        desc("Update first party frameworks")
        sh(command: "carthage update --platform iOS lottie-ios --no-use-binaries Cosmos stripe-ios FSCalendar")
    }
    
    func updateFrameworksLane() {
        desc("Update frameworks")
        sh(command: "carthage update --platform iOS")
    }
    
}
