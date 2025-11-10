%_______________________________________________________________________________________________
%  Hybrid Puma Optimizer Algorithm (PUMA-PSO)
%
%  Based on:
%  Abdollahzadeh et al., “Puma optimizer (PO): a novel metaheuristic optimization algorithm,”
%  Cluster Computing, 2023.
%
%  Hybrid modification by Group 19 Soft Computing (2025):
%  Added micro-PSO refinement inside the exploitation phase to strengthen local exploitation.
%
%_______________________________________________________________________________________________

function [Puma_X, Puma_C, Convergence] = Puma_PSO_hybrid(nSol, MaxIter, lb, ub, dim, CostFunction)

% ============================= INITIALIZATION =============================================
UnSelected = ones(1,2);     % 1: Exploration  2: Exploitation
F3_Explore = 0;
F3_Exploit = 0;
Seq_Time_Explore = ones(1,3);
Seq_Time_Exploit = ones(1,3);
Seq_Cost_Explore = ones(1,3);
Seq_Cost_Exploit = ones(1,3);
Score_Explore = 0;
Score_Exploit = 0;
PF = [0.5 0.5 0.3];         % parameters from original paper
PF_F3 = [];
Mega_Explor = 0.99;
Mega_Exploit = 0.99;

% Initialize population
for i = 1:nSol
   Sol(i).X = unifrnd(lb,ub,1,dim);
   Sol(i).Cost = CostFunction(Sol(i).X);
end
[~,ind] = min([Sol.Cost]);
Best = Sol(ind);
Initial_Best = Best;
Flag_Change = 1;

% ============================= UNEXPERIENCED PHASE =======================================
for Iter = 1:3
    Sol_Explor = Exploration(Sol,lb,ub,dim,nSol,CostFunction);
    Costs_Explor(1,Iter) = min([Sol_Explor.Cost]);

    Sol_Exploit = Exploitation(Sol,lb,ub,dim,nSol,Best,MaxIter,Iter,CostFunction);
    Costs_Exploit(1,Iter) = min([Sol_Exploit.Cost]);

    Sol = [Sol Sol_Explor Sol_Exploit];
    [~,sind] = sort([Sol.Cost]);
    Sol = Sol(sind(1:nSol));
    Best = Sol(1);
    Convergence(Iter) = Best.Cost;
    disp(['Iteration: ' num2str(Iter) ' Best Cost = ' num2str(Best.Cost)]);
end

% Initialize phase statistics
Seq_Cost_Explore(1) = abs(Initial_Best.Cost - Costs_Explor(1));
Seq_Cost_Exploit(1) = abs(Initial_Best.Cost - Costs_Exploit(1));
Seq_Cost_Explore(2) = abs(Costs_Explor(2) - Costs_Explor(1));
Seq_Cost_Exploit(2) = abs(Costs_Exploit(2) - Costs_Exploit(1));
Seq_Cost_Explore(3) = abs(Costs_Explor(3) - Costs_Explor(2));
Seq_Cost_Exploit(3) = abs(Costs_Exploit(3) - Costs_Exploit(2));

for i=1:3
    if Seq_Cost_Explore(i)~=0, PF_F3=[PF_F3,Seq_Cost_Explore(i)]; end
    if Seq_Cost_Exploit(i)~=0, PF_F3=[PF_F3,Seq_Cost_Exploit(i)]; end
end

% Calculate initial scores
F1_Explor = PF(1)*(Seq_Cost_Explore(1)/Seq_Time_Explore(1));
F1_Exploit = PF(1)*(Seq_Cost_Exploit(1)/Seq_Time_Exploit(1));
F2_Explor = PF(2)*((Seq_Cost_Explore(1)+Seq_Cost_Explore(2)+Seq_Cost_Explore(3)) / ...
                  (Seq_Time_Explore(1)+Seq_Time_Explore(2)+Seq_Time_Explore(3)));
F2_Exploit = PF(2)*((Seq_Cost_Exploit(1)+Seq_Cost_Exploit(2)+Seq_Cost_Exploit(3)) / ...
                  (Seq_Time_Exploit(1)+Seq_Time_Exploit(2)+Seq_Time_Exploit(3)));
Score_Explore = (PF(1)*F1_Explor) + (PF(2)*F2_Explor);
Score_Exploit = (PF(1)*F1_Exploit) + (PF(2)*F2_Exploit);

