#sleep 3
kscreen-doctor \
    output.DP-1.enable output.DP-1.mode.1920x1200@60 output.DP-1.position.0,0 \
output.DP-2.enable output.DP-2.primary output.DP-2.mode.2560x1440@60 output.DP-2.position.1200,268 \
output.HDMI-A-1.enable output.HDMI-A-1.mode.1920x1080@60 output.HDMI-A-1.position.3760,628 || true
