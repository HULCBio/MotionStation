function execstring(t,varargin)
%EXECSTRING executes a string in a tlc context
%   EXECSTRING(H,STRING) runs STRING in tlc
%   context H.
%
%   See also: TLCHANDLE

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/10 17:57:10 $

for i=1:length(varargin)
   tlc('execstring',t.Handle,varargin{i});
end