function varargout = panfcn(varargin)
%PANFCN  Pan Function for Axes and Signal GUI
%  Usage: call this function either as the buttondownfcn of the lines in
%   an axes that you want to pan, or as the windowbuttondownfcn when you
%   click inside an axes.
%  Inputs are in param/value pairs
%    'Ax'  axes to pan, default: gca 
%    'Bounds' structure with .xlim and .ylim - panning will not
%      ever leave these bounds.  default: no bounds
%    'DirectFlag' 1 ==> drag in main axes, 0 ==> drag in panner. default = 1
%    'borderAxes'  axes whose perimeter is one pixel outside of 'Axes' -
%       if not defined, the 'Axes' will get erased if the erasemode
%       of the lines is background.
%    'PannerPatch'  handle to pannerpatch - if [], don't update.
%         Defaults to [].
%    'DynamicDrag'  1 ==> update lines on the fly (default), 
%                   0 ==> update panner patch only
%    'Data'  structure array with fields
%         .h   vector of handles to lines
%         .data matrix of data for the lines (in columns)
%         .xdata  if this is present, it must be the same size as .data, and
%            the entire line will be transformed into the current limits; 
%            if not present, a linearly
%            spaced xdata will be assumed, and during the dynamic pan, the
%            xdata and ydata of the lines will be updated in such a way
%            as to only display what is between the current xlimits
%         defaults to all the lines in the axes
%    'Transform'  function string - applied with feval before setting ydata
%         defaults to ''
%    'Immediate' 1==>switch to border Axes immediately (default)
%                0==> "     "    "       "   on mouse motion only
%    'Invisible'  vector of handles to hide and restore on exit
%    'UserHand'  handle to object to use for userdata - defaults to Ax
%    'EraseMode' used for lines during panning, should be 'xor' or 
%         'background', defaults to 'background'
%    'Pointer'  used during drag - defaults to 'closedhand'
%    'InterimPointer'  used prior to drag in case Immediate == 0; defaults
%         to nothing (doesn't change).  This is a string which is passed
%         to setptr.
% OUTPUTS:
%   returns 1 if limits changed, 0 else
%   Copyright 1988-2002 The MathWorks, Inc.
%       $Revision: 1.8 $

% define default values:
ax = [];
bounds = [];
directflag = 1;
borderaxes = [];
pannerpatch = [];
panneraxes = [];  % parent of pannerpatch
dynamicdrag = 1;
data = [];
transform = '';
immediate = 1;
invisible = [];
userhand = [];
erasemode = 'background';
pointer = 'closedhand';
interimpointer = '';

% parse parameters - could use some error checking
for i=1:2:length(varargin)
    param = lower(varargin{i});
    value = varargin{i+1};
    eval([param ' = value;'])
end

% finish default value setting
if isempty(ax)
    ax = gca;
end
fig = get(ax,'parent');
ptr = getptr(fig);
if ~isempty(interimpointer)
    setptr(fig,interimpointer)
end
if isempty(userhand)
    userhand = ax;
end
if ~isempty(pannerpatch)
    panneraxes = get(pannerpatch,'parent');
end
% initialize "data" structure array from axes line objects here.
% This costly computation will be skipped if you pass in the "data"
% structure array yourself.
% This array has fields:
%    .data - matrix
%    .columns - index vector; indicates which columns of .data are
%        actually displayed as lines
%    .h - line handles - one per column of .data(:, data.columns)
%    .xdata - either the same size as .data or empty if .Fs >0
%    .Fs - scalar; -1 indicates xdata matrix contains x information,
%         if >0, xdata is created evenly spaced
%    .t0 - scalar; used with .Fs to compute xdata
if isempty(data)
    h = findobj(ax,'type','line');
    h = setdiff(h,invisible);
    if isempty(h)
        setptr(fig,ptr)
        return
    end
    for i=1:length(h)
        data(i).h = h(i);
        data(i).data = get(h(i),'ydata');
        data(i).data = data(i).data(:);  % make into column
        data(i).columns = 1;
        data(i).xdata = get(h(i),'xdata');
        data(i).xdata = data(i).xdata(:);  % make into column
        xdf=diff(data(i).xdata);   % see if this line is evenly spaced
        if length(xdf)>1  &  all(xdf==xdf(1)) &  xdf(1)~=0
            data(i).t0 = data(i).xdata(1);  data(i).Fs = 1./xdf(1);
        else
            data(i).t0 = 0; data(i).Fs = -1;
        end
    end
end

save_userhand_tag = get(userhand,'tag');
set(userhand,'tag','userhand')

% get current point of mouse click
if directflag
    p = get(ax,'currentpoint');  
else
    p = get(panneraxes,'currentpoint');
end
p = p(1,1:2);
np = p;

if immediate
   [oldptr,save_visible] = start_motion(fig,ax,borderaxes,...
            data,erasemode,invisible,pointer);
end

xlim = get(ax,'xlim');
ylim = get(ax,'ylim');

% To get fast panning without axes redrawing, we never change
% the xlim and ylim of ax during the dragging.  Instead, we
% set the xdata and ydata of the lines during dragging and
% set the xlim and ylim when we are done.

actual_xlim = xlim;
actual_ylim = ylim;
logscale = [strcmp(get(ax,'xscale'),'log') strcmp(get(ax,'yscale'),'log')];

save_callBacks = ...
   installCallbacks(userhand,fig,...
       {'windowbuttonmotionfcn', 'windowbuttonupfcn'},{'motion', 'up'});

done = 0;
moved = 0;
while ~done
    event = waitForNextEvent(userhand);
    switch event
    case 'motion'
        if ~moved, 
            if ~immediate
                [oldptr,save_visible] = start_motion(fig,ax,borderaxes,...
                            data,erasemode,invisible,pointer);
            end 
            moved = 1;
        end

        p = np;
        [xlim,ylim,oxlim,oylim,np] = ...
              draglims(directflag,ax,panneraxes,xlim,ylim,bounds,p,logscale);

        if ~isequal([xlim ylim],[oxlim oylim])
            if ~isempty(pannerpatch)
                setpdata(pannerpatch,xlim,ylim)
            end
            if dynamicdrag
                doDynamicDrag(xlim,ylim,actual_xlim,actual_ylim,....
                              data,transform)
            end
        end

    case 'up'
        done = 1;
    end
end

if immediate | moved

    p = np;
    [xlim,ylim,oxlim,oylim,np] = ...
          draglims(directflag,ax,panneraxes,xlim,ylim,bounds,p,logscale);

    stop_motion(ax,borderaxes,data,invisible,save_visible)

    if dynamicdrag & moved
    % need to restore x and y data
        for i=1:length(data)
            if data(i).Fs > 0
                xdata = data(i).t0 + (0:size(data(i).data,1)-1)/data(i).Fs;
            else
                xdata = data(i).xdata;
            end
            for j=1:length(data(i).columns)
                y = data(i).data(:,data(i).columns(j));
                if ~isempty(transform)
                    y = feval(transform,y);
                end
                set(data(i).h(j),'xdata',xdata,'ydata',y)
            end
        end
    end

    set(ax,'xlim',xlim,'ylim',ylim)
    set(fig,oldptr{:})
end

set(fig,{'windowbuttonmotionfcn' 'windowbuttonupfcn'},save_callBacks)
set(userhand,'tag',save_userhand_tag)

if nargout>0
    varargout{1} = moved;
end
set(fig,ptr{:})
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [oldptr,save_visible] = start_motion(fig,ax,borderaxes,...
        data,erasemode,invisible,pointer)
    oldptr = getptr(fig);
    setptr(fig,pointer)
    switchToBorderAxes(ax,borderaxes)

    for i=1:length(data)
        set(data(i).h,'erasemode',erasemode)
    end
    save_visible = get(invisible,{'visible'});
    set(invisible,'visible','off')

function stop_motion(ax,borderaxes,data,invisible,save_visible)
    for i=1:length(data)
        set(data(i).h,'erasemode','normal')
    end
    set(invisible,{'visible'},save_visible)
    switchToMainAxes(ax,borderaxes)
 

function [xlim,ylim,oxlim,oylim,np] = draglims(directflag,ax,...
      panneraxes,xlim,ylim,bounds,p,logscale);
% This function takes the current point information and the old limits,
% and calculates the new xlims and ylims.
    if directflag
        np = get(ax,'currentpoint');  % new point
    else
        np = get(panneraxes,'currentpoint');  % new point
    end
    np = np(1,1:2);

    if any(isnan(np)), np = p; end

    oxlim = xlim;
    oylim = ylim;

    if directflag  % drag line in main axes
        if logscale(1)
            xlim = 10.^ (log10(oxlim) - log10(np(1)/p(1)));
        else
            xlim = oxlim - (np(1)-p(1));
        end
        if logscale(2)
            ylim = 10.^ (log10(oylim) - log10(np(2)/p(2)));
        else
            ylim = oylim - (np(2)-p(2));
        end
    else  % drag panner patch
        if logscale(1)
            xlim = 10.^ (log10(oxlim) + log10(np(1)/p(1)));
        else
            xlim = oxlim + (np(1)-p(1));
        end
        if logscale(2)
            ylim = 10.^ (log10(oylim) + log10(np(2)/p(2)));
        else
            ylim = oylim + (np(2)-p(2));
        end
    end

    if ~isempty(bounds)
        xlim1 = inbounds(xlim,bounds.xlim,logscale(1));
        ylim1 = inbounds(ylim,bounds.ylim,logscale(2));
        
        if ~isequal(xlim,xlim1)
            if directflag
                if logscale(1)
                    np(1) = 10.^( log10(np(1)) - log10(xlim1(1)/xlim(1)) );
                else
                    np(1) = np(1)-(xlim1(1)-xlim(1));
                end
            else
                if logscale(1)
                    np(1) = 10.^( log10(np(1)) + log10(xlim1(1)/xlim(1)) );
                else
                    np(1) = np(1)+(xlim1(1)-xlim(1));
                end
            end
            xlim = xlim1;
        end
        if ~isequal(ylim,ylim1)
            if directflag
                if logscale(2)
                    np(2) = 10.^( log10(np(2)) - log10(ylim1(1)/ylim(1)) );
                else
                    np(2) = np(2)-(ylim1(1)-ylim(1));
                end
            else
                if logscale(1)
                    np(2) = 10.^( log10(np(2)) + log10(ylim1(1)/ylim(1)) );
                else
                    np(2) = np(2)+(ylim1(1)-ylim(1));
                end
            end
            ylim = ylim1;
        end
    end

function saveCallbacks = installCallbacks(h,fig,callbackList,valueList)
% installCallbacks
%   inputs:
%      h - handle of object which will be changed by callbacks
%      fig - handle of figure
%      callbackList - list of figure callbacks in cell array
%           elements are e.g., 'windowbuttonmotionfcn'
%      valueList - same length as callbackList - cell array containing
%           values  (string or numeric) for h's userdata
%   outputs:
%      saveCallbacks - cellarray of what the callbacks were before

   saveCallbacks = cell(1,length(callbackList));
   for i=1:length(callbackList)
       if isstr(valueList{i})
           vstr = ['''' valueList{i} ''''];
       else
           vstr = num2str(valueList{i});
       end
       if 0,  % if problems with fig not being gcf, set this to 1
           figstr = ['hex2num(''' sprintf('%bx',h) ''')'];
       else
           figstr = 'gcf';
       end
       str = ['set(findall(' figstr ',' ...
              '''tag'',''' get(h,'tag') '''),''userdata'',' ...
              vstr ')'];
       saveCallbacks{i} = get(fig,callbackList{i});
       set(fig,callbackList{i},str)
   end

%  
function event = waitForNextEvent(h)
% waitForNextEvent

   set(h,'userdata',0)
   waitfor(h,'userdata')
   event = get(h,'userdata');
   

function switchToBorderAxes(ax,borderaxes)
% This function hides the main axes and shows the border axes.
% IF borderaxes is NOT EMPTY:
% 		It hides the main axes by setting its x and ycolor to the
% 		color of the axes, instead of turning the mainaxes invisible -
% 		 this is because if we just set visible to off, any lines
% 		 in background erasemode would erase in the FIGURE's background
% 		 color, not the axes' (and that would be bad).
% ELSE
%       Just turns off the axes ticks.
    if ~isempty(borderaxes)
        ax_color = get(ax,'color');
        if isstr(ax_color)
        % use figure's color in case axes's color is 'none'
            ax_color = get(get(ax,'parent'),'color');
        end
        set(ax,'xcolor',ax_color,'ycolor',ax_color)
        set(get(ax,'xlabel'),'color',get(borderaxes,'xcolor'))
        set(get(ax,'ylabel'),'color',get(borderaxes,'ycolor'))
        set(borderaxes,'visible','on')
    end
    set(ax,'xtick',[],'ytick',[])

function switchToMainAxes(ax,borderaxes)
% This function hides the border axes and shows the main axes.
% It undoes what switchToBorderAxes does.
% Assumes xcolor and ycolor of ax should be the same as those of borderaxes
    if ~isempty(borderaxes)
        set(ax,'xcolor',get(borderaxes,'xcolor'),...
                    'ycolor',get(borderaxes,'ycolor'))
        set(borderaxes,'visible','off')
    end
    set(ax,'xtickmode','auto','ytickmode','auto')


function doDynamicDrag(xlim,ylim,actual_xlim,actual_ylim,data,...
    transform)


    % needed by setDataWithTransform:
    xl = [xlim(:)' actual_xlim];
    yl = [ylim(:)' actual_ylim];

    hh=[]; xx={}; yy={};
    for i=1:length(data)
        if data(i).Fs>0
            % translate interval to integer indices
            xlim1 = xlim*data(i).Fs + (1-data(i).Fs*data(i).t0);
            xlim1 = [floor(xlim1(1)) ceil(xlim1(2))];
            ind = max(1,xlim1(1)):min(xlim1(2),size(data(i).data,1));
            if ~isempty(ind)
                if ind(1) == 0, ind(1) = []; end
                x = (ind-1)/data(i).Fs + data(i).t0;
                for j = 1:length(data(i).h)
                    y = data(i).data(ind,j);
                    if ~isempty(transform)
                        y = feval(transform,y); 
                    end
                    hh = [hh; data(i).h(j)];
                    xx = {xx{:} x};
                    yy = {yy{:} y};
                end
            else
                hh = [hh; data(i).h(:)];
                for j = 1:length(data(i).h)
                    xx = {xx{:} []};
                    yy = {yy{:} []};
                end
            end
        else
            for j = 1:length(data(i).h)
                x = data(i).xdata(:,j);
                y = data(i).data(:,j);
                if ~isempty(transform)
                    y = feval(transform,y); 
                end
                hh = [hh; data(i).h(j)];
                xx = {xx{:} x};
                yy = {yy{:} y};
            end
        end
    end
    % wait until end to set data, so all lines are erased, and THEN
    % redrawn.  This prevents background erasures from erasing other
    % previously drawn lines.
    setDataWithTransform(hh,xl,yl,xx',yy')

function setDataWithTransform(h,xlim,ylim,xd,yd)
%setDataWithTransform Set xdata and ydata of lines transforming from one
%   set of limits to another.
%   Inputs:
%      h - vector of line handles
%      xlim, ylim - limits of mainaxes
%         if xlim and ylim are 4 elements long, uses the 3rd and 4th 
%         elements as the interval in which to map the data.
%      xd - vector or cell array.  Each element of the cell
%            will get mapped from xlim to [0 1] or xlim(3:4)
%      yd - vector or cell array.  Each element of the cell
%            will get mapped from ylim to [0 1] or ylim(3:4)

if length(xlim)<=2
    xslope = 1/diff(xlim);
    xintercept = -xlim(1)*xslope;
else
    xslope = (xlim(4)-xlim(3))/(xlim(2)-xlim(1));
    xintercept = xlim(3)-xlim(1)*xslope;
end
if length(ylim)<=2
    yslope = 1/diff(ylim);
    yintercept = -ylim(1)*yslope;
else
    yslope = (ylim(4)-ylim(3))/(ylim(2)-ylim(1));
    yintercept = ylim(3)-ylim(1)*yslope;
end

if ~iscell(xd)
    xd = {xd};
end
if ~iscell(yd)
    yd = {yd};
end
for j=1:length(h)
    xd{j} = xslope*xd{j}+xintercept;
    yd{j} = yslope*yd{j}+yintercept;
end
set(h,{'xdata'},xd,{'ydata'},yd)

function setpdata(panpatch,xlim,ylim)
%setpdata - set x and ydata of patch object to rectangle specified by
% xlim and ylim input
 
     set(panpatch,'xdata',[xlim(1) xlim(2) xlim(2) xlim(1) xlim(1)], ...
              'ydata',[ylim(1) ylim(1) ylim(2) ylim(2) ylim(1)]) % thumb patch
    

  

