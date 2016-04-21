function schema
% Generic Data Source.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.

% Register class 
c = schema.class(findpackage('ResponseOptimizer'),'Source');
c.Description = 'Source for constraint data';

p = schema.prop(c,'Name','string');
p.Description = 'Source name';
