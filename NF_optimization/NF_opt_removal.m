function [CODc, TNc, TPc, tmp, A, B, mat, mwco, Areac,Ecostc, Wrecov, Acostc, membranec, Energy, Jwc, CODrej, Nrej, Prej] = ...
    NF_opt_removal(COD, TN, TP, Q, T, target_COD, limit_COD, target_TN, limit_TN, target_TP, limit_TP, ...
    targetw, eff, plotif)

%% Optimization

[result_max, SR, SRbnd, tmps, Wperm, Bs, flux, fluxbnd, Ecod, Etn, Etp] = NF_MaxOptim(COD, TN, TP);
[result_min, Area, Ecost, Wrecov, Acost, E] = NF_costOptim(tmps, Q, eff, targetw, fluxbnd);

%% With recovery target

% Salt rejection
SRbnd1 = SRbnd(:,:,1);
SRbnd2 = SRbnd(:,:,2);
SRbnd3 = SRbnd(:,:,3);

optim_matrix = zeros(size(SRbnd1));

if T == 1

%COD
if target_COD ~= 0
    if limit_COD == 0
        for i = 1:size(Bs,2)
            for j = 1:length(tmps)
                if SRbnd1(i,j) <= target_COD
                    optim_matrix(i,j) = result_min(i,j);
                else
                    optim_matrix(i,j) = NaN;
                end
            end
        end
    else
        for i = 1:size(Bs,2)
            for j = 1:length(tmps)
                if SRbnd1(i,j) >= target_COD
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
                if SRbnd2(i,j) <= target_TN
                    if target_COD ~= 0
                    optim_matrix(i,j) = optim_matrix(i,j);
                    else
                    optim_matrix(i,j) = result_min(i,j);  
                    end
                else
                    optim_matrix(i,j) = NaN;
                end
            end
        end
    else
        for i = 1:size(Bs,2)
            for j = 1:length(tmps)
                if SRbnd2(i,j) >= target_TN
                    if target_COD ~= 0
                    optim_matrix(i,j) = optim_matrix(i,j);
                    else
                    optim_matrix(i,j) = result_min(i,j);  
                    end
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
                if SRbnd3(i,j) <= target_TP
                    if target_COD == 0 && target_TN == 0
                    optim_matrix(i,j) = result_min(i,j);
                    else
                    optim_matrix(i,j) = optim_matrix(i,j);
                    end
                else
                    optim_matrix(i,j) = NaN;
                end
            end
        end
    else
        for i = 1:size(Bs,2)
            for j = 1:length(tmps)
                if SRbnd3(i,j) >= target_TP
                    if target_COD == 0 && target_TN == 0
                    optim_matrix(i,j) = result_min(i,j);
                    else
                    optim_matrix(i,j) = optim_matrix(i,j);
                    end
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
    
Rmax = max(result_min(:));
Rmin = min(result_min(:));
result_min_n = (result_min - Rmin)/(Rmax - Rmin); % Normalized values
result = zeros(size(result_min_n));

for i = 1:size(result_min_n,1)
    for j = 1:size(result_min_n,2)
        result(i,j) = result_max(i,j) + result_min_n(i,j);
    end
end

optim = min(result(:));
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
  
[Jwc, CODc, TNc, TPc, tmp, A, B, Areac, Ecostc, Acostc, Energy, CODrej, Nrej, Prej] = deal([]);
end

%% Meaning

if R ~= 0
membrane = load('../NF_parameter_estimation/Membranes.mat');
    
mat = membrane.material(x);
mwco = membrane.MWCO(x);
membranec = membrane.names_memb(x);
else
 [mat, mwco, membranec] = deal([]);   
end
    

%membrane = {'Membrane', 'A', 'Material', 'MWCO'; 'NF-270', Wperm(1), 'TFC', '200-400 Da';...
%              'NF-90', Wperm(2), 'TFC', '150-300 Da'};
% mat = membrane{(x+1),3};
% mwco = membrane{(x+1),4};
% membranec = membrane{(x+1),1};

%% Graphic results

if plotif == 1
Graphics_subplots(Wperm, tmps, result_min, SR, SRbnd, flux, fluxbnd, x, y);
end