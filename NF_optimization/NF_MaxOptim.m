function [result_max, SR, SRbnd, tmps, Wperm, Bs, flux, fluxbnd, Ecod, Etn, Etp] ...
         = NF_MaxOptim(COD, TN, TP)

%%  Initial calculation

% Calculates flux and pollutant rejection
[flux, fluxbnd, SR, SRbnd, tmps, Wperm, Bs] = Calculate_SR_Flux();

SR1 = SRbnd(:,:,1);
SR2 = SRbnd(:,:,2);
SR3 = SRbnd(:,:,3);

%% Concentration of parameters on effluent (mg/L)

% COD
Ecod = (1-SR1).* COD; 


% TN

Etn = (1-SR2).* TN;

% TP

Etp = (1-SR3).* TP; 


%% Result matrix

% Initialize matrix
result2 = nan(size(flux,1),size(flux,2));

% result is the multiplication of all normalized parameter
for i = 1:size(flux,1)
    for j = 1:size(flux,2)
        result2(i,j) = Ecod(i,j) + Etn(i,j) + Etp(i,j);
    end
end

Rmax = max(result2(:));
Rmin = min(result2(:));
result_max = (result2 - Rmin)/(Rmax - Rmin); % Normalized values

