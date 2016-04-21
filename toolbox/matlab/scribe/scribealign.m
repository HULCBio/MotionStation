function scribealign(varargin)
%SCRIBEALIGN Align objects.
%   SCRIBEALIGN(H,Aligntype) aligns objects in handle vector H according to
%   the Aligntype:
%       'Left'   = Align left edges
%       'Center' = Align centers (X)
%       'Right'  = Align right edges
%       'Top'    = Align top edges
%       'Middle' = Align middles (Y)
%       'Bottom' = Align bottom edges
%       'VDistAdj' = Vertical distribution spaced between adjacent edges
%       'VDistTop' = Vertical distribution spaced from top to top
%       'VDistMid' = Vertical distribution spaced between middles
%       'VDistBot' = Vertical distribution spaced from bottom to bottom
%       'HDistAdj' = Horizontal distribution spaced between adjacent edges
%       'HDistLeft' = Horizontal distribution spaced from left edges
%       'HDistCent' = Horizontal distribution spaced at centers
%       'HDistRight' = Horizontal distribution spaced at right edges
%       'Smart' = Align and Distribute into closest grid%
%   SCRIBEALIGN(FIG,Aligntype) aligns selected objects (with 'position'
%   properties) in FIG according to Aligntype.
%
%   Examples:
%       r(1) = scriberect([10,20,40,40]);
%       r(2) = scriberect([20,30,50,30]);
%       scribealign(r,'Left');
%
%       scribealign(gcf,'Top');
%
%       scribealign(gcf,'VDistMid',20);
%
%   See also PLOTEDIT.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $  $  $  $

if nargin==1 && ~ischar(varargin{1}) && ishandle(varargin{1}) && isequal(get(varargin{1},'type'),'figure')
    fig = varargin{1};
    % START GUI
    if isappdata(0,'ScribeGUIS_Aligner')
        AlignFrame = getappdata(0,'ScribeGUIS_Aligner');
        AlignFrame.setVisible(true);
        AlignFrame.requestFocus;
        aligntogg = uigettoolbar(fig,'Annotation.AlignDistribute');
        set(aligntogg,'state','off');
        return;
    end
    AlignFrame=com.mathworks.mwswing.MJFrame('Align Distribute Tool');
    AlignPanel=com.mathworks.page.scribealign.ScribeAlignmentPanel;
    AlignFrame.getContentPane.add(AlignPanel);
    AlignFrame.setResizable(false);
    AlignFrame.pack;
    AlignFrame.show;
    setappdata(0,'ScribeGUIS_Aligner',AlignFrame);
    start_listeners(AlignFrame,fig);
    aligntogg = uigettoolbar(fig,'Annotation.AlignDistribute');
    set(aligntogg,'state','off');
    
elseif ischar(varargin{1}) && nargin>1
    % GUI FUNCTION
    switch varargin{1}
        case 'doalign'
            vals = varargin{2};
            if length(vals)~=4
                error('bad alignment input');
            end
            vop = vals(1);
            vspace = vals(2);
            hop = vals(3);
            hspace = vals(4);            
            % do the vertical alignment
            if vspace <=0
                switch vop
                    case 0
                        %noop
                    case 4
                        scribealign(gcf,'Top');
                    case 2
                        scribealign(gcf,'Middle');
                    case 5
                        scribealign(gcf,'Bottom');
                    case 7
                        scribealign(gcf,'VDistAdj');
                    case 11
                        scribealign(gcf,'VDistTop');
                    case 9
                        scribealign(gcf,'VDistMid');
                    case 12
                        scribealign(gcf,'VDistBot');
                    otherwise
                        error('bad vertical alignment type');
                end
            else
                switch vop
                    case 0
                        %noop
                    case 4
                        scribealign(gcf,'Top',vspace);
                    case 2
                        scribealign(gcf,'Middle',vspace);
                    case 5
                        scribealign(gcf,'Bottom',vspace);
                    case 7
                        scribealign(gcf,'VDistAdj',vspace);
                    case 11
                        scribealign(gcf,'VDistTop',vspace);
                    case 9
                        scribealign(gcf,'VDistMid',vspace);
                    case 12
                        scribealign(gcf,'VDistBot',vspace);
                    otherwise
                        error('bad vertical alignment type');
                end
            end
            if hspace <=0
                switch hop
                    case 0
                        %noop
                    case 1
                        scribealign(gcf,'Left');
                    case 2
                        scribealign(gcf,'Center');
                    case 3
                        scribealign(gcf,'Right');
                    case 7
                        scribealign(gcf,'HDistAdj');
                    case 8
                        scribealign(gcf,'HDistLeft');
                    case 9
                        scribealign(gcf,'HDistCent');
                    case 10
                        scribealign(gcf,'HDistRight');
                    otherwise
                        error('bad horizontal alignment type');
                end
            else
                switch hop
                    case 0
                        %noop
                    case 1
                        scribealign(gcf,'Left',hspace);
                    case 2
                        scribealign(gcf,'Center',hspace);
                    case 3
                        scribealign(gcf,'Right',hspace);
                    case 7
                        scribealign(gcf,'HDistAdj',hspace);
                    case 8
                        scribealign(gcf,'HDistLeft',hspace);
                    case 9
                        scribealign(gcf,'HDistCent',hspace);
                    case 10
                        scribealign(gcf,'HDistRight',hspace);
                    otherwise
                        error('bad horizontal alignment type');
                end
            end
    end
    
