
%% Data preparation

% Insert number and name of membranes being analyzed
n_memb = 2; 
names_memb = ["NF270" ; "NF90"];
material = ["TFC"; "TFC"];
MWCO = ["150-300"; "200-400"];

% Insert operational parameters
Flux_max = [185.6; 86.8];  % maximum flux for each membrane
TMP_max = [20; 20];        % maximum TMP for each membrane
A_factor  = [Flux_max(1)/TMP_max(1), Flux_max(2)/TMP_max(2)]; %used to re-scale data

for i = 1:n_memb
%% Prepare data
%Load measured data

if i == 1 % First membrane
input_flux = readmatrix('NF_270_norm.xlsx','Sheet',1);
input_COD = readmatrix('NF_270_norm.xlsx','Sheet',2);
input_N = readmatrix('NF_270_norm.xlsx','Sheet',3);
input_P = readmatrix('NF_270_norm.xlsx','Sheet',4);
end

if i == 2 % Second membrane
input_flux = readmatrix('NF_90_norm.xlsx','Sheet',1);
input_COD = readmatrix('NF_90_norm.xlsx','Sheet',2);
input_N = readmatrix('NF_90_norm.xlsx','Sheet',3);
input_P = readmatrix('NF_90_norm.xlsx','Sheet',4);
end

%% Initialize storage vectors

if i == 1    % Initialize only on the first loop
    
    % coefficients
A_store = zeros(n_memb, 2);
B_SR_store = zeros(n_memb, 6);

    % operational parameters
TMP_bnd_store = zeros( n_memb, 2);
EC_store = zeros(n_memb, 1);
TMP_store = cell(2,4);

    % literature data
Flux_data_store = cell(1,n_memb);
COD_data_store = cell(1,n_memb);
N_data_store = cell(1,n_memb);
P_data_store = cell(1,n_memb);

    % estimated results
Flux_test_store = cell(1,n_memb);
Flux_train_store = cell(1,n_memb);
COD_test_store = cell(1,n_memb);
N_test_store = cell(1,n_memb);
P_test_store = cell(1,n_memb);
end

%% Calculate calibration values

% Separates flux and SR into two diff. categories
F = 0;
Srej = 1;

[A, ~, ~] = NF_Calibration(input_flux, F);
[B_COD, ~, ~] = NF_Calibration(input_COD, Srej);
[B_N, ~, ~] = NF_Calibration(input_N, Srej);
[B_P, ~, ~] = NF_Calibration(input_P, Srej);

%% Calculate validation results and percentual erros


[Flux_data, Flux_val, Flux_val_error_N] = NF_Validation(input_flux, F, A);
[COD_data, COD_val, COD_error] = NF_Validation(input_COD, Srej, B_COD);
[N_data, N_val, N_error] = NF_Validation(input_N, Srej, B_N);
[P_data, P_val, P_error] = NF_Validation(input_P, Srej, B_P);

% Store values corrected for temperature
Flux_data_store{1,i} = Flux_data .* Flux_max(i,1);
Flux_train_store{1,i} = Flux_val .* Flux_max(i,1);

Flux_val_error = Flux_val_error_N .* Flux_max(i,1);

COD_data_store{1,i} = COD_data;
N_data_store{1,i}  = N_data;
P_data_store{1,i}  = P_data;


%% Boxplot the results and identifies outliers

% A 

figure
boxchart(A.* A_factor(1,i))
ylabel('Water permeability')
legend('A')
title(names_memb(i))


% B values for COD, N and P

 figure
 title(names_memb(i))
 subplot(1,3,1)
 boxchart(B_COD .* Flux_max(i,1))
 ylabel('Permeability')
 legend('B(COD)')
 
 subplot(1,3,2)
 boxchart(B_N .* Flux_max(i,1))
 title('Pollutants Permeability - Boxchart '+ names_memb(i))
 legend('B(N)')
 
 subplot(1,3,3)
 boxchart(B_P .* Flux_max(i,1))
 legend('B(P)')
 

%% Mean values and standart deviation

A_mean = mean(A);           % A mean values
A_std = std(A);             % A standart deviation

B_COD_mean = mean(B_COD);       % B (COD) mean value
B_COD_std = std(B_COD);         % B (COD) standart deviation

B_N_mean = mean(B_N);           % B (Nitrogen) mean value
B_N_std = std(B_N);             % B (Nitrogen) standart deviation

