function t = isequal(varargin)
%ISEQUAL  True if qfilt properties are equal.
%   ISEQUAL(Hq1,Hq2) is true if both Hq1 and Hq2 are qfilt objects, and
%   they have the same values.
%
%   ISEQUAL(Hq1,Hq2,...) is true if all qfilts have the same values.

%   Thomas A. Bryan, 6 March 2003
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/06 15:38:58 $

error(nargchk(2,inf,nargin));

t = true;
Hq = varargin{1};
if ~isa(Hq,'qfilt')
  t = false;
  return
end

k=2;
while k<=nargin && t==true
  if ~isa(varargin{k},'qfilt')
    t = false;
  else
    Hqk = varargin{k};
    t = t ...
        && isequalwithequalnans( Hq.referencecoefficients, Hqk.referencecoefficients ) ...
        && isequal( Hq.filterstructure,       Hqk.filterstructure       ) ...
        && isequal( Hq.scalevalues,           Hqk.scalevalues           ) ...
        && isequal( Hq.coefficientformat,     Hqk.coefficientformat     ) ...
        && isequal( Hq.inputformat,           Hqk.inputformat           ) ...
        && isequal( Hq.outputformat,          Hqk.outputformat          ) ...
        && isequal( Hq.multiplicandformat,    Hqk.multiplicandformat    ) ...
        && isequal( Hq.productformat,         Hqk.productformat         ) ...
        && isequal( Hq.sumformat,             Hqk.sumformat             );
  end
  k = k+1;
end
