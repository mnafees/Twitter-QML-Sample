import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4

import me.mnafees 1.0

Window {
    visible: true
    width: 300
    height: 300

    Twitter {
        id: twitter

        // Callbacks
        onLoginSuccess: {
            twitter.fetchUserProfile()
            tweetButton.visible = true
            loginButton.text = "Logout"
            console.log("Login successful")
        }
        onLoginFailed: {
            console.log("Login failed")
        }
        onUserProfileFetched: {
            console.log("User profile fetched")
            console.log(id)
            console.log(name)
            console.log(url)
            console.log(profileImageUrl)
        }
    }

    Button {
        id: tweetButton
        anchors.bottom: loginButton.top
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Tweet"
        visible: false

        onClicked: {
            if (twitter.isLoggedIn()) {
                twitter.tweet("Test", "https://github.com/mnafees")
            }
        }
    }

    Button {
        id: loginButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        text: "Login with Twitter"

        onClicked: {
            if (twitter.isLoggedIn()) {
                twitter.logout()
                tweetButton.visible = false
                loginButton.text = "Login with Twitter"
            } else {
                twitter.login()
            }
        }
    }

    Component.onCompleted: {
        if (twitter.isLoggedIn()) {
            tweetButton.visible = true
            loginButton.text = "Logout"
            twitter.fetchUserProfile()
        }
    }
}
