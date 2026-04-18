function pos = moonPosition(t, C)
% MOONPOSITION  Position of the Moon in Earth-centred inertial frame.
%   pos = moonPosition(t, C) returns [x, y] in km at time t (s).
%   The Moon is assumed to follow a circular orbit of radius C.D_em.
%
% Inputs:
%   t - time in seconds (scalar)
%   C - constants struct from constants()
% Outputs:
%   pos - [x y] position in km

    theta = C.phase_m0 + C.omega_m * t;
    pos   = C.D_em * [cos(theta), sin(theta)];
end
