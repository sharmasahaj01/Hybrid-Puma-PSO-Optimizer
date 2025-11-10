% wilcoxon.m
% Perform Wilcoxon rank-sum tests and compute Cohen's d between
% Original PUMA (results_PO) and Hybrid PUMA-PSO (results_PO_hybrid).
%
% Saves CSV to results_PO_hybrid/Wilcoxon_results.csv and prints summary.

function wilcoxon()
    % ---- User config ----
    proj = 'C:/Files/Semester_5/projects/PO';  % adjust if needed
    funcs = {'F1','F2','F3','F4','F5','F6','F7'};
    R = 30;
    resultsDir_HY = fullfile(proj,'results_PO_hybrid');
    resultsDir_PO = fullfile(proj,'results_PO');
    outCSV = fullfile(resultsDir_HY, 'Wilcoxon_results.csv');

    % Check directories
    if ~exist(resultsDir_HY,'dir')
        error('Hybrid results folder not found: %s', resultsDir_HY);
    end
    if ~exist(resultsDir_PO,'dir')
        error('Original results folder not found: %s', resultsDir_PO);
    end

    % Prepare output storage
    T = cell(numel(funcs)+1, 9);
    T(1,:) = {'Function','Median_PO','Median_HY','Mean_PO','Mean_HY','Std_PO','Std_HY','Wilcoxon_p','Cohens_d'};

    % Loop functions
    for i = 1:numel(funcs)
        f = funcs{i};
        poFile = fullfile(resultsDir_PO, [f '_results.mat']);
        hyFile = fullfile(resultsDir_HY, [f '_results.mat']);
        if ~exist(poFile,'file') || ~exist(hyFile,'file')
            warning('Missing results for %s. Skipping.', f);
            continue;
        end

        PO = load(poFile,'all_curves');
        HY = load(hyFile,'all_curves');

        % Extract final values (last column)
        finalPO = PO.all_curves(:,end);
        finalHY = HY.all_curves(:,end);

        % Remove NaNs if any
        finalPO = finalPO(~isnan(finalPO));
        finalHY = finalHY(~isnan(finalHY));

        % Basic stats
        medPO = median(finalPO,'omitnan');
        medHY = median(finalHY,'omitnan');
        meanPO = mean(finalPO,'omitnan');
        meanHY = mean(finalHY,'omitnan');
        stdPO = std(finalPO,'omitnan');
        stdHY = std(finalHY,'omitnan');

        % Wilcoxon rank-sum (A vs B)
        try
            p = ranksum(finalPO, finalHY);
        catch ME
            warning('ranksum failed for %s: %s', f, ME.message);
            p = NaN;
        end

        % Cohen's d (pooled std). d = (meanPO - meanHY) / pooledStd
        pooledStd = sqrt((stdPO^2 + stdHY^2)/2);
        if pooledStd == 0
            d = NaN;
        else
            d = (meanPO - meanHY) / pooledStd;
        end

        % Save into table structure (for CSV)
        T{i+1,1} = f;
        T{i+1,2} = medPO;
        T{i+1,3} = medHY;
        T{i+1,4} = meanPO;
        T{i+1,5} = meanHY;
        T{i+1,6} = stdPO;
        T{i+1,7} = stdHY;
        T{i+1,8} = p;
        T{i+1,9} = d;

        % Print line to console
        fprintf('%s: medPO=%.6g medHY=%.6g meanPO=%.6g meanHY=%.6g stdPO=%.6g stdHY=%.6g p=%.3e d=%.3f\n', ...
            f, medPO, medHY, meanPO, meanHY, stdPO, stdHY, p, d);
    end

    % Write CSV
    try
        fid = fopen(outCSV,'w');
        fprintf(fid, 'Function,Median_PO,Median_HY,Mean_PO,Mean_HY,Std_PO,Std_HY,Wilcoxon_p,Cohens_d\n');
        for r = 2:size(T,1)
            if isempty(T{r,1}), continue; end
            fprintf(fid, '%s,%.6e,%.6e,%.6e,%.6e,%.6e,%.6e,%.6e,%.6f\n', ...
                T{r,1}, T{r,2}, T{r,3}, T{r,4}, T{r,5}, T{r,6}, T{r,7}, T{r,8}, T{r,9});
        end
        fclose(fid);
        fprintf('Wilcoxon results saved to: %s\n', outCSV);
    catch ME
        warning('Failed to write CSV: %s', ME.message);
        if exist('fid','var') && fid>0, fclose(fid); end
    end

    % Save MATLAB .mat summary as well
    try
        save(fullfile(resultsDir_HY,'Wilcoxon_results.mat'),'T');
    catch
        % ignore
    end
end

