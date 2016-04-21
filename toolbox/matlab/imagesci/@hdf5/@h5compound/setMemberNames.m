function setMemberNames(hObj, varargin)
%SETMEMBERNAMES  Set the names of the compound object's members.

%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:03:35 $
%   Copyright 1984-2002 The MathWorks, Inc.

if (~iscellstr(varargin))
    error('MATLAB:h5compound:setMemberNames:badNameType', ...
          'Member names must be strings.')
end

for p = 1:(nargin - 1)
    disp(sprintf('Adding member "%s"', varargin{p}))
    hObj.addMember(varargin{p});
end