% ============================= EXPERIENCED PHASE ==========================================
for Iter = 4:MaxIter
    global PO_CURRENT_ITER;
    PO_CURRENT_ITER = Iter;
    if Score_Explore > Score_Exploit
        % ------------------ EXPLORATION PHASE ------------------
        SelectFlag = 1;
        Sol = Exploration(Sol,lb,ub,dim,nSol,CostFunction);
        Count_select = UnSelected;
        UnSelected(2) = UnSelected(2)+1; UnSelected(1) = 1;
        F3_Explore = PF(3); F3_Exploit = F3_Exploit+PF(3);
        [~,TBind] = min([Sol.Cost]); TBest = Sol(TBind);
        Seq_Cost_Explore(3)=Seq_Cost_Explore(2);
        Seq_Cost_Explore(2)=Seq_Cost_Explore(1);
        Seq_Cost_Explore(1)=abs(Best.Cost - TBest.Cost);
        if Seq_Cost_Explore(1)~=0, PF_F3=[PF_F3,Seq_Cost_Explore(1)]; end
        if TBest.Cost < Best.Cost, Best = TBest; end

    else
        % ------------------ EXPLOITATION PHASE ------------------
        SelectFlag = 2;
        Sol = Exploitation(Sol,lb,ub,dim,nSol,Best,MaxIter,Iter,CostFunction);

        % ---------- MICRO-PSO LOCAL REFINEMENT (HYBRID ADDITION) ----------
        k_refine = 5;   % top k elites to refine
        L_iter   = 8;   % small number of micro-PSO iterations
        params = struct('w',0.7,'c1',1.5,'c2',1.5,'vmax_scale',0.1);
        try
            Sol = micro_pso_elite(Sol, k_refine, L_iter, lb, ub, CostFunction, params);
        catch ME
            warning('micro_pso_elite failed: %s', ME.message);
        end
        % -----------------------------------------------------------------

        Count_select = UnSelected;
        UnSelected(1)=UnSelected(1)+1; UnSelected(2)=1;
        F3_Explore = F3_Explore+PF(3); F3_Exploit = PF(3);
        [~,TBind] = min([Sol.Cost]); TBest = Sol(TBind);
        Seq_Cost_Exploit(3)=Seq_Cost_Exploit(2);
        Seq_Cost_Exploit(2)=Seq_Cost_Exploit(1);
        Seq_Cost_Exploit(1)=abs(Best.Cost - TBest.Cost);
        if Seq_Cost_Exploit(1)~=0, PF_F3=[PF_F3,Seq_Cost_Exploit(1)]; end
        if TBest.Cost < Best.Cost, Best = TBest; end
    end

    % ----------- UPDATE SCORES & PARAMETERS -----------
    if Flag_Change ~= SelectFlag
        Flag_Change = SelectFlag;
        Seq_Time_Explore(3)=Seq_Time_Explore(2);
        Seq_Time_Explore(2)=Seq_Time_Explore(1);
        Seq_Time_Explore(1)=Count_select(1);
        Seq_Time_Exploit(3)=Seq_Time_Exploit(2);
        Seq_Time_Exploit(2)=Seq_Time_Exploit(1);
        Seq_Time_Exploit(1)=Count_select(2);
    end

    F1_Explor = PF(1)*(Seq_Cost_Explore(1)/Seq_Time_Explore(1));
    F1_Exploit= PF(1)*(Seq_Cost_Exploit(1)/Seq_Time_Exploit(1));
    F2_Explor = PF(2)*((Seq_Cost_Explore(1)+Seq_Cost_Explore(2)+Seq_Cost_Explore(3)) / ...
                      (Seq_Time_Explore(1)+Seq_Time_Explore(2)+Seq_Time_Explore(3)));
    F2_Exploit= PF(2)*((Seq_Cost_Exploit(1)+Seq_Cost_Exploit(2)+Seq_Cost_Exploit(3)) / ...
                      (Seq_Time_Exploit(1)+Seq_Time_Exploit(2)+Seq_Time_Exploit(3)));

    % adaptive scaling
    if Score_Explore < Score_Exploit
       Mega_Explor = max((Mega_Explor-0.01),0.01);
       Mega_Exploit = 0.99;
    elseif Score_Explore > Score_Exploit
       Mega_Explor = 0.99;
       Mega_Exploit = max((Mega_Exploit-0.01),0.01);
    end

    lmn_Explore = 1-Mega_Explor;
    lmn_Exploit = 1-Mega_Exploit;

    Score_Explore = (Mega_Explor*F1_Explor)+(Mega_Explor*F2_Explor)+(lmn_Explore*(min(PF_F3)*F3_Explore));
    Score_Exploit = (Mega_Exploit*F1_Exploit)+(Mega_Exploit*F2_Exploit)+(lmn_Exploit*(min(PF_F3)*F3_Exploit));
    Convergence(Iter) = Best.Cost;
    disp(['Iteration: ' num2str(Iter) ' Best Cost = ' num2str(Best.Cost)]);
    Puma_C = Best.Cost;
    Puma_X = Best.X;
end
end

