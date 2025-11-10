% =======================================================================
% wilcoxon_compare_octave.m
% Performs pairwise Wilcoxon rank-sum tests between HPO and other algorithms
% Compatible with Octave
% =======================================================================

clear; clc;

baseDir = 'C:/Files/Semester_5/projects/PO/Compare_Algos/results_compare';
algos = {'PO','SCA','GWO','WOA','TSA','FHO','PSO'};   % Compare each vs HPO
funcs = {'F1','F2','F3','F4','F5','F6','F7'};

outFile = fullfile(baseDir, 'Wilcoxon_HPO_vs_All.csv');
fid = fopen(outFile, 'w');

fprintf(fid, 'Function');
for a = 1:numel(algos)
    fprintf(fid, ',p_%s,d_%s', algos{a}, algos{a});
end
fprintf(fid, '\n');

for f = 1:numel(funcs)
    F = funcs{f};
    fprintf('Analyzing %s\n', F);
    fprintf(fid, '%s', F);

    % Load HPO data
    hpoFile = fullfile(baseDir, 'HPO', [F '_results.mat']);
    if ~exist(hpoFile, 'file')
        warning('Missing HPO results for %s', F);
        continue;
    end
    HPO = load(hpoFile);
    HPO_data = HPO.all_bests(:);

    for a = 1:numel(algos)
        algo = algos{a};
        file = fullfile(baseDir, algo, [F '_results.mat']);
        if ~exist(file, 'file')
            warning('Missing %s results for %s', algo, F);
            continue;
        end

        A = load(file);
        A_data = A.all_bests(:);

        % Wilcoxon rank-sum test
        [p, h, stats] = ranksum(HPO_data, A_data);

        % Compute Cohen’s d effect size
        d = (mean(HPO_data) - mean(A_data)) / ...
            sqrt(0.5 * (var(HPO_data) + var(A_data)));

        fprintf(fid, ',%.3e,%.3f', p, d);
        fprintf('  %s vs HPO: p=%.3e, d=%.3f\n', algo, p, d);
    end
    fprintf(fid, '\n');
end

fclose(fid);
fprintf('\n✅ Wilcoxon results saved to: %s\n', outFile);

