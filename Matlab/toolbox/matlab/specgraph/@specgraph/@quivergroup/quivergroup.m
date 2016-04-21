function h = quivergroup(varargin)
%QUIVERGROUP quivergroup constructor
%  H = QUIVERGROUP(PARAM1, VALUE1, PARAM2, VALUE2, ...) creates
%  a quiver plot in the current axes with given param-value pairs.
%  This function is an internal helper function for Handle Graphics
%  and shouldn't be called directly.
  
%   Copyright 1984-2004 The MathWorks, Inc. 

args = varargin;
args(1:2:end) = lower(args(1:2:end));
parentind = find(strcmp(args,'parent'));
if isempty(parentind)
  parent = gca;
else
  parent = args{parentind(end)+1}; % take last parent specified
  args(unique([parentind parentind+1]))=[];
end
h = specgraph.quivergroup('parent',parent);
l1 = line('hittest','off',...
	  'parent',double(h),'linestyle','none','marker','none');
l2 = line('hittest','off',...
	  'parent',double(h));
l3 = line('hittest','off',...
	  'parent',double(h));
hasbehavior(l1,'legend',false);
hasbehavior(l2,'legend',false);
hasbehavior(l3,'legend',false);
h.initialized = 1;
if ~isempty(args)
  set(h,args{:})
end
setLegendInfo(h);