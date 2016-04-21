function scribecallback(varargin)
%SCRIBECALLBACK common callback functions for scribe objects and objects
%being edited by plotedit

% Copyright 2003-2004 The MathWorks, Inc.

% ignore first two arguments
varargin = varargin(3:length(varargin));

switch varargin{1}
    case 'addaxesdata'
        addaxesdata(varargin{2});
    case 'makemcode'
        makemcode(varargin{2},'Output','-editor');
    case 'inspect'
        inspect(varargin{2});
    case 'propedit'
        propedit(varargin{2},'-noselect');
    case 'pin_rect'
        h=varargin{2};
        h.methods('pin_at_current_position');
    case 'unpin_scribepin'
        h=varargin{2};
        pins = h.Pin;
        pins(~ishandle(pins)) = [];
        delete(pins);
        h.Pin = [];
    case 'arrow_pinheads'
        arrow_pinheads(varargin{2});
    case 'arrow_pinhead'
     arrow_pinhead(varargin{2:end});
    case 'arrow_unpinheads'
        arrow_unpinheads(varargin{2});
    case 'arrow_unpinhead'
        arrow_unpinhead(varargin{2:end});
    case 'arrow_flip'
        arrow_flip(varargin{2});
    case 'arrow_mcode'
        arrow_mcode(varargin{2});
    case 'togglelegend'
        legend(double(varargin{2}),'toggle');
    case 'togglepropcb'
        if strcmpi(get(varargin{2:3}),'on')
            set(varargin{2:3},'off')
        else
            set(varargin{2:3},'on');
        end
    case 'togglepropscb'
        vals = cell(1,length(varargin{3}));
        if all(strcmpi(get(varargin{2:3}),'on'))
            [vals{:}] = deal('off');
        else
            [vals{:}] = deal('on');
        end
        set(varargin{2:3},vals);
    case 'propvalcb'
        set(varargin{2:4});
    case 'propeditcb'
     h=varargin{2};
     if strcmp(get(h,'Selected'),'on')
       propedit(varargin{2},'-noselect');
     else
       propedit(varargin{2});
     end
    case 'colorpropcb'
        c = uisetcolor(get(varargin{2:3}));
        if ~isequal(c,0)
          set(varargin{2:3},c);
        end
    case 'fontpropscb'
        h=varargin{2};
        props = {'FontName','FontSize','FontUnits','FontWeight','FontAngle'};
        pv = [props; get(h,props)]; % 2-by-n array to be flattened
        s = uisetfont(struct(pv{:}));
        if ~isequal(s,0)
            set(h,s);
        end

    case 'textstringeditcb'
        if strcmpi(get(varargin{2},'type'),'text') % hg.text
            set(varargin{2},'Editing','on');
        else % scribe objects with text
            switch class(handle(varargin{2}))
                case 'scribe.textbox'
                    varargin{2}.methods('beginedit');
                case 'scribe.textarrow'
                    set(varargin{2}.Text,'Editing','on');
            end
        end
    case 'closefigure'
        close(varargin{2});
    case 'clearfigure'
        clf(varargin{2});
    case 'clearaxes'
        cla(varargin{2});
    case 'copyfigure'
        uimenufcn(varargin{2},'EditCopyFigure');
end


%-------------------------------------------------------%
function addaxesdata (h)
adddatadlg (h, get(h, 'parent'));


%-------------------------------------------------------%
function arrow_unpinhead(h,n)

pins = h.Pin;
if nargin==2
  existing_pin = [];
  for pin = pins
    if isequal(getappdata(pin,'LineEndpoint'),n)
      existing_pin = pin;
    end
  end
  if ~isempty(existing_pin)
    delete(existing_pin);
  end
else
  fig = ancestor(h,'figure');
  scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
  point = methods(scribeax,'get_current_normalized_point');
  d1 = sqrt(  (point(1) - h.X(1))^2 + (point(2) - h.Y(1))^2  )+1e-5;
  d2 = sqrt(  (point(1) - h.X(2))^2 + (point(2) - h.Y(2))^2  )+1e-5;
  if abs(d1/d2)>4
    arrow_unpinhead(h,2);
  elseif abs(d2/d1)>4
    arrow_unpinhead(h,1);
  else
    arrow_unpinhead(h,1);
    arrow_unpinhead(h,2);
  end
end

%-------------------------------------------------------%
function arrow_unpinheads(h)
% unpin both heads
arrow_unpinhead(h,1);
arrow_unpinhead(h,2);

%-------------------------------------------------------%
function arrow_pinhead(h,n)

