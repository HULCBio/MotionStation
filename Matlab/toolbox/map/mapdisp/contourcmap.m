function hndlout = contourcmap(varargin)
%CONTOURCMAP Contour a colormap and colorbar for surfaces.
% 
%   CONTOURCMAP(cdelta,'cmap') creates a contour colormap for the current 
%   axes.  A contour colormap is a colormap with color changes aligned to
%   the  color data.  If cdelta is a scalar, contours are generated at
%   multiples  of cdelta.  If cdelta is a vector of evenly spaced values,
%   contours are  generated at those values.  The string input cmap is the
%   name of the  colormap function used in the surface.  Valid entries for
%   cmap include  'pink', 'hsv', 'jet', or any similar colormap function.
% 
%   CONTOURCMAP(cdelta,'cmap','property',value,...) allows you to add a 
%   colorbar and control the colorbar's properties.  You turn the colorbar 
%   on with the property-value pair 'Colorbar' and 'on'. The location of
%   the  colorbar is controlled by the 'Location' property. Valid entries
%   for  Location are 'vertical' (the default) or 'horizontal'. Properties 
%   'TitleString', 'XLabelString', 'YLabelString' and 'ZLabelString' set 
%   the respective strings. Property 'ColorAlignment' controls whether the 
%   colorbar labels are centered on the color bands or the color breaks. 
%   Valid values for ColorAlignment are 'center' or 'ends'. Property 
%   'SourceObject' controls which object is used to determine the color
%   limits for the colormap. The SourceObject value is the handle of a 
%   currently displayed object. If omitted, gca is used. Other valid 
%   property-value pairs are any properties and values that can be applied
%   to the title and labels of the colorbar axes.
% 
%   hcb = CONTOURCMAP(...) returns a handle to the colorbar.
% 
%   Example
%   -------
%      load geoid; figure
%      worldmap(geoid,geoidlegend,'lmesh3d')
%      hndl = contourcmap(20,'jet','colorbar','on');
% 
%      [c,h] = contourm(geoid,geoidlegend,-120:20:100);
%      zdatam(h,100); set(h,'color',0.75*[ 1 1 1])
% 
%   See also CONTOURFM, LCOLORBAR, DEMCMAP.

%   Copyright 1996-2003 The MathWorks, Inc.
%   Written by: L. Job, W. Stumpf
%   $Revision: 1.6.4.1 $ $Date: 2003/08/01 18:18:08 $

% Callbacks for colorbar
if nargin == 1 & ischar(varargin{1});
   action = varargin{1};
   cbutil(action);
   return
end

% input error checking
checknargin(2,inf,nargin,mfilename);
if mod(nargin,2) ~= 0
   eid = sprintf('%s:%s:invalidParams', getcomp, mfilename);
   error(eid,'%s','Inputs must be cdelta, colormap function name and property-value pairs');
end

cdelta = varargin{1};
checkinput(cdelta,'numeric',{'real','nonempty'},mfilename,'CDELTA',1);

cm = varargin{2};
checkinput(cm,'char',{},mfilename,'CMAP',2);
if  ~(exist(cm,'file')==2)
   eid = sprintf('%s:%s:invalidParam', getcomp, mfilename);
   error(eid,'%s','cmap string must contain a colormap function name')
end

varargin(1:2) = [];

% default is to use current axes, no colorbar and colorbreaks on the numbers
hax = gca;

loc = 'vertical';
coloralignment = 'ends';
h = gca;

titlestring = '';
xlabelstring = '';
ylabelstring = '';
zlabelstring = '';
cbar = 'off';

