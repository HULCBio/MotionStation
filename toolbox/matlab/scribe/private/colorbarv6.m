function h=colorbarv6(arg1, arg2, arg3)
%COLORBARV6 Display MATLAB 6 color bar (color scale).
%   COLORBARV6('vert') appends a vertical color scale to the current
%   axes. COLORBARV6('horiz') appends a horizontal color scale.
%
%   COLORBARV6(H) places the colorbar in the axes H. The colorbar will
%   be horizontal if the axes H width > height (in pixels).
%
%   COLORBARV6 without arguments either adds a new vertical color scale
%   or updates an existing colorbar.
%
%   H = COLORBARV6(...) returns a handle to the colorbar axes.
%
%   COLORBARV6(...,'peer',AX) creates a colorbar associated with axes AX
%   instead of the current axes.
%
%   See also COLORBAR, IMAGESC.

%   Clay M. Thompson 10-9-92
%   Copyright 1984-2003 The MathWorks, Inc.

narg = nargin;

% when this is done doing whatever it does
% gcf and gca should be what they were when we got here
% so get them now

GCF = gcf;
GCA = gca;

if narg<2
	haxes = gca;
	hfig = gcf;
	if narg<1
    	loc = 'vert'; % Default mode when called without arguments.
	else
		% Peer must be followed by a valid axes handle.
		if strcmp(arg1,'peer')
			error('Parameter ''peer'' must be followed by an axes handle.');
		end
		loc = arg1;
	end
elseif narg == 2
	% This is the case ONLY when peer and a handle is passed.
	if strcmp(arg1,'peer')
		if ishandle(arg2) & strcmp(get(arg2, 'type'), 'axes')
			haxes = arg2;
			hfig = get(haxes,'parent');
			loc = 'vert';
			narg = 0;
		else
			% If second arg is not a valid axes handle
			error('Second argument must be a scalar axes handle.');
		end
	else
		error('Unknown command option.');
	end
else
	% For three arguments the first must be the mode or a axes handle, 
	% second must be the string 'peer' and third must be the peer axes handle.
	loc = arg1;
	if strcmp(arg2,'peer')
		if ishandle(arg3) & strcmp(get(arg3, 'type'), 'axes')
			haxes = arg3;
			hfig = get(haxes,'parent');
			narg = 1;
		else
			error('Third argument must be a scalar axes handle.');
		end
	else
		error('Unknown command option.');
	end
end

