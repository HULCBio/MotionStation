function li=legendinfo(varargin)
%LEGENDINFO Create legendinfo object.
%   Helper function for legend and plot objects. Do not call directly.

%   LI=LEGENDINFO(PRIMITIVETYPE,PROPNAME,PROPVAL,...) creates a legendinfo
%   object of type PRIMITIVETYPE with the property/value pairs specified.
%   LI=LEGENDINFO(LISTRUCT) creates a legendinfo object according to the
%   properties of the structure (or vector of structures) LISTRUCT. The
%   fields of LISTRUCT are 'type','props' and 'children'. type is the only
%   field that is required.  It may be set to any hg primitive type that
%   can be a child of an axes (e.g. 'line', 'patch', 'surface', 'hggroup',
%   'text'); 'props' is a cell array of property/value pairs. 'children' is
%   a vector of children, each of which is a structure with the same three
%   properties.  If the 'type' is not 'hggroup' or 'hgtransform', the
%   'children' field should be empty or undefined.
%   LI=LEGENDINFO(H,...) creates and sets the legendinfo object for H.
%   LI=LEGENDINFO([H],GLYPHSIZE,...) GLYPHSIZE is a 1x2 vector that
%   specifies the width and height, in points, of the legend graphic.
%   LEGENDINFO(H,'clear') clears the legendinfo for H
%
%   Examples:
%       1. simple line (simple use of legendinfo witout struct(s))
%           l=plot(0:pi/24:4*pi,sin(0:pi/24:4*pi),'b-');
%           hold on
%           l2=plot(0:pi/6:4*pi,sin(0:pi/6:4*pi),'bo');
%           legendinfo(l,'line',...
%               'Marker',get(l2,'Marker'),...
%               'LineStyle',get(l,'LineStyle'),...
%               'Color','b');
%           legend(l,'myline');
%
%       2. multiple patches (example of vector of structs)
%           s=surf(peaks);
%           clim=get(gca,'clim');
%           n = 8;
%           pcdata = linspace(clim(1),clim(2),n);
%           lis=[];
%           for k=1:n
%               lis(k).type = 'patch';
%               lis(k).props = {...
%                   'XData',[(k-1)/n (k-1)/n k/n k/n],...
%                   'YData',[0 1 1 0],...
%                   'FaceColor','flat',...
%                   'EdgeColor','none',...
%                   'CData',pcdata(k)};
%           end
%           legendinfo(s,lis);
%           legend(s,'peaks');
%
%       3. group object (example of nested structs)
%           lis=[];
%           g=hg.hggroup;
%           p(1)=hg.patch(...
%               'Parent',g,...
%               'XData',[0,.5,0],...
%               'YData',[0,.5,1],...
%               'FaceColor',[1 0 .6]);
%           p(2)=hg.patch(...
%               'Parent',g,...
%               'XData',[1 .5 1],...
%               'YData',[0,.5,1],...
%               'FaceColor',[.6 0 1]);
%           lis.type = 'hggroup';
%           lisc(1).type = 'patch';
%           lisc(1).props = {...
%               'XData',get(p(1),'XData'),...
%               'YData',get(p(1),'YData'),...
%               'FaceColor',get(p(1),'FaceColor')};
%           lisc(2).type = 'patch';
%           lisc(2).props = {...
%               'XData',get(p(2),'XData'),...
%               'YData',get(p(2),'YData'),...
%               'FaceColor',get(p(2),'FaceColor')};
%           lis.children = lisc;
%           legendinfo(g,lis);
%           legend(g,'bowtie');
%
%       4. legendinfo objects without object handles 
%           [c,h]=contourf(peaks);
%           levels=get(h,'LevelList');
%           for k=fliplr(1:length(levels))
%               lih(k) = legendinfo('patch',...
%               'FaceColor','flat',...
%               'CData',levels(k));
%           end
%           strs = {};
%           for k=fliplr(1:length(levels))
%               strs{end+1} = sprintf('%1.4f',levels(k));
%           end
%           legend(lih,strs);
%
%   See also LEGEND.

%   Copyright 1984-2003 The MathWorks, Inc.

error(nargchk(1,inf,nargin));
li=[];
h=[];
nargs = nargin;

% set h if first arg is a hanle
if ishandle(varargin{1})
    h = varargin{1};
    varargin(1) = [];
    nargs = nargs - 1;
end

if ~isempty(h) && nargs==1 && ischar(varargin{1}) && strcmpi(varargin{1},'clear')
    % clearing legend info
    li = getappdata(h,'LegendLegendInfo');
    if ~isempty(li)
        rmappdata(h,'LegendLegendInfo');
        delete(li);
    end
    li=[];
else
    % creating and setting legendinfo
    if isempty(h)
        % legendinfo without graphics object
        li = scribe.legendinfo;
    else
        % legendinfo with graphics object
        li=scribe.legendinfo('GObject',h);
    end
    if isnumeric(varargin{1}) && isequal(length(varargin{1}),2)
        % first arg is glyph size if it is a numeric vector of length 2
        set(li,'GlyphWidth',varargin{1}(1),'GlyphHeight',varargin{1}(2));
        varargin(1) = [];
        nargs = nargs - 1;
    end
    if isstruct(varargin{1})
        % get glyph children from struct
        lic=parsestruct(varargin{1});
    else
        % glyph component (only one) from args
        % construct legendinfochild directly
        lic=scribe.legendinfochild(...
            'ConstructorName',['hg.',varargin{1}],...
            'PVPairs',varargin(2:length(varargin)));
        check_xydata(lic);
    end
    set(li,'GlyphChildren',lic);
    % if a graphics object handle was passed, set its legendlegendinfo
    % appdata
    if ~isempty(h)
        setappdata(double(h),'LegendLegendInfo',li);
    end
end
if ~isempty(h)
  ax = ancestor(h,'axes');
  setappdata(ax,'legendInfoAffectedObject',h);
  hleg = legend(ax);
  if ~isempty(hleg)
    send(handle(hleg),'LegendInfoChanged',...
         handle.EventData(handle(hleg),'LegendInfoChanged'));
  end
end

%------------------------------------------------------------------%
function lic = parsestruct(lis)
lic=handle([]);
if ~isempty(fieldnames(lis))
    % loop through vector of structures
    for k=1:length(lis)
        % create legendinfochild
        lic(k)=scribe.legendinfochild(...
            'ConstructorName',['hg.',lis(k).type]);
        % set PVPairs field
        if isfield(lis(k),'props')
            set(lic(k),'PVPairs',lis(k).props);
        end
        % set GlyphChildren field
        if isfield(lis(k),'children') && ~isempty(lis(k).children)
            set(lic(k),'GlyphChildren',parsestruct(lis(k).children));
        end
        check_xydata(lic(k));
    end
end

%------------------------------------------------------------------%
function check_xydata(lic)

% add reasonable x/ydata as first pvpairs for lines, patches and surfaces
% if neither xdata or ydata is included in pvpairs
if strcmpi(lic.ConstructorName,'hg.line')
    if ~any(strcmpi('XData',lic.PVPairs)) && ~any(strcmpi('YData',lic.PVPairs))
        lic.PVPairs = [{'XData',[0 1],'YData',[.5 .5]},lic.PVPairs];
    end
elseif any(strcmpi(lic.ConstructorName,{'hg.Patch','hg.Surface'}));
    if ~any(strcmpi('XData',lic.PVPairs)) && ~any(strcmpi('YData',lic.PVPairs))
        lic.PVPairs = [{'XData',[0 0 1 1],'YData',[0 1 1 0]},lic.PVPairs];
    end
end
        