else % ALIGNMENT OPERATIONS
    
    [fig,h,aligntype,disttype,space]=process_args(varargin);
    
    if isempty(h)
        warning('nothing to align');
        return;
    elseif length(h)==1
        return;
    end
    
    [halign,hunits,hpos,tops,bots,mids,lefts,rights,cents,widths,heights,top,bot,left,right,middle,center] = prepare_alignment(h);
    
    if ~isempty(aligntype)
        do_alignment(halign,hpos,tops,lefts,widths,heights,top,bot,left,right,middle,center,aligntype);
    else
        if strcmpi(disttype,'smart')
            do_smartalign(halign,hpos,tops,bots,lefts,rights,widths,heights,top,bot,left,right,middle,center,space);
        else
            do_distribution(halign,hpos,tops,bots,lefts,rights,widths,heights,top,bot,left,right,middle,center,disttype,space);
        end
    end
    cleanup_alignment(halign,hunits);
end

%---------------------------------------------------------------%
function [halign,hunits,hpos,tops,bots,mids,lefts,rights,cents,widths,heights,top,bot,left,right,middle,center] = prepare_alignment(h)

top=[]; bot=[]; right=[]; left=[]; middle=[]; center=[];
tops=[]; mids=[]; bots=[]; lefts=[]; cents=[]; rights=[];
halign = [];
hunits = {};
hpos = {};
for k=1:length(h)
    [ok,u,p] = getalignobjectposition(h(k));
    if ok
        hunits{length(hunits)+1} = u;
        hpos{length(hpos)+1} = p;
        halign = [halign,double(h(k))];
        tops(length(halign)) = p(2) + p(4);
        bots(length(halign)) = p(2);
        mids(length(halign)) = (tops(length(halign)) + bots(length(halign)))/2;
        lefts(length(halign)) = p(1);
        rights(length(halign)) = p(1) + p(3);
        cents(length(halign)) = (lefts(length(halign)) + rights(length(halign)))/2;
        widths(length(halign)) = p(3);
        heights(length(halign)) = p(4);
        if isempty(top) || length(halign)==1 || top < (p(2) + p(4))
            top = p(2) + p(4);
        end
        if isempty(bot) || length(halign)==1 || bot > p(2) 
            bot = p(2);
        end
        if isempty(left) || length(halign)==1 || left > p(1)
            left = p(1);
        end
        if isempty(right) || length(halign)==1 || right < (p(1) + p(3))
            right = p(1) + p(3);
        end
    end
end
if isempty(halign)
    warning('nothing to be aligned');
end
middle = (top + bot)/2;
center = (left + right)/2;

%---------------------------------------------------------------%
function cleanup_alignment(h,u)

for k=1:length(u)
    set(handle(h(k)),'units',u{k});
end

%---------------------------------------------------------------%
function do_distribution(halign,hpos,tops,bots,lefts,rights,widths,heights,top,bot,left,right,middle,center,disttype,space)