% Check for special properties (not properties of the axes labels or title)
todelete = [];
if nargin > 2
   
   for i=1:2:length(varargin)
      
      varargin{i} = canonicalProps(varargin{i});
      
      switch varargin{i}
      case 'location'
         loc = canonicalvals(varargin{i+1});
         todelete = [todelete i i+1];
      case 'coloralignment'
         coloralignment = canonicalvals(varargin{i+1});
         todelete = [todelete i i+1];
      case 'colorbar'
         cbar = canonicalvals(varargin{i+1});
         todelete = [todelete i i+1];
      case 'sourceobject'
         h = varargin{i+1};
         todelete = [todelete i i+1];
      case 'titlestring'
         titlestring = varargin{i+1};
         todelete = [todelete i i+1];
      case 'xlabelstring'
         xlabelstring = varargin{i+1};
         todelete = [todelete i i+1];
      case 'ylabelstring'
         ylabelstring = varargin{i+1};
         todelete = [todelete i i+1];
      case 'zlabelstring'
         zlabelstring = varargin{i+1};
         todelete = [todelete i i+1];
      end
      
   end
   
   varargin(todelete) = [];
   
end


% check values for special properties
switch cbar
case 'off'
   loc = 'none';
end

switch loc
case{'none','vertical','horizontal'}
otherwise
   eid = sprintf('%s:%s:invalidLocationParam', getcomp, mfilename);
   error(eid,'%s','Valid location values are ''none'', ''vertical'' and ''horizontal''.') 
end

switch coloralignment
case{'center','ends'}
otherwise
   eid = sprintf('%s:%s:invalidColorAlignmentParam', getcomp, mfilename);
   error(eid,'%s','Valid coloralignment values are ''center'' and ''ends''.') 
end

switch cbar
case{'on','off'}
otherwise
   eid = sprintf('%s:%s:invalidColorBarParam', getcomp, mfilename);
   error(eid,'%s','Valid colorbar values are ''on'' and ''off''.') 
end

% test that h is a handle and get color limits
if ~ ishandle(h); eid = sprintf('%s:%s:invalidHandle', getcomp, mfilename);
        error(eid,'%s','h must be a handle to an axes or graphic object'); end
switch get(h,'type')
case 'axes'
	caxis('auto')
	climits = get(h,'clim');
otherwise

    try
        cdata = get(h,'cdata');
    catch
        eid = sprintf('%s:%s:invalidHandleObject', getcomp, mfilename);
        error(eid,'%s','object must be an axes or contain color data')
    end

    if isempty(cdata) | all(isnan(cdata))
        eid = sprintf('%s:%s:invalidCDATA', getcomp, mfilename);
        error(eid,'%s','Object''s ''CData'' property must contain numeric color data')
    end

    climits = [min(cdata(:)) max(cdata(:))];
    
    if diff(climits) == 0;
        eid = sprintf('%s:%s:invalidCDATAProperty', getcomp, mfilename);
        error(eid,'%s','Object''s ''CData'' property must contain a range of values')
    end
    
end


% get the axes units and change them to normalized
axesunits = get(hax,'units');
set(hax,'units','normalized')

% compute the labels with nice increments
if length(cdelta) == 1
	cmin = floor(climits(1));
	multfactor = floor(cmin/cdelta);
	cmin = cdelta*multfactor;
	cmax = ceil(climits(2));
	clevels = [cmin:cdelta:cmax];
	if max(clevels) < cmax
		clevels = [clevels max(clevels)+cdelta];
    end	
else
	% check to see that spacing is the same
	tolerance = 0.1;
	if abs(max(diff(diff(cdelta)))) > tolerance
		eid = sprintf('%s:%s:invalidCDATASize', getcomp, mfilename);
      error(eid,'%s','CDELTA must consist of evenly spaced elements')
    end	
	clevels = cdelta;
end	

% round numbers less than epsilon to zero
indx = find(abs(clevels) < eps);
clevels(indx) = 0;

% reset the climits based on new increments
set(gca,'clim',[min(clevels) max(clevels)])

% compute the number of colors to pick up
switch coloralignment
case 'ends'
    numberofcolors = length(clevels)-1;
    eval(['colormap(',cm,'(',num2str(numberofcolors),'))'])
