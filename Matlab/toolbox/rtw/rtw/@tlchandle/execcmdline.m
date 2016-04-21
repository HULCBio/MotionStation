function execcmdline(t,varargin)
%EXECCMDLINE executes a command line in a tlc context
%   EXECCMDLINE(H,STRINGS) runs command line formed by
%   STRINGS in tlc context H.
%
%   See also: TLCHANDLE

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/10 17:57:31 $

tlc('execcmdline',t.Handle,varargin{:});