switch disttype
    
    case 'vdistadj'
        % sort by tops descending
        [tops,ind] = sort(tops);
        tops = fliplr(tops); ind = fliplr(ind);
        if isempty(space)
            availablespace = top - bot;
            objectspace = sum(heights);
            if objectspace > availablespace
                space = 0;
            else
                space = (availablespace - objectspace)/(length(halign)-1);
            end
        end
        yt = top;
        for k=1:length(halign)
            ha = halign(ind(k)); %index from sorted list
            pos = hpos{ind(k)};
            pos(2) = yt - pos(4);
            yt = yt - (pos(4) + space);
            setalignobjectposition(ha,pos);
        end
        
    case 'vdisttop'
        % sort by tops descending
        [tops,ind] = sort(tops);
        tops = fliplr(tops); ind = fliplr(ind);
        if isempty(space)
            space = ((top - bot) - heights(ind(length(halign))))/(length(halign)-1);
        end
        yt = top;
        for k=1:length(halign)
            ha = halign(ind(k)); %index from sorted list
            pos = hpos{ind(k)};
            pos(2) = yt - pos(4);
            yt = yt - space;
            setalignobjectposition(ha,pos);
        end
        
    case 'vdistmid'
        % sort by tops descending
        [tops,ind] = sort(tops);
        tops = fliplr(tops); ind = fliplr(ind);
        if isempty(space)
            h1 = heights(ind(length(halign)))/2;
            h2 = heights(ind(1))/2;
            space = ((top-bot)-(h1 + h2))/(length(halign)-1);
        end
        ymid = top - (heights(ind(1))/2);
        for k=1:length(halign)
            ha = halign(ind(k)); %index from sorted list
            pos = hpos{ind(k)};
            pos(2) = ymid - (pos(4)/2);
            ymid = ymid - space;
            setalignobjectposition(ha,pos);
        end
        
    case 'vdistbot'
        [bots,ind] = sort(bots);
        if isempty(space)
            space = (bots(length(bots))- bots(1))/(length(bots)-1);
        end
        yb = bots(1);
        for k=1:length(halign)
            ha = halign(ind(k)); %index from sorted list
            pos = hpos{ind(k)};
            pos(2) = yb;
            yb = yb + space;
            setalignobjectposition(ha,pos);
        end 
        
    case 'hdistadj'
        % sort by lefts ascending
        [lefts,ind] = sort(lefts);
        if isempty(space)
            availablespace = right - left;
            objectspace = sum(widths);
            if objectspace > availablespace
                space = 0;
            else
                space = (availablespace - objectspace)/(length(halign)-1);
            end
        end
        xl = left;
        for k=1:length(halign)
            ha = halign(ind(k)); %index from sorted list
            pos = hpos{ind(k)};
            pos(1) = xl;
            xl = xl + (pos(3) + space);
            setalignobjectposition(ha,pos);
        end
        
    case 'hdistleft'
        % sort by lefts ascending
        [lefts,ind] = sort(lefts);
        if isempty(space)
            space = ((right - left) - widths(ind(length(halign))))/(length(halign)-1);
        end
        xl = left;
        for k=1:length(halign)
            ha = halign(ind(k)); %index from sorted list
            pos = hpos{ind(k)};
            pos(1) = xl;
            xl = xl + space;
            setalignobjectposition(ha,pos);
        end
        
    case 'hdistcent'  
        % sort by tops descending
        [lefts,ind] = sort(lefts);
        if isempty(space)
            w1 = widths(ind(length(halign)))/2;
            w2 = widths(ind(1))/2;
            space = ((right - left)-(w1 + w2))/(length(halign)-1);
        end
        xmid = left + (widths(ind(1))/2);
        for k=1:length(halign)
            ha = halign(ind(k)); %index from sorted list
            pos = hpos{ind(k)};
            pos(1) = xmid - (pos(3)/2);
            xmid = xmid + space;
            setalignobjectposition(ha,pos);
        end
        
    case 'hdistright'
        [rights,ind] = sort(rights);
        if isempty(space)
            space = (rights(length(rights))- rights(1))/(length(rights)-1);
        end
        xl = rights(1);
        for k=1:length(halign)
            ha = halign(ind(k)); %index from sorted list
            pos = hpos{ind(k)};
            pos(1) = xl - pos(3);
            xl = xl + space;
            setalignobjectposition(ha,pos);
        end 
end

%---------------------------------------------------------------%
function do_alignment(halign,hpos,tops,lefts,widths,heights,top,bot,left,right,middle,center,aligntype)

for k=1:length(halign)
    pos = hpos{k};
    switch aligntype
        case 'left'
            pos(1) = left;
        case 'center'
            pos(1) = center - pos(3)/2;
        case 'right'
            pos(1) = right - pos(3);
        case 'top'
            pos(2) = top - pos(4);
        case 'middle'
            pos(2) = middle - pos(4)/2;
        case 'bottom'
            pos(2) = bot;
    end
    setalignobjectposition(halign(k),pos);
end

