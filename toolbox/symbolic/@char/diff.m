function y = diff(f,varargin)
%DIFF   Alternative entry to the symbolic differentiation function.
%   DIFF(F,...) is the same as diff(sym(F),...).
%   See also SYM/DIFF.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/15 03:05:56 $

y = diff(sym(f),varargin{:});
