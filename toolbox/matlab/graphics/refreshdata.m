function refreshdata(h,workspace)
%REFRESHDATA Refresh data in plot
%   REFRESHDATA evaluates any data source properties in the
%   plots in the current figure and sets the corresponding data
%   properties of each plot. 
%
%   REFRESHDATA(FIG) refreshes the data in figure FIG.
%
%   REFRESHDATA(H) for a vector of handles H refreshes the data of
%   the objects specified in H or the children of those
%   objects. Therefore, H can contain figure, axes, or plot object
%   handles.
%
%   REFRESHDATA(H,WS) evaluates the data source properties in the
%   workspace WS. WS can be 'caller' or 'base'. The default
%   workspace is 'base'.

%   Copyright 1984-2004 The MathWorks, Inc. 

if nargin == 0
  h = gcf;
end
if nargin < 2
  workspace = 'base';
end
if iscell(h), h = [h{:}]; end
h = unique(h(ishandle(h)));
h = handle(findall(h));

% gather up all the objects to refresh
objs = {};
for k = 1:length(h)
  obj = h(k);
  objfields = fields(obj);
  for k2 = 1:length(objfields)
    % search for properties ending in DataSource
    if strncmpi(fliplr(objfields{k2}),'ecruoSataD',10)
      objs = {objs{:},obj, objfields{k2}};
    end
  end
end

% run through obj,prop pairs and re-evaluate the source
for k = 1:2:length(objs)
  h = objs{k};
  sourceprop = objs{k+1};
  str = get(h,sourceprop);
  if ~isempty(str)
    prop = sourceprop(1:end-6);
    try
      val = evalin(workspace,str);
      set(h,prop,val);
    catch
      warning('MATLAB:refreshdata:InvalidSource',...
              ['Could not refresh ' prop ' from ''' str '''.']);
    end
  end
end
