function schema
% Defines properties for @VirtualArray class.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:29:14 $

% Register class 
p = findpackage('hds');
c = schema.class(p,'VirtualArray',findclass(p,'ValueArray'));

% Public properties
schema.prop(c,'Storage','MATLAB array');  % Array container

