function [CODc, TNc, TPc, tmp, A, B, mat, mwco, Areac,Ecostc, Wrecov, Acostc, membranec, Energy, Jwc, CODrej, Nrej, Prej] = ...
    NF_opt_concentration(COD, TN, TP, Q, T, target_COD, limit_COD, target_TN, limit_TN, target_TP, limit_TP, ...
    targetw, eff, plotif)

%% Optimization

[result_max, SR, SRbnd, tmps, Wperm, Bs, flux, fluxbnd, Ecod, Etn, Etp] = NF_MaxOptim(COD, TN, TP);
[result_min, Area, Ecost, Wrecov, Acost, E] = NF_costOptim(tmps, Q, eff, targetw, fluxbnd);

%% With recovery target

SRbnd1 = SRbnd(:,:,1);
SRbnd2 = SRbnd(:,:,2);
SRbnd3 = SRbnd(:,:,3);

optim_matrix = NaN(size(Ecod));

if T == 2

%COD
if target_COD == 0
    optim_matrix = result_min;
else
    if limit_COD == 0
        for i = 1:size(Bs,2)
            for j = 1:length(tmps)
                if Ecod(i,j) <= target_COD
                    optim_matrix(i,j) = result_min(i,j);
                else
                    optim_matrix(i,j) = NaN;
                end
            end
        end
    else
        for i = 1:size(Bs,2)
            for j = 1:length(tmps)
                if Ecod(i,j) >= target_COD
                    optim_matrix(i,j) = result_min(i,j);
                else
                    optim_matrix(i,j) = NaN;
                end
            end
        end
                    
    end

end

%TN
if target_TN ~= 0
    if limit_TN == 0
        for i = 1:size(Bs,2)
            for j = 1:length(tmps)
                if Etn(i,j) <= target_TN
                    optim_matrix(i,j) = optim_matrix(i,j);
                else
                    optim_matrix(i,j) = NaN;
                end
            end
        end
    else
        for i = 1:size(Bs,2)
            for j = 1:length(tmps)
                if Etn(i,j) >= target_TN
                    optim_matrix(i,j) = optim_matrix(i,j);
                else
                    optim_matrix(i,j) = NaN;
                end
            end
        end
                    
    end
    
end

%TP
if target_TP ~= 0
    if limit_TP == 0
        for i = 1:size(Bs,2)
            for j = 1:length(tmps)
                if Etp(i,j) <= target_TP
                    optim_matrix(i,j) = optim_matrix(i,j);
                else
                    optim_matrix(i,j) = NaN;
                end
            end
        end
    else
        for i = 1:size(Bs,2)
            for j = 1:length(tmps)
                if Etp(i,j) >= target_TP
                    optim_matrix(i,j) = optim_matrix(i,j);
                else
                    optim_matrix(i,j) = NaN;
                end
            end
        end
                    
    end
    
end

if ~any(~isnan(optim_matrix(:)))
    R = 0; % No results
else
    R = 1;
    optim = min(optim_matrix(:));
    [x,y] = find(optim_matrix==optim);
end

end

%% No recovery target

% Calculates the general best option
if T == 0
result = zeros(size(result_min));
for i = 1:size(result_min,1)
    for j = 1:size(result_min,2)
        result(i,j) = result_max(i,j) - result_min(i,j);
    end
end

optim = max(result(:));
[x,y] = find(result==optim);

R = 1;
end


%% Chosen values

if R ~= 0
Jwc = flux(x,y);
CODc = Ecod(x,y);
TNc = Etn(x,y);
TPc = Etp(x,y);
tmp = tmps(y);
A = Wperm(x);
B(1) = Bs(1,x,1);
B(2) = Bs(1,x,2);
B(3) = Bs(1,x,3);
Areac = Area(x,y);
Ecostc = Ecost(1,y);
Acostc = Acost(x,y);
Energy = E(y);
CODrej = SRbnd1(x,y);
Nrej = SRbnd2(x,y);
Prej = SRbnd3(x,y);

else
  
[Jwc, CODc, TNc, TPc, tmp, A, B, Areac, Ecostc, Acostc, Energy, CODrej, Nrej, Prej] = deal('n.a.');
end

%% Meaning

if R ~= 0
membrane = load('../NF_parameter_estimation/Membranes.mat');
    
mat = membrane.material(x);
mwco = membrane.MWCO(x);
membranec = membrane.names_memb(x);
else
 [mat, mwco, membranec] = deal('n.a.');   
end
    
 

%membrane = {'Membrane', 'A', 'Material', 'MWCO'; 'NF-270', Wperm(1), 'TFC', '200-400 Da';...
%              'NF-90', Wperm(2), 'TFC', '150-300 Da'};
% mat = membrane{(x+1),3};
% mwco = membrane{(x+1),4};
% membranec = membrane{(x+1),1};

%% Graphic results
if R ~= 0
if plotif == 1
Graphics_subplots(Wperm, tmps, result_min, SR, SRbnd, flux, fluxbnd, x, y);
end
end