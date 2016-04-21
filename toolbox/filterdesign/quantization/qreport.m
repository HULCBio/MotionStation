function s = qreport(F)
%QREPORT  Quantized report.
%   QREPORT(F) displays a report of the minimum, maximum, number of overflows
%   number of underflows, and number of operations of the most recent
%   application of F, where F is a quantized filter object, quantized FFT
%   object, quantizer object, or a structure of quantization information
%   returned by QFILT/FILTER, QFFT/FFT, or QFFT/IFFT.  If F is a quantized
%   filter object, then one line of information is displayed for each section of
%   the filter.
%
%   If WARNING is ON, then this report is displayed whenever a quantized filter
%   or quantized FFT overflows.
%
%   S = QREPORT(F) returns a MATLAB structure containing the information, and
%   QREPORT(S) displays the report.  MATLAB structure S contains the
%   following fields:
%
%     S.coefficient
%      .input
%      .output
%      .multiplicand
%      .product
%      .sum
%   and each subfield contains:
%                  .max
%                  .min
%                  .nover
%                  .nunder
%                  .noperations
%   For coefficient, multiplicand, product, and sum, the subfields can be indexed
%   into like this:
%     S.coefficient(1:N).max
%     S.coefficient(1:N).min
%     etc.
%
%   Fields S.input and S.output only contain one element.
%
%   Examples:
%       w = warning('on');
%       [b,a] = butter(6,.5);
%       Hq = sos(qfilt('ReferenceCoefficients',{b,a}));
%       y = filter(Hq,randn(50,1));
%       qreport(Hq)
%   % Alternatively:
%       [y,zf,s] = filter(Hq,randn(50,1));
%       qreport(s)
%
%       F = qfft('length',64,'scale',1/64);
%       Y = fft(F,randn(64,1));
%       qreport(F)
%   % Alternatively:
%       [Y,S] = fft(F,randn(64,1));
%       qreport(S)
%       warning(w);
%
%  
%   See also QFILT/QFILT, QFFT/QFFT, QUANTIZER/QUANTIZER.

%   Thomas A. Bryan, 31 August 1999
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/12 23:32:19 $

error(nargchk(1,1,nargin));
error(nargoutchk(0,1,nargout));
switch(class(F))
  case 'qfilt'
    if nargout
      s = get(F,'report');
    else
      qfiltlog(get(F,'report'));
    end
  case 'qfft'
    if nargout
      s = qfftreport(F);
    else
      qfftreport(F);
    end
  case 'struct'
    if nargout
      s = F;
    else
      qfiltlog(F);
    end
  otherwise
    error(['QREPORT not defined for objects of class ',class(F),'.']);
end
