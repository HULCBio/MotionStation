function execfile(t,varargin)
%EXECFILE executes a tlc file in a context
%   EXECFILE(H,FILENAME) executes the file specified
%   in FILENAME in context H.
%
%   See also: TLCHANDLE

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/10 17:57:13 $

for i=1:length(varargin)
   tlc('execfile',t.Handle,varargin{i});
end

