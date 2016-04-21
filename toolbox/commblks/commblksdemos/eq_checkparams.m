function [emsg, wmsg] = eq_checkparams(block)
% EQ_CHECKPARAMS Checks mask parameters for the Equalizer Demo
% 
% Syntax:
% [emsg, wmsg] = eq_checkparams(block);

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2004/01/26 23:19:48 $

%-- Reset variables
emsg = '';
wmsg = '';

setallfieldvalues(block);

%-- Check parameters
if sum(size(maskMconst))>2 || ~isreal(maskMconst) || ...
        floor(maskMconst) ~= maskMconst || maskMconst<1 || mod(maskMconst,2)~=0
    emsg = ['The number of points in constellation must a positive integer '...
        'scalar greater than 1 and multiple of 2.'];
end

if size(maskChCoeff,1)~=1 || isempty(maskChCoeff)
    emsg = 'The channel coefficients parameter must be a row vector';
end

if sum(size(maskSnrdB))>2 || ~isreal(maskSnrdB)
    emsg = 'The Signal to Noise Ratio (SNR) must be a real number scalar.';
end

if sum(size(maskNumTaps))>2 || ~isreal(maskNumTaps) || ....
        floor(maskNumTaps) ~= maskNumTaps || maskNumTaps<1
    emsg = 'The number of equalizer coefficients must be a positive integer number.';
end

if sum(size(maskStepSize))>2 || ~isreal(maskStepSize) || maskStepSize<0
    emsg = 'The Step-size parameter (Mu) must a positive integer scalar';
end

s = size(maskIcCoeff);
if (s(1)>1 && s(2)>1) || ischar(maskIcCoeff) 
    emsg = 'Initial conditions must be a vector of scalars.';
end

%-- Normalized LMS
if(sum(size(maskNormalBias))>2 || ~isreal(maskNormalBias) || maskNormalBias<0 )
    emsg =['The Phi parameter in the Normalized LMS algorithm must be a' ...
            ' small positive real scalar.'];
end

%-- Variable Step LMS
if sum(size(maskMuParIni))>2 || ~isreal(maskMuParIni) || maskMuParIni<0 
    emsg =['The initial value of the Step size parameter in the Variable Step'...
            ' LMS algorithm must be a positive real scalar.'];
end

if sum(size(maskMuParStep))>2 || ~isreal(maskMuParStep) || maskMuParStep<0
    emsg =['The increment value of the Step size parameter in the Variable Step'...
            ' LMS algorithm must be a small positive real scalar.'];
end

if sum(size(maskMuParMax))>2 || ~isreal(maskMuParMax) || maskMuParMax<0
    emsg =['The maximum value of the Step size parameter in the Variable Step'...
            ' LMS algorithm must be a positive real scalar.'];
end

if sum(size(maskMuParMin))>2 || ~isreal(maskMuParMin) || maskMuParMin<0 
    emsg =['The minimum value of the Step size parameter in the Variable Step' ...
            ' LMS algorithm must be a positive real scalar.'];
end

%-- Leaky LMS
if sum(size(maskLeakage))>2 || ~isreal(maskLeakage) || maskLeakage<0
    emsg =['The Leakage parameter in the Leaky LMS algorithm must be a'...
            ' positive real scalar close to 1.'];
end

%-- RLS
if sum(size(maskIcCorr))>2 || ~isreal(maskIcCorr) || maskIcCorr<0
    emsg =['The initial conditions for the inverese correlation matrix in the RLS'...
            ' algorithm must be a fairly large positive real scalar'];
end

if sum(size(maskLambdaPar))>2 || ~isreal(maskLambdaPar) || maskLambdaPar<0
    emsg =['The Forgetting factor (lambda) parameter in the RLS algorithm must be a'...
            ' positive real scalar close to 1.'];
end

%[end of eq_checkparams.m]