% Catch colorbar('delete') special case -- must be called by the deleteFcn.
if narg==1 & strcmp(loc,'delete')
    ax = gcbo;
    % 
    % If called from ColorbarDeleteProxy, delete the colorbar axes
    %
    if strcmp(get(ax,'tag'),'ColorbarDeleteProxy')
        cbo = ax;
        ax = get(cbo,'userdata');
        if ishandle(ax)
            ud = get(ax,'userdata');
            
            % Do a sanity check before deleting colorbar
            if isfield(ud,'ColorbarDeleteProxy') & ...
                    isequal(ud.ColorbarDeleteProxy,cbo) & ...
                    ishandle(ax)
                try
            	    delete(ax)
            	end
            end
        end
    else
        %
        % If called from the colorbar image resize the original axes
        %
        if strcmp(get(ax,'tag'),'TMW_COLORBAR')
            ax=get(ax,'parent');
        end
       
        ud = get(ax,'userdata');
        if isfield(ud,'PlotHandle') & ...
                ishandle(ud.PlotHandle) & ...
                isfield(ud,'origPos') & ...
                ~isempty(ud.origPos)
            
            % Get position and orientation of colorbar being deleted
            delpos = get(ax,'Position');
            if delpos(3)<delpos(4)
                delloc = 'vert';
            else
                delloc = 'horiz';
            end
            
            % Search figure for existing colorbars
            % If one is found with the same plothandle but that is not
            % the same colorbar as the one being deleted
            % Get its position and orientation
            otherloc = '';
            otherpos = [];
            othercbar = [];
            phch = get(findall(hfig,'type','image','tag','TMW_COLORBAR'),{'parent'});
            for i=1:length(phch)
                phud = get(phch{i},'userdata');
                if isfield(ud,'PlotHandle') & isfield(phud,'PlotHandle')
                    if isequal(ud.PlotHandle,phud.PlotHandle)
                        if ~isequal(phch{i},ax)
                            othercbar = phch{i};
                            otherpos = get(phch{i},'Position');
                            if otherpos(3)<otherpos(4)
                                otherloc = 'vert';
                            else
                                otherloc = 'horiz';
                            end
                            break;
                        end
                    end
                end
            end
            
            
            % get the current plothandle units
            units = get(ud.PlotHandle,'units');
            % set plothandle units to normalized
            set(ud.PlotHandle,'units','normalized');
            % get current plothandle position
            phpos = get(ud.PlotHandle,'position');
            
            % if the colorbar being deleted is vertical
            % set the plothandle axis width to the original Pos
            % width of the colorbar being deleted
            % if there is another (horizontal) colorbar
            % do the same to that
            if strncmp(delloc,'vert',1) 
                phpos(3) = ud.origPos(3);
                set(ud.PlotHandle,'position',phpos);
                if strncmp(otherloc,'horiz',1)
                    otherpos(3) = ud.origPos(3);
                    set(othercbar,'position',otherpos);
                end
                
            % elseif the colorbar being deleted is horizontal
            % set the plothandle y and height to the original Pos
            % y and height of the colorbar being deleted.
            % if there is another (vertical) colorbar
            % do the same to that
            elseif strncmp(delloc,'horiz',1)
                phpos(4) = ud.origPos(4);
                phpos(2) = ud.origPos(2);
                set(ud.PlotHandle,'position',phpos);
                if strncmp(otherloc,'vert',1)
                    otherpos(4) = ud.origPos(4);
                    otherpos(2) = ud.origPos(2);
                    set(othercbar,'position',otherpos);
                end
                
            end
            
            % restore the plothandle units
            set(ud.PlotHandle,'units',units);
            
            
        end
        
        if isfield(ud,'ColorbarDeleteProxy') & ishandle(ud.ColorbarDeleteProxy)
            try
                delete(ud.ColorbarDeleteProxy)
            end
        end
    end
    % before going, be sure to reset current figure and axes
    if ishandle(GCF) && ~strcmpi(get(GCF,'beingdeleted'),'on')
        set(0,'currentfigure',GCF);
    end
    if ishandle(GCA) && ~strcmpi(get(GCA,'beingdeleted'),'on')
        set(gcf,'currentaxes',GCA);
    end
    return
end

%   If called with COLORBAR(H) or for an existing colorbar, don't change
%   the NextPlot property.

ax = [];
cbarinaxis=0;
if narg==1
    if ishandle(loc)
        ax = loc;
        ud = get(ax,'userdata');
        if isfield(ud,'ColorbarDeleteProxy')
            error('Colorbar cannot be added to another colorbar.')
        end
        if ~strcmp(get(ax,'type'),'axes')
            error('Requires axes handle.');
        end
        
        cbarinaxis=1;
        units = get(ax,'units');
        set(ax,'units','pixels');
        rect = get(ax,'position');
        set(ax,'units',units);
        if rect(3) > rect(4)
            loc = 'horiz';
        else
            loc = 'vert';
        end
    end
end


% the axes handle, shorter name
h = haxes;

% Catch attempt to add colorbar to a colorbar or legend
% if the axes h is a colorbar or legend (according to tag)
% reset it to the PlotHandle field of its userdata
tagstr = get(h,'tag');
if strcmpi('Legend',tagstr) | strcmpi('Colorbar',tagstr)
    ud = get(h,'userdata');
    if isfield(ud,'PlotHandle')
        h = ud.PlotHandle;
    else
        % If handle is a dying or mutant colorbar or legend
        % do nothing.
        % but before going, be sure to reset current figure and axes
        set(0,'currentfigure',GCF);
        set(gcf,'currentaxes',GCA);
        return;
    end
