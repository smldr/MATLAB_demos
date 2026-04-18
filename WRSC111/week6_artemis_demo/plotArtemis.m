function plotArtemis(results, C, mode)
% PLOTARTEMIS  Static plot + live animation of the Artemis demo.
%   plotArtemis(results, C, mode) draws the Earth, Moon orbit, and up to
%   three trajectories: nominal (mode 1), perturbed (mode 2), corrected
%   (mode 3), then animates the active trajectory over time.
%
% Inputs:
%   results - struct with fields .clean, .wind, .control, each a struct
%             with .t, .pos, .moon (.wind and .control may be empty)
%   C       - constants struct
%   mode    - active mode (1/2/3)

    % colours chosen for a bright projector on white background
    COL_NOMINAL  = [0.05 0.60 0.15];   % dark green
    COL_WIND     = [0.85 0.10 0.10];   % red
    COL_CONTROL  = [0.90 0.50 0.00];   % orange

    % =============== STATIC OVERVIEW ===============
    figure('Name', 'Artemis II - Trajectory', 'Color', 'w', ...
           'Position', [60 100 1100 620]);
    ax = gca;
    set(ax, 'Color', 'w', 'GridColor', [0.4 0.4 0.4], 'GridAlpha', 0.3, ...
            'FontSize', 12);
    hold on; grid on; axis equal;

    th = linspace(0, 2*pi, 400);
    plot(C.D_em*cos(th), C.D_em*sin(th), '--', 'Color', [0.55 0.55 0.55], ...
         'LineWidth', 1.2, 'DisplayName', 'Moon orbit');

    drawBody(0, 0, 4*C.R_earth, [0.2 0.4 1.0], 'Earth');

    m_end = results.clean.moon(end,:);
    drawBody(m_end(1), m_end(2), 6*C.R_moon, [0.6 0.6 0.6], 'Moon (end)');

    plot(results.clean.pos(:,1), results.clean.pos(:,2), '-', ...
         'Color', COL_NOMINAL, 'LineWidth', 2.5, 'DisplayName', 'Nominal (gravity only)');

    if ~isempty(results.wind)
        plot(results.wind.pos(:,1), results.wind.pos(:,2), '-', ...
             'Color', COL_WIND, 'LineWidth', 2.0, 'DisplayName', 'With solar wind');
    end
    if ~isempty(results.control)
        plot(results.control.pos(:,1), results.control.pos(:,2), '-', ...
             'Color', COL_CONTROL, 'LineWidth', 2.0, 'DisplayName', 'Wind + PD control');
    end

    xlabel('x  (km)', 'FontSize', 13);
    ylabel('y  (km)', 'FontSize', 13);
    title(sprintf('Artemis II Free-Return — mode %d', mode), ...
          'FontSize', 14, 'Color', [0.1 0.1 0.1]);
    lg = legend('Location', 'best', 'FontSize', 11);
    lg.Color      = 'w';
    lg.EdgeColor  = [0.4 0.4 0.4];
    lg.TextColor  = [0.1 0.1 0.1];
    hold off;

    % =============== ANIMATION ===============
    animateRun(results, mode, C, COL_NOMINAL, COL_WIND, COL_CONTROL);
end

% -----------------------------------------------------------------------
function drawBody(x, y, r, col, name)
    th = linspace(0, 2*pi, 60);
    patch(x + r*cos(th), y + r*sin(th), col, 'EdgeColor', [0.2 0.2 0.2], ...
          'DisplayName', name);
end

% -----------------------------------------------------------------------
function animateRun(results, mode, C, COL_NOMINAL, COL_WIND, COL_CONTROL)
    if mode == 3 && ~isempty(results.control)
        active = results.control;  col = COL_CONTROL;  label = 'Wind + PD control';
    elseif mode == 2 && ~isempty(results.wind)
        active = results.wind;     col = COL_WIND;     label = 'With solar wind';
    else
        active = results.clean;    col = COL_NOMINAL;  label = 'Nominal';
    end

    figure('Name', 'Artemis II - Live Animation', 'Color', 'w', ...
           'Position', [60 100 1100 620]);
    ax = gca;
    set(ax, 'Color', 'w', 'GridColor', [0.4 0.4 0.4], 'GridAlpha', 0.3, ...
            'FontSize', 12);
    hold on; grid on; axis equal;

    th = linspace(0, 2*pi, 60);

    % ghost of the nominal trajectory as a subtle reference
    plot(results.clean.pos(:,1), results.clean.pos(:,2), '-', ...
         'Color', [0.70 0.88 0.70], 'LineWidth', 1.5);

    % Earth and Moon orbit ring
    patch(4*C.R_earth*cos(th), 4*C.R_earth*sin(th), [0.2 0.4 1.0], ...
          'EdgeColor', [0.1 0.2 0.6]);
    plot(C.D_em*cos(th), C.D_em*sin(th), '--', 'Color', [0.55 0.55 0.55], ...
         'LineWidth', 1.2);

    % animated handles
    hTrail = plot(NaN, NaN, '-',  'Color', col, 'LineWidth', 2.5);
    hCraft = plot(active.pos(1,1), active.pos(1,2), 'o', ...
                  'MarkerSize', 11, 'MarkerFaceColor', col, ...
                  'MarkerEdgeColor', [0.2 0.2 0.2], 'LineWidth', 1.5);
    hMoon  = patch(active.moon(1,1) + 6*C.R_moon*cos(th), ...
                   active.moon(1,2) + 6*C.R_moon*sin(th), ...
                   [0.6 0.6 0.6], 'EdgeColor', [0.2 0.2 0.2]);
    hTxt   = text(0.02, 0.96, '', 'Units', 'normalized', ...
                  'FontWeight', 'bold', 'FontSize', 13, 'Color', [0.15 0.15 0.15]);

    pad  = 6e4;
    allX = [-C.D_em; C.D_em; active.pos(:,1); results.clean.pos(:,1)];
    allY = [-C.D_em; C.D_em; active.pos(:,2); results.clean.pos(:,2)];
    xlim([min(allX)-pad, max(allX)+pad]);
    ylim([min(allY)-pad, max(allY)+pad]);
    xlabel('x  (km)', 'FontSize', 13);
    ylabel('y  (km)', 'FontSize', 13);
    title(sprintf('Artemis II Free-Return — %s', label), 'FontSize', 14);

    % arc-length uniform frame sampling -- constant visual speed
    nFrames       = 300;
    arc           = [0; cumsum(vecnorm(diff(active.pos), 2, 2))];
    targets       = linspace(0, arc(end), nFrames);
    frames        = arrayfun(@(s) find(arc >= s, 1, 'first'), targets);
    totalDuration = 20;                        % seconds -- raise to slow further
    frameDelay    = totalDuration / nFrames;

    for idx = 1:numel(frames)
        k = frames(idx);
        set(hTrail, 'XData', active.pos(1:k,1), 'YData', active.pos(1:k,2));
        set(hCraft, 'XData', active.pos(k,1),   'YData', active.pos(k,2));
        set(hMoon,  'XData', active.moon(k,1) + 6*C.R_moon*cos(th), ...
                    'YData', active.moon(k,2) + 6*C.R_moon*sin(th));
        set(hTxt,   'String', sprintf('t = %.2f days', active.t(k)/86400));
        drawnow limitrate;
        pause(frameDelay);
    end
    drawnow;
end
