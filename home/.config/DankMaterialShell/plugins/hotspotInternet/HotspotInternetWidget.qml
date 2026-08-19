import QtQuick
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // ip rule 8990（绕行规则）存在 = 热点设备绕过 mihomo，无外网
    property bool bypassActive: false
    property bool busy: false
    readonly property bool internetOn: !bypassActive

    ccWidgetIcon: internetOn ? "wifi_tethering" : "wifi_tethering_off"
    ccWidgetPrimaryText: "热点外网"
    ccWidgetSecondaryText: busy ? "切换中…" : (internetOn ? "设备经 mihomo 上外网" : "已断外网")
    ccWidgetIsActive: internetOn

    onCcWidgetToggled: requestToggle()

    function requestToggle() {
        if (busy)
            return;
        busy = true;
        toggleProc.running = true;
    }

    function refresh() {
        statusProc.running = true;
    }

    Process {
        id: statusProc
        command: ["ip", "rule", "show", "pref", "8990"]
        stdout: StdioCollector {
            onStreamFinished: root.bypassActive = text.trim().length > 0
        }
    }

    Process {
        id: toggleProc
        command: ["sh", "-c", "exec \"$HOME/.local/bin/hotspot-internet\" toggle"]
        onExited: exitCode => {
            root.busy = false;
            root.refresh();
            if (exitCode !== 0)
                ToastService.showError("热点外网", "切换失败：未获得 root 授权");
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    pillClickAction: () => root.requestToggle()

    horizontalBarPill: Component {
        DankIcon {
            name: root.internetOn ? "wifi_tethering" : "wifi_tethering_off"
            size: Theme.barIconSize(root.barThickness, -4, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
            color: root.internetOn ? Theme.widgetTextColor : Theme.error
        }
    }

    verticalBarPill: Component {
        DankIcon {
            name: root.internetOn ? "wifi_tethering" : "wifi_tethering_off"
            size: Theme.barIconSize(root.barThickness, -4, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
            color: root.internetOn ? Theme.widgetTextColor : Theme.error
        }
    }
}
