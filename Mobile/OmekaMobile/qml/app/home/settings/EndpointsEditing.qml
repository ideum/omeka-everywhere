import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "../../base"
import "../../../utils"
import "../../clients"

Item {
    id: root

    property string endpoint_url: url_input.text

    //default endpoint title and url
    property var omekaIDs: []//["develop_digitalmediauconn"]
    property var omekaTitles: []//["OMEKA EVERYWHERE"]
    property var omekaUrls: []//["http://oe.develop.digitalmediauconn.org/"]

    property int currentDeletingIndex: -1

    ///////////////////////////////////////////////////////////
    //          UI
    ///////////////////////////////////////////////////////////

    //initialize loading endpoints from local storage
    Component.onCompleted: {
        var entry
        var url
        var omekaID

        var _endpoints = ItemManager.getEndpoints()
        for(var i=0; i<_endpoints.length; i++) {
            entry = _endpoints[i]
            omekaID = entry.setting
            url = entry.value
            console.log("omekaID = ", omekaID, " url = ", url)
            Omeka.getSiteInfo(root, url + "api/");
        }
    }

    Connections {
        target: Omeka
        onLoadComplete: {console.log("ENDPOINT LOADED: "+Omeka.endpoint);indicator.running = false;disable_all_buttons.visible = false;}
        onSiteInfo: {
            if(result.context === root) {
                for(var i = 0; i < omekaIDs.length; i++)
                {
                    if(result.omekaID === omekaIDs[i])
                    {
                        return;
                    }
                }
                var revised_url = result.url.slice(0, (result.url.length - 4));
                omekaIDs.push(result.omekaID)
                omekaTitles.push(result.title)
                omekaUrls.push(revised_url)

                var revised_title
                if(result.title.length > 40)
                {
                    revised_title = result.title.slice(0, 40);
                    revised_title += "..."
                }
                else
                {
                    revised_title = result.title;
                }


                var url_length = result.url.length

                if(omekaTitles.length == 1)
                {
                    endpoints.addEndpoint(revised_title, revised_url, true)
                }
                else
                {
                    endpoints.addEndpoint(revised_title, revised_url, false)
                }


            }

            //add site title as endpoint
            if(result.context === add_endpoint_btn) {
                for(var i = 0; i < omekaIDs.length; i++)
                {
                    if(result.omekaID === omekaIDs[i])
                    {
                        return;
                    }
                }

                omekaIDs.push(result.omekaID)
                omekaTitles.push(result.title)
                omekaUrls.push(root.endpoint_url)

                var revised_title
                if(result.title.length > 40)
                {
                    revised_title = result.title.slice(0, 40);
                    revised_title += "..."
                }
                else
                {
                    revised_title = result.title;
                }

                endpoints.addEndpoint(revised_title, root.endpoint_url, false)

                var endpoint = ({});
                endpoint.omekaID = result.omekaID;
                endpoint.url = root.endpoint_url;
                endpoint.title = result.title;

                ItemManager.registerEndpoint(endpoint);
                resetAddNewEndpointArea();
            }
        }

    }

    /*!Pairing header and back button*/
    OmekaToolBar {
        id: bar
        backgroundColor: Style.color3
        z: 0

        OmekaText {
            anchors.centerIn: parent
            text: "select an endpoint"
            _font: Style.titleFont
        }

        OmekaButton {
            id: back
            icon: Style.back
            iconScale: .7
            onClicked: if(homeStack) homeStack.pop()
        }
    }

    /*!List of endpoints*/
    OmekaScrollView {
        id: scroll
        width: parent.width
        height: parent.height - bar.height * 2
        anchors.top: bar.bottom
        anchors.topMargin: Resolution.applyScale(95)
        Column {
            ExclusiveGroup { id: endpointsGroup }
            width: scroll.width
            height: childrenRect.height
            spacing: Resolution.applyScale(5)

            //restore initial state when invisible
            onVisibleChanged: {
                if(!visible) {
                    console.log("endpoint visible is false!!")
                    //endpointsGroup.current = default_endpoint.endpointCategory;
                }
            }
            Endpoints
            {
                id: endpoints
                onEndpointChecked:
                {
                    disable_all_buttons.visible = true;
                    indicator.running = true;
                }
                onEndpointPressAndHold:
                {
                    console.log("url = ", url)
                    for(var i = 0; i < omekaUrls.length; i++)
                    {
                        console.log("omekaUrls = ", omekaUrls[i])
                        if(url == omekaUrls[i])
                        {
                            root.currentDeletingIndex = i

                            console.log("root.currentDeletingIndex = ", root.currentDeletingIndex)
                            if(root.currentDeletingIndex === 0)
                            {
                                return;
                            }
                        }
                    }
                    confirm_delete_endpoint.visible = true;

                }
            }

        }
    }

    //Add new endpoint
    OmekaText
    {
        id: add_endpoint
        anchors.top: bar.bottom
        anchors.topMargin: Resolution.applyScale(714)
        anchors.left: parent.left
        anchors.leftMargin: Resolution.applyScale(60)
        text: "Add new endpoint"
        _font: Style.addEndpointFont

    }

    Rectangle
    {
        id: edit_url_area
        width: parent.width
        height: Resolution.applyScale(150)
        anchors.top: add_endpoint.bottom
        anchors.topMargin: Resolution.applyScale(18)
        color: "white"
        TextInput
        {
            id: url_input
            font.capitalization: Font.MixedCase
            font.pixelSize: Resolution.applyScale(68)
            color: "#666666"
            focus: true
            validator: RegExpValidator { regExp: /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/ }
            x: Resolution.applyScale(60)
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            width: 1122
            //height: 26
            selectByMouse: true
            text: qsTr("http://www...")
            z: 1
            selectionColor: Style.color1
            onTextChanged:
            {

                var re = new RegExp('^(https?:\\/\\/)?'+ // protocol
                                    '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.?)+[a-z]{2,}|'+ // domain name
                                    '((\\d{1,3}\\.){3}\\d{1,3}))'+ // OR ip (v4) address
                                    '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*'+ // port and path
                                    '(\\?[;&a-z\\d%_.~+=-]*)?'+ // query string
                                    '(\\#[-a-z\\d_]*)?$','i'); // fragment locator
                var domain = text
                if(!domain.match(re))
                {
                    color = "red"
                    add_endpoint_btn.visible = false;
                }
                else
                {
                    color = "green"

                    add_endpoint_btn.visible = true;
                }
            }
        }
    }

    Button {
        id: add_endpoint_btn
        height: Resolution.applyScale(122)
        anchors.horizontalCenter: root.horizontalCenter
        anchors.top: edit_url_area.bottom
        anchors.topMargin: Resolution.applyScale(38)
        onClicked: {Omeka.getSiteInfo(add_endpoint_btn, root.endpoint_url + "api/"); console.log("add endpoint btn clicked!", root.endpoint_url + "/api/")}
        visible: false

        style: ButtonStyle {
            background: Rectangle {
                color: Style.color1
                radius: Resolution.applyScale(30)
            }
            label: OmekaText {
                center: true
                text: "ADD ENDPOINT"
                _font: Style.addEndpointBtnFont
            }
        }
    }

    Rectangle
    {
        id: disable_all_buttons
        color: "white"
        opacity: 0.8
        visible: false
        anchors.fill: parent
        enabled: visible

        MultiPointTouchArea
        {
            anchors.fill: parent

        }
        OmekaIndicator {
            id: indicator
            anchors.centerIn: parent
            //running: parent.visible
            scale: Resolution.applyScale(1.5)
        }
    }
    //confirm delete an endpoint
    Rectangle
    {
        id: confirm_delete_endpoint
        color: "white"
        opacity: 0.8
        visible: false
        anchors.fill: parent
        enabled: visible

        MultiPointTouchArea
        {
            anchors.fill: parent

        }
        OmekaText
        {
            width: root.width
            anchors.top: parent.top
            anchors.topMargin: Resolution.applyScale(200)
            anchors.horizontalCenter: parent.horizontalCenter
            center: true
            text: "ARE YOU SURE TO DELETE THE ENDPOINT?"
            _font: Style.deleteFont
        }

        Button {
            id: delete_btn
            height: Resolution.applyScale(122)
            x: Resolution.applyScale(100)
            anchors.top: parent.top
            anchors.topMargin: Resolution.applyScale(300)
            onClicked:
            {
                var endpoint = ({});
                endpoint.omekaID = omekaIDs[root.currentDeletingIndex]
                endpoint.url = omekaUrls[root.currentDeletingIndex];
                endpoint.title = omekaTitles[root.currentDeletingIndex];
                ItemManager.unregisterEndpoint(endpoint);

                endpoints.removeEndpoint(root.currentDeletingIndex);

                confirm_delete_endpoint.visible = false;
            }

            style: ButtonStyle {
                background: Rectangle {
                    color: Style.color1
                    radius: Resolution.applyScale(30)
                }
                label: OmekaText {
                    center: true
                    text: "DELETE"
                    _font: Style.addEndpointBtnFont
                }
            }
        }

        Button {
            id: cancel_btn
            height: Resolution.applyScale(122)
            x: Resolution.applyScale(900)
            anchors.top: parent.top
            anchors.topMargin: Resolution.applyScale(300)
            onClicked:
            {
                root.currentDeletingIndex = -1;
                confirm_delete_endpoint.visible = false;
            }

            style: ButtonStyle {
                background: Rectangle {
                    color: Style.color1
                    radius: Resolution.applyScale(30)
                }
                label: OmekaText {
                    center: true
                    text: "CANCEL"
                    _font: Style.addEndpointBtnFont
                }
            }
        }
    }

    function resetAddNewEndpointArea()
    {
        url_input.text = qsTr("http://www...");
        url_input.color = "#666666"
        add_endpoint_btn.visible = false;
    }

}