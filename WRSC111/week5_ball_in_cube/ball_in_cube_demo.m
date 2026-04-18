%[text] # LECTURE 5 DEMO — Ball in a Cube
%[text] *A weeks 1–5 culmination: generate physics data, save it, reload it, plot it, animate it.*
%%
%[text] ## Overview
%[text] Every skill from the first five weeks in one script:
%[text:table]{"ignoreHeader":true}
%[text] | Week | Skill used here |
%[text] | --- | --- |
%[text] | 1–2 | Variables, vectors, maths (`.^`, `sqrt`, `zeros`, `max`/`min`) |
%[text] | 3 | `plot3`, `subplot`, `legend`, `sgtitle`, `drawnow` |
%[text] | 4 | `for` loop, `if` for wall collisions, pre-allocation |
%[text] | 5 | `input`, `table`, `writetable`, `readtable`, script header |
%[text:table]
%%
%[text] ## 1. Generate Physics Data
%[text] First, `input()` asks which simulation mode to run — plain elastic bouncing, or bouncing with **gravity and air resistance**.
%[text] At each time step:
%[text] - **Position update** → `pos = pos + vel × dt`  (Euler integration)
%[text] - **Gravity** → `vz = vz − g × dt`  (constant downward pull, physics mode only)
%[text] - **Air resistance** → `v = v × (1 − drag × dt)`  (proportional drag, physics mode only)
%[text] - **Wall collision** → reflect position and reverse velocity component

% =========================================================
% Script name:   Lecture5_Demo.m
% Author:        WRSC111
% Date:          2026-04-13
% Description:   Bouncing ball simulation — weeks 1–5 culmination demo.
%                Generates physics data with a for loop, saves to CSV,
%                reads back, produces a static plot, then animates.
% Inputs:        user prompt — gravity/drag mode (y/n)
% Outputs:       ball_data.csv, two figure windows
% =========================================================
clear; clc; close all;

%--- Ask the user which mode to run ---
fprintf("=== Ball in a Cube Simulation ===\n")
choice     = input("Add gravity and air resistance? (y/n): ", "s");
usePhysics = strcmpi(choice, "y");

%--- Simulation parameters ---
dt        = 0.05;                     % time step (s)
tEnd      = 20;                       % total duration (s)
spaceSize = 10;                       % cube side length (m) — spans [0, spaceSize]
N         = round(tEnd / dt) + 1;    % number of steps

%--- Random initial conditions (scaled to cube size) ---
rng("shuffle");                        % different result each run
px = rand * spaceSize;
py = rand * spaceSize;
pz = rand * spaceSize;

maxSpeed = spaceSize;                  % m/s — keeps motion visually interesting
vx = (rand * 2 - 1) * maxSpeed;
vy = (rand * 2 - 1) * maxSpeed;
vz = (rand * 2 - 1) * maxSpeed;

%--- Physics parameters (gravity + air resistance mode) ---
g    = 9.81;   % gravitational acceleration (m/s²) — acts in −Z direction
drag = 0.12;   % linear drag coefficient (s⁻¹)  — ball retains ~10% speed by t = 20 s

%--- Pre-allocate storage (Week 4 good practice) ---
Time = zeros(N, 1);
PosX = zeros(N, 1);  PosY = zeros(N, 1);  PosZ = zeros(N, 1);
VelX = zeros(N, 1);  VelY = zeros(N, 1);  VelZ = zeros(N, 1);

%--- Euler integration loop ---
for k = 1:N

    % Record state at this step
    Time(k) = (k - 1) * dt;
    PosX(k) = px;  PosY(k) = py;  PosZ(k) = pz;
    VelX(k) = vx;  VelY(k) = vy;  VelZ(k) = vz;

    % Update position
    px = px + vx * dt;
    py = py + vy * dt;
    pz = pz + vz * dt;

    % Apply gravity and air resistance (physics mode only)
    if usePhysics
        vz = vz - g * dt;              % gravity — constant downward pull
        vx = vx * (1 - drag * dt);    % drag — slows all components
        vy = vy * (1 - drag * dt);
        vz = vz * (1 - drag * dt);
    end

    % Bounce off walls — reflect position, reverse velocity
    % (while loop handles the rare case of overshooting past a wall corner)
    while px < 0 || px > spaceSize
        if px < 0,              px = -px;                  vx = -vx;  end
        if px > spaceSize,      px = 2*spaceSize - px;     vx = -vx;  end
    end
    while py < 0 || py > spaceSize
        if py < 0,              py = -py;                  vy = -vy;  end
        if py > spaceSize,      py = 2*spaceSize - py;     vy = -vy;  end
    end
    while pz < 0 || pz > spaceSize
        if pz < 0,              pz = -pz;                  vz = -vz;  end
        if pz > spaceSize,      pz = 2*spaceSize - pz;     vz = -vz;  end
    end

