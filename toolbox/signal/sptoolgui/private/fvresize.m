function fvresize(varargin)
%FVRESIZE Resize callback for Filter Viewer figure.
%   This function can be called with 0 or 1 input arguments.
%   Case a: no input arguments
%      Used to reposition uicontrols during figure's ResizeFcn
%      Also calls Case b.
%   Case b: 1 input argument
%      Positions the axes objects in ud.ht.a according to which
%      axes are turned on (ud.prefs.plots).  Sets visible properties
%      of the axes.

%   Copyright 1988-2002 The MathWorks, Inc.
%       $Revision: 1.11 $

if nargin == 0
	fig = gcbf;
	
	ud = get(fig,'userdata');
	
	sz = ud.sz;
	
	fp = get(fig,'position');
	if fp(3)<ud.resize.minsize(1)  |  fp(4)<ud.resize.minsize(2)
	    w = max(ud.resize.minsize(1),fp(3));
	    h = max(ud.resize.minsize(2),fp(4));
	    fp = [fp(1) fp(2)+fp(4)-h w h];  % keep upper-left corner stationary
	    set(fig,'position',fp)  % THIS WILL CALL THE RESIZEFCN
	    return % SO JUST RETURN WHEN DONE
	end

   % Disable the following since the ruler might initiate a resize callback
   % when turning itself on/off, in which case the figure position is unchanged
	%if all(fp==ud.resize.figpos)
	%    return
	%end
	
	% first resize the underlying frames:
	set(ud.ht.frame1,'position',[1 0 sz.bw+6*sz.ffs-1 fp(4)-sz.ih])
   set(ud.ht.frame2,'position',[1 fp(4)-sz.ih-1 sz.bw+6*sz.ffs-1 sz.ih+1])

	% Now keep all the rest of the uicontrols in the same position 
        % relative to the upper left corner of the figure
	
	h = [     
	     ud.ht.plotsframe
	      ud.ht.freqframe
	       ud.ht.magframe
	     ud.ht.phaseframe
	    ud.ht.fscaleframe
	    ud.ht.frangeframe
	     ud.ht.plotslabel
	      ud.ht.freqlabel
   	         ud.ht.Fsedit
	    ud.ht.filterLabel
	    ud.ht.fscalelabel
	    ud.ht.frangelabel
	          ud.ht.cb(:)
	         ud.ht.magpop
	       ud.ht.phasepop
	      ud.ht.fscalepop
	      ud.ht.frangepop
	         ud.ht.Fsedit
	    ];
	
	dx = 0;
	dy = fp(4) - ud.resize.figpos(4);
	moveobjects(h,dx,dy)
	
	ud.resize.figpos = fp;
	set(fig,'userdata',ud)

   ut = get(ud.toolbar.whatsthis,'parent');
   tbfillblanks(ut,ud.toolbar.lineprop,ud.toolbar)
	
   fvresize(1,fig)
	