if nargin==2
  h.methods('pin_at_current_position',n);
else
    fig = ancestor(h,'figure');
    scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
    point = methods(scribeax,'get_current_normalized_point');
    d1 = sqrt(  (point(1) - h.X(1))^2 + (point(2) - h.Y(1))^2 )+1e-5;
    d2 = sqrt(  (point(1) - h.X(2))^2 + (point(2) - h.Y(2))^2 )+1e-5;
    if abs(d1/d2)>4
        arrow_pinhead(h,2);
    elseif abs(d2/d1)>4
        arrow_pinhead(h,1);
    else
        arrow_pinhead(h,1);
        arrow_pinhead(h,2);
    end
end

%-------------------------------------------------------%
function arrow_pinheads(h)

arrow_pinhead(h,1);
arrow_pinhead(h,2);

%-------------------------------------------------------%
function arrow_flip(h)

arrow_unpinheads(h);
x = h.X;
y = h.Y;
h.X = [x(2) x(1)];
h.Y = [y(2) y(1)];

%-------------------------------------------------------%
function arrow_mcode(h)
% callback from arrow context menu

% get propvals to be used
[propnames,propvals]=get_arrow_mcode_propvals(h);
% constructor code
c{1} = '% Create Arrow';
c{2} = 'ah = arrow(gcf);';
% generate code
generate_arrow_mcode(h,'ah',c,propnames,propvals);

%--------------------------------------------------------%
function [propnames,propvals]=get_arrow_mcode_propvals(h)
% returns cell array of names and properties to be set in mcode

pv = get(h);
pnames = fieldnames(pv);
propnames = {};
propvals = {};
units = get(h,'units');
nprops = 0;

% set up heirarchial property info

% color
cpnames = [{'color'},arrow_hpropnames('FaceColor'),arrow_hpropnames('EdgeColor'),{'tailColor'}];
cpvals = get(h,cpnames);
ceq = isequal(cpvals{:});
fceq = isequal(cpvals{2:4});
eceq = isequal(cpvals{5:7});
% head style
hsnames = arrow_hpropnames('Style');
v=get(h,hsnames);
hseq = isequal(v{:});
% head back depth
hbdnames = arrow_hpropnames('BackDepth');
v=get(h,hbdnames);
hbdeq = isequal(v{:});
% head rose pq
hrpqnames = arrow_hpropnames('RosePQ');
v=get(h,hrpqnames);
hrpqeq = isequal(v{:});
% head hypocycloid n
hhnnames = arrow_hpropnames('HypocycloidN');
v=get(h,hhnnames);
hhneq = isequal(v{:});
% head filled
hfnames = arrow_hpropnames('Filled');
v=get(h,hfnames);
hfeq = isequal(v{:});
% head face alpha
hfanames = arrow_hpropnames('FaceAlpha');
v=get(h,hfanames);
hfaeq = isequal(v{:});
% head edged
henames = arrow_hpropnames('Edged');
v=get(h,henames);
heeq = isequal(v{:});
% head line width
hlwnames = arrow_hpropnames('LineWidth');
v=get(h,hlwnames);
hlweq = isequal(v{:});
% head line style
hlsnames = arrow_hpropnames('LineStyle');
v=get(h,hlsnames);
hlseq = isequal(v{:});
% head width
hwnames = arrow_hpropnames('Width');
v=get(h,hwnames);
hweq = isequal(v{:});
% head length
hlnames = arrow_hpropnames('Length');
v=get(h,hlnames);
hleq = isequal(v{:});

