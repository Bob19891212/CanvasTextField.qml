/*
 1. 在电脑上运行效果一般。
 2. 在安卓机上，输入框的水太深了。
*/

import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Window 2.0

ApplicationWindow {

    visible: true
    width: 360
    height: 640

    property real dpScale:  1.5
    readonly property real dp: Math.max(Screen.pixelDensity * 25.4 / 160 * dpScale, 1)

    title: qsTr("Canvas TextField")

    Text {
        id: attached
        text: "cursorPosition" + canvas.cursorPosition
        anchors.bottom: parent.bottom
    }

    Button {
        anchors.centerIn: parent
        text: "添加中文"
        onClicked: {
            canvas.text += "中文"
        }
    }

    Timer {
        id: lazy
        repeat: false
        interval: 100
        property var __callable
        onTriggered: {
            __callable();
        }

        function lazyDo(time, callable) {
            lazy.interval = time
            lazy.__callable = callable;
            lazy.start()
        }
    }

    Rectangle {
        anchors.fill: canvas
        color: "white"
        border.color: "black"
        border.width: 1
    }

    Canvas {
        id: canvas
        focus: true

        width: parent.width
        height: fontMetrics.height + fontMetrics.xHeight

        Accessible.role: Accessible.EditableText

//        anchors.bottom: parent.bottom
//        anchors.bottomMargin: 0

        property alias font: fontMetrics.font

        property string text: "中文输入法还没有办法调出"

        property int cursorPosition: 0
        readonly property rect cursor: Qt.rect(textMetrics.width, 0, 3, fontMetrics.height+fontMetrics.xHeight)
        property color cursorColor: "red"


        Keys.onPressed: {
            // console.log(event)

            if(event.key === Qt.Key_Backspace) {
                // console.log("back")

                text = text.substring(0,cursorPosition-1) + text.substring(cursorPosition,text.length);

                cursorPosition > 0 ? cursorPosition-- : 1;

            } else if(event.key === Qt.Key_Left) {
                cursorPosition > 0 ? cursorPosition-- : 1;

            } else if(event.key === Qt.Key_Right ) {
                cursorPosition <= canvas.text.length-1 ? cursorPosition++ : 1;

            } else if(event.key === Qt.Key_Shift
                      || event.key === Qt.Key_Control
                      || event.key === Qt.Key_Alt)
            {

            } else {

                text += event.text;
                cursorPosition+= event.text.length;
            }


            event.accepted = true;
            canvas.requestPaint();
        }

        onPaint: {
            var ctx = canvas.getContext("2d");
            ctx.clearRect(0,0, canvas.width, canvas.height);

            ctx.fillStyle = "black";
            ctx.font = fontMetrics.getFontToContext2D();
            ctx.fillText(text, 0, fontMetrics.height);

            ctx.fillStyle = canvas.cursorColor
            ctx.fillRect(cursor.x, cursor.y, cursor.width, cursor.height);
        }

        FontMetrics {
            id: fontMetrics
            font.pixelSize: 20 * dp
            font.family: "微软雅黑"

            onFontChanged: {
                canvas.requestPaint()
            }

            function getFontToContext2D() {
                var cssFontString = "";
                if(fontMetrics.font.italic) {
                    cssFontString += "italic ";
                } else {
                    cssFontString += "normal ";
                }

                if(fontMetrics.font.bold) {
                    cssFontString += "bold ";
                } else {
                    cssFontString += "normal ";
                }

                cssFontString += (fontMetrics.font.pixelSize+"px ");
                // cssFontString += ("/"+fontMetrics.height+"px ");
                cssFontString += fontMetrics.font.family;

                // console.log("cssFontString:", cssFontString)

                return cssFontString;
            }
        }

        TextMetrics {
            id: textMetrics
            font: fontMetrics.font
            text: canvas.text.substring(0, canvas.cursorPosition)
        }


        Timer {
            interval: 400
            repeat: true
            running: true
            onTriggered: {
                if(Qt.colorEqual(canvas.cursorColor, "red")) {
                    canvas.cursorColor = "black";
                } else {
                    canvas.cursorColor = "red";
                }
                canvas.requestPaint();
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {

                attached.forceActiveFocus();

                lazy.lazyDo(100, function(){
                    canvas.forceActiveFocus();
                    canvas.anchors.bottomMargin = 800;
                    lazy.lazyDo(50, function(){
                        Qt.inputMethod.show();
                    });
                })
            }
        }

        Component.onCompleted: {
            cursorPosition = text.length;
            Qt.inputMethod.visibleChanged.connect(function(){
                if(Qt.inputMethod.visible) {
                    canvas.anchors.bottomMargin = 800;
                } else {
                    canvas.anchors.bottomMargin = 0;
                }
            });

//            var families = Qt.fontFamilies();
//            fontMetrics.font.family = families[0];
        }

    }


}

