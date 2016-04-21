function [ax,args,nargs] = axescheck(varargin)
%AXESCHECK Process leading Axes object from input list
%   [AX,ARGS,NARGS] = AXESCHECK(ARG1,ARG2,...) checks if ARG1 is an Axes
%   and returns it in AX if it is and returns the processed argument
%   list in ARGS and NARGS.  If ARG1 is not an Axes, AX will return empty.
%   Also checks arguments that are property-value pairs 'parent',ARG.

%    Copyright 1984-2003 The MathWorks, Inc.
%    $Revision $  $Date: 2004/04/10 23:28:36 $

args = varargin;
nargs = nargin;
ax=[];
if (nargs > 0) && (numel(args{1}) == 1) && ...
      ishandle(args{1}) && strcmp(get(args{1},'type'),'axes')
  ax = args{1};
  args = args(2:end);
  nargs = nargs-1;
end
if nargs > 0
  inds = find(strcmpi('parent',args));
  if ~isempty(inds)
    inds = unique([inds inds+1]);
    pind = inds(end);
    if nargs <= pind && ishandle(args{pind})
      ax = args{pind};
      args(inds) = [];
      nargs = length(args);
    end
  end
end
