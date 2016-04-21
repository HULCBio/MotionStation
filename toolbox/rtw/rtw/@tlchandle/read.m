function read(t,varargin)
%READ brings a record file into a tlc context
%   READ(H,FILENAME) reads record file FILENAME
%   into tlc context H.
%
%   See also: TLCHANDLE

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/10 17:56:57 $

for i=1:length(varargin)
   tlc('read',t.Handle,varargin{i});
end