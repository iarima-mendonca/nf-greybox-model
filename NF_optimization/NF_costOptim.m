function [result_min, Area, Ecost, Wrecov, Acost, E] = NF_costOptim(tmps, Q, eff, targetw, fluxbnd)

%% Cost Calculation

%% Energy
tmpsPa = tmps*100;            % converts bar into kPa
cost = 0.941;                 % euros per kWh
E = (Q/eff)*tmpsPa*(1/(3.6e6)); % kW : Q is converted from L/h to m3/s This is the pump power
Ecost = E*cost;               % euros per h

Ecost = (Ecost/Q)*1000;       %Energy cost per m3 of wastewater

TEmax = max(Ecost(:));
TEmin = min(Ecost(:));
En = (Ecost - TEmin)./(TEmax - TEmin); % Normalized values

%% Membrane

% Membrane area
if targetw ~= 0
    Wrecov = targetw;
else
    Wrecov = 0.7;
end

Pflow = Q*Wrecov;    % permeate flow L/h
Area = 1.15.*Pflow./fluxbnd;  % area in m2 (%15 larger area)

% Membrane cost (Euro/m2)
Mcost = [300 300]; 

% Calculated area "cost" in euros/m3
Acost = zeros(size(Area));
for i = 1:size(Area,1)
    
        Acost(i,:) = ((Area(i,:).*((1/5).*Mcost(i)+ 93))*1000)./(Q*8766);  % polymeric with membrane life of 5 years
                                                                            % 8766 h in 1 year (/8766)                          
                                                                            % Q from L/h to  m3/h (*1000)
%       Acost(i,:) = ((Area(i,:).*((1/5).*Mcost(i)))*1000)./(Q*8766); % costs without investiments
                                                   
end


% TAmax = max(Acost(:));
% TAmin = min(Acost(:));
% An = (Acost - TAmin)./(TAmax - TAmin); % Normalized values

%% Matrix to be minimized

resultcost = nan(size(Area)); % initialize matrix

% for j = 1:size(Area,1)
%     for i = 1:size(Area,2)
%         resultcost(j,i) = An(j,i) + En(i); % sum of the costs
%     end
% end
% 
% Rcmax = max(resultcost(:));
% Rcmin = min(resultcost(:));
% result_min = (resultcost - Rcmin)./(Rcmax - Rcmin); % Normalized values
% result_min = resultcost;

for j = 1:size(Area,1)
    for i = 1:size(Area,2)
        resultcost(j,i) = Acost(j,i) + Ecost(i); % sum of the costs
    end
end

% Rcmax = max(resultcost(:));
% Rcmin = min(resultcost(:));
% result_min = (resultcost - Rcmin)./(Rcmax - Rcmin); % Normalized values

%% Flux instead of area

resultflux_energy = nan(size(fluxbnd)); % initialize matrix

fluxmin = min(fluxbnd(:));
fluxmax = max(fluxbnd(:));
fluxnorm = (fluxbnd - fluxmin)./(fluxmax - fluxmin);

for j = 1:size(Area,1)
    for i = 1:size(Area,2)
        resultflux_energy(j,i) =  En(i)./ fluxnorm(j,i); % sum of the costs
    end
end

result_min = resultcost;