%-------------------------------------------------------------%
function do_smartalign(halign,hpos,tops,bots,lefts,rights,widths,heights,top,bot,left,right,middle,center,space)

minx = min(lefts);maxx = max(rights);miny = min(bots);maxy = max(tops);
avw = sum(widths)/length(widths);avh = sum(heights)/length(heights);
maxcols = (maxx - minx)/avw;maxrows = (maxy - miny)/avh;
used = zeros(1,length(halign));
rows = zeros(1,length(halign));cols = zeros(1,length(halign));
row = 1;
% loop, adding rows until all ar used;
while ~all(used)
    % get the top object
    gotone=0;
    for k=1:length(halign)
        if ~used(k);
            pos = hpos{k};
            if ~gotone || top < (pos(2) + pos(4))
                top = pos(2) + pos(4);  topi = k;
            end
            gotone=1;
        end
    end
    % find top left object
    % start with top
    ul = topi;
    pos = hpos{ul};
    moreleft=1; joinfrx=.4;
    while moreleft
        found=0;
        % look for one to the left
        for k=1:length(halign)
            if k~=ul && ~used(k)
                tpos = hpos{k};
                if tpos(1) < pos(1)
                    if tpos(2)>pos(2) || (tpos(2) + tpos(4)) > pos(2) + (joinfrx*pos(4))
                        found=1;
                        ul = k;
                        pos = tpos;
                    end
                end
            end
            if ~found
                moreleft=0;
            end
        end
    end
    rows(ul) = row;  cols(ul) = 1; used(ul) = 1;
    % get everything in the row
    rowxpos = pos(1);
    for k=1:length(halign)
        if ~used(k)
            tpos = hpos{k};
            if tpos(2)>pos(2) || (tpos(2) + tpos(4)) > pos(2) + (joinfrx*pos(4))
                rowxpos = [rowxpos,tpos(1)];
                rows(k)=row;  used(k)=1;
            end
        end
    end
    [rowxpos,rind] = sort(rowxpos);
    col = 2;
    for k=1:length(halign)
        if k~=ul
            if rows(k)==row
                cols(k) = rind(col); col = col + 1;
            end
        end
    end
    row = row + 1;
end
% find all in first row and align middle
alignset=[];
for k=1:length(halign)
    if rows(k)==1
        alignset = [alignset,halign(k)];
    end
end
if ~isempty(alignset)
    scribealign(alignset,'middle')
end
% find all in last row and align middle
rlast = max(rows);
alignset=[];
for k=1:length(halign)
    if rows(k)==rlast
        alignset = [alignset,halign(k)];
    end
end
if ~isempty(alignset)
    scribealign(alignset,'middle')
end
% find all in first col and align center
alignset=[];
for k=1:length(halign)
    if cols(k)==1
        alignset = [alignset,halign(k)];
    end
end
if ~isempty(alignset)
    scribealign(alignset,'center')
end
% find all in last col and align center
clast = max(cols);
alignset=[];
for k=1:length(halign)
    if cols(k)==clast
        alignset = [alignset,halign(k)];
    end
end
if ~isempty(alignset)
    scribealign(alignset,'center')
end
% hdist adj each row
for r=1:rlast
    alignset=[];
    for k=1:length(halign)
        if rows(k)==r
            alignset = [alignset,halign(k)];
        end
    end
    if ~isempty(alignset)
        scribealign(alignset,'hdistcent')
    end
end
% vdist adj each col
for c=1:clast
    alignset=[];
    for k=1:length(halign)
        if cols(k)==c
            alignset = [alignset,halign(k)];
        end
    end
    if ~isempty(alignset)
        scribealign(alignset,'vdistmid');
    end
end

%-------------------------------------------------------------%
function [fig,h,aligntype,disttype,space]=process_args(argin)

fig = []; h = []; aligntype = ''; disttype = ''; space=[];

for k=1:length(argin)
    if ischar(argin{k})
        if isaligntype(argin{k})
            aligntype=lower(argin{k});
        elseif isdisttype(argin{k})
            disttype=lower(argin{k});
        else
            error('not a valid alignment type');
        end
    elseif isempty(aligntype) && ...
            isempty(disttype) && ...
            all(ishandle(argin{k})) % can't pass handle after type of operation
        doublehandle = double(argin{k});
        if length(doublehandle)>1
            h = doublehandle;
        elseif isequal(get(doublehandle,'type'),'figure')
            fig = doublehandle;
        else
            h = doublehandle;
        end
    elseif isnumeric(argin{k})
        if length(argin{k}) == 1
            if isempty(space)
                space = argin{k};
            else
                error('extra numeric argument');
            end
        else
            error('unknown argument');
        end
    else
        error('unknown argument');
    end
