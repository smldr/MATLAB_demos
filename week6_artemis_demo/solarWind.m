function a = solarWind(t, pos, C)
% SOLARWIND  Small push from solar radiation / wind pressure.
%
% [APPLIED MATHS PREVIEW]
%   A real solar-wind model integrates particle flux, spacecraft cross
%   section and attitude. Here we use a drastically simplified model:
%
%       a = p0 * (1 + 0.3 * sin(2*pi*t / tau)) * [cos(phi), sin(phi)]
%
%   - The Sun lies in the +x direction, so the wind pushes mostly in -x.
%   - The sinusoid mimics slow fluctuations in solar activity.
%   - The acceleration is tiny (~micro-g), but over several days it moves
%     the spacecraft thousands of kilometres off course.
%
%   In your numerical-methods and astrodynamics courses you will replace
%   this with a proper perturbation model and study how different ODE
%   integrators cope with small, time-varying forces.
%
% Inputs:
%   t   - time (s)
%   pos - spacecraft position (unused here, kept for generality)  (km)
%   C   - constants struct (unused here, kept for generality)
% Outputs:
%   a   - acceleration vector [ax ay]  (km/s^2)

    p0   = 8e-7;                 % baseline magnitude (km/s^2) — tuned for a visible but not absurd drift
    tau  = 2 * 86400;            % 2-day oscillation period
    phi  = pi + 0.4*sin(2*pi*t/(5*86400));   % direction wobbles slightly

    mag  = p0 * (1 + 0.3 * sin(2*pi*t / tau));
    a    = mag * [cos(phi), sin(phi)];
end
