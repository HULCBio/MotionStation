function ch = plotchild(ax,dim)
%PLOTCHILD Get plot objects in an axis
%  This function is a helper function for the plot tools and curve
%  fitting. Do not call this function directly.

%   CH = PLOTCHILD(AX) returns the list of plot object
%   children of axes AX. This function is a helper function for the
%   plot tools.
%
%   CH = PLOTCHILD(AX,DIM) for DIM=2 or 3 returns the 2D or 3D
%   children of axes AX, respectively.
%
%   See also: PLOTTOOLS

%   Copyright 1984-2003 The MathWorks, Inc. 

if nargin == 1
  dim = 3;
end
ch = get(ax,'children');
if ~isempty(ch)
  ok = false(1,length(ch));
  for k=1:length(ch)
    child = handle(ch(k));
    cls = child.classhandle;
    pkg = get(cls,'Package');
    pkgname = get(pkg,'Name');
    if strcmp(pkgname,'specgraph') || ...
          isa(child,'graph2d.lineseries') || ...
          strcmp(get(child,'type'),'image') || ...
          strcmp(get(child,'type'),'surface')
      ok(k) = (dim ~= 2) || (isprop(child,'ZData') && ...
                             isempty(get(child,'ZData')));
    end
  end
  ch = ch(ok);
end
