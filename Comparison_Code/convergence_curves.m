% =======================================================================
% plot_convergence_compare.m
% Plots median convergence curves of all algorithms on one graph
% for each benchmark function (F1–F7).
% =======================================================================

clear; clc; close all;

baseDir = 'C:/Files/Semester_5/projects/PO/Compare_Algos/results_compare';
algos   = {'PO','HPO','SCA','GWO','WOA','TSA','FHO','PSO'};
funcs   = {'F1','F2','F3','F4','F5','F6','F7'};
colors  = {'r','b','m','g','c','k','y',[0.5 0.2 0.9]};  % distinguishable colors
MaxIter = 500;   % adjust if needed
outDir  = fullfile(baseDir, 'Convergence_Plots');
if ~exist(outDir,'dir'), mkdir(outDir); end

% ----------------- safe plotting loop -----------------
for f = 1:numel(funcs)
    F = funcs{f};
    figure('Name',F,'Position',[100 100 900 500]); hold on; grid on;
    legendEntries = {};
    plottedAny = false;

    for a = 1:numel(algos)
        algo = algos{a};
        file = fullfile(baseDir, algo, [F '_results.mat']);
        if ~exist(file,'file')
            warning('Missing file for %s - %s', algo, F);
            continue;
        end

        S = load(file);

        if ~isfield(S,'all_curves')
            warning('No numeric field ''all_curves'' in %s', file);
            continue;
        end

        curves = S.all_curves;

        % Validate curves
        if ~isnumeric(curves) || ndims(curves)~=2
            warning('Skipping %s: all_curves not a numeric 2-D array (size=%s).', file, mat2str(size(curves)));
            continue;
        end

        [R,C] = size(curves);
        if R <= 0 || C <= 0
            warning('Skipping %s: empty array.', file);
            continue;
        end
        if C > 1e6
            warning('Skipping %s: too many iterations (%d).', file, C);
            continue;
        end

        % compute median (ignore NaNs)
        medCurve = median(curves,1,'omitnan');    % 1 x C

        % fix non-positive values for log plot
        posVals = medCurve(medCurve>0);
        if isempty(posVals)
            % no positive values at all: replace with eps
            medCurve(:) = eps;
            warning('all non-positive median values in %s; using eps placeholders', file);
        else
            minPos = min(posVals);
            % replace zeros/nonpositive by a fraction of smallest positive (keeps scale)
            medCurve(medCurve <= 0) = minPos * 1e-3;
        end

        % final safety: ensure medCurve is a row vector of reasonable length
        medCurve = medCurve(:)';
        if numel(medCurve) > 1000000
            warning('Skipping %s: medCurve length too big (%d).', file, numel(medCurve));
            continue;
        end

        % plot
        try
            semilogy(1:numel(medCurve), medCurve, 'Color', colors{a}, 'LineWidth',1.5);
            legendEntries{end+1} = algo; %#ok<SAGROW>
            plottedAny = true;
        catch ME
            warning('Plot failed for %s: %s', file, ME.message);
            continue;
        end
    end

    if ~plottedAny
        title(sprintf('No valid data for %s', F));
    else
        xlabel('Iteration');
        ylabel('Best-so-far Fitness (log scale)');
        title(sprintf('Convergence comparison on %s', F));
        legend(legendEntries, 'Location','bestoutside');
    end

    saveas(gcf, fullfile(outDir, [F '_Convergence.png']));
    close;
end


fprintf('✅ All convergence comparison plots saved to: %s\n', outDir);

