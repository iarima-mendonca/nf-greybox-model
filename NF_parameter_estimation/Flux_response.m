function [Flux_data, Flux_val, TMP] = Flux_response(valset, A)

TMP = valset(:,1);         % Transmembrane pressure difference (bar)
Flux_i = valset(:,2);      % Permeate flux (L/m2h). TMP dependent 
T = valset(:,3);           % Temperature (C)

%% Temperature correction

Tset = 25;    %Temperature to be corrected into
[Flux_data] = T_correction_flux(TMP, Tset, T, Flux_i);

%% Flux calculation

% Simulate the system flux output with the calculated values
Flux_val = A * TMP; 


