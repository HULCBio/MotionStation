function [symbolEst, symbolDet, symbolErr] = thisequalize(eqObj, inputSig, trainSig);
%THISEQUALIZE   Equalize a signal with an equalizer object.
%  THISEQUALIZE is a method for an equalizer.lineareq object.
%  For more information, type 'help equalize' in MATLAB.

% Copyright 2003 The MathWorks, Inc.

% Most error checking is inherited from baseclass.

% Note that this function is inherited by the DFE as well.  The key
% difference is the external function eqindices.m, which is overloaded for
% the DFE.

%--------------------------------------------------------------------------
% Extract equalizer object parameters.
alg = eqObj.AdaptAlg;
nWeights = eqObj.AdaptAlg.nWeights;
nSampPerSym = eqObj.nSampPerSym;
sigConst = eqObj.SigConst;
blindMode = eqObj.AdaptAlg.BlindMode;

% Derive signal dimensions.
nSamples = length(inputSig);
nSymbols = ceil(nSamples/nSampPerSym);
nTrain = length(trainSig);
delay = floor(eqObj.RefTap-1)/nSampPerSym;
x = flipud(reshape(inputSig, [nSampPerSym nSymbols]));

% nTrain should be shorter than nSymbols -
% ceil(delay/nSampPerSym), else it will be truncated
if nTrain > nSymbols - delay
    warning('comm:equalize:trainSigLength', ...
          ['TRAINSIG will be truncated to a length equal to '...
           'length(INPUTSIG)- delay, where delay = '...
           '(EQOBJ.RefTap-1)/EQOBJ.nSampPerSym.']);
end

% Initialize symbol estimates and errors.
symbolEst = zeros(nSymbols, 1);    % symbol estimate vector
symbolDet = zeros(nSymbols, 1);    % detected symbols vector
symbolErr = zeros(nSymbols, 1);    % symbol error vector

% Reset channel if required.
if eqObj.ResetBeforeFiltering
    reset(eqObj);
end

% Indices for input buffer, u, and decision sample, d.
% - i1 is the input buffer index for the current input signal sample:
%      u(i1)=sample; see below
% - nn1 and nn2 are input buffer indices used to perform the 
%   sample shifting operation each equalizer iteration: 
%      u(nn2)=u(nn1); see below.
% - id is an "index" into the decision value: 
%      decision_feedback_value=d(id); id=[] for a linear equalizer; 
%      id=1 for DFE.
[i1, nn1, nn2, id] = eqindices(eqObj);

% Initialize input buffer, accounting for reference tap delay.
% Get current equalizer weights.
w = eqObj.Weights';  % Use hermitian transpose for mathematical simplicity. 
u = eqObj.WeightInputs.';

% Constellation-related parameters.
conjConst = conj(sigConst);
constParam = 0.5*real(sigConst.*conjConst);

% Initial decision value (required for compatibility with DFE).
dref = eqObj.dref;

if blindMode
    if var(abs(sigConst))>eps
        warning('comm:equalize:CMAsigconst',...
            ['Signal constellation with non-constant magnitude '...
             'may cause CMA equalizer to be unstable.'])
    end
    % Set CMA constant
    R2 = mean(abs(sigConst).^4)/mean(abs(sigConst).^2);
end

%--------------------------------------------------------------------------
%  Main loop.

for n = 1:nSymbols
    
    u(nn2) = u(nn1);             % shift input signal buffer samples
    u(i1) = [x(:, n); dref(id)]; % current input signal vector
    
    y = w'*u;            % current output symbol (note hermitian transpose)

    % Find closest signal constellation point (detector/slicer).
    [minMetric, idx] = min(constParam - real(y*conjConst));
    d = sigConst(idx);

    % Symbol error for training/blind mode or decision-directed mode.
    if ~blindMode
        m = n - delay;
        if m >= 1 && m <= nTrain
            dref = trainSig(m);  % training mode
        else
            dref = d;  % decision-directed mode
        end
        e = dref - y;
    else
        dref = d;  % required for DFE
        e = y .* (R2 - abs(y).^2); % blind mode (CMA)
    end
    if isinf(e) || isnan(e)
        warning('comm:equalize:error',...
           ['Equalizer unstable. ' ...
            'Try adjusting step size or forgetting factor.']);
    end

    % Update weights until exhausted input samples. The weight update
    % algorithm, update_weights, is a UDD method. That is, the method
    % called will depend on the class of adaptive algorithm object.
    w = update_weights(alg, w, u, e);       

    % Assign outputs and symbol error.
    symbolEst(n) = y;
    symbolDet(n) = d;
    symbolErr(n) = e;
    
end

%--------------------------------------------------------------------------

% Save equalizer weights, weight inputs, and reference sample.
eqObj.Weights = w';  % note hermitian transpose
eqObj.WeightInputs = u.';   % note physical transpose
eqObj.dref = dref;

% Update number of samples processed by equalizer.
eqObj.NumSamplesProcessed = eqObj.NumSamplesProcessed + nSamples;
