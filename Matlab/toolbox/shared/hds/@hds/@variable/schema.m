function schema
% Defines properties for @variable class (data set variable).

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:29:42 $

% Register class 
c = schema.class(findpackage('hds'),'variable');

% Public properties
p = schema.prop(c,'Name','string'); % Variable name
p.AccessFlags.PublicSet = 'off';

