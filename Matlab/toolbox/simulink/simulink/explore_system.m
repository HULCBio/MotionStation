function explore_system(s)

% Copyright 2003 The MathWorks, Inc.

open_system(s);
h = get_param(s, 'Object');
me=daexplr;
me.view(h);