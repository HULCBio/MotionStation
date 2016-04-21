function schema
% Defines properties for @constreditor superclass

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $ $Date: 2002/04/10 05:12:40 $

% Register class 
c = schema.class(findpackage('plotconstr'), 'constreditor');

% Interface methods: show, isVisible