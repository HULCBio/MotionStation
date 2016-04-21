function [indx, quant] = dpcmenco(sig, codebook, partition, predictor)
%DPCMENCO Encode using differential pulse code modulation.
%   INDX = DPCMENCO(SIG, CODEBOOK, PARTITION, PREDICTOR) produces differential
%   pulse code modulation (DPCM) encoded index INDX. The signal to be encoded is
%   SIG. The predictive transfer function is provided in PREDICTOR. The
%   predictive-error quantization partition and code book are given in PARTITION
%   and CODEBOOK respectively. In general, an M-th order transfer function
%   numerator has the form of [0, n1, n2, ... nM].
%
%   [INDX, QUANT] = DPCMENCO(SIG, CODEBOOK, PARTITION, PREDICTOR) outputs the
%   quantized value in QUANT.
%
%   The input parameters CODEBOOK, PARTITION, and PREDICTOR can be estimated
%   by using DPCMOPT.
%
%   See also QUANTIZ, DPCMOPT, DPCMDECO.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.14 $

if nargin < 4
    error('Not enough input variables for DPCMENCO.');
end;

if (length(codebook)-1) ~= length(partition)
    error('The vector size for PARTITION must be the size of CODEBOOK -1.');
end;

if length(predictor) < 2
    error('The vector size for PREDICTOR must be more than 1.');
end;

% The structure of the DPCM is as follows:
%                       e                   quant
%   Input signal   -->+-----Quantization------|-------
%                     ^-                      V
%                     |---------------------->+
%                 out |<----Predictor<--------| inp

len_predictor = length(predictor) - 1;
predictor = predictor(2:len_predictor+1);
predictor = predictor(:)';
len_sig = length(sig);

x = zeros(len_predictor, 1);
for i = 1 : len_sig;
    out = predictor * x;
    e = sig(i) - out;
    % index
    indx(i) = sum(partition < e);
    % quantized value
    quant(i) = codebook(indx(i) + 1);
    inp = quant(i) + out;
    % renew the estimated output
    x = [inp; x(1:len_predictor-1)'];
end;

% -- end of dpcmenco --
