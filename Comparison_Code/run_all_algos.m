% =======================================================================
% run_all_algorithms.m
% Runs all algorithms (PO, HPO, SCA, GWO, WOA, TSA, FHO, PSO) on F1–F7
% and saves results in structured folders.
% =======================================================================

clear; clc; close all;

projectDir = 'C:/Files/Semester_5/projects/PO/Compare_Algos/results_compare';
funcs = {'F1'};
algos = {'PO','SCA','GWO','WOA','TSA','FHO','PSO'};  % HPO already done
N = 10;       % Population
MaxIter = 100;

% Add paths for all algorithms
addpath(genpath('C:/Files/Semester_5/projects/PO/Compare_Algos/PO'));
addpath(genpath('C:/Files/Semester_5/projects/PO/Compare_Algos/SCA'));
addpath(genpath('C:/Files/Semester_5/projects/PO/Compare_Algos/GWO'));
addpath(genpath('C:/Files/Semester_5/projects/PO/Compare_Algos/WOA'));
addpath(genpath('C:/Files/Semester_5/projects/PO/Compare_Algos/TSA'));
addpath(genpath('C:/Files/Semester_5/projects/PO/Compare_Algos/FHO'));
addpath(genpath('C:/Files/Semester_5/projects/PO/Compare_Algos/PSO'));

for a = 1:numel(algos)
    algo = algos{a};
    algoDir = fullfile(projectDir, algo);
    if ~exist(algoDir, 'dir'), mkdir(algoDir); end

    fprintf('\n==== Running %s ====\n', algo);

    for f = 1:numel(funcs)
        F = funcs{f};
        [lb, ub, dim, fobj] = Get_Functions_details(F);

        all_bests = nan(N,1);
        all_curves = nan(N, MaxIter);

        for run = 1:N
            rng(run);
            try
                switch algo
                    case 'PO'
                        [~, bestCost, Conv] = Puma(N, MaxIter, lb, ub, dim, fobj);
                    case 'SCA'
                        [~, bestCost, Conv] = SCA(N, MaxIter, lb, ub, dim, fobj);
                    case 'GWO'
                        [~, bestCost, Conv] = GWO(N, MaxIter, lb, ub, dim, fobj);
                    case 'WOA'
                        [~, bestCost, Conv] = WOA(N, MaxIter, lb, ub, dim, fobj);
                    case 'TSA'
                        [~, bestCost, Conv] = TSA(N, MaxIter, lb, ub, dim, fobj);
                    case 'FHO'
                        [~, bestCost, Conv] = FHO(N, MaxIter, lb, ub, dim, fobj);
                    case 'PSO'
                        [~, bestCost, Conv] = PSO(N, MaxIter, lb, ub, dim, fobj);
                end

                L = numel(Conv);
                if L < MaxIter
                    Conv(L+1:MaxIter) = Conv(end);
                end

                all_bests(run) = bestCost;
                all_curves(run,:) = Conv(:)';
            catch ME
                fprintf('Run %d failed: %s\n', run, ME.message);
            end
        end

        save(fullfile(algoDir, sprintf('%s_results.mat', F)), ...
             'all_bests','all_curves','F');
        fprintf('  Saved %s results for %s\n', algo, F);
    end
end

disp('====================================================');
disp('All algorithms have been executed and results saved.');
disp('You can now run compare_all_algorithms.m');
disp('====================================================');

