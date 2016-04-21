function legendcolorbarlayout(ax,action)
%LEGENDCOLORBARLAYOUT Layout legend and/or colorbar around axes
%   This is a helper function for legend and colorbar. Do not call
%   directly.

%   LEGENDCOLORBARLAYOUT(AX,'layout') lays out any
%   legends and colorbars around axes AX preserving OuterPosition.
%   LEGENDCOLORBARLAYOUT(AX,'on') turns on the listeners for laying
%   out legends and colorbars for axes AX.
%   LEGENDCOLORBARLAYOUT(AX,'off') turns off the listeners.
%   LEGENDCOLORBARLAYOUT(AX,'remove') deletes the listeners.

%   Copyright 1984-2004 The MathWorks, Inc.

switch(action)
 case 'layout'
  doOuterPositionSet([],[],ax,true);
 case 'on'
  list = getListeners(ax);
  if isempty(list)
    list = createListeners(ax);
  end
  set(list,'enable','on');
 case 'off'
  list = getListeners(ax);
  if ~isempty(list)
    set(list,'enable','on');
  end
 case 'remove'
  if ~isempty(getListeners(ax))
    rmListeners(ax);
  end
end

%----------------------------------------------------------------%
% Get peer axis listeners, if any
function res = getListeners(ax)
res = [];
hax = handle(ax);
if ~isempty(findprop(hax,'LegendColorbarListeners'))
  res = get(hax,'LegendColorbarListeners');
end

%----------------------------------------------------------------%
% Remove peer axis listeners, if any
function rmListeners(ax)
hax = handle(ax);
if ~isempty(hax) && ~isempty(findprop(hax,'LegendColorbarListeners'))
  set(get(hax,'LegendColorbarListeners'),'enable','off')
  set(hax,'LegendColorbarListeners',[]);
end

%----------------------------------------------------------------%
function list = createListeners(ax)
hax = handle(ax);
fig = get(ax,'Parent');
if ~isequal(get(fig,'Type'),'figure')
  fig = ancestor(fig,'figure');
end
list = handle.listener(hax,findprop(hax,'Position'),...
                              'PropertyPostSet',{@doPositionSet,ax});
list(end+1) = handle.listener(hax,findprop(hax,'OuterPosition'),...
                              'PropertyPostSet',{@doOuterPositionSet,ax,false});
list(end+1) = handle.listener(hax,findprop(hax,'LooseInset'),...
                              'PropertyPostSet',{@doInset,ax});
% see comment below for why TightInset listener is turned off
%list(end+1) = handle.listener(hax,findprop(hax,'TightInset'),...
%                              'PropertyPostSet',{@doTightInset,ax});
list(end+1) = handle.listener(hax,'AxisInvalidEvent',...
                              {@doInvalidate,ax});
list(end+1) = handle.listener(handle(fig),'FigureUpdateEvent',...
                              {@doValidateLayout,ax});

list(end+1) = handle.listener(hax,findprop(hax,'Units'),...
                       'PropertyPreSet',{@doEnable,ax,'off',list});
list(end+1) = handle.listener(hax,findprop(hax,'Units'),...
                              'PropertyPostSet',{@doEnable,ax,'on',list(1:end-1)});

% listeners are stored on the axis as non-serializable instance property
if isempty(findprop(hax,'LegendColorbarListeners'))
  prop = schema.prop(hax,'LegendColorbarListeners','handle vector');
  prop.AccessFlags.Serialize = 'off';
  prop.Visible = 'off';
end
set(hax,'LegendColorbarListeners',list)

%----------------------------------------------------------------%
% Enable or disable peer axis listeners that depend on units
function doEnable(hSrc,eventdata,ax,state,list)
set(list,'enable',state)

%----------------------------------------------------------------%
% Mark the data axis as needing to layout legends and colorbars
function doInvalidate(hSrc,eventdata,ax)
if ishandle(ax)
  setappdata(ax,'LegendColorbarLayoutDirty',true);
  fig = get(ax,'Parent');
  if ~isequal(get(fig,'Type'),'figure')
    fig = ancestor(fig,'figure');
  end
  setlayoutdirty(handle(fig));
end

%----------------------------------------------------------------%
% peer loose inset changed. 
function doInset(hSrc,eventdata,ax)

loose = offsetsInUnits(ax,get(ax,'LooseInset'),get(ax,'Units'),'normalized');
if strcmp(get(ax,'Units'),'normalized')
  outerpos = get(ax,'OuterPosition');
  loose = loose.*[outerpos(3:4) outerpos(3:4)];
