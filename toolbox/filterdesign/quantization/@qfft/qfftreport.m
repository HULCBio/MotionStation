function s1 = qfftreport(F)
%QFFTREPORT  Display QFFT quantization information.
%
%   This function is a support function for QREPORT.  Use QREPORT
%   instead. 
%
%   See also QREPORT.

%   QFFTREPORT(F) where F is a QFFT object displays the quantized FFT log data from
%   the most recent call to FFT or IFFT.
%
%   S = QFFTREPORT(F) returns a structure containing the log data.
%
%   Example:
%     warning off
%     F = qfft('mode','fixed','length',64,'scalevalues',0.5*[1 1 1 1 1 1]);
%     x = cos(2*pi*.2*(0:63));
%     y = fft(F,x);
%     qfftreport(F)
%
%   See also QFFT, QFFT/FFT, QFFT/IFFT.

%   Thomas A. Bryan, 28 June 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.17 $  $Date: 2002/04/14 15:27:10 $

if nargout==0
  fprintf('%12s%15s%15s%15s%15s%15s\n',' ','Max','Min','NOverflows',...
      'NUnderflows', 'NOperations') 
end

s.coefficient  = report(F,'Coefficient',nargout);
s.input        = report(F,'Input',nargout);
s.output       = report(F,'Output',nargout);
s.multiplicand = report(F,'Multiplicand',nargout);
s.product      = report(F,'Product',nargout);
s.sum          = report(F,'Sum',nargout);

if nargout==1
  s1=s;
end

function s=report(F,name,displayflag)
q = quantizer(F,name);
s.max = q.max;
s.min = q.min;
s.nover = q.nover;
s.nunder = q.nunder;
s.noperations = q.noperations;
if displayflag==0
%  fprintf('%s\n',name)
  if ischar(s.min)
    % quantizers were reset
    fprintf('%12s%15s%15s%15.10g%15.10g%15.10g',name, s.max, s.min, ...
        s.nover, s.nunder, s.noperations)
  else
    fprintf('%12s%15.4g%15.4g%15.10g%15.10g%15.10g',name, s.max, s.min, ...
        s.nover, s.nunder, s.noperations) 
  end
  fprintf('\n')
end