end

if isempty(aligntype) && isempty(disttype)
    error('alignment type not specified');
end
if isempty(fig)
    fig = gcf;
end
if isempty(h)
    h = get_figure_selected_objects(fig);  
else
    fp = get_figure_parent(h);
    if ~all(repmat(fig,1,length(fp))==fp)
        error('all objects to be aligned must be of the same parent figure');
    end
end

%------------------------------------------------------------%
function p=get_figure_parent(h)
p=[];
for k=1:length(h)
    if ~ishandle(h(k))
        error('non handle object')
    end
    a=[]; type='';
    ph = h(k);
    while ~strcmpi(type,'figure')
        ph = get(ph,'parent');
        if isempty(ph)
            error('no figure parent found');
        end
        type = get(ph,'type');
    end
    p(k) = ph;
end

%------------------------------------------------------------%
function ok=isaligntype(s)

%       'Left'   = Align left edges
%       'Center' = Align centers (X)
%       'Right'  = Align right edges
%       'Top'    = Align top edges
%       'Middle' = Align middles (Y)
%       'Bottom' = Align bottom edges
if strcmpi(s,'Left')||...
        strcmpi(s,'Center')||...
        strcmpi(s,'Right')||...
        strcmpi(s,'Top')||...
        strcmpi(s,'Middle')||...
        strcmpi(s,'Bottom')
    ok=1;
else 
    ok=0;
end
%-------------------------------------------------------------%
function ok=isdisttype(s)

%       'VDistAdj' = Vertical distribution spaced between adjacent edges
%       'VDistTop' = Vertical distribution spaced from top to top
%       'VDistMid' = Vertical distribution spaced between middles
%       'VDistBot' = Vertical distribution spaced from bottom to bottom
%       'HDistAdj' = Horizontal distribution spaced between adjacent edges
%       'HDistLeft' = Horizontal distribution spaced from left edges
%       'HDistCent' = Horizontal distribution spaced at centers
%       'HDistRight' = Horizontal distribution spaced at right edges
%       'Smart' = Smart distribution and alignment - pretty smart
if strcmpi(s,'VDistAdj')||...
        strcmpi(s,'VDistTop')||...
        strcmpi(s,'VDistMid')||...
        strcmpi(s,'VDistBot')||...
        strcmpi(s,'HDistAdj')||...
        strcmpi(s,'HDistLeft')||...
        strcmpi(s,'HDistCent')||...
        strcmpi(s,'HDistRight')||...
        strcmpi(s,'Smart')
    ok=1;
else 
    ok=0;
end
%-------------------------------------------------------------%
function h = get_figure_selected_objects(fig)

h=[];
scribeov = handle(findall(fig,'tag','scribeOverlay'));
if isempty(scribeov)
    return;
end
methods(scribeov,'fixselectobjs');
h = double(get(scribeov,'SelectedObjects'));

%-------------------------------------------------------------%
function [ok,u,p] = getalignobjectposition(h)

u=[];p=zeros(1,4);ok=0;
fig = ancestor(h,'figure');
hh = handle(h);
linobjs = {'scribe.arrow','scribe.doublearrow','scribe.line','scribe.textarrow'};
tboxobjs = {'scribe.textbox','scribe.scriberect','scribe.scribeellipse'};
if any(strcmp(class(hh),linobjs))
  x = hh.X;
  y = hh.Y;
  u = get(hh,'units');
  if x(2) > x(1)
    p(1) = x(1);
    p(3) = x(2) - x(1);
  else
    p(1) = x(2);
    p(3) = x(1) - x(2);
  end
  if y(2) > y(1)
    p(2) = y(1);
    p(4) = y(2) - y(1);
  else
    p(2) = y(2);
    p(4) = y(1) - y(2);
  end
  p = hgconvertunits(fig,p,get(h,'Units'),'pixels',fig);
  ok=1;
elseif any(strcmp(class(hh),tboxobjs))
  u = get(hh,'units');
  p = hgconvertunits(fig,get(h,'Position'),get(h,'Units'),'pixels',fig);
  ok=1;
elseif isprop(h,'units')
  u = get(h,'units');
  if isprop(h,'position')
    set(h,'units','pixels');
    p = get(h,'position');
    ok=1;
  end
end

%-------------------------------------------------------------%
function setalignobjectposition(h,pos)

