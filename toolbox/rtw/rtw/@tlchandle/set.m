function set(t,varargin)
%SET retrieves a tlc context parameter
%   SET(H,PARAMETER,VALUE) sets the user
%   data field PARAMETER to VALUE for tlc
%   context H.
%
%   See also: TLCHANDLE

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/10 17:56:54 $

for i=1:2:length(varargin)-1
   tlc('set',t.Handle,varargin{i},varargin{i+1});
end