
 function [flux, fluxbnd, SR, SRbnd, tmps, Wperm, B] = Calculate_SR_Flux()
%% Constraint definitions
% Constraints were defined as 20% up and down of the known interval

% Constraint for the TMP tested range
TMP_bounds = load('../NF_parameter_estimation/TMP_bounds.mat');   % Load storage file
Upbnd = 1.2 .* TMP_bounds.TMP_bnd_store(:,1);
Lwbnd = 0.8 .* TMP_bounds.TMP_bnd_store(:,2);
tmps = linspace(1,max(Upbnd),max(Upbnd));
%% Known parameters

p_values = load('../NF_parameter_estimation/p_values.mat'); % Load storage file

% Flux
A = p_values.A_store;

Wperm = A(:,1)';

% Pollutants
B_SR = p_values.B_SR_store;

B = zeros(1,size(B_SR,1),3);
%COD
B(:,:,1) = B_SR(:,1)'; 

%TN
B(:,:,2) = B_SR(:,3)'; 

%TP
B(:,:,3) = B_SR(:,5)'; 

n = length(B(1,1,:)); % Amount of different membranes/Permeability values

%% Calculate results

%% Flux

% Initialize flux matrix
fluxbnd = nan(length(Wperm),length(tmps));
flux = nan(length(Wperm),length(tmps));

for i = 4:length(tmps)
    for j = 1:length(Wperm)
        
        flux(j,i) = Wperm(j)*tmps(i);
  
        if tmps(i) <= Upbnd(j) && tmps(i) >= Lwbnd(j)
            
        fluxbnd(j,i) = flux(j,i);
      
        else
            
        fluxbnd(j,i) = NaN;
     
        end
        if flux (j,i) < 0
            
            flux(j,i) = NaN;
            fluxbnd(j,i) = NaN;
            
        end
    end
end

%% Salt Rejection

%Initialize matrix
SR = nan(length(Wperm),length(tmps),length(n));
SRbnd = nan(length(Wperm),length(tmps),length(n));

for i = 1:length(tmps)
    for j = 1:length(Wperm)
        for z = 1:n
            SR(j,i,z) = 1/(1+(B(1,j,z))/flux(j,i));
            SRbnd(j,i,z) = 1/(1+(B(1,j,z))/fluxbnd(j,i));
        end
    end
end
