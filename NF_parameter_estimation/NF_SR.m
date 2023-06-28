
% Calculates SR for the estimated parameters.

function [SR_est] = NF_SR(p_SR, Flux)


% Inicialize output matrix
SR_est = zeros(size(Flux)); % Estimated salt rejection
    
for j = 1:length(Flux)
    SR_est(j) = 1 ./ (1 + (p_SR/Flux(j)));
end

end