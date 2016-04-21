function varargout = quantizer(F,varargin)
%QUANTIZER  Return QFFT quantizers.
%   [QCOEFF,QINPUT,QOUTPUT,QMULTIPLICAND,QPRODUCT,QSUM] = QUANTIZER(F) returns the
%   coefficient, input, output, product, and sum quantizers associated with
%   QFFT object F.
%
%   Q = QUANTIZER(F,T) returns the quantizer determined by format T where T is
%   a string whose value can be one of 'coefficient','input', 'output',
%   'multiplicand', 'product', 'sum'. 
%
%   [Q1, Q2, ...] = QUANTIZER(F, T1, T2, ...) returns quantizers
%   associated with strings T1, T2, ....
%
%   Example:
%     F = qfft;
%     q = quantizer(F,'coefficient')
%   returns the default coefficient quantizer object.
%
%   See also QFFT, QUANTIZER, UNITQUANTIZER.

%   Thomas A. Bryan, 13 June 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 2002/04/14 15:26:25 $

validnames = {'coefficient','input','output','multiplicand','product','sum'};
if nargin<2
  names = validnames;
else
  names = varargin;
end
if nargout > length(names)
  error('Too many output arguments.')
end
names = {names{1:max(1,nargout)}};

for k=1:length(names)
  name = lower(names{k});
  if ~ischar(name)
    error('QUANTIZER type must be a character string');
  end
  ind = strmatch(name,names);
  if length(ind)==1
    name = names{ind};
  end
  switch lower(name)
  case 'coefficient'
    varargout{k} = F.coefficientformat;
  case 'input'
    varargout{k} = F.inputformat;
  case 'output'
    varargout{k} = F.outputformat;
  case 'multiplicand'
    varargout{k} = F.multiplicandformat;
  case 'product'
    varargout{k} = F.productformat;
  case 'sum'
    varargout{k} = F.sumformat;
  otherwise
    error([name,' is not a valid QUANTIZER type.']);
  end
end
