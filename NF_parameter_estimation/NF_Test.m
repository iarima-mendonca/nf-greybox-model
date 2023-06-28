function [data_test, dif_error, TMP_bnd, TMP_store] = NF_Test(input, t, coef, A)

%% Initialize matrixes

TEST = 2; % specifies that this script and data is for validation
% This variable will be used inside of function SR_response by both
% valiation and test functions. Therefore it is used to make a distinction
% among them.

% input(TF,:) = [];
v = size(input,1);   % Amount of different data points

% Validation matrixes
data_real = zeros(1, v);
data_test = zeros(1, v);
TMP_store = zeros(1, v);

if t ~= 0
    TMP_bnd = 0; 
end

for n = 1:v
    
    testset = input(n,:);
    
    %% Calculate results of test set
    
    if t == 0 
       [d_real, d_test, TMP] = Flux_response(testset, coef);
       
       data_real(:,n) = d_real;
       data_test(:,n) = d_test;
       TMP_store(1,n) = TMP;
    else
       [d_real, d_test, TMP] = SR_response(testset, coef, TEST, A);
       
       data_real(:,n) = d_real;
       data_test(:,n) = d_test;
       TMP_store(:,n) = TMP;
    end
end

%% Calculate the percentage error matrix
dif_error = (abs(data_real - data_test));

%% Store values
if t == 0
% TMP constraints
% Read and stores the minimum and maximum TMP tested for each membrane
Upbnd = max(TMP_store);
Lwbnd = min(TMP_store);
TMP_bnd = [Upbnd Lwbnd];

end
