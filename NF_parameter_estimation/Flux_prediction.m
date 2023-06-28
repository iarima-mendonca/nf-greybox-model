

function [A, Flux_fit, Flux] = Flux_prediction(calset)
TMP = calset(:,1);         % Transmembrane pressure difference (bar)
Flux_i = calset(:,2);     % Permeate flux (L/m2h). TMP dependent 
T = calset(:,3);           % Temperature (C)


%% TMP constraints
% Read and stores the minimum and maximum TMP tested for each membrane
% Upbnd(i) = max(TMP);
% Lwbnd(i) = min(TMP);

%% Temperature correction

Tset = 25;    %Temperature to be corrected into
[Flux] = T_correction_flux(TMP, Tset, T, Flux_i);

%% Flux parameters calculation

% Linear fiting  
A = TMP(:)\Flux(:);

% % Simulate the system flux output with the calculated values
Flux_fit = A*TMP; 


end