case 'center'	
    numberofcolors = length(clevels);
    eval(['colormap(',cm,'(',num2str(numberofcolors),'))'])
otherwise
    eid = sprintf('%s:%s:invalidColorAlignment', getcomp, mfilename);
    error(eid,'%s','Unrecognized color alignment option. Valid entries are ''ends'' and ''center''.')
end

% Create the colorbar. Based on code in the MATLAB COLORBAR function
switch loc % colorbar location
case 'none'
    hndl = [];
case 'vertical'
    obj = findobj('tag',[num2str(hax),'v']);
    if isempty(obj) == 1 % colorbar does not exist
        % get the limits
        ax.clim = get(hax,'clim');
        ax.origpos = get(hax,'pos');
        ax.h = hax;
        ax.units = axesunits;
        ax.figh = get(hax,'parent');
        cm = colormap; C(size(cm,1),1,3) = NaN;
        % shrink length by 10 percent
        pos = ax.origpos;
        pos(3) = ax.origpos(3)*0.90;
        set(hax,'pos',pos)
        % create colorbar axis
        len = ax.origpos(3)*0.05;
        width = ax.origpos(4);
        axes('pos',[ax.origpos(1)+ax.origpos(3)*0.95 ax.origpos(2) len width])
        % create image
        xlimits = [0 1];
        ylimits = [1,size(cm,1)];
        hndl = image(xlimits,ylimits,(1:size(cm,1))','tag',[num2str(hax),'v'],...
        'userdata',ax,'deletefcn','contourcmap(''deleteob'')');
        % set gca properties
        set(gca,'xtick',[],'ydir','normal','yaxislocation','right')
    else % colorbar does exist
        parent = get(obj,'parent');
        axes(parent);delete(parent);axes(hax)
        % get the limits
        ax.clim = get(hax,'clim');
        ax.origpos = get(hax,'pos');
        ax.h = hax;
        ax.units = axesunits;
        ax.figh = get(hax,'parent');
        cm = colormap; C(size(cm,1),1,3) = NaN;
        % shrink length by 10 percent
        pos = ax.origpos;
        pos(3) = ax.origpos(3)*0.90;
        set(hax,'pos',pos)
        % create colorbar axis
        len = ax.origpos(3)*0.05;
        width = ax.origpos(4);
        axes('pos',[ax.origpos(1)+ax.origpos(3)*0.95 ax.origpos(2) len width])
        % create image
        xlimits = [0 1];
        ylimits = [1,size(cm,1)];
        hndl = image(xlimits,ylimits,(1:size(cm,1))','tag',[num2str(hax),'v'],...
        'userdata',ax,'deletefcn','contourcmap(''deleteob'')');
        % set gca properties
        set(gca,'xtick',[],'ydir','normal','yaxislocation','right')
    end	

    % set the labels
    switch coloralignment
    case 'ends'
        lowerlim = 1-0.5;
        upperlim = size(cm,1)+0.5;
        delta = 1;
        ytickloc = [lowerlim:delta:upperlim];
        set(gca,'ytick',ytickloc,'yticklabel',clevels);
    case 'center'	
        lowerlim = 1;
        upperlim = size(cm,1);
        delta = 1;
        ytickloc = [lowerlim:delta:upperlim];
        set(gca,'ytick',ytickloc,'yticklabel',clevels);
    end
    % set delete function for gca
    set(gca,'userdata',ax,'deletefcn','contourcmap(''deleteax'')')
	
