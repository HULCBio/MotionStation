function y = hgconvertunits(fig,x,srcunits,destunits, ref)
%HGCONVERTUNITS Converts units on a handle graphics object
%   This is an internal helper m-file for Handle Graphics.

%   Y = HGCONVERTUNITS(FIG, X, SRCUNITS, DESTUNITS, REF) converts
%   rectangle X in figure FIG from units SRCUNITS to DESTUNITS
%   using the object with handle REF as the reference container for
%   normalized units. REF can be the root object.

%   Copyright 1984-2003 The MathWorks, Inc.

error(nargchk(5,5,nargin,'struct'));

if ~(length(ref) == 1) || ~ishandle(ref)
  error('MATLAB:hgconvertunits:InvalidHandle','Invalid handle.');
end
if ~(length(fig) == 1) || ~ishandle(fig) || ~isa(handle(fig),'hg.figure')
  error('MATLAB:hgconvertunits:InvalidHandle','Invalid figure handle.');
end

if ~ischar(srcunits) || ~ischar(destunits)
  error('MATLAB:hgconvertunits:InvalidUnits','Units must be a string.');
end

if ~isa(x,'double') || ~isequal(size(x),[1 4])
  error('MATLAB:hgconvertunits:InvalidTarget',...
        'The value to convert must have the form [x y w h].');
end

y = builtin('hgconvertunits',fig,x,srcunits,destunits,ref);