B_P_mean = mean(B_P);           % B (Phosphorus) mean value
B_P_std = std(B_P);             % B (Phosphorus) standart deviation

% Store coeficient values
A_store(i,:) = [A_mean A_std];
B_SR_store(i,:) = [B_COD_mean B_COD_std B_N_mean B_N_std B_P_mean B_P_std ];

%% Test with the calculated parameters (the average values)

[Flux_test, Flux_test_error_N, TMP_bnd, TMP1] = NF_Test(input_flux, F, A_mean);
[COD_test, COD_test_error, ~, TMP2] = NF_Test(input_COD, Srej, B_COD_mean, A_mean);
[N_test, N_test_error, ~, TMP3] = NF_Test(input_N, Srej, B_N_mean, A_mean);
[P_test, P_test_error, ~, TMP4] = NF_Test(input_P, Srej, B_P_mean, A_mean);


%  Store operational values (TMP bounds, EC rejection and NDP)
TMP_bnd_store(i,:) = TMP_bnd .* TMP_max(i,1);
TMP_store{i,1} = TMP1 .* TMP_max(i,1);
TMP_store{i,2} = TMP2 .* TMP_max(i,1);
TMP_store{i,3} = TMP3 .* TMP_max(i,1);
TMP_store{i,4} = TMP4 .* TMP_max(i,1);

% Re-calculate A and Bs
A_store(i,:) = A_store(i,:) .* A_factor(1,i);
B_SR_store(i,:) = B_SR_store(i,:) .* Flux_max(i,1);

% Re-scale flux error
Flux_test_error = Flux_test_error_N .* Flux_max(i,1);

