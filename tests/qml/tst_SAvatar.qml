import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SAvatar"
    when: windowShown

    SAvatar { id: avatar; initials: "JD"; size: 40 }
    SAvatar { id: avatarLarge; initials: "AB"; size: 80 }

    function test_instantiation() {
        verify(avatar !== null)
    }

    function test_defaultSize() {
        compare(avatar.size, 40)
        compare(avatar.implicitWidth, 40)
        compare(avatar.implicitHeight, 40)
    }

    function test_customSize() {
        compare(avatarLarge.size, 80)
        compare(avatarLarge.implicitWidth, 80)
    }

    function test_initialsProperty() {
        compare(avatar.initials, "JD")
    }

    function test_circleShape() {
        compare(avatar.radius, avatar.width / 2)
    }
}
