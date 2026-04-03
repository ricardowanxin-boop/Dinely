import XCTest

final class DineRankUITests: XCTestCase {
    private let timeout: TimeInterval = 12

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchesHomeAndCanSwitchTabs() throws {
        let app = launchApp()

        XCTAssertTrue(locateCreateButton(in: app).waitForExistence(timeout: timeout))
        XCTAssertTrue(app.buttons["event-card-周五火锅回血局"].waitForExistence(timeout: timeout))
        attachScreenshot(name: "home")

        tapTab("root-tab-我的段位", in: app, waitFor: app.buttons["rank-share-button"])
        attachScreenshot(name: "rank")

        tapTab("root-tab-设置", in: app, waitFor: app.buttons["settings-privacy-policy"])
        attachScreenshot(name: "settings")

        tapTab("root-tab-约饭", in: app, waitFor: locateCreateButton(in: app))
    }

    func testCanCreateEventAndCompleteLifecycle() throws {
        let app = launchApp()

        let createButton = locateCreateButton(in: app)
        XCTAssertTrue(createButton.waitForExistence(timeout: timeout))
        createButton.tap()

        let titleField = app.textFields["draft-title-field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: timeout))
        replaceText(in: titleField, placeholder: "约饭主题", with: "测试约饭局")

        let cuisineField = app.textFields["draft-cuisine-field"]
        XCTAssertTrue(cuisineField.waitForExistence(timeout: timeout))
        replaceText(in: cuisineField, placeholder: "菜系 / 关键词", with: "川菜")
        dismissKeyboardIfPossible(in: app)

        app.buttons["create-event-primary"].tap()
        XCTAssertTrue(app.buttons["＋ 添加候选时间"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.buttons["create-event-secondary"].waitForExistence(timeout: timeout))
        attachScreenshot(name: "create-step-2-time")

        app.buttons["create-event-primary"].tap()
        XCTAssertTrue(app.otherElements["create-event-step-restaurant"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.staticTexts["地图选餐厅"].waitForExistence(timeout: timeout))
        attachScreenshot(name: "create-step-3")

        app.buttons["create-event-primary"].tap()
        XCTAssertTrue(app.buttons["share-created-event-button"].waitForExistence(timeout: timeout))
        attachScreenshot(name: "create-share")

        app.buttons["share-created-event-done"].tap()
        XCTAssertTrue(app.buttons["event-card-测试约饭局"].waitForExistence(timeout: timeout))

        app.buttons["event-card-测试约饭局"].tap()
        XCTAssertTrue(app.navigationBars["约饭详情"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.buttons["确认约饭局"].waitForExistence(timeout: timeout))

        app.buttons["确认约饭局"].tap()
        XCTAssertTrue(app.buttons["查看约饭当天地图"].waitForExistence(timeout: timeout))

        app.buttons["查看约饭当天地图"].tap()
        XCTAssertTrue(app.switches["location-sharing-toggle"].waitForExistence(timeout: timeout))
        attachScreenshot(name: "live-map")

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.buttons["签到 / AA / 战报"].waitForExistence(timeout: timeout))

        app.buttons["签到 / AA / 战报"].tap()
        XCTAssertTrue(app.textFields["total-bill-field"].waitForExistence(timeout: timeout))

        let totalBillField = app.textFields["total-bill-field"]
        totalBillField.tap()
        totalBillField.typeText("600")

        let ricoToggle = app.buttons["attendance-toggle-Rico"]
        if ricoToggle.waitForExistence(timeout: timeout) {
            ricoToggle.tap()
        }

        let minaToggle = app.buttons["attendance-toggle-Mina"]
        if minaToggle.waitForExistence(timeout: timeout) {
            minaToggle.tap()
        }

        app.buttons["确认并结算"].tap()
        XCTAssertTrue(app.buttons["完成结算"].waitForExistence(timeout: timeout))
        attachScreenshot(name: "aa")

        app.buttons["完成结算"].tap()
        XCTAssertTrue(app.staticTexts["守约战报"].waitForExistence(timeout: timeout))
        attachScreenshot(name: "battle-report")
    }

    private func locateCreateButton(in app: XCUIApplication) -> XCUIElement {
        let identifiedButton = app.buttons["create-event-fab"]
        if identifiedButton.exists {
            return identifiedButton
        }

        let labelledButton = app.buttons["创建约饭"]
        if labelledButton.exists {
            return labelledButton
        }

        return identifiedButton
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-ui-testing"]
        app.launchArguments += ["-AppleLanguages", "(zh-Hans)"]
        app.launchArguments += ["-AppleLocale", "zh_CN"]
        app.launch()
        return app
    }

    private func tapTab(_ identifier: String, in app: XCUIApplication, waitFor element: XCUIElement) {
        let button = app.buttons[identifier]
        XCTAssertTrue(button.waitForExistence(timeout: timeout))
        button.tap()
        XCTAssertTrue(element.waitForExistence(timeout: timeout))
    }

    private func replaceText(in element: XCUIElement, placeholder: String, with newText: String) {
        element.tap()

        if let currentValue = element.value as? String, currentValue != placeholder {
            let deleteSequence = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
            element.typeText(deleteSequence)
        }

        element.typeText(newText)
    }

    private func attachScreenshot(name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func dismissKeyboardIfPossible(in app: XCUIApplication) {
        let candidateButtons = ["完成", "Done", "Return", "收起键盘", "隐藏"]
        for label in candidateButtons {
            let button = app.keyboards.buttons[label]
            if button.waitForExistence(timeout: 0.5) {
                button.tap()
                return
            }
        }

        let header = app.staticTexts["步骤 1 / 3"]
        if header.waitForExistence(timeout: 0.5) {
            header.tap()
        }
    }
}
