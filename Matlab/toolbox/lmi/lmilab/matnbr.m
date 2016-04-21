% nmvars = matnbr(lmisys)
% [nmvars,varid] = matnbr(lmisys)
%
% Returns the number of matrix variables in the LMI
% system LMISYS as well as the list of matrix variable
% identifiers.
%
% Input:
%  LMISYS     array describing the LMI system
%
% Output:
%  NMVARS     number of matrix variables
%  VARID      optional: vector of the matrix variable
%             identifiers.
%
% See also  DECNBR, LMINBR, LMIINFO.

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [nmvars,varid]=matnbr(LMIsys)

if nargin ~= 1,
  error('usage: nmvars = matnbr(lmisys)');
elseif size(LMIsys,1)<10 | size(LMIsys,2)>1,
  error('LMISYS is an incomplete LMI system description');
elseif any(LMIsys(1:8)<0),
  error('LMISYS is not an LMI description');
end

nmvars=LMIsys(2);

if nargout > 1,
  [lmis,lmiv]=lmiunpck(LMIsys);
  varid=lmiv(1,:);
end