end
setappdata(ax,'LegendColorbarOriginalInset',loose);
fig = ancestor(ax,'figure');
par = get(ax,'Parent');
pos = hgconvertunits(fig,get(par,'Position'),get(par,'Units'),'points',...
                     get(par,'Parent'));
setappdata(ax,'LegendColorbarOriginalSize',pos);
% user changes insets so if outerposition layout need to update them
doLayout(hSrc,eventdata,ax,false);

%----------------------------------------------------------------%
% peer tight inset changed. Now this is unused since tight insets
% are set after figure layout is done and so our updates don't do
% anything. HG will need another figure layout to refresh properly.
%function doTightInset(hSrc,eventdata,ax)
% user changes insets so if outerposition layout need to update them
%doLayout(hSrc,eventdata,ax,true);

%----------------------------------------------------------------%
% layout legends and colorbars, if peer axis is dirty
function doValidateLayout(hSrc,eventdata,ax)
if strcmp(get(ax,'ActivePositionProperty'),'outerposition')
  needs_refresh = getappdata(ax,'LegendColorbarLayoutDirty');
  if isempty(needs_refresh) || ~needs_refresh, return, end
  doLayout(hSrc,eventdata,ax,true);
end


%----------------------------------------------------------------%
% peer position changed
function doOuterPositionSet(hSrc,eventdata,ax,force)
if force || strcmp(get(ax,'ActivePositionProperty'),'outerposition')
  % recompute insets appdata since it is relative to figure position
  if ~force && isappdata(ax,'LegendColorbarOriginalInset')
    loose = offsetsInUnits(ax,get(ax,'LooseInset'),get(ax,'Units'),'normalized');
    if strcmp(get(ax,'Units'),'normalized')
      outerpos = get(ax,'OuterPosition');
      loose = loose.*[outerpos(3:4) outerpos(3:4)];
    end
    setappdata(ax,'LegendColorbarOriginalInset',loose);
    fig = ancestor(ax,'figure');
    par = get(ax,'Parent');
    pos = hgconvertunits(fig,get(par,'Position'),get(par,'Units'),'points',...
                         get(par,'Parent'));
    setappdata(ax,'LegendColorbarOriginalSize',pos);
  end
  doLayout(hSrc,eventdata,ax,true);
end

%----------------------------------------------------------------%
% peer position changed
function doPositionSet(hSrc,eventdata,ax)
if strcmp(get(ax,'ActivePositionProperty'),'position')

  % recompute insets appdata since it is relative to figure position
  if isappdata(ax,'LegendColorbarOriginalInset')
    loose = offsetsInUnits(ax,get(ax,'LooseInset'),get(ax,'Units'),'normalized');
    if strcmp(get(ax,'Units'),'normalized')
      outerpos = get(ax,'OuterPosition');
      loose = loose.*[outerpos(3:4) outerpos(3:4)];
    end
    setappdata(ax,'LegendColorbarOriginalInset',loose);
    fig = ancestor(ax,'figure');
    par = get(ax,'Parent');
    pos = hgconvertunits(fig,get(par,'Position'),get(par,'Units'),'points',...
                         get(par,'Parent'));
    setappdata(ax,'LegendColorbarOriginalSize',pos);
  end

  % compute needed space to contain all the legends, colorbars
  doLayout(hSrc,eventdata,ax,false);
end

%----------------------------------------------------------------%
% Respond to container resize event. If the width and height are 
% the same then exit without doing anything
function doResize(hSrc,eventdata,ax,outer)
dSrc = double(hSrc);
size = getappdata(dSrc,'LegendColorbarLayoutSize');
newsize = get(dSrc,'Position');
if isempty(size) || ~isequal(size,newsize(3:4));
  setappdata(dSrc,'LegendColorbarLayoutSize',newsize(3:4));
  doLayout(hSrc,eventdata,ax,outer)
end

