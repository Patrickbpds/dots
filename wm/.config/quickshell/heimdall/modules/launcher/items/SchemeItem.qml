import "../services"
import qs.components
import qs.services
import qs.config
import QtQuick

Item {
    id: root

    required property Schemes.Scheme modelData
    required property var list

    implicitHeight: Config.launcher.sizes.itemHeight

    anchors.left: parent?.left
    anchors.right: parent?.right

    StateLayer {
        radius: Appearance.rounding.full

        function onClicked(): void {
            root.modelData?.onClicked(root.list);
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.larger
        anchors.rightMargin: Appearance.padding.larger
        anchors.margins: Appearance.padding.smaller

        StyledRect {
            id: preview

            anchors.verticalCenter: parent.verticalCenter

            border.width: 1
            border.color: Qt.alpha(`#${root.modelData?.colours?.outline}`, 0.5)

            color: `#${root.modelData?.colours?.surface}`
            radius: Appearance.rounding.full
            implicitWidth: parent.height * 0.8
            implicitHeight: parent.height * 0.8

            Item {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right

                implicitWidth: parent.implicitWidth / 2
                clip: true

                StyledRect {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right

                    implicitWidth: preview.implicitWidth
                    color: `#${root.modelData?.colours?.primary}`
                    radius: Appearance.rounding.full
                }
            }
        }

        // Text content on the left
        Column {
            anchors.left: preview.right
            anchors.leftMargin: Appearance.spacing.normal
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            StyledText {
                id: name

                text: root.modelData?.name ?? ""
                font.pointSize: Appearance.font.size.normal
            }

            StyledText {
                id: comment

                text: {
                    const flavour = root.modelData?.flavour ?? "";
                    const source = root.modelData?.source ?? "";
                    if (source && source !== "unknown") {
                        return `${flavour} • ${source}`;
                    }
                    return flavour;
                }
                font.pointSize: Appearance.font.size.small
                color: Colours.palette.m3outline
            }
        }

        // Color palette preview - aligned to the right and vertically centered
        Column {
            id: colorPalette
            spacing: 3
            visible: root.modelData?.colours
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            // First row of colors
            Row {
                spacing: 2
                anchors.right: parent.right

                // Primary group
                Row {
                    spacing: 2
                    Repeater {
                        model: {
                            const colors = [];
                            const c = root.modelData?.colours;
                            if (c) {
                                if (c.primary) colors.push(c.primary);
                                if (c.secondary) colors.push(c.secondary);
                                if (c.tertiary) colors.push(c.tertiary);
                            }
                            return colors;
                        }
                        delegate: Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: `#${modelData}`
                            border.width: 1
                            border.color: Qt.alpha(Colours.palette.m3outline, 0.2)
                        }
                    }
                }

                // Spacer between groups
                Item { 
                    width: 6
                    height: 1
                }

                // Accent colors group 1
                Row {
                    spacing: 2
                    Repeater {
                        model: {
                            const colors = [];
                            const c = root.modelData?.colours;
                            if (c) {
                                if (c.red) colors.push(c.red);
                                if (c.green) colors.push(c.green);
                                if (c.blue) colors.push(c.blue);
                                if (c.yellow) colors.push(c.yellow);
                            }
                            return colors;
                        }
                        delegate: Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: `#${modelData}`
                            border.width: 1
                            border.color: Qt.alpha(Colours.palette.m3outline, 0.2)
                        }
                    }
                }
            }

            // Second row of colors
            Row {
                spacing: 2
                anchors.right: parent.right

                // Pastel/Light colors group
                Row {
                    spacing: 2
                    Repeater {
                        model: {
                            const colors = [];
                            const c = root.modelData?.colours;
                            if (c) {
                                if (c.pink) colors.push(c.pink);
                                if (c.lavender) colors.push(c.lavender);
                                if (c.peach) colors.push(c.peach);
                                if (c.mauve) colors.push(c.mauve);
                            }
                            return colors;
                        }
                        delegate: Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: `#${modelData}`
                            border.width: 1
                            border.color: Qt.alpha(Colours.palette.m3outline, 0.2)
                        }
                    }
                }

                // Spacer between groups
                Item { 
                    width: 6
                    height: 1
                }

                // Cool colors group
                Row {
                    spacing: 2
                    Repeater {
                        model: {
                            const colors = [];
                            const c = root.modelData?.colours;
                            if (c) {
                                if (c.teal) colors.push(c.teal);
                                if (c.sky) colors.push(c.sky);
                                if (c.sapphire) colors.push(c.sapphire);
                            }
                            return colors;
                        }
                        delegate: Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: `#${modelData}`
                            border.width: 1
                            border.color: Qt.alpha(Colours.palette.m3outline, 0.2)
                        }
                    }
                }
            }
        }
    }
}