case 'horizontal'
    obj = findobj('tag',[num2str(hax),'h']);
    if isempty(obj) == 1 % colorbar does not exist
        % get the limits
        ax.clim = get(hax,'clim');
        ax.origpos = get(hax,'pos');
        ax.h = hax;
        ax.units = axesunits;			
        ax.figh = get(hax,'parent');
        cm = colormap; C(size(cm,1),1,3) = NaN;
        % shrink width by 10 percent
        pos = ax.origpos;
        pos(4) = ax.origpos(4)*0.90;
        pos(2) = ax.origpos(2) + ax.origpos(4)*0.10;
        set(hax,'pos',pos)
        % create colorbar axis
        width = ax.origpos(4)*0.05;
        len = ax.origpos(3);
        axes('pos',[ax.origpos(1) ax.origpos(2) len width])
        % create image
        xlimits = [1,size(cm,1)];
        ylimits = [0 1];
        hndl = image(xlimits,ylimits,(1:size(cm,1)),'tag',[num2str(hax),'h'],...
        'userdata',ax,'deletefcn','contourcmap(''deleteob'')');
        % set gca properties
        set(gca,'ytick',[],'xdir','normal','xaxislocation','bottom')
    else % colorbar does exist
        parent = get(obj,'parent');
        axes(parent);delete(parent);axes(hax)
        % get the limits
        ax.clim = get(hax,'clim');
        ax.origpos = get(hax,'pos');
        ax.h = hax;
        ax.units = axesunits;
        ax.figh = get(hax,'parent');
        cm = colormap; C(size(cm,1),1,3) = NaN;
        % shrink width by 10 percent
        pos = ax.origpos;
        pos(4) = ax.origpos(4)*0.90;
        pos(2) = ax.origpos(2) + ax.origpos(4)*0.10;
        set(hax,'pos',pos)
        % create colorbar axis
        width = ax.origpos(4)*0.05;
        len = ax.origpos(3);
        axes('pos',[ax.origpos(1) ax.origpos(2) len width])
        % create image
        xlimits = [1,size(cm,1)];
        ylimits = [0 1];
        hndl = image(xlimits,ylimits,(1:size(cm,1)),'tag',[num2str(hax),'h'],...
        'userdata',ax,'deletefcn','contourcmap(''deleteob'')');
        % set gca properties
        set(gca,'ytick',[],'xdir','normal','xaxislocation','bottom')
    end	

    % set the labels
    switch coloralignment
    case 'ends'
        lowerlim = 1-0.5;
        upperlim = size(cm,1)+0.5;
        delta = 1;
        xtickloc = [lowerlim:delta:upperlim];
        set(gca,'xtick',xtickloc,'xticklabel',clevels);
    case 'center'	
        lowerlim = 1;
        upperlim = size(cm,1);
        delta = 1;
        xtickloc = [lowerlim:delta:upperlim];
        set(gca,'xtick',xtickloc,'xticklabel',clevels);
    end
    % set delete function for gca
    set(gca,'userdata',ax,'deletefcn','contourcmap(''deleteax'')')
	
otherwise
    eid = sprintf('%s:%s:unknownColorLocation', getcomp, mfilename);
    error(eid,'%s','Unrecognized colorbar location option. Valid entries are ''vertical'', ''horizontal'' or ''none''.')
end

% reset the axes units 
set(hax,'units',axesunits)

% activate the initial axes
axes(hax)

% set text properties of colorbar axes and title if provided
if ~isempty(hndl)
   set(get(get(hndl,'Parent'),'Title'),'String',titlestring); 
   set(get(get(hndl,'Parent'),'Xlabel'),'String',xlabelstring); 
   set(get(get(hndl,'Parent'),'Ylabel'),'String',ylabelstring); 
   set(get(get(hndl,'Parent'),'Zlabel'),'String',zlabelstring); 
   
   if length(varargin) > 0
      set(get(get(hndl,'Parent'),'Title'),varargin{:}); 
      set(get(hndl,'Parent'),varargin{:});   
   end
   
end


% output arguments
if nargout > 0; 
   if isempty(hndl)
      hndlout = hndl;
   else
      hndlout = get(hndl,'parent'); % return axes handle
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cbutil(action)
% CBUTIL(ACTION) callbacks for CONTOURCMAP

