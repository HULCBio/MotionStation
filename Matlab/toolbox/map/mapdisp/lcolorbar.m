function hndlout = lcolorbar(varargin)

%LCOLORBAR labeled colorbar
%
%   LCOLORBAR(labels) appends a colorbar with text labels.  The
%   labels input is a cell array of label strings. The colorbar 
%   is constructed using the current colormap with the label
%   strings applied at the centers of the color bands.
%
%   LCOLORBAR(labels,'property',value,...) controls the colorbar's 
%   properties. The location of the colorbar is controlled by the 
%   'Location' property. Valid entries for Location are 'vertical' 
%   (the default) or 'horizontal'. Properties 'TitleString', 
%   'XLabelString', 'YLabelString' and 'ZLabelString' set the 
%   respective strings. Property 'ColorAlignment' controls whether 
%   the colorbar labels are centered on the color bands or the color 
%   breaks. Valid values for ColorAlignment are 'center' or 'ends'. 
%   Other valid property-value pairs are any properties and values 
%   that can be applied to the title and labels of the colorbar axes.
%
%   hcb = LCOLORBAR(...) returns a handle to the colorbar axes.
% 
%   Examples:
%
%         figure; colormap(jet(5))
%         labels = {'apples','oranges','grapes','peachs','melons'};
%         lcolorbar(labels,'fontweight','bold');
%
%   See also CONTOURCMAP, CMAPUI


%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by: L. Job, W. Stumpf, 4-30-98
%  $Revision: 1.4.4.1 $    $Date: 2003/08/01 18:18:39 $



% Callbacks for colorbar
if nargin == 1 & isstr(varargin{1}) & size(varargin{1},1) == 1;
   action = varargin{1};
   cbutil(action);
   return
end

if nargin < 1
   error('Insufficient number of input arguments')
end
      
% input error checking
if mod(nargin,2) ~= 1
   error('Inputs must be labels and property-value pairs')
end

labels = varargin{1};
varargin(1) = [];

% Defaults
fs = 10;
titlestr = {};

loc = 'vertical';
coloralignment = 'center';
titlestring = '';
xlabelstring = '';
ylabelstring = '';
zlabelstring = '';

h = gca;

% Check for special properties (not properties of the axes labels or title)
todelete = [];
if nargin > 1
   
   for i=1:2:length(varargin)
      
      varargin{i} = canonicalProps(varargin{i});
      
      switch varargin{i}
      case 'location'
         loc = canonicalvals(varargin{i+1});
         todelete = [todelete i i+1];
      case 'coloralignment'
         coloralignment = canonicalvals(varargin{i+1});
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
switch loc
case{'vertical','horizontal'}
otherwise
   error('Valid location values are ''vertical'' and ''horizontal''.') 
end

switch coloralignment
case{'center','ends'}
otherwise
   error('Valid coloralignment values are ''center'' and ''ends''.') 
end


% test to see if current object is axes
objtest = 0;
axesobjs = findobj(gcf,'type','axes');
for i = 1:size(axesobjs,1)
	if isequal(h,axesobjs(i)) == 1
		objtest = 1;
	end	
end	
if objtest == 0
	error('Invalid object type, h is not an axes object')
end	

% get the axes units and change them to normalized
axesunits = get(h,'units');
set(h,'units','normalized')

