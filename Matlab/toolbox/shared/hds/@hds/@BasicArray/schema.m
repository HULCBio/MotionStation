function schema
% Defines properties for @BasicArray class.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:28:37 $

% Register class 
p = findpackage('hds');
c = schema.class(p,'BasicArray',findclass(p,'ValueArray'));

% Public properties
schema.prop(c,'Data','MATLAB array');       % Array value

