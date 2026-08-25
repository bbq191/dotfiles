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
        flagFile.reload();
    }

    // flag 文件事件驱动：脚本改写 / mihomo 重生成时立即刷新，不再轮询
    FileView {
        id: flagFile
        path: "/etc/mihomo/flags/usb-direct.yaml"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.directActive = text().includes("SRC-IP")
        onLoadFailed: root.directActive = false
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
