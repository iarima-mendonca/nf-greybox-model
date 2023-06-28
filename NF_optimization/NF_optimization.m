%% Testing

%Objective: Choose best membrane and pressure, between those analyzed, in
%order to satisfy a set target and minimize costs
%(pressure/energy, membrane area).
%% Input

influent = readmatrix('NF_influent_optimization.xlsx','Sheet',1);

%Insert initial parameters of influent
COD = influent(1,2);    % mg/L
TN =  influent(1,3);    % mg/L
TP =  influent(1,4);    % mg/L
Q =   influent(1,6);    % L/h
eff = 0.70;  % pump efficiency

%% Recovery/removal targets

% Do you want to set removal targets for the pollutants?
% To set removal targets: T = 1, for targets in percentages
%                         T = 2, for targets in effluents concentrations (mg/L)
% Otherwise,
%                         T = 0, for no targets; the script then calculates
%                         the best combination of SR and costs.

T = 1;

% To set a removal target for the pollutants, use variable 'target_PollutantName'
% If the pollutant must be removed: it must be limited as 'above the target'
% If the pollutant must pass the membrane: it must be limited as 'below the target'
% For this, use:
%                 Above the target, then, 'limit_PollutantName' = 1;
%                 Below the target, then, 'limit_PollutantName' = 0;


%COD
target_COD = 0.7; %Value between 0 and 1 OR concentration (mg/L)
limit_COD = 1;
 
%TN
target_TN = 0.4;
limit_TN = 0;
 
%TP
target_TP = 0.8;
limit_TP = 1;

% Is there a target for water recovery?
targetw = 0.7;

              % standart value is 70% of recovery
              % insert percentage of water recovery, between 0 and 1.
              % no target: targetw = 0 (standart value will be used)

%% Graphic results

% Plot graphic results?
p = 1;     % 1 = yes, 0 = no
%% Calculate
% [CODc, TNc, TPc, tmp, A, B, mat, mwco, Areac,Ecostc, Wrecov, Acostc, membranec, Energy, Jwc, CODrej, Nrej, Prej] = ...
% NF_opt_concentration(COD, TN, TP, EC, Q, T, target_COD, limit_COD, target_TN, limit_TN, target_TP, limit_TP, targetw, eff, p);

if T == 0 ||  T == 1

[CODc, TNc, TPc, tmp, A, B, mat, mwco, Areac,Ecostc, Wrecov, Acostc, membranec, Energy, Jwc, CODrej, Nrej, Prej] = ...
NF_opt_removal(COD, TN, TP, Q, T, target_COD, limit_COD, target_TN, limit_TN, target_TP, limit_TP, targetw, eff, p);
    
else
    

[CODc, TNc, TPc, tmp, A, B, mat, mwco, Areac,Ecostc, Wrecov, Acostc, membranec, Energy, Jwc, CODrej, Nrej, Prej] = ...
NF_opt_concentration(COD, TN, TP, Q, T, target_COD, limit_COD, target_TN, limit_TN, target_TP, limit_TP, targetw, eff, p);
end

input_store = [COD TN TP];
results_store = {tmp membranec CODc TNc TPc CODrej Nrej Prej Energy Ecostc Areac Acostc};
    
%% Show results
if isnumeric(tmp)
fprintf('\n The optimized parameters are: TMP = %.2f bar, membrane: %s, A = %.2f',tmp, membranec, A);
fprintf('\n With these conditions the effluent was (mg/L): COD = %.1f , TN = %.1f , TP = %.1f ', CODc, TNc, TPc);
fprintf('\n Salt rejection was: COD = %.1f %% , TN = %.1f %%, TP = %.1f %%', CODrej*(100), Nrej*(100),Prej*(100));
fprintf('\n and water recovery was %.2f %% with a flux of %.2f L/h.m2', (Wrecov*100), Jwc);
fprintf('\n Energy will be %.2f kW costing %.3f Euros/m3 influent',Energy, Ecostc);
fprintf('\n Area will be %.2f m2 costing %.3f Euros/m3 influent',Areac,Acostc);
else
   fprintf('\n No combination possible for targets provided. Please check the set targets'); 
end