% Store estimated results
Flux_test_store{1,i} = Flux_test .* Flux_max(i,1);
COD_test_store{1,i} = COD_test;
N_test_store{1,i}  = N_test;
P_test_store{1,i}  = P_test;

 %% Write results in Excel file
 
 % Flux 
 % Flux - Input
 writematrix(TMP_store{i,1}','NF_estimation.xlsx','Sheet',i,'Range','A4')
 writematrix(Flux_data_store{1,i}','NF_estimation.xlsx','Sheet',i,'Range','B4');
 
 % Flux - cross validation
 writematrix(Flux_train_store{1,i}','NF_estimation.xlsx','Sheet',i,'Range','C4');
 writematrix(Flux_val_error','NF_estimation.xlsx','Sheet',i,'Range','D4');
 writematrix(A,'NF_estimation.xlsx','Sheet',i+2,'Range','A3');
 
 % Flux - testing
 writematrix(Flux_test_store{1,i}','NF_estimation.xlsx','Sheet',i,'Range','F4');
 writematrix(Flux_test_error','NF_estimation.xlsx','Sheet',i,'Range','G4');
 
 % COD
 % COD - Input
  writematrix(TMP_store{i,2}','NF_estimation.xlsx','Sheet',i,'Range','I4')
  writematrix(COD_data','NF_estimation.xlsx','Sheet',i,'Range','J4');
  
 % COD - cross validation
 writematrix(COD_val','NF_estimation.xlsx','Sheet',i,'Range','K4');
 writematrix(COD_error','NF_estimation.xlsx','Sheet',i,'Range','L4');
 writematrix(B_COD,'NF_estimation.xlsx','Sheet',i+2,'Range','B3');

 
 % COD - testing
 writematrix(COD_test','NF_estimation.xlsx','Sheet',i,'Range','N4');
 writematrix(COD_test_error','NF_estimation.xlsx','Sheet',i,'Range','O4');
 
 % TN
 % TN - Input 
 writematrix(TMP_store{i,3}','NF_estimation.xlsx','Sheet',i,'Range','Q4');
 writematrix(N_data','NF_estimation.xlsx','Sheet',i,'Range','R4');
 
 % TN - cross validation
 writematrix(N_val','NF_estimation.xlsx','Sheet',i,'Range','S4');
 writematrix(N_error','NF_estimation.xlsx','Sheet',i,'Range','T4');
 writematrix(B_N,'NF_estimation.xlsx','Sheet',i+2,'Range','C3');
 
 % TN - testing
 writematrix(N_test','NF_estimation.xlsx','Sheet',i,'Range','V4');
 writematrix(N_test_error','NF_estimation.xlsx','Sheet',i,'Range','W4');

 % TP
 % TP - Input
 writematrix(TMP_store{i,4}','NF_estimation.xlsx','Sheet',i,'Range','Y4');
 writematrix(P_data','NF_estimation.xlsx','Sheet',i,'Range','Z4');
 
 % TP - cross validation
 writematrix(P_val','NF_estimation.xlsx','Sheet',i,'Range','AA4');
 writematrix(P_error','NF_estimation.xlsx','Sheet',i,'Range','AB4');
 writematrix(B_P,'NF_estimation.xlsx','Sheet',i+2,'Range','D3');

 
 % TP - testing
 writematrix(P_test','NF_estimation.xlsx','Sheet',i,'Range','AD4');
 writematrix(P_test_error','NF_estimation.xlsx','Sheet',i,'Range','AE4');

 end

%% Save average and std on excel
 % Coefficients
 writematrix(A_store,'NF_estimation.xlsx','Sheet',5,'Range','B3');
 writematrix(B_SR_store,'NF_estimation.xlsx','Sheet',5,'Range','D3');

%% Validation plots
%  
 %NF-270
 figure
 subplot(4,1,1)
 plot(TMP_store{1,1},Flux_data_store{1,1},'ko')
 hold on
 plot(TMP_store{1,1}, Flux_test_store{1,1},'*','Color','#0072BD')
 hold off
 ylabel('J (L/{m}^2.h)')
 axis padded
 ylim([0 200])
 title('NF270')
 
 subplot(4,1,2)
 plot(TMP_store{1,2},COD_data_store{1,1}*100,'ko')
 hold on
 plot(TMP_store{1,2},COD_test_store{1,1}*100, '*','Color','#0072BD')
 hold off
 ylabel('SR COD (%)')
 axis padded
 ylim([0 100])

 subplot(4,1,3)
 plot(TMP_store{1,3},N_data_store{1,1}*100,'ko')
 hold on
 plot(TMP_store{1,3},N_test_store{1,1}*100, '*','Color','#0072BD')
 hold off
 ylabel('SR TN (%)')
 axis padded
 ylim([0 100])
 
 subplot(4,1,4)
 plot(TMP_store{1,4},P_data_store{1,1}*100,'ko')
 hold on
 plot(TMP_store{1,4},P_test_store{1,1}*100, '*','Color','#0072BD')
 hold off
 ylabel('SR TP (%)')
 axis padded
 ylim([0 100])
 xlabel('TMP (bar)')
 legend('Data', 'Predicted', 'Location', 'best')

 %NF-90
 figure
 subplot(4,1,1)
 plot(TMP_store{2,1},Flux_data_store{1,2},'ko')
 hold on
 plot(TMP_store{2,1}, Flux_test_store{1,2},'*','Color', '#D95319')
 hold off
 ylabel('J (L/{m}^2.h)')
 axis padded
 ylim([0 200])
 title('NF90')
 
 subplot(4,1,2)
 plot(TMP_store{2,2},COD_data_store{1,2}*100,'ko')
 hold on
 plot(TMP_store{2,2},COD_test_store{1,2}*100, '*','Color', '#D95319')
 hold off
 ylabel('SR COD (%)')
 axis padded
 ylim([0 100])

 subplot(4,1,3)
 plot(TMP_store{2,3},N_data_store{1,2}*100,'ko')
 hold on
 plot(TMP_store{2,3},N_test_store{1,2}*100, '*','Color', '#D95319')
 hold off
 ylabel('SR TN (%)')
 axis padded
 ylim([0 100])
 
 subplot(4,1,4)
 plot(TMP_store{2,4},P_data_store{1,2}*100,'ko')
 hold on
 plot(TMP_store{2,4},P_test_store{1,2}*100, '*','Color', '#D95319')
 hold off
 ylabel('SR TP (%)')
 axis padded
 ylim([0 100])
 xlabel('TMP (bar)')
 legend('Data', 'Predicted', 'Location', 'best')

%% Write results in a MATLAB structure

% Save parameters in a MATLAB file for use in the optimization script
save('p_values.mat','names_memb', 'A_store','B_SR_store');

% Save TMP constraint values for use in the optimization script
save('TMP_bounds.mat','TMP_bnd_store');

% Save membranes characteristics
save('Membranes.mat', 'names_memb', 'material', 'MWCO');