function tutdpcm
%TUTDPCM Shows a source coding example.
%
%WARNING: This is an obsolete function and may be removed in the future.

%       This function is called by COMMHELP.HTML.
%
%       See also HMODEM.

%       Wes Wang 11/20/95.
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.13 $

figure
t = [0:.1:40];
sig = sin(t);
[p_tran,codebook,partition]=dpcmopt(sig,1,8);
indx = dpcmenco(sig, codebook,partition,p_tran);
quant = dpcmdeco(indx, codebook, p_tran);
subplot(211);plot(t,indx);
title('Quantized digital output.');
subplot(212);plot(t,[sig;quant]');
title('Quantization recovery vs. original signal.');

%---end of tutdpcm---
