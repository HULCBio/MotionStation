function varargout = copyobj(varargin)
%COPYOBJ  Copy QFILT object.
%   Hq1 = COPYOBJ(Hq) makes a copy of QFILT object Hq and returns it in QFILT
%   object Hq1.
%
%   [Hq1,Hq2,...] = COPYOBJ(Hqa,Hqb,...) copies Hqa into Hq1, Hqb into Hq2, etc.
%
%   [Hq1,Hq2,...] = COPYOBJ(Hq) makes multiple copies of the same object.
%
%   Example:
%     Hq = qfilt('CoefficientFormat',[8 7]);
%     Hq1 = copyobj(Hq)
%
%   See also QFILT.

%   Thomas A. Bryan, 20 January 2000
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 15:31:59 $


n=max(1,nargout);
if nargin>1 & n~=nargin
  error(['Number of input and output arguments must match with multiple' ...
        ' inputs.'])
end
wrn = warning('off');
for k=1:n
  Hq = varargin{min(k,nargin)};
  if ~isa(Hq,'qfilt')
    error('Input must be a quantized filter (qfilt) object.');
  end
  % Convert to a structure, and copy the quantizer objects individually. 
  s = get(Hq);
  s.coefficientformat  = copyobj(s.coefficientformat);
  s.inputformat        = copyobj(s.inputformat);
  s.outputformat       = copyobj(s.outputformat);
  s.multiplicandformat = copyobj(s.multiplicandformat);
  s.productformat      = copyobj(s.productformat);
  s.sumformat          = copyobj(s.sumformat);
  varargout{k} = qfilt(s);
end
warning(wrn)


