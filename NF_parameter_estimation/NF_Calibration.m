function [coef_store, cal_fit, calset_T] = NF_Calibration(input, t)

%% Initialize matrixes

% Coefficient matrixes
v = size(input,1);

c = cvpartition(v,'Kfold',v);
nFolds = c.NumTestSets;
TestSize = c.TestSize;
TrainSize = c.TrainSize;
x_size = TestSize(1);

coef_store = zeros(nFolds,1);

for n = 1:nFolds
    if n == 1
        calset=input(TestSize(n)+1:v,:);
        
    elseif n == nFolds
        calset=input(1:TrainSize(n),:);
        
    else
        calset=input([1:x_size x_size+TestSize(n)+1:v],:);
        x_size = x_size + TestSize(n);
    end
    
    
    %% Calculate coefficients with the calibration set
    
    if t == 0 % t == 0 means the flux prediction function is used
        
          [coef, cal_fit, calset_T] = Flux_prediction(calset);
          
    % coef = A, if calculating for flux or B if calcutating for pollutant
    % est_cal = flux or SR calculated using the coef estimated
    % calset_T = Flux or SR with temperature correction
  
          coef_store(n,:) = coef;
    
    else % t is not 0 (for SR t==1), the SR prediction function is used.
          [coef, cal_fit, calset_T] = SR_prediction(calset);
          
          coef_store(n,:) = coef;
    end
    

end

