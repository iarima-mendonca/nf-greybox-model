function [Flux_t, SR_t] = T_correction_SR(Tset, T, Pflux, SR)

viscosity = readmatrix('T_correction.xlsx','Sheet',1,'Range','A1:B21');
Temp = viscosity(:,1);
m = viscosity(:,2);

x = find(Temp==Tset);
mT = m(x);

%% Flux 
Flux_t = zeros(size(Pflux)); % Initialize matrix

% Calculate flux corrected for temperature
for z = 1:length(Pflux)
    y = find(Temp==T(z));
    Flux_t(z) =  Pflux(z)*(m(y)/mT);
end

%% SR correction
SR_t = zeros(size(SR)); % Initialize matrix

% Calculate SR corrected for temperature
for j = 1:length(SR)
    y = find(Temp==T(j));
    SR_t(j) = SR(j)/(m(y)/mT);
end
    
end