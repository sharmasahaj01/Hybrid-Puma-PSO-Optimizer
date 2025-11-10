% =======================================================================
% produce_summary_table_octave.m
% Octave-compatible version (no 'table' or 'writetable')
% =======================================================================

projectDir = 'C:/Files/Semester_5/pojects/PO';   % adjust
resultsDir = 'C:/Files/Semester_5/pojects/PO/results_PO'; % where your results are

funcs = {'F1','F2','F3','F4','F5','F6','F7'};
R = 30; MaxIter = 500;
halfIdx = floor(MaxIter/2)+1;
last20 = ceil(MaxIter*0.8);

% Preallocate numeric matrix for all summary data
summary = zeros(numel(funcs),6);

for i = 1:numel(funcs)
    fname = funcs{i};
    S = load(fullfile(resultsDir, sprintf('%s_results.mat', fname)));

    curves = S.all_curves; % R x MaxIter
    exploit = S.PO_EXPLOIT_HISTORY; % R x MaxIter
    final_bests = curves(:, end);

    % --- Performance stats ---
    m = mean(final_bests);
    med = median(final_bests);
    sdev = std(final_bests);

    % --- Exploitation stats ---
    late_exploit_counts = sum(exploit(:, halfIdx:end), 2);
    mean_late_exploit_per_iter = mean(late_exploit_counts) / (MaxIter - halfIdx + 1);
    frac_improved_last20 = sum(any(exploit(:, last20:end), 2)) / R;

    % --- Late convergence slope ---
    p20 = last20; slopes = nan(R,1);
    for r = 1:R
        y = curves(r, p20:end)';
        if any(y <= 0), y = y - min(y) + eps; end
        p = polyfit((p20:MaxIter)', log(y), 1);
        slopes(r) = p(1);
    end
    med_late_slope = median(slopes);

    % --- Save row ---
    summary(i,:) = [m, med, sdev, mean_late_exploit_per_iter, frac_improved_last20, med_late_slope];
end

% --- Write to CSV manually ---
header = {'Function','Mean','Median','Std','MeanLateExploitPerIter','FracImprovedLast20','MedianLateSlope'};
csvFile = fullfile(resultsDir, 'PO_unimodal_summary.csv');
fid = fopen(csvFile, 'w');
fprintf(fid, '%s,%s,%s,%s,%s,%s,%s\n', header{:});

for i = 1:numel(funcs)
    fprintf(fid, '%s,%.3e,%.3e,%.3e,%.4f,%.4f,%.3e\n', ...
        funcs{i}, summary(i,1), summary(i,2), summary(i,3), ...
        summary(i,4), summary(i,5), summary(i,6));
end
fclose(fid);

% --- Also write LaTeX table ---
texFile = fullfile(resultsDir, 'PO_unimodal_summary.tex');
fid = fopen(texFile, 'w');
fprintf(fid, '\\begin{tabular}{lrrrrrr}\n\\hline\nFunction & Mean & Median & Std & LateExpl/iter & FracLast20 & LateSlope\\\\\\hline\n');
for i = 1:numel(funcs)
    fprintf(fid, '%s & %.3e & %.3e & %.3e & %.4f & %.4f & %.3e \\\\\n', ...
        funcs{i}, summary(i,1), summary(i,2), summary(i,3), ...
        summary(i,4), summary(i,5), summary(i,6));
end
fprintf(fid, '\\hline\n\\end{tabular}\n');
fclose(fid);

fprintf('\n✅ Summary CSV and LaTeX files saved in: %s\n', resultsDir);
fprintf('   Files created: PO_unimodal_summary.csv, PO_unimodal_summary.tex\n');

