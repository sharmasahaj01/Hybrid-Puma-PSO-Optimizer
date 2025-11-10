% =======================================================================
%  run_F1_to_F7_with_instrumentation.m
%
%  Runs Puma Optimizer on F1–F7 (unimodal) benchmark functions,
%  collects exploitation improvement data and convergence curves.
%
%  Output:
%   - results_PO/F#_results.mat per function
%   - summary plots for convergence and exploitation counts
% =======================================================================
projectDir = 'C:/Files/Semester_5/projects/PO';

funcs = {'F1','F2','F3','F4','F5','F6','F7'};  % Unimodal functions
R = 30;            % number of independent runs
MaxIter = 500;     % iterations
nSol = 30;         % population size
resultsDir = fullfile(projectDir, 'results_PO');
if ~exist(resultsDir, 'dir'), mkdir(resultsDir); end

% --- Global logs ---
global PO_EXPLOIT_HISTORY PO_LOG_RUN PO_CURRENT_ITER;

for fidx = 1:numel(funcs)
    fname = funcs{fidx};
    fprintf('\nRunning function %s (%d/%d)\n', fname, fidx, numel(funcs));

    % Get benchmark function details
    [lb, ub, dim, fobj] = Get_Functions_details(fname);

    % Initialize result holders
    all_curves = nan(R, MaxIter);
    all_bests = nan(R, 1);
    PO_EXPLOIT_HISTORY = zeros(R, MaxIter);  % reset log

    for run = 1:R
        rng(run);
        PO_LOG_RUN = run;

        try
            [bestX, bestCost, Conv] = Puma(nSol, MaxIter, lb, ub, dim, fobj);
            L = numel(Conv);
            if L < MaxIter
                Conv(L+1:MaxIter) = Conv(end);
            end
            all_curves(run,:) = Conv(:)';
            all_bests(run) = bestCost;

            fprintf('  Run %2d done: best = %.3e\n', run, bestCost);
        catch ME
            fprintf('  Run %2d FAILED: %s\n', run, ME.message);
        end
    end

    % Save per-function results
    save(fullfile(resultsDir, sprintf('%s_results.mat', fname)), ...
        'all_curves','all_bests','PO_EXPLOIT_HISTORY','fname');

    % --- Compute mean convergence and exploitation stats ---
    median_curve = median(all_curves,1,'omitnan');
    avg_exploit = mean(PO_EXPLOIT_HISTORY,1,'omitnan');

    % Plot median convergence
    figure('Name',['Convergence - ' fname],'Position',[100 100 900 400]);
    plot(1:MaxIter, median_curve, '-r','LineWidth',2);
    xlabel('Iteration'); ylabel('Best-so-far'); title(['Median convergence - ' fname]);
    grid on;
    saveas(gcf, fullfile(resultsDir, [fname '_convergence.png']));

    % Plot exploitation improvements per iteration
    figure('Name',['Exploit Activity - ' fname],'Position',[100 100 900 300]);
    bar(1:MaxIter, avg_exploit);
    xlabel('Iteration'); ylabel('Avg successful exploitation'); grid on;
    title(['Avg successful exploitation improvements per iteration - ' fname]);
    saveas(gcf, fullfile(resultsDir, [fname '_exploit_activity.png']));

    % Quick console summary
    late_half = ceil(MaxIter/2);
    late_avg = mean(sum(PO_EXPLOIT_HISTORY(:,late_half:end),2)/(MaxIter-late_half));
    fprintf('  Avg successful exploit per iteration (late half): %.4f\n', late_avg);
end

disp('===================================================================');
disp('All functions (F1–F7) completed. Results stored in: results_PO/');
disp('You can now analyze them using analyze_exploitation.m');
disp('===================================================================');

