function varargout = quantizer(F,varargin)
%QUANTIZER  Return Qfilt quantizers.
%   [QCOEFF,QINPUT,QOUTPUT,QMULTIPLICAND,QPRODUCT,QSUM] = QUANTIZER(Hq) returns the
%   coefficient, input, output, product, and sum quantizers associated with
%   QFILT object Hq.
%
%   Q = QUANTIZER(Hq,F) returns the quantizer determined by format F where F is
%   a string whose value can be one of 'coefficient','input', 'output',
%   'multiplicand', 'product', 'sum'. 
%
%   [Q1,Q2,...] = QUANTIZER(Hq,F1,F2,...) returns multiple quantizers
%   determined by formats F1, F2, etc.
%
%   Example:
%     Hq = qfilt;
%     q = quantizer(Hq,'coefficient')
%
%   See also QFILT.

%   Thomas A. Bryan 22 June 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.15 $  $Date: 2002/04/14 15:29:07 $

validnames = {'coefficient','input','output', 'multiplicand','product','sum'};
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
    error('Quantizer type must be a character string');
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
    error([name,' is not a valid Quantizer type.']);
  end
end
