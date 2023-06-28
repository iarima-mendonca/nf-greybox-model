

function [p_SR, SR_est, SR] = SR_prediction(calset)
Flux_i = calset(:,2);      % Permeate flux (L/m2h). TMP dependent 
SR_i = calset(:,3);        % Salt (pollutant) rejection 
T = calset(:,4);           % Temperature (C)

%% TMP constraints
% Read and stores the minimum and maximum TMP tested for each membrane
% Upbnd(i) = max(TMP);
% Lwbnd(i) = min(TMP);

%% Temperature correction

Tset = 25;    %Temperature to be corrected into
[Flux, SR] = T_correction_SR(Tset, T, Flux_i, SR_i);

%% Initial guess

% SR Parameters
B = 1;  % Salt permeability (L/m2h)

% Parameters vector
p_SR = B;

%% SR parameters estimation

% Minimization / parameter estimation
fh = @(p_SR)objectiveNFsr(p_SR, SR, Flux); % Function handle for objective
[p_SR,~] = fminsearch(fh,p_SR);            % Finds p (parameter vector) that minimizes the error

[SR_est] = NF_SR(p_SR, Flux);
end