switch loc % colorbar location
	case 'vertical'
		obj = findobj('tag',[num2str(h),'v']);
		if isempty(obj) == 1 % colorbar does not exist
			% get the limits
			ax.clim = get(h,'clim');
			ax.origpos = get(h,'pos');
			ax.h = h;
			ax.units = axesunits;
			ax.figh = get(h,'parent');
			cm = colormap; C(size(cm,1),1,3) = NaN;
			% shrink length by 10 percent
			pos = ax.origpos;
			pos(3) = ax.origpos(3)*0.90;
			set(h,'pos',pos)
			% create colorbar axis
			len = ax.origpos(3)*0.05;
			width = ax.origpos(4);
			axes('pos',[ax.origpos(1)+ax.origpos(3)*0.95 ax.origpos(2) len width])
			% create image
			xlimits = [0 1];
			ylimits = [1,size(cm,1)];
			hndl = image(xlimits,ylimits,(1:size(cm,1))','tag',[num2str(h),'v'],...
			   		  'userdata',ax,'deletefcn','lcolorbar(''deleteob'')');
			% set gca properties
			set(gca,'xtick',[],'ydir','normal','yaxislocation','right')
		else % colorbar does exist
			parent = get(obj,'parent');
			axes(parent);delete(parent);axes(h)
			% get the limits
			ax.clim = get(h,'clim');
			ax.origpos = get(h,'pos');
			ax.h = h;
			ax.units = axesunits;
			ax.figh = get(h,'parent');
			cm = colormap; C(size(cm,1),1,3) = NaN;
			% shrink length by 10 percent
			pos = ax.origpos;
			pos(3) = ax.origpos(3)*0.90;
			set(h,'pos',pos)
			% create colorbar axis
			len = ax.origpos(3)*0.05;
			width = ax.origpos(4);
			axes('pos',[ax.origpos(1)+ax.origpos(3)*0.95 ax.origpos(2) len width])
			% create image
			xlimits = [0 1];
			ylimits = [1,size(cm,1)];
			hndl = image(xlimits,ylimits,(1:size(cm,1))','tag',[num2str(h),'v'],...
			   		  'userdata',ax,'deletefcn','lcolorbar(''deleteob'')');
			% set gca properties
			set(gca,'xtick',[],'ydir','normal','yaxislocation','right')
		end	
	
		switch coloralignment
			case 'ends'
				lowerlim = 1-0.5;
				upperlim = size(cm,1)+0.5;
				delta = 1;
				ytickloc = [lowerlim:delta:upperlim];
				lowerlabel = floor(ax.clim(1));
				upperlabel = ceil(ax.clim(2));
				yticklabels = [lowerlabel:(upperlabel-lowerlabel)/(size(cm,1)):upperlabel];
				% round yticklabel points
				yticklabels = round(yticklabels);
				% find cases where label is less than epsilon
				indx = find(abs(yticklabels) < eps);
				yticklabels(indx) = 0;
				% apply labels if provided
				if isempty(labels) == 0
					numberrequired = size(yticklabels,2);
					numberlabels = size(labels,2);
					if numberlabels ~= numberrequired
						warning(['Incorrect number of label entries: ',num2str(numberrequired),' required to match colormap size'])
					end
					yticklabels = labels;
				end	
				set(gca,'ytick',ytickloc,'yticklabel',yticklabels);
			case 'center'	
				lowerlim = 1;
				upperlim = size(cm,1);
				delta = 1;
				ytickloc = [lowerlim:delta:upperlim];
				lowerlabel = floor(ax.clim(1));
				upperlabel = ceil(ax.clim(2));
				yticklabels = [lowerlabel:(upperlabel-lowerlabel)/(size(cm,1)-1):upperlabel];
				% round yticklabel points
				yticklabels = round(yticklabels);
				% find cases where label is less than epsilon
				indx = find(abs(yticklabels) < eps);
				yticklabels(indx) = 0;
				% apply labels if provided
				if isempty(labels) == 0
					numberrequired = size(yticklabels,2);
					numberlabels = size(labels,2);
					if numberlabels ~= numberrequired
						warning(['Incorrect number of label entries: ',num2str(numberrequired),' required to match colormap size'])
					end
					yticklabels = labels;
				end	
				set(gca,'ytick',ytickloc,'yticklabel',yticklabels)
		end
		% set delete function for gca
		set(gca,'userdata',ax,'deletefcn','lcolorbar(''deleteax'')','fontsize',fs)
		% set the title if requested
		if isempty(titlestr) == 0
			title = get(gca,'title');
			set(title,'string',titlestr,'fontweight','bold','fontsize',fs)
		end	
	
	case 'horizontal'
		obj = findobj('tag',[num2str(h),'h']);
		if isempty(obj) == 1 % colorbar does not exist
			% get the limits
			ax.clim = get(h,'clim');
			ax.origpos = get(h,'pos');
			ax.h = h;
			ax.units = axesunits;			
			ax.figh = get(h,'parent');
			cm = colormap; C(size(cm,1),1,3) = NaN;
			% shrink width by 10 percent
			pos = ax.origpos;
			pos(4) = ax.origpos(4)*0.90;
			pos(2) = ax.origpos(2) + ax.origpos(4)*0.10;
			set(h,'pos',pos)
			% create colorbar axis
			width = ax.origpos(4)*0.05;
			len = ax.origpos(3);
			axes('pos',[ax.origpos(1) ax.origpos(2) len width])
			% create image
			xlimits = [1,size(cm,1)];
			ylimits = [0 1];
			hndl = image(xlimits,ylimits,(1:size(cm,1)),'tag',[num2str(h),'h'],...
			   		  'userdata',ax,'deletefcn','lcolorbar(''deleteob'')');
			% set gca properties
			set(gca,'ytick',[],'xdir','normal','xaxislocation','bottom')
		else % colorbar does exist
			parent = get(obj,'parent');
			axes(parent);delete(parent);axes(h)
			% get the limits
			ax.clim = get(h,'clim');
			ax.origpos = get(h,'pos');
			ax.h = h;
			ax.units = axesunits;
			ax.figh = get(h,'parent');
			cm = colormap; C(size(cm,1),1,3) = NaN;
			% shrink width by 10 percent
			pos = ax.origpos;
			pos(4) = ax.origpos(4)*0.90;
			pos(2) = ax.origpos(2) + ax.origpos(4)*0.10;
			set(h,'pos',pos)
			% create colorbar axis
			width = ax.origpos(4)*0.05;
			len = ax.origpos(3);
			axes('pos',[ax.origpos(1) ax.origpos(2) len width])
			% create image
			xlimits = [1,size(cm,1)];
			ylimits = [0 1];
			hndl = image(xlimits,ylimits,(1:size(cm,1)),'tag',[num2str(h),'h'],...
			   		  'userdata',ax,'deletefcn','lcolorbar(''deleteob'')');
			% set gca properties
			set(gca,'ytick',[],'xdir','normal','xaxislocation','bottom')
		end	
	
		switch coloralignment
			case 'ends'
				lowerlim = 1-0.5;
				upperlim = size(cm,1)+0.5;
				delta = 1;
				xtickloc = [lowerlim:delta:upperlim];
				lowerlabel = floor(ax.clim(1));
				upperlabel = ceil(ax.clim(2));
				xticklabels = [lowerlabel:(upperlabel-lowerlabel)/(size(cm,1)):upperlabel];
				% round yticklabel points
				xticklabels = round(xticklabels);
				% find cases where label is less than epsilon
				indx = find(abs(xticklabels) < eps);
				xticklabels(indx) = 0;
				% apply labels if provided
				if isempty(labels) == 0
					numberrequired = size(xticklabels,2);
					numberlabels = size(labels,2);
					if numberlabels ~= numberrequired
						warning(['Incorrect number of label entries: ',num2str(numberrequired),' required to match colormap size'])
					end
					xticklabels = labels;
				end	
				set(gca,'xtick',xtickloc,'xticklabel',xticklabels);
			case 'center'	
				lowerlim = 1;
				upperlim = size(cm,1);
				delta = 1;
				xtickloc = [lowerlim:delta:upperlim];
				lowerlabel = floor(ax.clim(1));
				upperlabel = ceil(ax.clim(2));
				xticklabels = [lowerlabel:(upperlabel-lowerlabel)/(size(cm,1)-1):upperlabel];
				% round yticklabel points
				xticklabels = round(xticklabels);
				% find cases where label is less than epsilon
				indx = find(abs(xticklabels) < eps);
				xticklabels(indx) = 0;
				% apply labels if provided
				if isempty(labels) == 0
					numberrequired = size(xticklabels,2);
					numberlabels = size(labels,2);
					if numberlabels ~= numberrequired
						warning(['Incorrect number of label entries: ',num2str(numberrequired),' required to match colormap size'])
					end
					xticklabels = labels;
				end	
				set(gca,'xtick',xtickloc,'xticklabel',xticklabels)
		end
		% set delete function for gca
		set(gca,'userdata',ax,'deletefcn','lcolorbar(''deleteax'')','fontsize',fs)
		% set the title if requested
		if isempty(titlestr) == 0
			title = get(gca,'title');
			set(title,'string',titlestr,'fontweight','bold','fontsize',fs)
		end	
	
end

% reset the axes units 
set(h,'units',axesunits)

% activate the initial axes
axes(h)

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

if ~isstr(in)
   error('Property names must be strings')
end

if size(in,1) > 1
   error('input string matrices not supported')
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

if ~isstr(in)
   error('Value name must be strings')
end

if size(in,1) > 1
   error('input string matrices not supported')
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