end

% Determine color limits by context.  If any axes child is an image
% use scale based on size of colormap, otherwise use current CAXIS.

ch = get(gcda(hfig,h),'children');
hasimage = 0; t = [];
cdatamapping = 'direct';

for i=1:length(ch),
    typ = get(ch(i),'type');
    if strcmp(typ,'image'),
        hasimage = 1;
        cdatamapping = get(ch(i), 'CDataMapping');
    elseif strcmp(typ,'surface') & ...
            strcmp(get(ch(i),'FaceColor'),'texturemap') % Texturemapped surf
        hasimage = 2;
        cdatamapping = get(ch(i), 'CDataMapping');
    elseif strcmp(typ,'patch') | strcmp(typ,'surface')
        cdatamapping = get(ch(i), 'CDataMapping');
    end
end

if ( strcmp(cdatamapping, 'scaled') )
  % Treat images and surfaces alike if cdatamapping == 'scaled'
  t = caxis(h);
  d = (t(2) - t(1))/size(colormap(h),1);
  t = [t(1)+d/2  t(2)-d/2];
else
    if hasimage,
        t = [1, size(colormap(h),1)]; 
    else
        t = [1.5  size(colormap(h),1)+.5];
    end
end

oldloc = 'none';
oldax = [];
if ~cbarinaxis
    % Search for existing colorbar (parents of TMW_COLORBAR tagged images)
    ch = get(findall(hfig,'type','image','tag','TMW_COLORBAR'),{'parent'});
    ax = [];
    for i=1:length(ch)
        ud = get(ch{i},'userdata');
        d = ud.PlotHandle;
        % if the plothandle (axis) of the colorbar is our axis
        if isequal(d,h)
            pos = get(ch{i},'Position');
            if pos(3)<pos(4)
                oldloc = 'vert';
            else
                oldloc = 'horiz';
            end
            % set ax to the ith colorbar
            % if it's location (orientation) is the same as the
            % new colorbar location (so a second colorbar with
            % the same orientation won't be created, and existing
            % colorbar will be updated
            if strncmp(oldloc,loc,1)
                ax = ch{i}; 
                % Make sure image deletefcn doesn't trigger a colorbar('delete')
                % for colorbar update - huh?
                set(findall(ax,'type','image'),'deletefcn','')
                break; 
            end
        end
    end
end

origNextPlot = get(hfig,'NextPlot');
if strcmp(origNextPlot,'replacechildren') | strcmp(origNextPlot,'replace')
        set(hfig,'NextPlot','add');
end

if loc(1)=='v' % create or refresh vertical colorbar
    
    if isempty(ax)
        units = get(h,'units');
        set(h,'units','normalized');
        pos = get(h,'Position'); 
        [az,el] = view(h);
        stripe = 0.075; edge = 0.02; 
        if all([az,el]==[0 90])
            space = 0.05;
        else
            space = .1;
        end
        set(h,'Position',[pos(1) pos(2) pos(3)*(1-stripe-edge-space) pos(4)]);

        rect = [pos(1)+(1-stripe-edge)*pos(3) pos(2) stripe*pos(3) pos(4)];
        ud.origPos = pos;
        
        % Create axes for stripe and
        % create ColorbarDeleteProxy object (an invisible text object in
        % the target axes) so that the colorbar will be deleted
        % properly.
        ud.ColorbarDeleteProxy = text('parent',h,...
            'visible','off',...
            'tag','ColorbarDeleteProxy',...
            'HandleVisibility','off',...
            'deletefcn','colorbar(''v6'',''delete'',''peer'',get(gcbf,''currentaxes''))');
 
        axH = graph3d.colorbar('parent',hfig);
        set(axH,'position',rect,'Orientation','vert');
        ax = double(axH);

        setappdata(ax,'NonDataObject',[]); % For DATACHILDREN.M
        set(ud.ColorbarDeleteProxy,'userdata',ax)
        set(h,'units',units)
    else
        axH=[];
        ud = get(ax,'userdata');
    end
    
    % Create color stripe
    n = size(colormap(h),1);
    
    img = image([0 1],t,(1:n)',...
        'Parent',ax,...
        'Tag','TMW_COLORBAR',...
        'deletefcn','colorbar(''v6'',''delete'',''peer'',get(gcbf,''currentaxes''))',...
        'SelectionHighlight','off',...
        'HitTest','off');

    %set up axes delete function
    set(ax,...
        'Ydir','normal',...
        'YAxisLocation','right',...
        'xtick',[],...
        'tag','Colorbar',...
        'deletefcn','colorbar(''v6'',''delete'',''peer'',get(gcbf,''currentaxes''))');
   
    
elseif loc(1)=='h', % create or refresh horizontal colorbar
    
    if isempty(ax),
        units = get(h,'units'); set(h,'units','normalized')
        pos = get(h,'Position');
        stripe = 0.075; space = 0.1;
        set(h,'Position',...
            [pos(1) pos(2)+(stripe+space)*pos(4) pos(3) (1-stripe-space)*pos(4)])
        rect = [pos(1) pos(2) pos(3) stripe*pos(4)];
        ud.origPos = pos;

        % Create axes for stripe and
        % create ColorbarDeleteProxy object (an invisible text object in
        % the target axes) so that the colorbar will be deleted
        % properly.
        ud.ColorbarDeleteProxy = text('parent',h,...
            'visible','off',...
            'tag','ColorbarDeleteProxy',...
            'handlevisibility','off',...
            'deletefcn','colorbar(''v6'',''delete'',''peer'',get(gcbf,''currentaxes''))');

        axH = graph3d.colorbar('parent',hfig);
        set(axH,'Orientation','horiz');
        set(axH,'position',rect);
        ax = double(axH);
        
        setappdata(ax,'NonDataObject',[]); % For DATACHILDREN.M
        set(ud.ColorbarDeleteProxy,'userdata',ax)
        set(h,'units',units)
    else
        axH=[];
        ud = get(ax,'userdata');
    end
    
    % Create color stripe
    n = size(colormap(h),1);
    img=image(t,[0 1],(1:n),...
        'Parent',ax,...
        'Tag','TMW_COLORBAR',...
        'deletefcn','colorbar(''v6'',''delete'',''peer'',get(gcbf,''currentaxes''))',...
        'SelectionHighlight','off',...
        'HitTest','off');

    % set up axes deletefcn
    set(ax,...
        'Ydir','normal',...
        'Ytick',[],...
        'tag','Colorbar',...
        'deletefcn','colorbar(''v6'',''delete'',''peer'',get(gcbf,''currentaxes''))')
    
else
  error('COLORBAR expects a handle, ''vert'', or ''horiz'' as input.')
end

if ~isfield(ud,'ColorbarDeleteProxy')
    ud.ColorbarDeleteProxy = [];
end

if ~isfield(ud,'origPos')
    ud.origPos = [];
end

ud.PlotHandle = h;
set(ax,'userdata',ud)
set(hfig,'NextPlot',origNextPlot)

if nargout>0
    h = ax;
end

% Finally, before going, be sure to reset current figure and axes
if ishandle(GCF) && ~strcmpi(get(GCF,'beingdeleted'),'on')
    set(0,'currentfigure',GCF);
end
if ishandle(GCA) && ~strcmpi(get(GCA,'beingdeleted'),'on')
    set(gcf,'currentaxes',GCA);
end

%--------------------------------
function h = gcda(hfig, haxes)
%GCDA Get current data axes

h = datachildren(hfig);
if isempty(h) | any(h == haxes)
  h = haxes;
else
  h = h(1);
end

