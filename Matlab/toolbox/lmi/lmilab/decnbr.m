% ndecv = decnbr(lmisys)
%
% Returns the number of decision variables (free scalar
% variables) in the system of LMIs decribed by LMISYS
%
% Input:
%   LMISYS       array describing the LMI system
%
% Output:
%   NDECV        number of decision variables
%
%
% See also  DECINFO, DEC2MAT, MAT2DEC, MATNBR, LMIVAR.

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function ndecv=decnbr(LMIsys)

if nargin ~= 1,
  error('usage: ndecv = decnbr(lmisys)');
elseif size(LMIsys,1) < 10 | size(LMIsys,2)>1,
  error('LMISYS is not an LMI description');
end

ndecv=LMIsys(8);
