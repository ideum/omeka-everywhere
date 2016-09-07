import QtQuick 2.5
import QtQuick.Controls 1.4
import "../../../utils"
import "../../base"

/*! Item browser component */
OmekaScrollView {
    id: view
    width: parent.width
    height: parent.height
    state: User.layoutID

    property Flickable layout

    property var model: ListModel{}

    property var delegate: OmekaItem{}

    property real divisor: 478

    property real rowHeight: width/Math.floor(width/(Math.floor(Resolution.applyScale(divisor))))

    property real spacing: Resolution.applyScale(30)

    property real cacheBuffer: rowHeight > 0 ? rowHeight * 200 : 0

    /*! Grid layout */
    GridView {
        id: grid
        visible: layout === grid
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter
        cellWidth: cellHeight
        cellHeight: view.rowHeight
        cacheBuffer: view.cacheBuffer
        delegate: view.delegate
        maximumFlickVelocity: 8000
        flickDeceleration: 3000
        boundsBehavior: Flickable.StopAtBounds
        header: Rectangle{
            color: "white"
            width: view.width
            height: view.height/2
        }
    }

    /*! List layout */
    ListView {
        id: list
        visible: layout === list
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: view.spacing
        cacheBuffer: view.cacheBuffer
        delegate: view.delegate
        maximumFlickVelocity: 8000
        flickDeceleration: 3000
        boundsBehavior: Flickable.StopAtBounds
        header: Rectangle {
            color: "white"
            width: view.width
            height: view.height/2
        }
    }

    /*! Add item from browser */
    function append(item) {
        layout.model.append(item);
    }

    /*! Clear browser */
    function clear() {
        layout.model.clear();
    }

    states: [
        State{
            name: "grid"
            PropertyChanges { target:view; explicit: true; layout: grid }
            PropertyChanges { target: grid; explicit: true; model: view.model; z: 1 }
        },
        State{
            name: "list"
            PropertyChanges { target: view; explicit: true; layout: list; divisor: 290 }
            PropertyChanges { target: list; explicit: true; model: view.model; z: 1 }
        }
    ]
}