fig = ancestor(h,'figure');
hh = handle(h);
linobjs = {'scribe.arrow','scribe.doublearrow','scribe.line','scribe.textarrow'};
tboxobjs = {'scribe.scriberect','scribe.textbox','scribe.scribeellipse'};
if any(strcmp(class(hh),linobjs))
  pos = hgconvertunits(fig,pos,'pixels',get(h,'Units'),fig);
  XX = hh.X;
  YY = hh.Y;
  if XX(1)<XX(2)
    x = [pos(1),pos(1)+pos(3)];
  else
    x = [pos(1) + pos(3),pos(1)];
  end
  if YY(1)<YY(2)
    y = [pos(2),pos(2)+pos(4)];
  else
    y = [pos(2)+pos(4),pos(2)];
  end
  hh.X = x;
  hh.Y = y;
elseif any(strcmp(class(hh),tboxobjs))
  p = hgconvertunits(fig,pos,'pixels',get(h,'Units'),fig);
  set(h,'Position',p);
else
  set(h,'position',pos);
end

%-------------------------------------------------------------%
% GUI MANAGEMENT
%-------------------------------------------------------------%
function start_listeners(gui,fig)

if ~isprop(handle(fig),'ScribeAlignGUIFigListeners')
    flp = schema.prop(handle(fig),'ScribeAlignGUIFigListeners','MATLAB array');
    flp.AccessFlags.Serialize = 'off';
    flp.Visible = 'off';
end

cls = classhandle(handle(0));
ml.cfigchanged = handle.listener(0, cls.findprop('CurrentFigure'),'PropertyPostSet', {@currentFigureChanged, gui, fig});
set(ml.cfigchanged,'Enabled','on');
setappdata(0,'ScribeAlignGUIMATLABListeners',ml);

cls = classhandle(handle(fig));
fl.deleting = handle.listener(fig,'ObjectBeingDestroyed',{@figureDestroyed,gui,fig});
set(fl.deleting,'Enabled','on');
set(handle(fig),'ScribeAlignGUIFigListeners',fl);

%-------------------------------------------------------------%
function kill_listeners

% remove all listeners
if isappdata(0,'ScribeAlignGUIMATLABListeners');
    rmappdata(0,'ScribeAlignGUIMATLABListeners');
end

fig = get(0,'CurrentFigure');
if isempty(fig)
    return;
end

if isprop(handle(fig),'ScribeAlignGUIFigListeners')
    set(handle(fig),'ScribeAlignGUIFigListeners',[]);
end

%-------------------------------------------------------------%
function currentFigureChanged(hProp, eventData, gui, oldfig)

fig = get(0,'CurrentFigure');
if isempty(fig)  %no current figure, close editor and kill listeners
    gui.setVisible(false);
    kill_listeners;
    return;
else
    if isequal(fig,oldfig) %if current figure is unchanged
        return;
    end
end

% get rid of old figure listeners
if ishandle(oldfig)
    if ~strcmpi('on',get(oldfig,'BeingDeleted'))
        if isprop(handle(oldfig),'ScribeAlignGUIFigListeners')
            fl = get(handle(oldfig),'ScribeAlignGUIFigListeners');
            set(fl.deleting,'Enabled','off');
            set(handle(oldfig),'ScribeAlignGUIFigListeners',fl);
        end
    end
end

cls = classhandle(handle(0));
ml.cfigchanged = handle.listener(0, cls.findprop('CurrentFigure'),'PropertyPostSet', {@currentFigureChanged, gui, fig});
set(ml.cfigchanged,'Enabled','on');
setappdata(0,'ScribeAlignGUIMATLABFigListeners',ml);

if ~isprop(handle(fig),'ScribeAlignGUIFigListeners')
    flp = schema.prop(handle(fig),'ScribeAlignGUIFigListeners','MATLAB array');
    flp.AccessFlags.Serialize = 'off';
    flp.Visible = 'off';
end
cls = classhandle(handle(fig));
fl.deleting = handle.listener(fig,'ObjectBeingDestroyed',{@figureDestroyed,gui,fig});
set(fl.deleting,'Enabled','on');
set(handle(fig),'ScribeAlignGUIFigListeners',fl);

%-------------------------------------------------------------%
function figureDestroyed(hProp,eventData,gui,oldfig)

nfigs=length(findobj(0,'type','figure'));
if nfigs<=1
    gui.setVisible(false);
    kill_listeners;
end

%-------------------------------------------------------------%
