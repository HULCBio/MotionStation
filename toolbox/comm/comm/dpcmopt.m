function [predictor, codebook, partition] = dpcmopt(training_set, ord, ini_codebook)
%DPCMOPT Optimize differential pulse code modulation parameters.
%   PREDICTOR = DPCMOPT(TRAINING_SET, ORD) estimates the predictive transfer
%   function using the given order ORD and training set TRAINING_SET.
%
%   [PREDICTOR,CODEBOOK,PARTITION] = DPCMOPT(TRAINING_SET,ORD,LENGTH) returns
%   the corresponding optimized CODEBOOK and PARTITION. LENGTH is an integer
%   that prescribes the length of CODEBOOK.
%
%   [PREDICTOR,CODEBOOK,PARTITION] = DPCMOPT(TRAINING_SET,ORD,INI_CODEBOOK)
%   produces the optimized predictive transfer function PREDICTOR, CODEBOOK,
%   and PARTITION for the DPCM. The input variable INI_CODEBOOK can either be a
%   vector that contains the initial estimated value of the codebook vector or a
%   scalar integer that specifies the vector size of CODEBOOK.
%
%   See also DPCMENCO, DPCMDECO, LLOYDS.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.1 $

training_set = training_set(:);
% compute the correlation vectors ri
len = length(training_set);
if len < ord+3
    error('The size of the training set is not large enough for the design in DPCMOPT.')
end;
for i = 1 : ord+2
    r(i) = training_set(1:len-i+1)' * training_set(i:len) / (len - i);
end;

% Levinson-Durbin Algorithm in finding the coeficient for A(z).
predictor = [1, zeros(1, ord)];
D = r(1);
r = r(:);

for m = 0 : ord-1
    beta = predictor(1:m+1) * r(m+2:-1:2);
    K = -beta/D;
    predictor(2 : m+2) = predictor(2 : m+2) + K * predictor(m+1 : -1 : 1);
    D = (1 - K*K) * D;
end;

% P = 1 - A(z), the FIR filter for the
predictor(1) = 0;
predictor=-predictor;


if nargout > 1
    % continue to find the partition and codebook.
    % calculate the predictive errors:
    for i = ord+1 : len
        err(i-ord) = training_set(i) - predictor * training_set(i:-1:i-ord);
    end;
    % use err for partition and codebook optimization
    [partition, codebook] = lloyds(err, ini_codebook);
end;

% -- end of dpcmopt --

