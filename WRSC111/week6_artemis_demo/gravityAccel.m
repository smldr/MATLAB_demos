function a = gravityAccel(pos, bodyPos, mu)
% GRAVITYACCEL  Newtonian gravitational acceleration from one body.
%   a = gravityAccel(pos, bodyPos, mu) returns the acceleration vector
%   (km/s^2) acting on a spacecraft at `pos` due to a body at `bodyPos`
%   with gravitational parameter `mu` (= G*M).
%
% Physics:
%   a = mu * (bodyPos - pos) / |bodyPos - pos|^3
%
% Inputs:
%   pos     - spacecraft position [x y]  (km)
%   bodyPos - attracting body position [x y]  (km)
%   mu      - gravitational parameter  (km^3/s^2)
% Outputs:
%   a - acceleration vector [ax ay]  (km/s^2)

    r_vec = bodyPos - pos;
    r_mag = sqrt(r_vec(1)^2 + r_vec(2)^2);
    a     = mu * r_vec / r_mag^3;
end