%----------------------------------------------------------------%
% Performs layout of all legends and colorbars around axes ax. If
% outer is true then perserve the outerposition
function doLayout(hSrc,eventdata,ax,outer)
if ishandle(ax) && ~strcmp(get(ax,'beingdeleted'),'on')
  list = getListeners(ax);
  oldstate = get(list,'enable');
  set(list,'enable','off') % don't fire any layout listeners during layout
  
  fig = ancestor(ax,'figure');
  parent = get(ax,'Parent');
  hparent = handle(parent);
  hax = handle(ax);
  units = get(ax,'Units');
  normalized = strcmp(units,'normalized');

  % reset to the "original" spacing without legends or colorbars
  % except if obeying OuterPosition in which case set the loose
  % inset while in OuterPosition mode so that the plot area shrinks
  originalinsets = getappdata(ax,'LegendColorbarOriginalInset');
  if ~isempty(originalinsets)
    if outer
        ap = get(ax,'ActivePositionProperty');
        % set the LooseInsets and make sure OuterPosition is fixed
        set(ax,'ActivePositionProperty','outerposition');
    end
    if normalized
      outerpos = get(ax,'OuterPosition');
      % the inset appdata is relative to figure position
      origInsetsInUnits = originalinsets./[outerpos(3:4) outerpos(3:4)];
    else
      %      origInsetsInUnits = offsetsInUnits(ax,originalinsets,'normalized',units);
      originalsize = getappdata(ax,'LegendColorbarOriginalSize');
      fig = ancestor(ax,'figure');
      par = get(ax,'Parent');
      newsize = hgconvertunits(fig,get(par,'Position'),get(par,'Units'),'points',...
                           get(par,'Parent'));
      ratio = originalsize(3:4)./newsize(3:4);
      originalinsets = originalinsets.*[ratio ratio];
      origInsetsInUnits = offsetsInUnits(ax,originalinsets,'normalized',units);
    end
    set(ax,'LooseInset',origInsetsInUnits);
    if outer
      get(ax,'Position');
      set(ax,'ActivePositionProperty',ap);
    end
    loose = originalinsets;
  else
    % original inset appdata doesn't exist so set it now
    loose = get(ax,'LooseInset');
    if normalized
      outerpos = get(ax,'OuterPosition');
      loose = loose.*[outerpos(3:4) outerpos(3:4)];
    else
      loose = offsetsInUnits(ax,loose,units,'normalized');
    end
    setappdata(ax,'LegendColorbarOriginalInset',loose);
    fig = ancestor(ax,'figure');
    par = get(ax,'Parent');
    pos = hgconvertunits(fig,get(par,'Position'),get(par,'Units'),'points',...
                         get(par,'Parent'));
    setappdata(ax,'LegendColorbarOriginalSize',pos);
  end
  
  colorbars = find(hparent,'-isa','scribe.colorbar','Axes',hax,'BeingDeleted','off');
  legends = find(hparent,'-isa','scribe.legend','Axes',hax,'BeingDeleted','off');
  if isempty(colorbars) && isempty(legends)
    % no more objects so remove listeners
    rmListeners(ax);
    return;
  end

  oldlayout = getappdata(ax,'inLayout');
  setappdata(ax,'inLayout',true);
  
  % compute sizes of gaps to leave around peer axis from OuterPosition
  outerpos = get(ax,'OuterPosition');
  pos = get(ax,'Position');
  tight = get(ax,'TightInset');
  if ~normalized
    outerpos = hgconvertunits(fig,outerpos,units,'normalized',parent);
    pos = hgconvertunits(fig,pos,units,'normalized',parent);
    tight = offsetsInUnits(ax,tight,units,'normalized');
  end
  if ~all(isfinite(tight)) || (tight(1)+tight(3) > 1) || (tight(2)+tight(4) > 1)
    setappdata(ax,'inLayout',oldlayout);
    set(list,{'enable'},oldstate)
    return;
  end
  insets = tight;
  borderGap = offsetsInUnits(ax,[5 5 5 5],'point','normalized');
  for k=1:length(colorbars)
    cbar = colorbars(k);
    insets = requestColorbarSpace(outerpos,insets,cbar,borderGap);
  end
  for k=1:length(legends)
    leg = legends(k);
    insets = requestLegendSpace(outerpos,insets,leg,borderGap);
  end
  loose = max(loose,insets);
  if normalized
    loose = loose./[outerpos(3:4) outerpos(3:4)];
  else
    loose = offsetsInUnits(ax,loose,'normalized',units);
  end
  if outer
    ap = get(ax,'ActivePositionProperty');
    % set the LooseInsets and make sure OuterPosition is fixed
    set(ax,'ActivePositionProperty','outerposition');
    set(ax,'LooseInset',loose);
    get(ax,'Position'); % fire any listeners from setting above properties
    set(ax,'ActivePositionProperty',ap);
    outerpos = get(ax,'OuterPosition');
    pos = get(ax,'Position');
    if ~normalized
      outerpos = hgconvertunits(fig,outerpos,units,'normalized',parent);
      pos = hgconvertunits(fig,pos,units,'normalized',parent);
    end
    layoutOuterPosition(ax,colorbars,legends,tight,pos,outerpos,borderGap);
  else
    % set the LooseInsets making sure the Position is fixed
    ap = get(ax,'ActivePositionProperty');
    set(ax,'ActivePositionProperty','position');
    set(ax,'LooseInset',loose);
    set(ax,'ActivePositionProperty',ap);
    outerpos = get(ax,'OuterPosition');
    pos = get(ax,'Position');
    if ~normalized
      outerpos = hgconvertunits(fig,outerpos,units,'normalized',parent);
      pos = hgconvertunits(fig,pos,units,'normalized',parent);
    end
    layoutOuterPosition(ax,colorbars,legends,tight,pos,outerpos,borderGap);
  end
  setappdata(ax,'inLayout',oldlayout);
  setappdata(ax,'LegendColorbarLayoutDirty',[]);
  set(list,{'enable'},oldstate)
