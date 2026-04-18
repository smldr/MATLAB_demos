function [posNew, velNew] = rk4Step(pos, vel, t, dt, accelFn)
% RK4STEP  One 4th-order Runge-Kutta step for a 2nd-order ODE.
%
%   [posNew, velNew] = rk4Step(pos, vel, t, dt, accelFn) advances the
%   spacecraft state by dt using classical RK4. `accelFn` is an anonymous
%   function handle returning acceleration at a given (position, velocity,
%   time):
%       accelFn = @(p, v, tt) totalAccel(p, v, tt, C, mode, ref)
%
% [APPLIED MATHS PREVIEW]
%   RK4 evaluates the acceleration four times per step and combines the
%   estimates to cancel low-order error. You will derive this method and
%   its error bounds in your numerical-methods course.
%
% Inputs:
%   pos, vel - current state  (km, km/s)
%   t        - current time   (s)
%   dt       - step size      (s)
%   accelFn  - acceleration function handle @(p,v,t) -> [ax ay]
% Outputs:
%   posNew, velNew - state after one step

    k1p = vel;                        k1v = accelFn(pos,             vel,             t);
    k2p = vel + 0.5*dt*k1v;           k2v = accelFn(pos + 0.5*dt*k1p, vel + 0.5*dt*k1v, t + 0.5*dt);
    k3p = vel + 0.5*dt*k2v;           k3v = accelFn(pos + 0.5*dt*k2p, vel + 0.5*dt*k2v, t + 0.5*dt);
    k4p = vel +     dt*k3v;           k4v = accelFn(pos +     dt*k3p, vel +     dt*k3v, t +     dt);

    posNew = pos + (dt/6) * (k1p + 2*k2p + 2*k3p + k4p);
    velNew = vel + (dt/6) * (k1v + 2*k2v + 2*k3v + k4v);
end
