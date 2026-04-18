function a = totalAccel(pos, vel, t, C, mode, ref)
% TOTALACCEL  Net acceleration on the spacecraft at a given state.
%   a = totalAccel(pos, vel, t, C, mode, ref) sums gravity from Earth and
%   Moon, plus optional perturbations depending on mode:
%       mode = 1  just gravity             (clean trajectory)
%       mode = 2  gravity + solar wind     (perturbation)
%       mode = 3  gravity + wind + control (with correction)
%
% Inputs:
%   pos, vel - spacecraft state (km, km/s)
%   t        - time (s)
%   C        - constants struct
%   mode     - 1, 2 or 3
%   ref      - reference trajectory struct used by controlThrust (mode 3).
%              Pass [] for modes 1 and 2.
% Outputs:
%   a - acceleration vector [ax ay]  (km/s^2)

    % --- always: two-body gravity ---
    a = gravityAccel(pos, [0 0], C.mu_earth) ...
      + gravityAccel(pos, moonPosition(t, C), C.mu_moon);

    % --- mode 2+: solar wind perturbation  (APPLIED MATHS preview) ---
    if mode >= 2
        a = a + solarWind(t, pos, C);
    end

    % --- mode 3: active course correction  (CONTROL SYSTEMS preview) ---
    if mode == 3
        a = a + controlThrust(pos, vel, t, ref, C);
    end
end
