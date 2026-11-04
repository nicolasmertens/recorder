import Testing
import Foundation
@testable import Recorder

struct MeetingPickTests {
    private func at(_ h: Int, _ m: Int = 0) -> Date {
        Date(timeIntervalSince1970: TimeInterval(h * 3600 + m * 60))
    }

    @Test func callInsideLongBlockWins() {
        let sandy = Meeting(id: "a", title: "Poetsvrouw Sandy", start: at(8), end: at(12))
        let mubo = Meeting(id: "b", title: "Mubo", start: at(9), end: at(9, 30))
        let studie10 = Meeting(id: "c", title: "Studie10 - opzet AI agents", start: at(10), end: at(11))
        let picked = Meeting.mostRecentInProgress([sandy, mubo, studie10], now: at(10, 2))
        #expect(picked?.title == "Studie10 - opzet AI agents")
    }

    @Test func sameStartPrefersShorter() {
        let block = Meeting(id: "a", title: "Block", start: at(10), end: at(14))
        let call = Meeting(id: "b", title: "Call", start: at(10), end: at(10, 30))
        #expect(Meeting.mostRecentInProgress([block, call], now: at(10, 5))?.title == "Call")
    }

    @Test func nothingInProgress() {
        let later = Meeting(id: "a", title: "Later", start: at(11), end: at(12))
        #expect(Meeting.mostRecentInProgress([later], now: at(10)) == nil)
    }
}
