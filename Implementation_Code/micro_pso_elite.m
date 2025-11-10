% micro_pso_elite.m
% Lightweight PSO-based local intensifier for top-k solutions in a population.
%
% Usage:
%   Sol = micro_pso_elite(Sol, k, L, lb, ub, CostFunction, params)
%
% Inputs:
%   Sol         - array of solution structs with fields .X (1xdim) and .Cost
%   k           - number of top solutions to refine (e.g., 5)
%   L           - number of micro-PSO iterations (e.g., 8 or 10)
%   lb, ub      - vectors of lower/upper bounds (1xdim)
%   CostFunction- function handle: cost = CostFunction(x)
%   params      - (optional) struct with fields w,c1,c2, vmax_scale (see defaults)
%
% Output:
%   Sol         - population with refined elites (replaced if improved)
%
function Sol = micro_pso_elite(Sol, k, L, lb, ub, CostFunction, params)

if nargin < 7, params = struct(); end
if ~isfield(params,'w'), params.w = 0.7; end
if ~isfield(params,'c1'), params.c1 = 1.5; end
if ~isfield(params,'c2'), params.c2 = 1.5; end
if ~isfield(params,'vmax_scale'), params.vmax_scale = 0.2; end

nSol = numel(Sol);
if k <= 0 || k > nSol
    k = min(max(1, round(k)), nSol);
end

% dimension
dim = numel(Sol(1).X);

% sort population by cost (ascending)
[~, idx] = sort([Sol.Cost]);
elite_idx = idx(1:k);

% extract elite positions and costs
X_elite = zeros(k, dim);
Pbest = zeros(k, dim);
Pbest_val = inf(k,1);
for i=1:k
    X_elite(i,:) = Sol(elite_idx(i)).X;
    Pbest(i,:) = X_elite(i,:);
    Pbest_val(i) = Sol(elite_idx(i)).Cost;
end

% initialize velocity small
V = zeros(k, dim);

% vmax based on bounds and scale
vmax = (ub - lb) * params.vmax_scale;
if isscalar(vmax), vmax = vmax * ones(1,dim); end

% global best among elites
[global_val, gidx] = min(Pbest_val);
Gbest = Pbest(gidx,:);

% micro-PSO iterations
for t = 1:L
    for i = 1:k
        r1 = rand(1,dim); r2 = rand(1,dim);
        V(i,:) = params.w * V(i,:) + ...
                 params.c1 * r1 .* (Pbest(i,:) - X_elite(i,:)) + ...
                 params.c2 * r2 .* (Gbest - X_elite(i,:));
        % clamp velocity
        V(i,:) = max(min(V(i,:), vmax), -vmax);
        % update position
        X_elite(i,:) = X_elite(i,:) + V(i,:);
        % enforce bounds
        X_elite(i,:) = max(min(X_elite(i,:), ub), lb);
        % evaluate
        val = CostFunction(X_elite(i,:));
        if val < Pbest_val(i)
            Pbest_val(i) = val;
            Pbest(i,:) = X_elite(i,:);
            % update global
            if val < global_val
                global_val = val;
                Gbest = Pbest(i,:);
            end
        end
    end
end

% After micro-PSO, replace elites in Sol if improved
for j = 1:k
    run_idx = elite_idx(j);
    if Pbest_val(j) < Sol(run_idx).Cost
        Sol(run_idx).X = Pbest(j,:);
        Sol(run_idx).Cost = Pbest_val(j);
    end
end

end

