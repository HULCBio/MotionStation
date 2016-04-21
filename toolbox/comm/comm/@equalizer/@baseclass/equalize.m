function [symbolEst, symbolDet, symbolErr] = ...
    equalize(eqObj, inputSig, trainSig);
%EQUALIZE   Equalize a signal with an equalizer object.
%  EQUALIZE is a method for an equalizer object.
%  For more information, type 'help equalize' in MATLAB.

% eqObj must be an equalizer object for this method to be invoked.

%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/20 23:14:57 $

%--------------------------------------------------------------------------
% Check number of arguments; if only two, set trainSig to zero length.
error(nargchk(2, 3, nargin));
if nargin<3, trainSig=[]; end

%--------------------------------------------------------------------------
% Error checking for inputSig and trainSig.

% Check inputSig is numeric.
if isempty(inputSig) || ~isnumeric(inputSig)
    error('comm:equalize:inputSigNumeric', 'INPUTSIG must be numeric.');
end

% Force inputSig to be a column vector.
sizeSig = size(inputSig);
if min(sizeSig) == 1
    nSamples = max(sizeSig);
    inputSig = inputSig(:);
else
    error('comm:equalize:inputSigVector', 'INPUTSIG must be a vector.')
end

% Determine number of symbols to estimate.
nSampPerSym = eqObj.nSampPerSym;
nSymbols = ceil(nSamples/nSampPerSym);

% nSamples must be an integer multiple of nSampPerSym.
if nSymbols*nSampPerSym ~= nSamples
   error('comm:equalize:inputSigLength', ...
       ['Number of elements in INPUTSIG must be an integer multiple of '...
        'EQOBJ.nSampPerSym.']);
end

% Force trainSig to be a column vector.
sizeTrainSig = size(trainSig);
if min(sizeTrainSig)<=1
    nTrain = max(sizeTrainSig);
    trainSig = trainSig(:);
else
    error('comm:equalize:trainSigVector', 'TRAINSIG must be a vector.')
end

% Check trainSig is numeric and shorter than number of output symbols.
if ~isnumeric(trainSig) || nTrain > nSymbols
    error('comm:equalize:trainSigNumeric', ...
          ['TRAINSIG must be numeric vector, '...
            'with length less than or equal to ', ...
            'length(INPUTSIG)/EQOBJ.nSampPerSym.']);
end

% Warn if CMA equalizer is used with training signal.
if eqObj.AdaptAlg.BlindMode & nTrain>0
    warning('comm:equalize:blindmode', ...
        ['Training signal is ignored for constant modulus algorithm.']);
end

%--------------------------------------------------------------------------
[symbolEst, symbolDet, symbolErr] = thisequalize(eqObj, inputSig, trainSig);

if sizeSig(2)>sizeSig(1)
    symbolEst = symbolEst.';
    symbolDet = symbolDet.';
    symbolErr = symbolErr.';
end
    