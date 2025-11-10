% =======================================================================
% compare_all_algorithms.m
% Summarizes all algorithms' results (mean, median, std) for each F1–F7
% =======================================================================

clear; clc;

baseDir = 'C:/Files/Semester_5/projects/PO/Compare_Algos/results_compare';
algos = {'PO','SCA','GWO','WOA','TSA','FHO','PSO'};
funcs = {'F1','F2','F3','F4','F5','F6','F7'};

summaryData = zeros(numel(funcs), numel(algos)*3); % mean, median, std per algo

for f = 1:numel(funcs)
    F = funcs{f};
    fprintf('\nFunction %s\n', F);

    for a = 1:numel(algos)
        algo = algos{a};
        file = fullfile(baseDir, algo, [F '_results.mat']);
        if ~isfile(file)
            warning('Missing %s', file);
            continue;
        end

        S = load(file);
        data = S.all_bests;  % 30x1 best fitness values

        meanV = mean(data, 'omitnan');
        medV  = median(data, 'omitnan');
        stdV  = std(data, 'omitnan');

        summaryData(f, (a-1)*3 + (1:3)) = [meanV medV stdV];
        fprintf('%6s: mean=%.3e  median=%.3e  std=%.3e\n', algo, meanV, medV, stdV);
    end
end

% Create table headers dynamically
headers = {};
for a = 1:numel(algos)
    headers = [headers, ...
        {sprintf('Mean_%s',algos{a}), sprintf('Median_%s',algos{a}), sprintf('Std_%s',algos{a})}];
end

T = array2table(summaryData, 'VariableNames', headers, 'RowNames', funcs);

% Save to CSV
writetable(T, fullfile(baseDir, 'Overall_Summary.csv'), 'WriteRowNames', true);

disp('✅ Summary table saved as Overall_Summary.csv');