end

%----------------------------------------------------------------%
% Request 1/10 of the OuterPosition for Outside colorbars with a
% minimum size based on the tight insets
function inset = requestColorbarSpace(outerpos, inset, h, borderGap)
location = get(h,'Location');
if strncmp(fliplr(location),'edistuO',7)
  gap = 1/10;
  oldunits = get(h,'FontUnits');
  set(h,'FontUnits','points');
  parent = get(h,'parent');
  positionPts = hgconvertunits(ancestor(parent,'figure'),...
                               get(parent,'Position'),get(parent,'units'),...
                               'points',get(parent,'parent'));
  % 3.5 is magic scaling factor to look good at small sizes
  fontsize = get(h,'FontSize')*3.5./positionPts(3:4); 
  set(h,'FontUnits',oldunits);
  switch location
   case 'WestOutside'
    inset(1) = inset(1) + max(outerpos(3)*gap,fontsize(1))+borderGap(1);
   case 'EastOutside'
    inset(3) = inset(3) + max(outerpos(3)*gap,fontsize(1))+borderGap(3);
   case 'SouthOutside'
    inset(2) = inset(2) + max(outerpos(4)*gap,fontsize(2))+borderGap(2);
   case 'NorthOutside'
    inset(4) = inset(4) + max(outerpos(4)*gap,fontsize(2))+borderGap(4);
  end
end

%----------------------------------------------------------------%
% Compute legend size and request space if outside axes plot box
function inset = requestLegendSpace(outerpos, inset, h, borderGap)
location = get(h,'Location');
if strncmp(fliplr(location),'edistuO',7)
  if strcmp(location,'BestOutside')
    location = calculate_best_outside(h);
  end
  siz = methods(h,'getsize');
  switch location
   case {'WestOutside','SouthWestOutside','NorthWestOutside'}
    inset(1) = inset(1) + siz(1)+borderGap(1);
   case {'EastOutside','SouthEastOutside','NorthEastOutside'}
    inset(3) = inset(3) + siz(1)+borderGap(3);
   case 'SouthOutside'
    inset(2) = inset(2) + siz(2)+borderGap(2);
   case 'NorthOutside'
    inset(4) = inset(4) + siz(2)+borderGap(4);
  end
end

%----------------------------------------------------------------%
% Layout colorbars and legends according to the axes OuterPosition property
% The size computation should be the compatible with requestColobarSpace.
function layoutOuterPosition(ax,colorbars,legends,tight,pos,outerpos,borderGap)

fig = ancestor(ax,'figure');
parent = get(ax,'parent');

% outpos is the tight outer position as legends and colorbars are added
% stored as [left bottom right top] not [x y w h]
outpos = [pos(1)-tight(1) pos(2)-tight(2) ...
        pos(1)+pos(3)+tight(3) pos(2)+pos(4)+tight(4)];

% ingap is the space between the plot box and the inner colorbars/legends
ingap = 1/60;

% edgegap is space inside plot box between sides of colorbars and
% plot box
edgegap = 1/40;

% inpos is the tight inner position as legends and colorbars are added
inpos = [pos(1)+ingap*outerpos(3) pos(2)+ingap*outerpos(4) ...
         pos(1)+pos(3)-ingap*outerpos(3) pos(2)+pos(4)-ingap*outerpos(4)];

