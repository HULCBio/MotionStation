function [sig, quant] = dpcmdeco(indx, codebook, predictor)
%DPCMDECO Decode using differential pulse code modulation.
%   SIG = DPCMDECO(INDX, CODEBOOK, PREDICTOR) decodes a differential pulse
%   code modulation (DPCM) encoded index signal INDX. The predictive
%   transfer function is provided in PREDICTOR. The predictive-error
%   quantization codebook is given in CODEBOOK. In general, an M-th
%   order transfer function has the form of [0, n1, n2, ... nM]. To
%   obtain a correct decode result, the parameters must match the encode
%   parameters.
%
%   [SIG, QUANT] = DPCMDECO(INDX, CODEBOOK, PREDICTOR) outputs the
%   quantized predictive error in QUANT.
%
%   The input parameters CODEBOOK and PREDICTOR can be estimated by using
%   DPCMOPT.
%
%   See also QUANTIZ, DPCMOPT, DPCMENCO.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.15 $

if nargin < 3
    error('Not enough input variables for DPCMDECO.');
end;

% The structure of the DPCM is as follows:
%             e                   quant
%   INDX   -->------Quantization------+-----------------------|--->sig
%                                     ^                       V
%                                 out |<----Predictor<--------| inp

len_predictor = length(predictor) - 1;
predictor = predictor(2:len_predictor+1);
predictor = predictor(:)';
len_sig = length(indx);

quant = indx;
quant = codebook(indx+1);

x = zeros(len_predictor, 1);
for i = 1 : len_sig;
    out = predictor * x;
    sig(i) = quant(i) + out;
    % renew the estimated output
    x = [sig(i); x(1:len_predictor-1)'];
end;

% -- end of dpcmdeco --