end

if usePhysics
    modeStr = "Gravity + Air Resistance";
else
    modeStr = "Elastic — No Gravity";
end
fprintf("Generated %d time steps (%.0f s of simulation) — mode: %s\n", N, tEnd, modeStr)

%%
%[text] ## 2. Save to CSV (Week 5 — `writetable`)
%[text] Bundle the column vectors into a named **table**, then write to disk.
%[text] Open `ball_data.csv` in Excel to see what was produced.

T = table(Time, PosX, PosY, PosZ, VelX, VelY, VelZ);
writetable(T, "ball_data.csv");
fprintf("Saved %d rows to ball_data.csv\n", height(T))

%%
%[text] ## 3. Read Back from CSV (Week 5 — `readtable`)
%[text] Now imagine we are a *different* script — we clear the data and reload from file.

clear Time PosX PosY PosZ VelX VelY VelZ   % drop the raw arrays

data = readtable("ball_data.csv");

t      = data.Time;
posX   = data.PosX;  posY = data.PosY;  posZ = data.PosZ;
velX   = data.VelX;  velY = data.VelY;  velZ = data.VelZ;
velMag = sqrt(velX.^2 + velY.^2 + velZ.^2);

fprintf("Loaded %d rows from ball_data.csv\n", height(data))

%%
%[text] ## 4. Static Overview Plot (Week 3)
%[text] A quick look at the full trajectory and velocity profile before animating.

figure("Name", "Ball Overview", "Color", "w", "Position", [50 80 1200 520]);

subplot(1, 2, 1);
% Path coloured by time (darker = earlier, brighter = later)
scatter3(posX, posY, posZ, 3, t, "filled");
colormap("parula");  cb = colorbar;  cb.Label.String = "Time (s)";
hold on;
% Cube wireframe
s = spaceSize;
cubeEdges = { ...
    [0 s],[0 0],[0 0];  [0 s],[s s],[0 0];  [0 s],[0 0],[s s];  [0 s],[s s],[s s]; ...
    [0 0],[0 s],[0 0];  [s s],[0 s],[0 0];  [0 0],[0 s],[s s];  [s s],[0 s],[s s]; ...
    [0 0],[0 0],[0 s];  [s s],[0 0],[0 s];  [0 0],[s s],[0 s];  [s s],[s s],[0 s]  ...
};
for e = 1:size(cubeEdges, 1)
    plot3(cubeEdges{e,1}, cubeEdges{e,2}, cubeEdges{e,3}, ...
          "Color", [0.55 0.55 0.55], "LineWidth", 0.8, "LineStyle", "--");
end
plot3(posX(1),   posY(1),   posZ(1),   "g^", "MarkerSize", 10, ...
      "MarkerFaceColor", "g", "DisplayName", "Start");
plot3(posX(end), posY(end), posZ(end), "rs", "MarkerSize", 10, ...
      "MarkerFaceColor", "r", "DisplayName", "End");
xlabel("X (m)");  ylabel("Y (m)");  zlabel("Z (m)");
title("3D Trajectory (colour = time)");
legend("Start", "End", "Location", "best");
grid on;  axis equal;  view(35, 25);

subplot(1, 2, 2);
plot(t, velX,   "r-",  "LineWidth", 1.5, "DisplayName", "V_x");  hold on;
plot(t, velY,   "b-",  "LineWidth", 1.5, "DisplayName", "V_y");
plot(t, velZ,   "g-",  "LineWidth", 1.5, "DisplayName", "V_z");
plot(t, velMag, "k--", "LineWidth", 2.0, "DisplayName", "|V|");
xlabel("Time (s)");  ylabel("Velocity (m/s)");
title("Velocity Components & Magnitude");
legend("Location", "best");  grid on;

sgtitle(sprintf("Bouncing Ball (%s) — Static Overview", modeStr), "FontSize", 13, "FontWeight", "bold");

%%
%[text] ## 5. Animation (Week 3 + Week 4)
%[text] A `for` loop updates the 3D ball position and the velocity cursor on every frame.
%[text] The two panels stay **linked in time** — the cursor tracks exactly where the ball is.

figure("Name", "Ball Animation", "Color", "w", "Position", [50 80 1200 520]);

%--- Left: 3D trajectory panel ---
ax1 = subplot(1, 2, 1);

% Faint ghost of the full path
plot3(ax1, posX, posY, posZ, "Color", [0.82 0.82 0.82], "LineWidth", 1);
hold(ax1, "on");

