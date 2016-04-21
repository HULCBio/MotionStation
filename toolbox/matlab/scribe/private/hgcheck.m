function [hgobj,args,nargs] = hgcheck(classname,varargin)
%HGCHECK Process leading hg object from input list
%   [HGOBJ,ARGS,NARGS] = HGCHECK(CLASSNAME, ARG1,ARG2,...) checks if 
%   ARG1 is an object of classname CLASSNAME and returns it
%   in HGOBJ if it is and returns the remaining argument list in ARGS and NARGS.
%   If ARG1 is not an object of package PKG and classname CLASSNAME, HGOBJ 
%   will return empty.
%   Also checks arguments for property-value pairs 'parent',ARG.

% Copyright 2002-2003 The MathWorks, Inc.

args = varargin;
nargs = length(args);
hgobj=[];
if (nargs > 0) && (numel(args{1}) == 1) && ...
      ishandle(args{1}) && isa(handle(args{1}),classname)
  hgobj = args{1};
  args = args(2:end);
  nargs = length(args);
end
if nargs > 0
  inds = find(strcmpi('parent',args));
  if ~isempty(inds)
    inds = unique([inds inds+1]);
    pind = inds(end);
    if nargs <= pind && ishandle(args{pind})
      hgobj = args{pind};
      args(inds) = [];
      nargs = length(args);
    end
  end
end
