function a = controlThrust(pos, vel, t, ref, C)
% CONTROLTHRUST  Proportional-derivative course correction.
%
% [CONTROL SYSTEMS PREVIEW]
%   The spacecraft is supposed to follow the "nominal" free-return
%   trajectory computed without any perturbation. The solar wind pushes it
%   off course. A closed-loop controller measures the error against the
%   nominal and fires thrusters to drive that error back to zero:
%
%       e       = pos_nominal(t) - pos
%       edot    = vel_nominal(t) - vel
%       a_thr   = Kp * e + Kd * edot     % PD control law
%
%   `Kp` penalises position error, `Kd` damps out oscillation. In your
%   control-systems course you will learn how to choose these gains,
%   analyse stability, and extend to PID and state-feedback controllers.
%
% Inputs:
%   pos, vel - current state                 (km, km/s)
%   t        - current time                  (s)
%   ref      - struct with fields .t, .pos, .vel (nominal trajectory)
%   C        - constants struct (unused, kept for generality)
% Outputs:
%   a        - correction acceleration [ax ay]  (km/s^2)

    % look up nominal state at this time (linear interpolation)
    pos_ref = [interp1(ref.t, ref.pos(:,1), t, 'linear', 'extrap'), ...
               interp1(ref.t, ref.pos(:,2), t, 'linear', 'extrap')];
    vel_ref = [interp1(ref.t, ref.vel(:,1), t, 'linear', 'extrap'), ...
               interp1(ref.t, ref.vel(:,2), t, 'linear', 'extrap')];

    % PD gains (tuned by hand for this demo)
    Kp = 4e-8;
    Kd = 4e-4;

    e    = pos_ref - pos;
    edot = vel_ref - vel;
    a    = Kp * e + Kd * edot;
end