% layout all legends
for k=1:length(legends)
  h = legends(k);
  if ~ishandle(h), continue; end
  
  % get BestOutside location
  location = get(h,'Location');
  lpos = [0 0 0 0];
  if strcmp(location,'Best')
    lpos = methods(h,'get_best_location');
  elseif strcmp(location,'none')
    lpos = hgconvertunits(fig,get(h,'Position'),get(h,'Units'),...
                          'normalized',parent);
    center = lpos(1:2) + lpos(3:4)/2;
    newsize = methods(h,'getsize');
    if all(newsize < lpos(3:4))
      lpos = [0 0 0 0];
    else
      legsize = max(newsize,lpos(3:4));
      lpos = [center-legsize/2 legsize];
    end
  else
    if strcmp(location,'BestOutside')
      location = calculate_best_outside(h);
    end
    
    legsize = methods(h,'getsize');
    lpos(3:4) = legsize;
    xyind = location_to_xy_index(location);
    switch xyind(1)
     case 1
      lpos(1) = outpos(1)-legsize(1);
      outpos(1) = outpos(1)-legsize(1);
     case 2
      lpos(1) = inpos(1);
     case 3
      lpos(1) = pos(1) + pos(3)/2 - legsize(1)/2;
     case 4
      lpos(1) = inpos(3)-legsize(1);
     case 5
      lpos(1) = outpos(3);
      outpos(3) = outpos(3)+legsize(1);
    end
    switch xyind(2)
     case 1
      lpos(2) = outpos(4);
      outpos(4) = outpos(4)+legsize(2);
     case 2
      lpos(2) = inpos(4)-legsize(2);
     case 3
      lpos(2) = pos(2) + pos(4)/2 - legsize(2)/2;
     case 4
      lpos(2) = inpos(2);
     case 5
      lpos(2) = outpos(2)-legsize(2);
      outpos(2) = outpos(2)-legsize(2);
    end
  end
  oldlpos = get(h,'Position');
  % 1e-10 is to be robust to roundoff error
  if all(lpos(3:4) > 0) && any(abs(oldlpos-lpos) > 1e-10)
    lpos = hgconvertunits(fig,lpos,'normalized',get(h,'Units'),parent);
    set(h,'Position',lpos);
    methods(h,'update_userdata');
  end
end

% reset inner bounding box but leave outer box as is so that
% legends and colorbars don't overlap outside
inpos = [pos(1)+ingap*outerpos(3) pos(2)+ingap*outerpos(4) ...
         pos(1)+pos(3)-ingap*outerpos(3) pos(2)+pos(4)-ingap*outerpos(4)];

defwidth = 1/10; % default width is 1/10 width of axes outerposition.

