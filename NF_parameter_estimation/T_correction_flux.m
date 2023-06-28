function [Flux_t] = T_correction_flux(TMP, Tset, T, Pflux)


viscosity = readmatrix('T_correction.xlsx','Sheet',1,'Range','A1:B21');
Temp = viscosity(:,1);
m = viscosity(:,2);

x = find(Temp==Tset);
mT = m(x);

%% Flux and EC correction
Flux_t = zeros(size(TMP)); % Initialize matrix

for z = 1:length(TMP)
    y = find(Temp==T(z));
    Flux_t(z) =  Pflux(z)*(m(y)/mT);
end

