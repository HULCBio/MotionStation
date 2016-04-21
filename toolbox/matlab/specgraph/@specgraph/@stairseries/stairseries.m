function h = stairseries(varargin)
%STAIRSERIES stairseries constructor
%  H = STAIRSERIES(PARAM1, VALUE1, PARAM2, VALUE2, ...) creates
%  a stairseries in the current axes with given param-value pairs.
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
h = specgraph.stairseries('parent',parent);
h.initialized = 1;
l1 = line('hittest','off',...
	  'parent',double(h));
if ~isempty(args)
  set(h,args{:})
end
setLegendInfo(h);
