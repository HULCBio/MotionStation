function schema
% Defines properties for @MATFileContainer class
% (implements @ArrayContainer interface)

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:28:49 $

% Register class 
p = findpackage('hds');
c = schema.class(p,'MATFileContainer',findclass(p,'ArrayContainer'));

% Public properties
schema.prop(c,'FileName','string');  % MAT file name