switch action
	case 'deleteax'
		ax = get(gca,'userdata');
		if isempty(ax) == 0 & isfield(ax,'h') == 1
			axesobjs = findobj(gcf,'type','axes');
			for i = 1:size(axesobjs,1)
				% restore original position if colorbar is deleted
				if isequal(ax.h,axesobjs(i)) == 1
					set(axesobjs(i),'units','normalized')
					set(axesobjs(i),'pos',ax.origpos)
					set(axesobjs(i),'units',ax.units)
				end	
			end	
		end
	case 'deleteob'
		ax = get(gca,'userdata');
		% in case object handle is deleted first
		if isempty(ax) == 1 % userdata is empty
			obj = get(gcbo);
			parent = obj.Parent;
			ax = get(parent,'userdata');
			axes(parent)
			delete(gca)
			axes(ax.h)
		end
		if isempty(ax) == 0 & isstruct(ax) == 0 % userdata is not empty
			obj = get(gcbo);					% but is not a structure
			parent = obj.Parent;
			ax = get(parent,'userdata');
			axes(parent)
			delete(gca)
			axes(ax.h)
		end	
		% userdata is not empty, is a structure, but does not contain the 
		% field struct.h
		if isempty(ax) == 0 & isstruct(ax) == 1 & isfield(ax,'h') == 0
			obj = get(gcbo);				
			parent = obj.Parent;
			ax = get(parent,'userdata');
			axes(parent)
			delete(gca)
			axes(ax.h)
		end	
		% userdata is not empty, is a structure, and does contain the 
		% field struct.h
		if isempty(ax) == 0 & isstruct(ax) == 1 & isfield(ax,'h') == 1
			if ishandle(ax.h) == 1
				axes(ax.h)
			end
		end	
		axesobjs = findobj(gcf,'type','axes');
		for i = 1:size(axesobjs,1)
			% restore original position if colorbar is deleted
			if isequal(ax.h,axesobjs(i)) == 1
				set(axesobjs(i),'units','normalized')
				set(axesobjs(i),'pos',ax.origpos)
				set(axesobjs(i),'units',ax.units)
			end	
		end	
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = canonicalProps(in)
% CANONICALPROPS expand property names to canonical names

if ~ischar(in)
   eid = sprintf('%s:%s:invalidPropertyName', getcomp, mfilename);
   error(eid,'%s','Property names must be strings')
end

if size(in,1) > 1
   eid = sprintf('%s:%s:invalidStringSize', getcomp, mfilename);
   error(eid,'%s','Input string matrices not supported')
end

in = lower(in);
out = in;

goodnames = {'location','coloralignment','sourceobject','titlestring',...
      'xlabelstring','ylabelstring','zlabelstring','colorbar'};
minnames  = {'l','colora','so','titles','xlabels','ylabels','zlabels','colorb'}; % minimal strings that can be distinguished from text object properties

for i=1:length(goodnames)
   
   if strcmp(in,goodnames{i})
      return
   end
   
   % check for match to valid names, enforce minimum name length
   if strmatch(in,goodnames{i}) & strmatch(minnames{i},in) 
      out = goodnames{i};
      return
   end
   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = canonicalvals(in)
% CANONICALVALS expand value names to canonical names

if ~ischar(in)
   eid = sprintf('%s:%s:invalidParamValue', getcomp, mfilename);
   error(eid,'%s','Value name must be strings')
end

if size(in,1) > 1
   eid = sprintf('%s:%s:invalidStringSize', getcomp, mfilename);
   error(eid,'%s','Input string matrices not supported')
end

in = lower(in);
out = in;


goodnames = {'horizontal','vertical','none','center','ends','on','off'};
minnames  = {'h','v','n','c','e','on','of'}; % minimal strings that can be distinguished from other properties

for i=1:length(goodnames)
   
   if strcmp(in,goodnames{i})
      return
   end
   
   % check for match to valid names, enforce minimum name length
   if strmatch(in,goodnames{i}) & strmatch(minnames{i},in) 
      out = goodnames{i};
      return
   end
   
end
