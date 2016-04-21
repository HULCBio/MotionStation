% setlmis(lmisys0)
%
% Initializes the description of a new LMI system.
%
% To start from scratch, type
%
%                  setlmis([])
%
% To add on to an existing LMI system LMISYS0, type
%
%                  setlmis(lmisys0)
%
% See also  LMIVAR, LMITERM, GETLMIS.

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function setlmis(lmi0)

global GLZ_HEAD GLZ_LMIS GLZ_LMIV GLZ_LMIT GLZ_DATA

if nargin ~=1 | nargout ~=0,
  error('usage: setlmis(lmisys0)');
end


if isempty(lmi0),
  GLZ_HEAD=zeros(10,1); GLZ_LMIV=[];
  GLZ_LMIS=zeros(20,7);
  GLZ_LMIT=zeros(6,50);
  GLZ_DATA=zeros(1e3,1);

elseif size(lmi0,1)<10 | size(lmi0,2)>1,
  error('LMISYS0 is not an LMI description');

elseif length(lmi0)~=10+lmi0(1)*lmi0(4)+lmi0(2)*lmi0(5)+...
                     6*lmi0(3)+lmi0(7),
  error('LMISYS0 is not an LMI description');

else
  [GLZ_LMIS,GLZ_LMIV,GLZ_LMIT,GLZ_DATA]=lmiunpck(lmi0);
  GLZ_LMIS=GLZ_LMIS';  % row-wise listing
  GLZ_HEAD=lmi0(1:10);
end
