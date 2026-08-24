import QtQuick
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // flag 文件含 SRC-IP = USB 设备被强制 DIRECT（不可翻墙）；网络接入本身常通
    property bool directActive: false
    property bool busy: false
    readonly property bool proxiedOn: !directActive

    ccWidgetIcon: proxiedOn ? "usb" : "usb_off"
    ccWidgetPrimaryText: "USB 翻墙"
    ccWidgetSecondaryText: busy ? "切换中…" : (proxiedOn ? "设备经 mihomo 可翻墙" : "已切直连（不可翻墙）")
    ccWidgetIsActive: proxiedOn

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
        command: ["cat", "/etc/mihomo/flags/usb-direct.yaml"]
        stdout: StdioCollector {
            onStreamFinished: root.directActive = text.includes("SRC-IP")
        }
    }

    Process {
        id: toggleProc
        command: ["sh", "-c", "exec \"$HOME/.local/bin/usb-internet\" toggle"]
        onExited: exitCode => {
            root.busy = false;
            root.refresh();
            if (exitCode !== 0)
                ToastService.showError("USB 翻墙", "切换失败：mihomo API 不可达");
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
            name: root.proxiedOn ? "usb" : "usb_off"
            size: Theme.barIconSize(root.barThickness, -4, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
            color: root.proxiedOn ? Theme.widgetTextColor : Theme.error
        }
    }

    verticalBarPill: Component {
        DankIcon {
            name: root.proxiedOn ? "usb" : "usb_off"
            size: Theme.barIconSize(root.barThickness, -4, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
            color: root.proxiedOn ? Theme.widgetTextColor : Theme.error
        }
    }
}
