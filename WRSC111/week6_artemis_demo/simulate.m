function [t, pos, vel, moon] = simulate(C, mode, ref)
% SIMULATE  Propagate the spacecraft for the full mission duration.
%   [t, pos, vel, moon] = simulate(C, mode, ref) integrates the equations
%   of motion using RK4 and returns time, position, velocity and Moon
%   position histories.
%
% Inputs:
%   C    - constants struct
%   mode - 1 (clean) | 2 (+ wind) | 3 (+ wind + control)
%   ref  - nominal trajectory struct (only used for mode 3, else [])
% Outputs:
%   t    - time vector                (N x 1, s)
%   pos  - spacecraft position history (N x 2, km)
%   vel  - spacecraft velocity history (N x 2, km/s)
%   moon - Moon position history       (N x 2, km)

    N    = round(C.tEnd / C.dt) + 1;
    t    = (0:N-1)' * C.dt;
    pos  = zeros(N, 2);
    vel  = zeros(N, 2);
    moon = zeros(N, 2);

    p = C.pos0;
    v = C.vel0;

    % build the acceleration function for this mode (anonymous function — Week 6!)
    accelFn = @(pp, vv, tt) totalAccel(pp, vv, tt, C, mode, ref);

    for k = 1:N
        pos(k,:)  = p;
        vel(k,:)  = v;
        moon(k,:) = moonPosition(t(k), C);

        if k < N
            [p, v] = rk4Step(p, v, t(k), C.dt, accelFn);
        end
    end
end
