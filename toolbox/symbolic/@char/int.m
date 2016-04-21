function y = int(f,varargin)
%INT    Alternative entry to the symbolic integration function.
%   INT(F,...) is the same as int(sym(F),...).
%   See also SYM/INT.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/15 03:05:53 $

y = int(sym(f),varargin{:});
