function h2 = changeseriestype(h1, newtype)
%CHANGESERIESTYPE Change a series plot type
%  Helper function for Plot Tool. Do not call directly.

%  H2 = CHANGESERIESTYPE(H1,NEWTYPE) switches series with handle
%  H1 to a new handle with same data and type NEWTYPE. H1 can be
%  a vector of handles.

%   Copyright 1984-2004 The MathWorks, Inc. 

if ~any(strcmp(newtype,{'stem','line','bar','stairs','area'}))
  error('Only ''line'',''stem'',''stairs'',''area'' and ''bar'' types are supported.');
end
returnCellArray = false;
if iscell(h1)
    h1 = [h1{:}];
    returnCellArray = true;
end 
if isempty(h1), return; end
h1(~ishandle(h1)) = [];
if isempty(h1)
  error('First argument must be a handle or vector of handles.');
end
N = length(h1);
cax = ancestor(h1(1),'axes');
switchprops = get(h1,'switchprops');
if N == 1
  vals = get(h1,switchprops);
else
  vals = cell(1,N);
  for k=1:N
    vals{k} = get(h1(k),switchprops{k});
  end
end
oldswitch = get(h1,'oldswitchprops');
oldswitchvals = get(h1,'oldswitchvals');

if N > 1
  h2 = [];
  for n=1:N
    h2 = [h2 change_one_series(h1(n),switchprops{n},vals{n},oldswitch{n},oldswitchvals{n},newtype)];
  end
else
  h2 = change_one_series(h1,switchprops,vals,oldswitch,oldswitchvals,newtype);
end
delete(h1);
plotdoneevent(cax,h2);
h2 = handle(h2); % plot tools expect handles not doubles
if (returnCellArray == true && length(h2) > 1)
    orig = h2;
    h2 = cell(1, length(orig));
    for i = 1:length(orig)
        h2{i} = orig(i);
    end
end


function h2=change_one_series(h1,switchprops,vals,oldswitch,oldswitchvals,newtype)
for k=1:length(oldswitch)
  prop = oldswitch{k};
  val = oldswitchvals{k};
  if ~any(strcmp(prop,switchprops))
    switchprops = {switchprops{:},prop};
    vals = {vals{:}, val};
  end
end

% filter out properties that have the factory values
k = 1;
while k < length(switchprops)
  prop = findprop(handle(h1),switchprops{k});
  if ~isempty(prop) && isequal(prop.FactoryValue, vals{k})
    switchprops(k) = [];
    vals(k) = [];
  else
    k = k+1;
  end
end

cax = get(h1,'parent');
ydata = get(h1,'ydata');
xdata = get(h1,'xdata');

try
  if strcmp(get(h1,'xdatamode'),'manual')
    xdata = get(h1,'xdata');
    pvpairs = {'xdata',xdata,'ydata',ydata,'parent',cax};
  else
    pvpairs = {'ydata',ydata,'parent',cax};
  end
end
switch newtype
 case 'line'
  lineseries('init');
  h2 = double(graph2d.lineseries(pvpairs{end-1:end}));
  set(h2,'xdatamode',get(h1,'xdatamode'));
  set(h2,pvpairs{1:end-2});
 case 'stem'
  h2 = specgraph.stemseries(pvpairs{:});
 case 'area'
  h2 = specgraph.areaseries(pvpairs{:});
  peers = find(handle(cax),'-class','specgraph.areaseries');
  set(peers,'AreaPeers',peers);
 case 'bar'
  h2 = specgraph.barseries(pvpairs{:});
  peers = find(handle(cax),'-class','specgraph.barseries');
  set(peers,'BarPeers',peers);
 case 'errorbar'
  h2 = specgraph.errorbarseries(pvpairs{:});
 case 'stairs'
  h2 = specgraph.stairseries(pvpairs{:});
end
for k=1:length(switchprops)
  try
    set(h2,switchprops{k},vals{k});
  end
end
if isprop(h2,'RefreshMode')
  set(h2,'RefreshMode','auto');
end
set(h2,'oldswitchprops',switchprops);
set(h2,'oldswitchvals',vals);
h2 = double(h2);
