function [data_real, data_val, diff_error] = NF_Validation(input, t, coef)

%% Initialize matrixes

VAL = 1; % specifies that this script and data is for validation
% This variable will be used inside of function SR_response by both
% valiation and test functions. Therefore it is used to make a distinction
% among them.

v = size(input,1);

% Validation matrixes
data_real = zeros(1, v);
data_val = zeros(1, v); 

c = cvpartition(v,'Kfold',v);
nFolds = c.NumTestSets;
TestSize = c.TestSize;
TrainSize = c.TrainSize;
x_size = TestSize(1);

 % Calculate results of validation set
for n = 1:nFolds
   if n == 1
      valset = input(1:TestSize(n),:);
          if t == 0 
       [d_real, d_val, ~] = Flux_response(valset, coef(n,:));
       
       data_real(:,1:TestSize(n)) = d_real';
       data_val(:,1:TestSize(n)) = d_val'; 

          else
       [d_real, d_val, ~] = SR_response(valset, coef(n), VAL);
       
       data_real(:,1:TestSize(n)) = d_real';
       data_val(:,1:TestSize(n)) = d_val'; 
       
          end
          
   elseif n == nFolds
      valset = input(TrainSize(n)+1:v,:); 
      
           if t == 0 
       [d_real, d_val, ~] = Flux_response(valset, coef(n,:));
       
       data_real(:,TrainSize(n)+1:v) = d_real';
       data_val(:,TrainSize(n)+1:v) = d_val'; 

          else
       [d_real, d_val, ~] = SR_response(valset, coef(n), VAL);
       
       data_real(:,TrainSize(n)+1:v) = d_real';
       data_val(:,TrainSize(n)+1:v) = d_val'; 
       
          end
   else
      valset = input(x_size+1 : x_size + TestSize(n),:);  
      
           if t == 0 
       [d_real, d_val, ~] = Flux_response(valset, coef(n,:));
       
       data_real(:,x_size+1 : x_size + TestSize(n)) = d_real';
       data_val(:,x_size+1 : x_size + TestSize(n)) = d_val'; 
       x_size = x_size + TestSize(n);
       
          else
       [d_real, d_val, ~] = SR_response(valset, coef(n), VAL);
       
       data_real(:,x_size+1 : x_size + TestSize(n)) = d_real';
       data_val(:,x_size+1 : x_size + TestSize(n)) = d_val'; 
       x_size = x_size + TestSize(n);
       
          end
   end

  

end



%% Calculate the percentage error matrix
diff_error = (abs(data_real - data_val));