else
    % reposition the axes
    if nargin > 1
        fig = varargin{2};
    else
        fig = gcbo;
    end
    fp = get(fig,'position');
    ud = get(fig,'userdata');
    ax_panel = [ud.resize.leftwidth ud.sz.rh*ud.prefs.tool.ruler ...
          fp(3)-ud.resize.leftwidth ...
          fp(4)-ud.resize.topheight-ud.sz.rh*ud.prefs.tool.ruler];

    ax_pos = fvaxpos(ax_panel,ud.prefs.tilemode,...
                     ud.prefs.plots,ud.prefs.plotspacing);
    ind = find(ud.prefs.plots);
    if ~isempty(ind)
        set(ud.ht.a(ind),{'position'},ax_pos,'visible','on')
        for i = 1:length(ud.ht.a(ind))
            chAll = get(ud.ht.a(ind(i)),'children');
            if ud.prefs.tool.ruler & (ud.ht.a(ind(i)) == ud.mainaxes)
                % If on the mainaxes don't turn on the ruler lines/markers
                RulerLinehandles = ruler('getrulerlines',fig);
                ch = setdiff(chAll,RulerLinehandles);  % exclude rulers
                ruler('resizebtns',fig)
            else
                ch = chAll;
            end
            if ~isempty(ch), set(ch,'visible','on'), end
        end
        if any(ind==4)
            apos = get(ud.ht.a(4),'Position');
            dr = get(get(ud.ht.a(4),'xlabel'),'userdata');
            if ~isempty(dr)
               xlim = dr(1:2);
               ylim = dr(3:4);
            else
               xlim = [-1 1];
               ylim = [-1 1];
            end
            [newxlim,newylim] = newlims(apos,xlim,ylim);

            set(ud.ht.a(4),'xlim',newxlim,'ylim',newylim,...
                'DataAspectRatio',[1 1 1],...
                'PlotBoxAspectRatio',apos([3 4 4]))
        end
        set(fig,'userdata',ud)
    end
    ind1 = find(~ud.prefs.plots);
    set(ud.ht.a(ind1),'visible','off')
    for i = 1:length(ud.ht.a(ind1))
        ch = get(ud.ht.a(ind1(i)),'children');
        if ~isempty(ch), set(ch,'visible','off'), end
    end
    if ud.prefs.tool.ruler & strcmp(get(ud.mainaxes,'visible'),'on')
        % update the ruler XY limits
        plotIndex = find(ud.mainaxes == ud.ht.a);
        ud_new = filtview('setudlimits',ud,ud.ht.a,plotIndex);
        set(fig,'userdata',ud_new)
        ruler('newlimits',fig,plotIndex,ud.focusline)
    end
    apos = get(ud.mainaxes,'position')+[-1 -1 2 2];
    set(ud.ht.highlightAxes,'position',apos)

end

%-----------

function moveobjects(h,dx,dy)
%MOVEOBJECTS Move objects in handle vector by a dx,dy amount

pos = get(h,'position');
for i=1:length(h)
    pos{i} = pos{i} + [dx dy 0 0];
end
set(h,{'position'},pos)

function pos = fvaxpos(r,tilemode,plots,spacing)
%FVAXPOS Filter Viewer Axes Positions
%       Inputs:
%           r - panel rectangle for outer edges which bounds all axes, in pixels
%           tilemode - size vector
%           plots - plot vector, binary, 1==>plot this one
%           spacing - spacing in pixels from [left bottom right top] 
%       Outputs:
%         pos - cell array of position vectors for axes, has one element for
%              each nonzero entry of plots.

    numplots = length(find(plots));

    if numplots == 0
        pos = {};
        return
    end

    numrows = tilemode(1);
    numcols = min(tilemode(2),ceil(numplots/numrows));

    if numcols == 1, numrows = min(numrows,numplots); end

    if ((numcols*numrows)==6)&(min(numrows,numcols)>1)&(numplots==4)
        numrows = 2;
        numcols = 2;
    end

    % now break r into a numrows-by-numcols grid
    for i=1:numrows
        for j=1:numcols
            pos{i,j} = [r(1)+r(3)*(j-1)/numcols r(2)+r(4)*(i-1)/numrows ...
                         r(3)/numcols r(4)/numrows];
        end
    end    

    pos = flipud(pos);  

    pos = pos(:);  % rearrange into a column

    pos = pos(1:numplots);   

    % offset each position rectangle by spacing

    spacing = [spacing(1:2)  -(spacing(3:4)+spacing(1:2))];
    for i = 1:length(pos)
        pos{i} = pos{i} + spacing;
        pos{i}(3) = max(1,pos{i}(3));
        pos{i}(4) = max(1,pos{i}(4));
        pos{i} = round(pos{i});
    end


% =================================

function [newxlim,newylim] = newlims(apos,xlim,ylim);

dx = diff(xlim);
dy = diff(ylim);

if dx * apos(4)/apos(3) >= dy   % Snap to the requested x limits, expand y to fit
   newxlim = xlim;
   newylen = apos(4)/apos(3) * dx;
   newylim = mean(ylim) + [-newylen/2 newylen/2];
else
   newylim = ylim;
   newxlen = apos(3)/apos(4) * dy;
   newxlim = mean(xlim) + [-newxlen/2 newxlen/2];
end

if diff(newxlim) <= 0
   newxlim = xlim;
end
if diff(newylim) <= 0
   newylim = ylim;
end

