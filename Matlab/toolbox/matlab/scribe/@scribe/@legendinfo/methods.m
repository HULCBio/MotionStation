function rh = methods(this,fcn,varargin)
% METHODS - methods for legendinfo class

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $  $  $  $

% one arg is methods(obj) call
if nargin==1
    cls= this.classhandle;
    m = get(cls,'Methods');
    val = get(m,'Name');
    return;
end

switch (fcn)
    case 'postdeserialize'
        postdeserialize(this);
    case 'delete'
        deletefcn(this);
end

%-----------------------------------------------------%
function postdeserialize(h)

%-----------------------------------------------------%
function deletefcn(h)

%-----------------------------------------------------%