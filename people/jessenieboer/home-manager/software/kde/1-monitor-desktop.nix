# Single-screen layout (laptop): left, center and right are all the one screen (0).
# The top panel follows screens.center. No window rules are needed here: the
# 3-monitor rules only spread apps across monitors, so on one screen they would
# all be "force onto screen 0", a no-op that would also pin apps to the laptop
# screen whenever an external monitor is plugged in.
{ ... }: {
  personal_workplace.plasma.screens = {
    left = 0;
    center = 0;
    right = 0;
  };
}