for k=1:length(pnames)
    % get the schema property
    p = findprop(findclass(findpackage('scribe'),'arrow'),pnames{k});
    val = get(h,pnames{k});
    % FILTER OUT PROPERTIES TO BE SENT TO MCODE
    % if it can be set or get
    % and the prop is an hgtransform property
    % and the property is visible
    % and it's not PX or PY if units is normalized
    % and it's not X or Y if units is pixels
    % and it's not the factory value for the property
    if strcmpi(p.AccessFlags.PublicSet,'on') && ...
            strcmpi(p.AccessFlags.PublicGet,'on') && ...
            ~isprop('hg','hgtransform',pnames{k}) && ...
            strcmpi(p.Visible,'on') && ...
            ~((strcmpi(pnames{k},'PX') || strcmpi(pnames{k},'PY')) && strcmpi(units,'normalized')) && ...
            ~((strcmpi(pnames{k},'X') || strcmpi(pnames{k},'Y')) && strcmpi(units,'pixels')) && ...
            ~isequal(p.FactoryValue,val) && ~isequal(p.DataType,'handle') && ~isequal(p.DataType,'handle vector')
        showval=true;
        % Special processing for heirarchial properties
        if ~isempty(find(strcmpi(pnames{k},cpnames)));
            % color properties
            c = find(strcmpi(pnames{k},cpnames));
            switch c
                case 1 % color
                    if ~ceq
                        showval=false;
                    end
                case 2 % headFaceColor
                    if  ceq || ~fceq || ...
                            (strcmpi(h.Head1Filled,'off') && strcmpi(h.Head2Filled,'off')) || ...
                            (strcmpi(h.Head1Style,'none') && strcmpi(h.Head2Style,'none'))
                        showval=false;
                    end
                case 3 % head1FaceColor
                    if ceq || fceq || ...
                            strcmpi(h.Head1Filled,'off') || ...
                            strcmpi(h.Head1Style,'none')
                        showval=false;
                    end
                case 4 % head2FaceColor
                    if ceq || fceq || ...
                            strcmpi(h.Head2Filled','off') || ...
                            strcmpi(h.Head2Style,'none')
                        showval=false;
                    end
                case 5 % headEdgeColor
                    if ceq || ~eceq || ...
                            (strcmpi(h.Head1Edged,'off') && strcmpi(h.Head2Edged,'off')) || ...
                            (strcmpi(h.Head1LineStyle','none') && strcmpi(h.Head2LineStyle,'none')) || ...
                            (strcmpi(h.Head1Style,'none') && strcmpi(h.Head2Style,'none'))
                        showval=false;
                    end
                case 6 % head1EdgeColor
                    if ceq || eceq || ...
                            strcmpi(h.Head1Edged,'off') || strcmpi(h.Head1LineStyle,'none') || ...
                            strcmpi(h.Head1Style,'none')
                        showval=false
                    end
                case 7 % head2EdgeColor
                    if ceq || eceq || ...
                            strcmpi(h.Head2Edged,'off') || strcmpi(h.Head2LineStyle,'none') || ...
                            strcmpi(h.Head2Style,'none')
                        showval=false
                    end
                case 8 % tailColor
                    if ceq || strcmpi(h.TailLineStyle,'none')
                        showval=false;
                    end
            end
        elseif ~isempty(find(strcmpi(pnames{k},hsnames)));
            % head style
            c = find(strcmpi(pnames{k},hsnames));
            switch c
                case 1 % headStyle
                    if ~hseq
                        showval=false;
                    end
                case 2 % head1Style
                    if hseq
                        showval=false;
                    end
                case 3 % head2Style
                    if hseq
                        showval=false;
                    end
            end
        elseif ~isempty(find(strcmpi(pnames{k},hbdnames)));
            % head back depth
            c = find(strcmpi(pnames{k},hbdnames));
            switch c
                case 1 % headBackDepth
                    if ~hbdeq || ...
                            (~(strncmp(h.Head1Style,'cback',5)||strncmp(h.Head1Style,'vback',5)) && ...
                            ~(strncmp(h.Head2Style,'cback',5)||strncmp(h.Head2Style,'vback',5)))
                        showval=false;
                    end
                case 2 % head1BackDepth
                    if hbdeq || ~(strncmp(h.Head1Style,'cback',5)||strncmp(h.Head1Style,'vback',5))
                        showval=false;
                    end
                case 3 % head2BackDepth
                    if hbdeq || ~(strncmp(h.Head2Style,'cback',5)||strncmp(h.Head2Style,'vback',5))
                        showval=false;
                    end
            end
        elseif ~isempty(find(strcmpi(pnames{k},hrpqnames)));
            % head rose pq
            c = find(strcmpi(pnames{k},hrpqnames));
            switch c
                case 1 % headRosePQ
                    if ~hrpqeq || ~(strcmpi(h.Head1Style,'rose')||strcmpi(h.Head2Style,'rose'))
                        showval=false;
                    end
                case 2 % head1RosePQ
                    if hrpqeq || ~strcmpi(h.Head1Style,'rose')
                        showval=false;
                    end
                case 3 % head2RosePQ
                    if hrpqeq || ~strcmpi(h.Head2Style,'rose')
                        showval=false;
                    end
            end
        elseif ~isempty(find(strcmpi(pnames{k},hhnnames)));
            % head hypocycloid n
            c = find(strcmpi(pnames{k},hhnnames));
            switch c
                case 1 % headHypocycloidN
                    if ~hhneq || ...
                            ~(strcmpi(h.Head1Style,'hypocycloid')||strcmpi(h.Head2Style,'hypocycloid'))
                        showval=false;
                    end
                case 2 % head1HypocycloidN
                    if hhneq || ~strcmpi(h.Head1Style,'hypocycloid')
                        showval=false;
                    end
                case 3 % head2HypocycloidN
                    if hhneq || ~strcmpi(h.Head2Style,'hypocycloid')
                        showval=false;
                    end
            end
        elseif ~isempty(find(strcmpi(pnames{k},hfnames)));
            % head filled
            c = find(strcmpi(pnames{k},hfnames));
            switch c
                case 1 % headFilled
                    if ~hfeq
                        showval=false;
                    end
                case 2 % head1Filled
                    if hfeq || strcmpi(h.Head1Style,'none')
                        showval=false;
                    end
                case 3 % head2Filled
                    if hfeq || strcmpi(h.Head2Style,'none')
                        showval=false;
                    end
            end
        elseif ~isempty(find(strcmpi(pnames{k},hfanames)));
            % head face alpha
            c = find(strcmpi(pnames{k},hfanames));
            switch c
                case 1 % headFaceAlpha
                    if ~hfaeq
                        showval=false;
                    end
                case 2 % head1FaceAlpha
                    if hfaeq || strcmpi(h.Head1Style,'none') || strcmpi(h.Head1Filled,'off')
                        showval=false;
                    end
                case 3 % head2FaceAlpha
                    if hfaeq || strcmpi(h.Head2Style,'none') || strcmpi(h.Head2Filled,'off')
                        showval=false;
                    end
            end
        elseif ~isempty(find(strcmpi(pnames{k},henames)));
            % head edged
            c = find(strcmpi(pnames{k},henames));
            switch c
                case 1 % headEdged
                    if ~heeq
                        showval=false;
                    end
                case 2 % head1Edged
                    if heeq || strcmpi(h.Head1Style,'none')
                        showval=false;
                    end
                case 3 % head2Edged
                    if heeq || strcmpi(h.Head2Style,'none')
                        showval=false;
                    end
            end
        elseif ~isempty(find(strcmpi(pnames{k},hlwnames)));
            % head line width
            c = find(strcmpi(pnames{k},hlwnames));
            switch c
                case 1 % headLineWidth
                    if ~hlweq
                        showval=false;
                    end
                case 2 % head1LineWidth
                    if hlweq || strcmpi(h.Head1Style,'none') || strcmpi(h.Head1Edged,'off')
                        showval=false;
                    end
                case 3 % head2LineWidth
                    if hlweq || strcmpi(h.Head2Style,'none') || strcmpi(h.Head2Edged,'off')
                        showval=false;
                    end
            end
        elseif ~isempty(find(strcmpi(pnames{k},hlsnames)));
            % head line style
            c = find(strcmpi(pnames{k},hlsnames));
            switch c
                case 1 % headLineStyle
                    if ~hlseq
                        showval=false;
                    end
                case 2 % head1LineStyle
                    if hlseq || strcmpi(h.Head1Style,'none') || strcmpi(h.Head1Edged,'off')
                        showval=false;
                    end
                case 3 % head2LineStyle
                    if hlseq || strcmpi(h.Head2Style,'none') || strcmpi(h.Head2Edged,'off')
                        showval=false;
                    end
            end
        elseif ~isempty(find(strcmpi(pnames{k},hwnames)));
            % head width
            c = find(strcmpi(pnames{k},hwnames));
            switch c
                case 1 % headWidth
                    if ~hweq
                        showval=false;
                    end
                case 2 % head1Width
                    if hweq || strcmpi(h.Head1Style,'none')
                        showval=false;
                    end
                case 3 % head2Width
                    if hweq || strcmpi(h.Head2Style,'none')
                        showval=false;
                    end
            end
        elseif ~isempty(find(strcmpi(pnames{k},hlnames)));
            % head length
            c = find(strcmpi(pnames{k},hlnames));
            switch c
                case 1 % headLength
                    if ~hleq
                        showval=false;
                    end
                case 2 % head1Length
                    if hleq || strcmpi(h.Head1Style,'none')
                        showval=false;
                    end
                case 3 % head2Length
                    if hleq || strcmpi(h.Head2Style,'none')
                        showval=false;
                    end
            end
        end
        if showval
            nprops = nprops+1;
            propnames{nprops} = pnames{k};
            propvals{nprops} = val;
        end
    end
end

%------------------------------------------------------------------%
function hn=arrow_hpropnames(sufx)

hn = {strcat('head',sufx),strcat('head',num2str(1),sufx),strcat('head',num2str(2),sufx)};

%------------------------------------------------------------------%
function generate_arrow_mcode(h,hname,constr,pnames,pvals)
% generates mcode
% inputs:
%   h = handle to object
%   hname = name to use in mcode for handle being created
%   constr = cell string array containing "constructor"
%   pnames = cell array of property names
%   pvals = cell array of property values

fig = ancestor(h,'figure');
scribeax = handle(findall(fig,'Tag','scribeOverlay'));

% SET UP FIGURE/EDIT CONTROL TO DISPLAY CODE
plotfig = fig;
codefig = double(h.McodeFigure);
% create a figure for the mcode if it doesn't exist
if isempty(codefig) || ~ishandle(codefig)
    codefig = figure('numbertitle','off',...
        'name','Arrow M-code', ...
        'toolbar','none',...
        'menu','none',...
        'units','pixels');
    h.McodeFigure = handle(codefig);
end
cfigpos = get(codefig,'position');
% position the mcode figure nicely
u=get(plotfig,'units');
set(plotfig,'units','pixels');
pfigpos = get(plotfig,'position');
set(plotfig,'units',u);
ss = get(0,'ScreenSize');
if pfigpos(1) > ss(1) - (pfigpos(1) + pfigpos(3))
    % go to right
    availspace = pfigpos(1);
    if availspace >= cfigpos(3)
        cfigpos(1) = pfigpos(1) - cfigpos(3);
    else
        cfigpos(1) = 10;
    end
else
    % go to left
    availspace = ss(1) - (pfigpos(1) + pfigpos(3))
    if availspace >= cfigpos
        cfigpos(1) = pfigpos(1) + pfigpos(3);
    else
        cfigpos(1) = ss(1) - cfigpos(3);
    end
end
if pfigpos(2) > ss(2) - (pfigpos(2) + pfigpos(4))
    % go down
    availspace = pfigpos(2);
    if availspace > cfigpos(4);
        cfigpos(2) = pfigpos(2) - cfigpos(4);
    else
        cfigpos(2) = 10;
    end
else
    % go up
    availspace = ss(2) - (pfigpos(2) + pfigpos(4))
    if availspace >= cfigpos(4)
        cfigpos(2) = pfigpos(2) + pfigpos(4);
    else
        cfigpos(2) = ss(2) - cfigpos(4);
    end
end
set(codefig,'position',cfigpos);
% create a uicontrol text edit
t=uicontrol('parent',codefig, ...
    'style','edit',...
    'units','pixels',...
    'position',[0, 80, cfigpos(3), (cfigpos(4) - 80)],...
    'backgroundcolor',[1 1 1],...
    'fontsize',10,...
    'fontname','monospaced',...
    'horizontalalignment','left',...
    'Max',2);

% start code with constructor
c = constr;
sx = length(c) + 1;
% add a space
c{sx} = '';
sx = sx + 1;
% code for creating arrow

% create code for setting properties
if ~isempty(pnames)
    c{sx} = '% Set Properties';
    sx = sx + 1;
    sxstart = sx;
    setstr = strcat('set(',hname,',');
    for k=1:length(pnames)
        % get the value and convert to string
        if ischar(pvals{k})
            valstr = pvals{k};
        elseif isnumeric(pvals{k})
            valstr = num2str(pvals{k});
        end
        % if it's not the first property being added then append the ', ...' to
        % the last line
        if sx>sxstart
            laststr = c{sx-1};
            c{sx-1} = strcat(laststr,', ...');
        end
        % if it's the first property, start with the setstr part
        if sx==sxstart
            if ischar(pvals{k})
                c{sx} = strcat(setstr,'''',pnames{k},'''',',','''',valstr,'''');
            elseif length(pvals{k})>1
                c{sx} = strcat(setstr,'''',pnames{k},'''',',','[',valstr,']');
            else
                c{sx} = strcat(setstr,'''',pnames{k},'''',',',valstr);
            end
            % otherwise start with tab space
        else
            if ischar(pvals{k})
                c{sx} = strcat('     ''',pnames{k},'''',',','''',valstr,'''');
            elseif length(pvals{k})>1
                c{sx} = strcat('     ''',pnames{k},'''',',','[',valstr,']');
            else
                c{sx} = strcat('     ''',pnames{k},'''',',',valstr);
            end
        end
        sx = sx+1;
    end
    % close with ');'
    laststr = c{sx-1};
    c{sx-1} = strcat(laststr,');');
end

% set edit control's string
set(t,'string',c);

%-----------------------------------------------------------------%