% layout all colorbars
for k=1:length(colorbars)
  h = colorbars(k);
  if ~ishandle(h), continue; end
  oldunits = get(h,'FontUnits');
  set(h,'FontUnits','points');
  positionPts = hgconvertunits(fig,get(parent,'Position'),get(parent,'units'),...
                               'points',get(parent,'parent'));
  fontsize = get(h,'FontSize')*3.5./positionPts(3:4);
  set(h,'FontUnits',oldunits);
  loose = get(0,'DefaultAxesLooseInset');
  switch h.Location
   case 'EastOutside'
    cwidth = max(outerpos(3)*defwidth,fontsize(1));
    cpos = [outpos(3) outerpos(2) cwidth outerpos(4)];
    outpos(3) = outpos(3) + cwidth + borderGap(3);
    loose(2) = pos(2) - outerpos(2);
    loose(4) = outerpos(4)-pos(4)-loose(2);
    loose([2 4]) = loose([2 4])./outerpos(4);
   case 'WestOutside'
    cwidth = max(outerpos(3)*defwidth,fontsize(1));
    cpos = [outpos(1)-cwidth outerpos(2) cwidth outerpos(4)];
    outpos(1) = outpos(1) - cwidth - borderGap(1);
    loose(2) = pos(2) - outerpos(2);
    loose(4) = outerpos(4)-pos(4)-loose(2);
    loose([2 4]) = loose([2 4])./outerpos(4);
   case 'SouthOutside'
    cheight = max(outerpos(4)*defwidth,fontsize(2));
    cpos = [outerpos(1) outpos(2)-cheight outerpos(3) cheight];
    outpos(2) = outpos(2) - cheight - borderGap(2);
    loose(1) = pos(1) - outerpos(1);
    loose(3) = outerpos(3)-pos(3)-loose(1);
    loose([1 3]) = loose([1 3])./outerpos(3);
   case 'NorthOutside'
    cheight = max(outerpos(4)*defwidth,fontsize(2));
    cpos = [outerpos(1) outpos(4) outerpos(3) cheight];
    outpos(4) = outpos(4) + cheight + borderGap(4);
    loose(1) = pos(1) - outerpos(1);
    loose(3) = outerpos(3)-pos(3)-loose(1);
    loose([1 3]) = loose([1 3])./outerpos(3);
   case 'East'
    cwidth = max(outerpos(3)*defwidth,fontsize(1));
    cedgegap = edgegap*outerpos(4);
    cpos = [inpos(3)-cwidth inpos(2)+cedgegap cwidth inpos(4)-inpos(2)-2*cedgegap];
    inpos(3) = inpos(3) - cwidth;
    loose([2 4]) = 0;
   case 'West'
    cwidth = max(outerpos(3)*defwidth,fontsize(1));
    cedgegap = edgegap*outerpos(4);
    cpos = [inpos(1) inpos(2)+cedgegap cwidth inpos(4)-inpos(2)-2*cedgegap];
    inpos(1) = inpos(1) + cwidth;
    loose([2 4]) = 0;
   case 'North'
    cheight = max(outerpos(4)*defwidth,fontsize(2));
    cedgegap = edgegap*outerpos(3);
    cpos = [inpos(1)+cedgegap inpos(4)-cheight inpos(3)-inpos(1)-2*cedgegap cheight];
    inpos(4) = inpos(4) - cheight;
    loose([1 3]) = 0;
   case 'South'
    cheight = max(outerpos(4)*defwidth,fontsize(2));
    cedgegap = edgegap*outerpos(3);
    cpos = [inpos(1)+cedgegap inpos(2) inpos(3)-inpos(1)-2*cedgegap cheight];
    inpos(2) = inpos(2) + cheight;
    loose([1 3]) = 0;
   otherwise
    cpos = [0 0 0 0];
  end
  oldcpos = get(h,'OuterPosition');
  oldcloose = get(h,'LooseInset');
  % 1e-10 is a tolerance to be robust to roundoff error
  if all(cpos(3:4) > 0) && (any(abs(oldcpos-cpos) > 1e-10) ||...
                            any(abs(oldcloose-loose) > 1e-10))
    cpos = clampToFigure(cpos);
    cpos = hgconvertunits(fig,cpos,'normalized',get(h,'Units'),parent);
    loose = offsetsInUnits(ax,loose,'normalized',get(h,'Units'));
    set(h,'OuterPosition',cpos);
    set(h,'LooseInset',loose);
  end
end

%----------------------------------------------------------------%
% Gets the best outside location for a given legend
function loc = calculate_best_outside(h)
if strcmp(get(h,'Orientation'),'vertical')
  loc = 'NorthEastOutside';
else
  loc = 'SouthOutside';
end

%----------------------------------------------------------------%
% translate location string to row,column number from top left
function ind = location_to_xy_index(locstr);
persistent vals;
if isempty(vals)
  vals.NorthOutside = [3,1];
  vals.NorthWestOutside = [1,2];
  vals.NorthWest = [2,2];
  vals.North = [3,2];
  vals.NorthEast = [4,2];
  vals.NorthEastOutside = [5,2];
  vals.WestOutside = [1,3];
  vals.West = [2,3];
  vals.East = [4,3];
  vals.EastOutside = [5,3];
  vals.SouthWestOutside = [1,4];
  vals.SouthWest = [2,4];
  vals.South = [3,4];
  vals.SouthEast = [4,4];
  vals.SouthEastOutside = [5,4];
  vals.SouthOutside = [3,5];
end
ind = vals.(locstr);

function out = offsetsInUnits(ax,in,from,to)
fig = ancestor(ax,'figure');
par = get(ax,'Parent');
p1 = hgconvertunits(fig,[0 0 in(1:2)],from,to,par);
p2 = hgconvertunits(fig,[0 0 in(3:4)],from,to,par);
out = [p1(3:4) p2(3:4)];

function out = clampToFigure(in)
botleft = max(in(1:2),[0 0]);
topright = min(in(1:2)+in(3:4),[1 1]);
if any(topright <= botleft)
  out = in;
else
  out = [botleft topright-botleft];
end
