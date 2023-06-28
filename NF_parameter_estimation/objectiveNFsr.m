
%Uses a sum of squares to minimize erros (difference) between measured
%values and calculates values (with estimated parameters).

function [obj] = objectiveNFsr(p, SR, Flux)

[SRp] = NF_SR(p, Flux); % Simulate model

  obj = sum(((SRp - SR)./SR).^2);

end
