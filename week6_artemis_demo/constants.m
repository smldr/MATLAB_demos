function C = constants()
% CONSTANTS  Physical constants and initial spacecraft state for the demo.
%   C = constants() returns a struct with gravitational parameters, body
%   positions and the trans-lunar injection (TLI) state used by the
%   Artemis II style free-return simulation.
%
% Outputs:
%   C - struct with fields:
%       mu_earth   gravitational parameter of Earth  (km^3/s^2)
%       mu_moon    gravitational parameter of Moon   (km^3/s^2)
%       R_earth    radius of Earth                    (km)
%       R_moon     radius of Moon                     (km)
%       D_em       Earth-Moon distance                (km)
%       omega_m    Moon angular velocity              (rad/s)
%       phase_m0   Moon initial phase angle           (rad)
%       dt         integration step                   (s)
%       tEnd       simulation duration                (s)
%       pos0       spacecraft initial position [x y]  (km)
%       vel0       spacecraft initial velocity [vx vy] (km/s)

    % --- physical bodies ---
    C.mu_earth = 398600;                 % Earth grav. parameter
    C.mu_moon  = 4903;                   % Moon grav. parameter
    C.R_earth  = 6371;                   % Earth radius
    C.R_moon   = 1737;                   % Moon radius
    C.D_em     = 384400;                 % mean Earth-Moon distance

    % --- Moon's circular orbit around Earth ---
    T_moon     = 27.32 * 86400;          % sidereal period (s)
    C.omega_m  = 2 * pi / T_moon;        % angular rate (rad/s)
    C.phase_m0 = deg2rad(128);           % initial angle so spacecraft meets Moon

    % --- time ---
    C.dt   = 60;                         % 1-minute step
    C.tEnd = 7.22 * 86400;               % ~7.22 days — stops just before Earth re-entry

    % --- spacecraft initial state (just after TLI burn from LEO) ---
    r0       = C.R_earth + 185;          % 185 km parking orbit
    v_tli    = 10.948;                   % trans-lunar injection speed (km/s)
    C.pos0   = [r0, 0];                  % start on +x axis
    C.vel0   = [0, v_tli];               % tangential, prograde (+y)
end
