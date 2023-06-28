function [SR_data, SR_val, TMP] = SR_response(valset, B_SR, check, A)

TMP = valset(:,1);     
Flux_i = valset(:,2);      % Permeate flux (L/m2h). TMP dependent 
SR_i = valset(:,3);        % Salt (pollutant) rejection 
T = valset(:,4);           % Temperature (C)

%% Temperature correction
Tset = 25;    %Temperature to be corrected into

%Corrects flux and salt rejection to temperature Tset
[Flux_data, SR_data] = T_correction_SR(Tset, T, Flux_i, SR_i); 
    
if check == 1 % variable check is used to make a distinction between validation
                % and test, as this function SR_response is used by both.
                % check == 1: validation set
                % check == 2: test set
    %% SR calculation for validation set
    SR_val = NF_SR(B_SR, Flux_data);

else
    %% SR calculation for test set
    Flux_pred = TMP .* A;
    SR_val = NF_SR(B_SR, Flux_pred);
end


