import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import "."

Component {
    Item
    {
        id: root
        width: 158; height: 190
        property var itemData: ({})
        property var title
        property string source: img.source

        scale: changeScale()
        z: changeZ();//1 - Math.abs(index - list.currentIndex)
        //visible: Math.abs(index - list.currentIndex) < 3 || (list.count + index - list.currentIndex) < 3 ||
        //         (list.count - index + list.currentIndex) < 3
        opacity: Math.abs(index - list.currentIndex) < 3 || (list.count + index - list.currentIndex) < 3 ||
                 (list.count - index + list.currentIndex) < 3 ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation
            {
                duration: 500
            }
        }

        Behavior on scale {
            NumberAnimation
            {
                duration: 50
            }
        }

        function changeScale()
        {
            if(Math.abs(index - list.currentIndex) == 1 || Math.abs(index - list.currentIndex) == list.count - 1)
            {
                return 0.8
            }
            else if(Math.abs(index - list.currentIndex) == 2 || Math.abs(index - list.currentIndex) == list.count - 2)
            {
                return 0.6
            }
            else if(index == list.currentIndex)
            {
                return 1
            }
            else
            {
                return 0.5
            }
        }
        function changeZ()
        {
            if(Math.abs(index - list.currentIndex) >= list.count - 2)
            {
                return list.count-(list.count - Math.abs(index - list.currentIndex))
            }
            else
            {
                return list.count - Math.abs(index - list.currentIndex)
            }
        }

        property bool inScene: false

        function imageInScene()
        {
            inScene = true;
            ItemManager.current = itemData;
            ItemManager.selectedItems.push(itemData);
            root.opacity = 0.5
        }
        function imageRemovedFromScene(source)
        {
            inScene = false;
            root.opacity = 1.0
        }


        Component.onCompleted:
        {
            itemData.id = String(item)
            //console.log("itemData.id = ", itemData.id)
            itemData.fileCount = parseInt(file_count)
            itemData.metadata = metadata
            //console.log("itemData.metadata = ", itemData.metadata)
            itemData.media = []
            itemData.mediaTypes = []

            setInfo();

            Omeka.getFiles(itemData.id, root)
        }
        function setInfo()
        {
            var name
            for(var i=0; i<metadata.count; i++) {
                name = metadata.get(i).element.name.toLowerCase();
                if(name === "title") {
                    title = metadata.get(i).text
                } /*else if(name === "source") {
                    source = metadata.get(i).text.split("View")[0]
                }*/
            }
        }

        Connections {
            target: Omeka
            onRequestComplete: {
                if(result.context === root)
                {
                    //console.log("thum = ", result.thumb)
                    itemData.thumb = result.thumb
                    //if(!itemData.thumb) return;

                    itemData.media.push(result.media)
                    itemData.mediaTypes.push(result.media_type)

                    if(itemData.media.length === itemData.fileCount)
                    {
                        img.source = itemData.thumb
                        //img_id.text = itemData.id //test
                        target = null
                    }
                }
            }
        }

        Image
        {
            id: bkg
            source: "content/POI/_Image_.png"
            anchors.fill: parent

        }
        Image
        {
            id: img
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            anchors.margins: 10
//            Text
//            {
//                id: img_id
//                color: "red"
//                anchors.centerIn: parent
//            }
        }

        Image
        {
            id: current_item_title_bkg
            source: "content/POI/canrousel_title_bkg.png"
            anchors.bottom: img.bottom
            anchors.left: img.left
            anchors.right: img.right
            anchors.margins: -7
            visible: itemData.id - 1 == list.currentIndex
            Text
            {
                id: current_item_title
                text: root.title
                color: "#ffffff"
                font.pixelSize : 9
                //anchors.centerIn: parent
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                width: parent.width - 6
            }
        }

        //load indicator
        OmekaIndicator {
            scale: 2
            running: img.progress < 1
        }
    }
}
