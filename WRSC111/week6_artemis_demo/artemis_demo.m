% =========================================================
% Script name:   artemis_demo.m
% Author:        WRSC111
% Date:          2026-04-18
% Description:   Artemis II free-return demo -- weeks 1-6 culmination.
%                Uses user-defined functions to model Earth + Moon
%                gravity, solar wind, and a closed-loop controller.
% Inputs:        user prompt -- scenario 1/2/3
% Outputs:       two figure windows (overview + live animation)
% =========================================================
%
% LECTURE 6 DEMO -- Artemis II Free-Return Trajectory
% A weeks 1-6 culmination: model the spacecraft's path around Earth and
% the Moon using USER-DEFINED FUNCTIONS.
%
% The Artemis II mission uses the gravity of the Earth and the Moon to
% slingshot astronauts around the far side of the Moon and back home --
% no thrust needed for most of the trip. The physics is broken up into
% small, named functions so the main script below reads almost like a
% mission plan.
%
% Files in this folder:
%   constants.m      -- struct of physical constants + initial state
%   moonPosition.m   -- location of the Moon at time t
%   gravityAccel.m   -- acceleration from one attracting body
%   totalAccel.m     -- sum of gravity + optional perturbations
%   rk4Step.m        -- one 4th-order Runge-Kutta step      [APPLIED MATHS]
%   solarWind.m      -- perturbation from solar radiation   [APPLIED MATHS]
%   controlThrust.m  -- PD feedback correction              [CONTROL SYSTEMS]
%   simulate.m       -- runs the full integration loop
%   plotArtemis.m    -- static plot + live animation
%
% Scenarios:
%   Mode 1 : just Earth + Moon gravity -- the clean free-return.
%   Mode 2 : add a solar wind perturbation -- trajectory drifts off.
%   Mode 3 : add a PD course-correction controller -- thrusters fight the drift.

clear; clc; close all;

%% 1. Choose a scenario
fprintf('=== Artemis II Free-Return Demo ===\n');
fprintf('  1) Clean trajectory (gravity only)\n');
fprintf('  2) With solar wind perturbation       [Applied Maths preview]\n');
fprintf('  3) Wind + PD course correction        [Control Systems preview]\n');
mode = input('Select scenario (1/2/3): ');

%% 2. Load constants
% Everything physical lives in one place -- gravitational parameters, the
% Moon's orbit, and the spacecraft's post-TLI state.
C = constants();

%% 3. Run simulations
% We always compute the NOMINAL trajectory (mode 1). If the user picked 2
% or 3, we also run the perturbed case. Mode 3 additionally runs the
% controller, which uses the nominal trajectory as its reference.

fprintf('Simulating nominal trajectory (mode 1) ...\n');
[t1, p1, v1, m1]  = simulate(C, 1, []);
results.clean     = struct('t', t1, 'pos', p1, 'vel', v1, 'moon', m1);
results.wind      = [];
results.control   = [];

if mode >= 2
    fprintf('Simulating with solar wind  (mode 2) ...\n');
    [t2, p2, v2, m2] = simulate(C, 2, []);
    results.wind = struct('t', t2, 'pos', p2, 'vel', v2, 'moon', m2);
end

if mode == 3
    fprintf('Simulating with controller  (mode 3) ...\n');
    ref = struct('t', t1, 'pos', p1, 'vel', v1);
    [t3, p3, v3, m3] = simulate(C, 3, ref);
    results.control = struct('t', t3, 'pos', p3, 'vel', v3, 'moon', m3);
end

%% 4. Visualise
% A static overview first (so you can see the whole mission), then a live
% animation of the active scenario.
plotArtemis(results, C, mode);

%% Recap
% Weeks used:
%   1-2  vectors, .^, sqrt, structs           (every function)
%   3    plot, patch, legend, drawnow anim    (plotArtemis.m)
%   4    for loop, if branching, preallocate  (simulate.m)
%   5    script header, user input            (this file)
%   6    USER-DEFINED FUNCTIONS, multiple
%        outputs, anonymous functions         (everywhere)
%
% Where this is going:
%   * solarWind.m and rk4Step.m are the kind of thing you will unpack in
%     your numerical-methods course -- how to model small time-varying
%     forces, and how to pick an integrator that doesn't drift.
%   * controlThrust.m is your first taste of control systems -- measuring
%     an error and feeding it back to a thruster. Next year you will
%     learn how to pick the gains properly and prove the loop is stable.
