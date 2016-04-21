% nlmis = lminbr(lmisys)
%
% Returns the number of LMIs in LMI system LMISYS
%
% Input:
%    LMISYS     array describing the LMI system
%
% Output:
%    NLMI       number of LMIs
%
%
% See also  MATNBR, DECNBR, LMIINFO.

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function nlmi=lminbr(LMIsys)

if nargin ~= 1,
  error('usage: nlmi = lminbr(LMISYS)');
elseif size(LMIsys,1)<10,
  error('LMISYS is an incomplete LMI system description');
elseif any(LMIsys(1:8)<0),
  error('LMISYS is not an LMI description');
end

nlmi=LMIsys(1);