% Growing trail (updated each frame)
hTraj = plot3(ax1, NaN, NaN, NaN, "b-", "LineWidth", 1.8);

% Ball marker
hBall = plot3(ax1, posX(1), posY(1), posZ(1), "o", ...
              "MarkerSize", 14, "MarkerFaceColor", "r", "MarkerEdgeColor", "k");

% Start marker
plot3(ax1, posX(1), posY(1), posZ(1), "g^", ...
      "MarkerSize", 10, "MarkerFaceColor", "g");

% Cube wireframe
for e = 1:size(cubeEdges, 1)
    plot3(ax1, cubeEdges{e,1}, cubeEdges{e,2}, cubeEdges{e,3}, ...
          "Color", [0.55 0.55 0.55], "LineWidth", 0.8, "LineStyle", "--");
end

xlabel(ax1, "X (m)");  ylabel(ax1, "Y (m)");  zlabel(ax1, "Z (m)");
title(ax1, "3D Position");
grid(ax1, "on");  view(ax1, 35, 25);

% Time label (placed just above the cube ceiling)
hTimeLabel = text(ax1, 0.0, 0.0, spaceSize * 1.08, "", ...
                  "FontSize", 11, "FontWeight", "bold", "Color", [0.2 0.2 0.2]);
hold(ax1, "off");

%--- Right: velocity vs time panel ---
ax2 = subplot(1, 2, 2);
plot(ax2, t, velX,   "r-",  "LineWidth", 1.5, "DisplayName", "V_x");  hold(ax2, "on");
plot(ax2, t, velY,   "b-",  "LineWidth", 1.5, "DisplayName", "V_y");
plot(ax2, t, velZ,   "g-",  "LineWidth", 1.5, "DisplayName", "V_z");
plot(ax2, t, velMag, "k--", "LineWidth", 2.0, "DisplayName", "|V|");

% Moving time cursor
hCursor = xline(ax2, t(1), "m-", "LineWidth", 2);

% Moving dots on each curve
hDotVx  = plot(ax2, t(1), velX(1),   "ro", "MarkerSize", 8, "MarkerFaceColor", "r");
hDotVy  = plot(ax2, t(1), velY(1),   "bo", "MarkerSize", 8, "MarkerFaceColor", "b");
hDotVz  = plot(ax2, t(1), velZ(1),   "go", "MarkerSize", 8, "MarkerFaceColor", "g");
hDotMag = plot(ax2, t(1), velMag(1), "ko", "MarkerSize", 8, "MarkerFaceColor", "k");
hold(ax2, "off");

xlabel(ax2, "Time (s)");  ylabel(ax2, "Velocity (m/s)");
title(ax2, "Velocity Components & Magnitude");
legend(ax2, "Location", "best");  grid(ax2, "on");

sgtitle(sprintf("Bouncing Ball (%s) — Live Animation", modeStr), "FontSize", 13, "FontWeight", "bold");

%--- Animation loop ---
trailLength = 60;   % past frames to keep on the 3D trail
frameSkip   = 2;    % render every Nth frame (raise this to speed up)

for k = 1:frameSkip:N

    % Sliding trail window
    startIdx = max(1, k - trailLength);
    set(hTraj, "XData", posX(startIdx:k), ...
               "YData", posY(startIdx:k), ...
               "ZData", posZ(startIdx:k));

    % Ball position
    set(hBall, "XData", posX(k), "YData", posY(k), "ZData", posZ(k));

    % Time label
    set(hTimeLabel, "String", sprintf("t = %.2f s", t(k)));

    % Velocity cursor
    hCursor.Value = t(k);

    % Velocity dots
    set(hDotVx,  "XData", t(k), "YData", velX(k));
    set(hDotVy,  "XData", t(k), "YData", velY(k));
    set(hDotVz,  "XData", t(k), "YData", velZ(k));
    set(hDotMag, "XData", t(k), "YData", velMag(k));

    drawnow;

end

fprintf("Animation complete.\n")

%%
%[text] ## What we used — full recap
%[text:table]{"ignoreHeader":true}
%[text] | Week | Feature | Where |
%[text] | --- | --- | --- |
%[text] | 1–2 | Variables, `.^`, `sqrt`, `zeros`, `max`, `min` | Physics loop |
%[text] | 3 | `plot3`, `subplot`, `legend`, `sgtitle`, `drawnow` | Both figures |
%[text] | 4 | `for` loop, `if` wall collisions, pre-allocation | Simulation + animation |
%[text] | 5 | `input`, `table`, `writetable`, `readtable`, script header | Sections 2 & 3 |
%[text:table]
