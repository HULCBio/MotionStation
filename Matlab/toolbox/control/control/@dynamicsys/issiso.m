function boo = issiso(sys)
%ISSISO  True for SISO systems.
%
%   ISSISO(SYS) returns 1 (true) if SYS is a single-input,
%   single-output (SISO) model or array of models, and
%   0 (false) otherwise.
%
%   See also SIZE, ISEMPTY.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:12:28 $
boo = all(iosize(sys)==1);

