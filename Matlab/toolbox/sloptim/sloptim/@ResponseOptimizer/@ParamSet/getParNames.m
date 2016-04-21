function p = getParNames(this)
% Returns list of parameter names.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:45:41 $
p = getvars(this);
p = get(p(2:end),{'Name'});