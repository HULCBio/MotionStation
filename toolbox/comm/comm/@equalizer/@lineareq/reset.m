function reset(eqObj)
%RESET  Reset equalizer object.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:01:02 $

reset(eqObj.AdaptAlg);
N = eqObj.nWeights;
Lw = sum(N); % Weights vector length
Ls = Lw;  % WeightInputs vector length
eqObj.WeightInputsPrivate = zeros(1, Ls);
if length(eqObj.WeightsPrivate)~=Lw || ~eqObj.AdaptAlg.BlindMode
    eqObj.WeightsPrivate = zeros(1, Lw);
end

% Initialize reference sample.
[minMetric, idx] = min(real(abs(eqObj.sigConst).^2));
eqObj.dref = eqObj.sigConst(idx);

eqObj.NumSamplesProcessed = 0;
