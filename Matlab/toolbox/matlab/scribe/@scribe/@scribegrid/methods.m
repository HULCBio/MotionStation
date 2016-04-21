function rh = methods(this,fcn,varargin)
% METHODS - methods for scribegrid class

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
end

%-----------------------------------------------------%
function postdeserialize(h)

% delete children not created in constructor
goodchildren = double([h.Srect, h.Vlines, h.Hlines]);
allchildren = get(double(h),'Children');
badchildren = setdiff(allchildren,goodchildren);
if ~isempty(badchildren)
    delete(badchildren);
end
