//
//  SizeUtility.swift
//  hye_eum
//
//  Created by mobicom on 9/25/24.
//

import DeviceKit

enum DeviceGroup {
    case fourInches
    case fiveInches
    case xSeries
    case iPads

    public var rawValue: [Device] {
        switch self {
        case .fourInches:
            return [.iPhone5s, .iPhoneSE]
        case .fiveInches:
            return [.iPhone6, .iPhone6s, .iPhone7, .iPhone8]
        case .xSeries:
            return Device.allDevicesWithSensorHousing
        case .iPads:
            return Device.allPads
        }
    }
}

class DeviceManager {
    static let shared: DeviceManager = DeviceManager()

    func isFourIncheDevice() -> Bool {
        return Device.current.isOneOf(DeviceGroup.fourInches.rawValue)
    }

    func isFiveIncheDevice() -> Bool {
        return Device.current.isOneOf(DeviceGroup.fiveInches.rawValue)
    }

    func isXseriesDevice() -> Bool {
        return Device.current.isOneOf(DeviceGroup.xSeries.rawValue)
    }

    func isPadDevice() -> Bool {
        return Device.current.isOneOf(DeviceGroup.iPads.rawValue)
    }

    // 폰트 크기 반환 함수
    func fontSize(forTextStyle style: String) -> CGFloat {

        // 시뮬레이터에서도 동작
        if Device.current.isSimulator {
            print("Running on Simulator")
            print(Device.current)
            // 시뮬레이터가 iPhone 또는 iPad인지 구분
            if Device.current == .simulator(.iPadPro12Inch5) {
                return fontSizeForPadDevice(style: style)
            } else if Device.current.isOneOf(DeviceGroup.fiveInches.rawValue){
                return fontSizeForFiveInchesDevice(style: style)
            } else {
                return fontSizeForXseriesDevice(style: style) // 기본적으로 iPhone 시뮬레이터에서 X 시리즈 크기 사용
            }
        }

        // 실제 기기 처리
        if isFourIncheDevice() {
            return fontSizeForFourInchesDevice(style: style)
        } else if isFiveIncheDevice() {
            return fontSizeForFiveInchesDevice(style: style)
        } else if isXseriesDevice() {
            return fontSizeForXseriesDevice(style: style)
        } else if isPadDevice() {
            return fontSizeForPadDevice(style: style)
        } else {
            return UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body).pointSize
        }
    }

    private func fontSizeForFourInchesDevice(style: String) -> CGFloat {
        return 30 // 4인치 기기 크기
    }

    private func fontSizeForFiveInchesDevice(style: String) -> CGFloat {
        return 30 // 5인치 기기 크기
    }

    private func fontSizeForXseriesDevice(style: String) -> CGFloat {
        print("Xseries size")
        switch style {
        case "splashLogo":
            return 78 // iPad에서 splashLogo 폰트 크기
        case "label":
            print("label")
            return 18
        default:
            return 18  // iPad에서 기본 폰트 크기
        } // X 시리즈 기기 크기, 13미니
    }

    private func fontSizeForPadDevice(style: String) -> CGFloat {
        print("pad size")
        switch style {
        case "splashLogo":
            return 120 // iPad에서 splashLogo 폰트 크기
        case "label":
            print("label")
            return 30
        default:
            return 50  // iPad에서 기본 폰트 크기
        }
    }

    // 기존 폰트의 크기만 조정하는 메서드
    func adjustFontSize(for label: UILabel, textStyle: String) {
        let newSize = fontSize(forTextStyle: textStyle)
        if let currentFont = label.font {
            // 기존 폰트 스타일을 유지하고 크기만 변경
            label.font = currentFont.withSize(newSize)
        }
    }
}
