function sfstyler(varargin)
% Stateflow Style Dialog

%  Jay R. Torgerson
%  Copyright 1995-2003 The MathWorks, Inc.
%  $Revision: 1.25.2.2 $  

switch(nargin),
case 0, errmsg('sfstyler requires a chart id.');
case 1, 
   arg1 = varargin{1};
   if is_a_valid_chart_id(arg1), construct_method(arg1); 
   elseif isstr(arg1), broadcast_method(arg1);
   else, error_func; return;
   end;
case 2, 
   % must be a KILL event
   sfm = get_sfm;
   if ~isempty(sfm),
      if (sfm.chartId == varargin{2}), broadcast_method('KILL'); end;
   else,
      fig = findobj('Tag', 'SF_STYLER');
      if ~isempty(fig),
         close(fig);
      end;
   end;
otherwise, error_func; return;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = is_a_valid_chart_id(arg)
%
%
%
chartISA = sf('get', 'default', 'chart.isa');
if (isnumeric(arg) & sf('ishandle', arg) & sf('get',arg,'.isa') == chartISA), 
   out = 1;
   % Force graphics into memory, if they aren't already.
   if (sf('get', arg, '.hg.figure') == 0),
      sf('Open', arg);
   end;
else out = 0;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function apply_colors_to_dd(sfm)
%
%
%
sf('set', sfm.chartId, '.colorsChanging', 1);
sf('set', sfm.chartId, '.chartColor', get(sfm.axes, 'color'));
sf('set', sfm.chartId, '.selectionColor', get(sfm.selectionH, 'color'));
sf('set', sfm.chartId, '.highlightColor', get(sfm.highlightH, 'color'));
sf('set', sfm.chartId, '.errorColor', get(sfm.errorH, 'color'));
sf('set', sfm.chartId, '.stateColor', get(sfm.stateH, 'edgecolor'));
sf('set', sfm.chartId, '.stateLabelColor', get(sfm.stateLabelH, 'color'));
sf('set', sfm.chartId, '.transitionColor', get(sfm.transH, 'color'));
sf('set', sfm.chartId, '.transitionLabelColor', get(sfm.transLabelH, 'color'));
sf('set', sfm.chartId, '.junctionColor', get(sfm.junctH, 'edgecolor'));
sf('set', sfm.chartId, '.colorsChanging', 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function apply_fonts_to_dd(sfm)
%
%
%
stateFont = get_font_from_hg_text(sfm.stateLabelH);
sf('set', sfm.chartId, '.fontsChanging', 1);

sf('set', sfm.chartId, '.stateFont.fontWeight', stateFont.FontWeight);
sf('set', sfm.chartId, '.stateFont.defaultFontSize', stateFont.FontSize);
sf('set', sfm.chartId, '.stateFont.fontAngle', stateFont.FontAngle);
sf('set', sfm.chartId, '.stateFont.fontName', stateFont.FontName);

transFont = get_font_from_hg_text(sfm.transLabelH);

sf('set', sfm.chartId, '.transitionFont.fontWeight', transFont.FontWeight);
sf('set', sfm.chartId, '.transitionFont.defaultFontSize', transFont.FontSize);
sf('set', sfm.chartId, '.transitionFont.fontAngle', transFont.FontAngle);
sf('set', sfm.chartId, '.transitionFont.fontName', transFont.FontName);
sf('set', sfm.chartId, '.fontsChanging', 0);

sfm.stateLabelPos = get_hg_text_extent_rect(sfm.stateLabelH);
sfm.transLabelPos = get_hg_text_extent_rect(sfm.transLabelH);

set_sfm(sfm);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function apply_color_to_focus(sfm)
%
% 
%	
switch(sfm.state.focus),
case 'selection',		set(sfm.selectionH, 'color', sfm.color);
case 'highlight',		set(sfm.highlightH, 'color', sfm.color);
case 'error',			set(sfm.errorH, 'color', sfm.color);
case 'chart',			set(sfm.axes, 'color', sfm.color, 'YColor', sfm.color, 'XColor', sfm.color);
case 'state',			set(sfm.stateH, 'edgeColor', sfm.color);
case 'stateLabel',		set(sfm.stateLabelH, 'color', sfm.color);
case 'transition',		set(sfm.transH, 'color', sfm.color);
case 'transitionLabel',	set(sfm.transLabelH, 'color', sfm.color);
case 'junction',		set(sfm.junctH, 'edgeColor', sfm.color);
otherwise,						
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function set_font_on_hg_text(textH, font),
%
%
%
name =font.FontName;
weight = font.FontWeight;
fangle = font.FontAngle;
fsize = font.FontSize;

set(textH, 'fontName', name);
set(textH, 'fontWeight', weight);
set(textH, 'fontAngle', fangle);
set(textH, 'fontSize', fsize);
set(textH, 'fontUnits', 'Points'); % hardcode this to points for security.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function apply_font_to_focus(sfm)
%
% 
%	
switch(sfm.state.focus),
case 'stateLabel',	
   set_font_on_hg_text(sfm.stateLabelH, sfm.font);
   set( sfm.stateLabelH, 'userdata', sfm.font );
   sfm.stateLabelPos = get_hg_text_extent_rect(sfm.stateLabelH);
case 'transitionLabel',	
   set_font_on_hg_text(sfm.transLabelH, sfm.font);
   set( sfm.transLabelH, 'userdata', sfm.font )
   sfm.transLabelPos = get_hg_text_extent_rect(sfm.transLabelH);
otherwise, error_func;
end;

set_sfm(sfm);

%%%%%%%%%%%%%%%%%%%%%%%%%
function revert(h, prop)
%
%
%
val = get(h, 'userdata');
set(h, prop, val);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function revert_colors(sfm)
%
%
%
revert(sfm.selectionH, 'color');
revert(sfm.highlightH, 'color');
revert(sfm.errorH, 'color');
revert(sfm.axes, 'color');
revert(sfm.stateH, 'edgecolor');
revert(sfm.stateLabelH, 'color');
revert(sfm.transH, 'color');
revert(sfm.transLabelH, 'color');
revert(sfm.junctH, 'edgecolor');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = something_has_changed(sfm)
%
%
%
out = 0;

ddColor = sf('get',sfm.chartId, '.selectionColor');
stylerColor = get(sfm.selectionH, 'color');
if ~isequal(ddColor, stylerColor) out = 1; return; end;

ddColor = sf('get',sfm.chartId, '.highlightColor');
stylerColor = get(sfm.highlightH, 'color');
if ~isequal(ddColor, stylerColor) out = 1; return; end;

ddColor = sf('get',sfm.chartId, '.errorColor');
stylerColor = get(sfm.errorH, 'color');
if ~isequal(ddColor, stylerColor) out = 1; return; end;

ddColor = sf('get',sfm.chartId, '.stateColor');
stylerColor = get(sfm.stateH, 'edgeColor');
if ~isequal(ddColor, stylerColor) out = 1; return; end;

ddColor = sf('get',sfm.chartId, '.stateLabelColor');
stylerColor = get(sfm.stateLabelH, 'color');
if ~isequal(ddColor, stylerColor) out = 1; return; end;

ddColor = sf('get',sfm.chartId, '.transitionLabelColor');
stylerColor = get(sfm.transLabelH, 'color');
if ~isequal(ddColor, stylerColor) out = 1; return; end;

ddColor = sf('get',sfm.chartId, '.transitionColor');
stylerColor = get(sfm.transH, 'color');
if ~isequal(ddColor, stylerColor) out = 1; return; end;

ddColor = sf('get',sfm.chartId, '.chartColor');
stylerColor = get(sfm.axes, 'color');
if ~isequal(ddColor, stylerColor) out = 1; return; end;

ddColor = sf('get',sfm.chartId, '.junctionColor');
stylerColor = get(sfm.junctH, 'edgeColor');
if ~isequal(ddColor, stylerColor) out = 1; return; end;

stateFont = get_font_from_sf(sfm.chartId, '.stateFont');
if ~isequal(stateFont, get_font_from_hg_text(sfm.stateLabelH)) out = 1; return; end;

transFont = get_font_from_sf(sfm.chartId, '.transitionFont');
if ~isequal(transFont, get_font_from_hg_text(sfm.transLabelH)) out = 1; return; end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function font = get_font_from_sf(chart, fontField)
%
%
%
font.FontName = sf('get', chart, [fontField,'.fontName']);	
font.FontWeight = sf('get', chart, [fontField,'.fontWeight']);	
font.FontAngle = sf('get', chart, [fontField,'.fontAngle']);	
font.FontSize = sf('get', chart, [fontField,'.defaultFontSize']);	
font.FontUnits = 'points';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function broadcast_method(event)
%
%
%
sfm = get_sfm;

if isempty(sfm), error_func, return; end;

switch(sfm.state.main),
case 'Idle',
   switch(event),
   case 'BM', update_focus(sfm);
   case 'BD',
      bdType = get(sfm.fig, 'selectionType');
      switch(bdType),
      case 'alt',	sfm.state.main = 'RightPress';
      otherwise,	sfm.state.main = 'LeftPress';
      end;
      set_sfm(sfm);
   case 'BU', return;
   case 'APPLY', 
      if (something_has_changed(sfm)),
         apply_colors_to_dd(sfm);
         apply_fonts_to_dd(sfm);
      end;
      %				case 'REVERT',
      %					revert_colors(sfm);
      %					revert_fonts(sfm);
      %					apply_colors_to_dd(sfm);
      %					apply_fonts_to_dd(sfm);
      %					set(sfm.revertB, 'enable', 'off');
   case 'OK', 
      broadcast_method('APPLY');
      close(sfm.fig);
   case 'CANCEL', broadcast_method('KILL');
   case 'KILL', close(sfm.fig);
   case 'SETDEFAULTS', set_defaults(sfm);
   case 'SAVEDEFAULTS', save_defaults(sfm);
   case 'NEON', schema_neon(sfm);
   case 'CLASSIC', schema_classic(sfm);
   case 'ANTIQUE', schema_antique(sfm);
   case 'DEFAULT', schema_default(sfm);
   case 'FACTORY', schema_factory(sfm);
   case 'PASTEL', schema_pastel(sfm);
   case 'GRAYSCALE', schema_grayscale(sfm);
   case 'ROSE', schema_rose(sfm);
   case 'SLATE', schema_slate(sfm);
   case 'DESERT', schema_desert(sfm);
   case 'VALERIE', schema_valerie(sfm);
   otherwise, error_func;
   end;
case 'LeftPress',
   switch(event), 
   case 'BU',
      switch(sfm.state.focus),
      case 'None', enter_idle_state(sfm);
      otherwise,	 enter_editing_color_state(sfm); % We have a focus, edit it.
      end;
   case 'BM', return;
   otherwise, enter_idle_state(sfm);
   end;
case 'RightPress',
   switch(event), 
   case 'BU',
      switch(sfm.state.focus),
      case 'stateLabel',		enter_editing_font_state(sfm); % We have a label focus, edit it.
      case 'transitionLabel',	enter_editing_font_state(sfm); % We have a label focus, edit it.
      otherwise, enter_idle_state(sfm);
      end;
   case 'BM', return;
   otherwise, enter_idle_state(sfm);
   end;
   
   %
   % Editing font or color
   %
case 'Editing', 
   switch(event),
   case 'CED',  % Color Editing Done
      enter_idle_state(sfm);
   case 'FED',  % Font Editing Done
      enter_idle_state(sfm);
   otherwise, return;
   end;
otherwise, error_func;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function enter_editing_color_state(sfm),
%
%
%
sfm.state.main = 'Editing';
set_sfm(sfm);
[name, currentColor] = name_color_from_focus_state(sfm);
sfm.color = get_rgb_color_from_user(currentColor, name); 
apply_color_to_focus(sfm);
set_sfm(sfm);
broadcast_method('CED'); % color editing done (CED)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function enter_editing_font_state(sfm),
%
%
%
sfm.state.main = 'Editing';
set_sfm(sfm);
[name, currentFont] = name_font_from_focus_state(sfm);
sfm.font = get_font_from_user(currentFont, name); 
if (isstruct(sfm.font)) apply_font_to_focus(sfm); end;
broadcast_method('FED'); % font editing done (FED)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function enter_idle_state(sfm),
%
%
%
sfm.state.main = 'Idle';
set_sfm(sfm);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sfm = get_sfm
%
%
%
sfm = [];
fig = findall(0,'Tag', 'SF_STYLER');
if isempty(fig), return;
else, fig = fig(1);
end;

sfm = get(fig, 'userdata');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [name, color] = name_color_from_focus_state(sfm),
%
%
%
switch(sfm.state.focus),
case 'selection',		name = xlate('Selection Color');		color = get(sfm.selectionH, 'color');
case 'highlight',		name = xlate('Highlight Color');		color = get(sfm.highlightH, 'color');
case 'error',			name = xlate('Error Color');			color = get(sfm.errorH, 'color');
case 'chart',			name = xlate('Chart Color (background)'); color = get(sfm.axes, 'color');
case 'state',			name = xlate('State/Frame Color');		color = get(sfm.stateH, 'edgeColor');
case 'stateLabel',		name = xlate('State/FrameLabel Color');color = get(sfm.stateLabelH, 'color');
case 'transition',		name = xlate('Transition Color');		color = get(sfm.transH, 'color');
case 'transitionLabel',	name = xlate('TransitionLabel Color'); color = get(sfm.transLabelH, 'color');
case 'junction',		name = xlate('Junction Color');		color = get(sfm.junctH, 'edgeColor');
otherwise,				name = xlate('None'); color = [];
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function font = get_font_from_hg_text(textH),
%
%
%
font.FontName = get(textH, 'fontName');
font.FontWeight = get(textH, 'fontWeight');
font.FontAngle = get(textH, 'fontAngle');
font.FontSize = get(textH, 'fontSize');
font.FontUnits = get(textH, 'fontUnits');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [name, font] = name_font_from_focus_state(sfm),
%
%
%
switch(sfm.state.focus),
case 'stateLabel',		
   name = xlate('State/FrameLabel Font');
   font = get( sfm.boldH, 'userdata' );
case 'transitionLabel',	
   name = xlate('TransitionLabel Font'); 
   font = get( sfm.boldH, 'userdata' );
otherwise, error_func;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function set_sfm(sfm)
%
%
%
set(sfm.fig, 'userdata', sfm);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_focus(sfm)
%
% 
%
% Focus precedence
%   i) Over editor at all
%	 ii) Over Selection
%   iii) Over State
%      iv) Over StateLabel
%       v) Over TransLabel
%      vi) Over Trans
%	  vii) Over Junct

cp = get(sfm.fig, 'currentpoint');
if point_inside_rect(cp, sfm.axesPos),					% over something
   acp = get(sfm.axes, 'currentpoint');
   if point_inside_rect(acp, sfm.selectionPos),		
      sfm.state.focus = 'selection';
      str = name_color_from_focus_state(sfm);
      set(sfm.focusText, 'string', str, 'vis','on');
      sfm.boldH = bold(sfm, sfm.selectionH);
      set(sfm.focusText2, 'vis','off');
   elseif point_inside_rect(acp, sfm.highlightPos),		
      sfm.state.focus = 'highlight';
      str = name_color_from_focus_state(sfm);
      set(sfm.focusText, 'string', str, 'vis','on');
      sfm.boldH = bold(sfm, sfm.highlightH);
      set(sfm.focusText2, 'vis','off');
   elseif point_inside_rect(acp, sfm.errorPos),		
      sfm.state.focus = 'error';
      str = name_color_from_focus_state(sfm);
      set(sfm.focusText, 'string', str, 'vis','on');
      sfm.boldH = bold(sfm, sfm.errorH);
      set(sfm.focusText2, 'vis','off');
   elseif point_inside_rect(acp, sfm.statePos),		% State focii
      if point_inside_rect(acp, sfm.stateLabelPos),	
         sfm.state.focus = 'stateLabel';
         str = name_color_from_focus_state(sfm);
         set(sfm.focusText, 'string', str, 'vis','on');
         set(sfm.focusText2, 'string', xlate('State/FrameLabel Font'));
         set(sfm.focusText2, 'vis','on');
         sfm.boldH = bold(sfm, sfm.stateLabelH);
      elseif point_inside_rect(acp, sfm.transLabelPos),	
         sfm.state.focus = 'transitionLabel';
         str = name_color_from_focus_state(sfm);
         set(sfm.focusText, 'string', str, 'vis','on');
         sfm.boldH = bold(sfm, sfm.transLabelH);
         set(sfm.focusText2, 'string', xlate('TransitionLabel Font'));
         set(sfm.focusText2, 'vis','on');
      elseif point_inside_rect(acp, sfm.transPos),	
         sfm.state.focus = 'transition';
         str = name_color_from_focus_state(sfm);
         set(sfm.focusText, 'string', str, 'vis','on');
         sfm.boldH = bold(sfm, sfm.transH);
         set(sfm.focusText2, 'vis','off');
      elseif point_inside_rect(acp, sfm.junctPos),	
         sfm.state.focus = 'junction';			
         str = name_color_from_focus_state(sfm);
         set(sfm.focusText, 'string', str, 'vis','on');
         sfm.boldH = bold(sfm, sfm.junctH);
         set(sfm.focusText2, 'vis','off');
      else,											
         sfm.state.focus = 'state';
         str = name_color_from_focus_state(sfm);
         set(sfm.focusText, 'string', str, 'vis','on');
         sfm.boldH = bold(sfm, sfm.stateH);
         set(sfm.focusText2, 'vis','off');
      end;
   else,											% over background
      sfm.state.focus = 'chart';
      str = name_color_from_focus_state(sfm);
      set(sfm.focusText, 'string', str , 'vis','on');
      sfm.boldH = bold(sfm, 0);
      set(sfm.focusText2, 'vis','off');
   end;
   
else,												 % No focus 
   sfm.state.focus =   'None';
   set(sfm.focusText,  'vis','off');
   set(sfm.focusText2, 'vis','off');
   sfm.boldH = bold(sfm, 0);
end;

set_sfm(sfm);	



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function error_func
%
%
%
disp('Error: Styler information failed to initialize.');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = point_inside_rect(point, rect),
%
%
%
p.x = point(1);
if (length(point(:)) > 3), p.y = point(3); 
else p.y = point(2);
end;
r.x = rect(1);
r.y = rect(2);
r.w = rect(3);
r.h = rect(4);

out = (p.x > r.x & p.x < (r.x + r.w) & p.y > r.y & p.y < (r.y + r.h));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = bold(sfm, h)
%
%
%
if (h==sfm.boldH) return; end;

%
% debold the old focus
%
if (sfm.boldH > 0),
   type = get(sfm.boldH, 'type');
   switch(type),
   case 'text',
      % restore old values stored in userdata      
      ud = get(sfm.boldH, 'userdata');
      set_font_on_hg_text( sfm.boldH, ud );
   otherwise, set(sfm.boldH, 'linewidth', 1);
   end 
end;

if (h > 0),
   sfm.boldH = h;
   type = get(h, 'type');
   switch(type),
   case 'text', 
      % record old text state for restoring later
      ftemp      = get_font_from_hg_text( h );
      fontWeight = lower(ftemp.FontWeight);
      
      set( h, 'userdata', ftemp );
      
      if strcmp(fontWeight, 'bold'),    
         set(h, 'fontSize', ftemp.FontSize+1);
      else
         set(h, 'fontWeight', 'bold' );
      end;
   otherwise,
      set(h, 'linewidth', 2);
   end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function get_colors(sfm)
%
%
%
cc = sf('get', sfm.chartId, '.chartColor');
sc = sf('get', sfm.chartId, '.selectionColor');
hc = sf('get', sfm.chartId, '.highlightColor');
ec = sf('get', sfm.chartId, '.errorColor');
stc = sf('get', sfm.chartId, '.stateColor');
stlc = sf('get', sfm.chartId, '.stateLabelColor');
tc = sf('get', sfm.chartId, '.transitionColor');
tlc = sf('get', sfm.chartId, '.transitionLabelColor');
jc = sf('get', sfm.chartId, '.junctionColor');

set(sfm.axes, 'color', cc, 'YColor', cc, 'XColor', cc, 'UserData', cc);
set(sfm.selectionH, 'color', sc, 'userdata',sc);
set(sfm.highlightH, 'color', hc, 'userdata',hc);
set(sfm.errorH, 'color', ec, 'userdata',ec);
set(sfm.stateH, 'edgecolor', stc, 'userdata', stc);
set(sfm.transH, 'color', tc,'userdata',tc);
set(sfm.junctH, 'edgecolor', jc, 'userdata', jc);
set(sfm.transLabelH, 'color', tlc, 'userdata', tlc);
set(sfm.stateLabelH, 'color', stlc, 'userdata', stlc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function get_fonts(sfm)
%
%
%
stateFont = [];
stateFont.FontName = sf('get', sfm.chartId, '.stateFont.fontName');
stateFont.FontWeight = sf('get', sfm.chartId, '.stateFont.fontWeight');
stateFont.FontAngle = sf('get', sfm.chartId, '.stateFont.fontAngle');
stateFont.FontSize = sf('get', sfm.chartId, '.stateFont.defaultFontSize');
stateFont.FontUnits = 'points';

transFont = [];
transFont.FontName = sf('get', sfm.chartId, '.transitionFont.fontName');
transFont.FontWeight = sf('get', sfm.chartId, '.transitionFont.fontWeight');
transFont.FontAngle = sf('get', sfm.chartId, '.transitionFont.fontAngle');
transFont.FontSize = sf('get', sfm.chartId, '.transitionFont.defaultFontSize');
transFont.FontUnits = 'points';

set_font_on_hg_text(sfm.stateLabelH, stateFont);
set_font_on_hg_text(sfm.transLabelH, transFont);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c = get_rgb_color_from_user(startColor, title),
%
%
%
c = uisetcolor(startColor, title);		

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = get_font_from_user(startFont, title),
%
%
%
f = uisetfont(startFont, title);		

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function title = compose_title(id)
%
%
%
title = sprintf('Colors & Fonts for: %s', sf('get', id,'.name'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function extRect = get_hg_text_extent_rect(h),
%
%
%
ext = get(h, 'extent');
pos = get(h, 'pos');

extRect = [pos(1) (pos(2)-ext(4)/2) ext(3) ext(4)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function construct_method(id)
%
%
%
sfm = get_sfm;

if ~isempty(sfm),
   sfm.chartId = id;
   get_colors(sfm);
   set(sfm.fig, 'Name', compose_title(sfm.chartId));
   figure(sfm.fig);
   set_sfm(sfm);
   return;
end;

% need to make sure that Japanese machines have Japanese fonts
helveticaFont = 'helvetica';
timesFont = 'times';
lang = get(0,'language');
if strncmp(lang,'ja',2)
   timesFont = get(0,'defaultTextFontname');
   helveticaFont = get(0,'defaultUIControlFontname');
end


sfm.chartId = id;

ss = get(0, 'screensize');

figW = 320;
figH = 310;
figX = (ss(3) - figW)/2;
figY = (ss(4) - figH)/2;
xMargin = 5;
yMargin = 5;
pixelsPerPoint = sf('get', id, '.screen.pixelsPerPoint');
buttonH = 16 * pixelsPerPoint;
buttonW = 40 * pixelsPerPoint;
buttonBuff = 6 * pixelsPerPoint;
buff = 8;
smallBuff = 3;
textH = 12;
bottomBuff = yMargin + buttonH + buff;
topBuff = figH - yMargin - 2*textH - buff;

uidefault = get(0, 'defaultuicontrolbackground');
sfm.fig = figure('visible', 'off' ...					 
   ,'pos', [figX figY figW figH]...
   ,'Name', compose_title(sfm.chartId) ...
   ,'doublebuffer','on'...
   ,'Menu','None'...
   ,'Toolbar','none' ...
   ,'NumberTitle','off'...
   ,'Tag', 'SF_STYLER'...
   ,'color', uidefault ...
,'handlevis', 'off' ...
   ,'integerhand', 'off' ...
   ,'resize','off'...
   );

sfm.axesPos = [xMargin bottomBuff figW-2*xMargin topBuff-bottomBuff];

sfm.axes = axes('parent', sfm.fig ...
   ,'box','off'...
   ,'YTick',[]...
   ,'XTick',[]...
   ,'units','pixels'...
   ,'pos',sfm.axesPos...
   ,'defaulttextfontname',timesFont...
   ,'XLim', [0 sfm.axesPos(3)]...
   ,'YLim', [0 sfm.axesPos(4)]...
   );

titleText2X = sfm.axesPos(1);
titleText2Y = sfm.axesPos(4) + textH;

sfm.titleText2 = text('parent', sfm.axes ...
   ,'string',xlate( '\itRight Click to change: ')...
   ,'interp','tex'...
   ,'pos', [titleText2X titleText2Y 0]...
   ,'fontname', helveticaFont...
   ,'fontsize', 9 ...
   ,'color', [.25 .25 .25]...
   );
titleExt2 = get(sfm.titleText2,'extent');
sfm.focusText2 = text('parent', sfm.axes ...
   ,'string', xlate('Background Color ')...
   ,'interp','tex'...
   ,'fontname', helveticaFont...
   ,'fontWeight', 'bold'...
   ,'pos', [titleText2X+titleExt2(3)+5 titleText2Y 0]...
   ,'fontsize', 10 ...
   ,'color', [0 0 0]...
   ,'vis','off'...
   );

titleTextX = titleText2X;
titleTextY = sfm.axesPos(4) + 2*textH + smallBuff;
sfm.titleText = text('parent', sfm.axes ...
   ,'string', xlate('\itClick to change: ')...
   ,'interp','tex'...
   ,'pos', [titleTextX titleTextY 0]...
   ,'fontsize', 9 ...
   ,'fontname', helveticaFont...
   ,'color', [.25 .25 .25]...
   );
titleExt = get(sfm.titleText,'extent');
titleTextX =  sfm.axesPos(1) + titleExt2(3) - titleExt(3);
set(sfm.titleText, 'pos', [titleTextX titleTextY 0]);
sfm.focusText = text('parent', sfm.axes ...
   ,'string', xlate('Background Color ')...
   ,'interp','tex'...
   ,'fontWeight', 'bold'...
   ,'pos', [titleTextX+titleExt(3)+5 titleTextY 0]...
   ,'color', [0 0 0]...
   ,'fontsize', 10 ...
   ,'fontname', helveticaFont...
   ,'vis','off'...
   );


% Selection
textPos = [2*xMargin sfm.axesPos(4)-2*textH 0];
sfm.selectionH = text('parent', sfm.axes ...
   ,'string', xlate('\itSelection')...
   ,'interp','tex'...
   ,'pos', textPos...
   );
sfm.selectionPos = get(sfm.selectionH, 'extent');
sfm.selectionPos(1) = textPos(1);
sfm.selectionPos(2) = textPos(2) - sfm.selectionPos(4)/2;

% Highlight
textPos = [sfm.axesPos(3)/2-sfm.selectionPos(3)/2 textPos(2) 0];
sfm.highlightH = text('parent', sfm.axes ...
   ,'string', xlate('\itHighlight')...
   ,'interp','tex'...
   ,'pos', textPos...
   );

sfm.highlightPos = get(sfm.highlightH, 'extent');
sfm.highlightPos(1) = textPos(1);
sfm.highlightPos(2) = textPos(2) - sfm.highlightPos(4)/2;

% Error
textPos = [sfm.axesPos(3)-sfm.selectionPos(3) textPos(2) 0];
sfm.errorH = text('parent', sfm.axes ...
   ,'string', xlate('\itError')...
   ,'interp','tex'...
   ,'pos', textPos...
   );

sfm.errorPos = get(sfm.errorH, 'extent');
sfm.errorPos(1) = textPos(1);
sfm.errorPos(2) = textPos(2) - sfm.errorPos(4)/2;

% State
sfm.statePos = [2*xMargin 2*yMargin sfm.axesPos(3)-4*xMargin textPos(2)-4*yMargin-textH];
sfm.stateH = rectangle('parent', sfm.axes ...
   ,'pos', sfm.statePos...
   ,'curvature', .18...
);


% State Label 
% this should not be translated until Stateflow can handle Japanese state names 
textPos = [4*xMargin sfm.statePos(2)+sfm.statePos(4)-textH-4 0];
sfm.stateLabelH = text('parent', sfm.axes ...
   ,'string','StateLabel'...
   ,'pos', textPos...
   );


% Trans
xdata = [...
      10.2500
   15.6149
   20.7620
   25.7115
   30.4838
   35.0991
   39.5777
   43.9398
   48.2058
   52.3958
   56.5301
   60.6291
   64.7129
   68.8019
   72.9163
   77.0764
   81.3024
   85.6147
   90.0335
   94.5790
   99.2715
   104.1313
   109.1787
   114.4339
   113.0722
   136.2739
   115.7956
   114.4339];

ydata = [...
      87.0000
   87.0862
   87.3314
   87.7160
   88.2202
   88.8242
   89.5083
   90.2525
   91.0373
   91.8428
   92.6492
   93.4368
   94.1858
   94.8765
   95.4890
   96.0035
   96.4004
   96.6598
   96.7620
   96.6872
   96.4156
   95.9274
   95.2029
   94.2224
   87.6704
   89.6833
   100.7743
   94.2224];
xdata = xdata - xdata(1) + sfm.statePos(1) + 1;
sfm.transH = line('parent', sfm.axes ...
   ,'XData', xdata...
   ,'YData', ydata...
   );
sfm.transPos = [sfm.statePos(1) sfm.statePos(2)+sfm.statePos(4)/2-textH max(xdata)-sfm.statePos(1) textH];


% Trans Label  
% this should not be translated until Stateflow can handle Japanese transition names 
textPos = [3*xMargin min(ydata)-textH 0];
sfm.transLabelH = text('parent', sfm.axes ...
   ,'string', 'TransitionLabel'...
   ,'pos', textPos...
   );

% Junction
r = 30;
sfm.junctPos = [max(xdata) sfm.statePos(4)/2-12 r r];
sfm.junctH = rectangle('parent', sfm.axes ...
   ,'curvature', 1 ...
   ,'pos',sfm.junctPos...
   );

pos = [(figW - xMargin - buttonW) 2*yMargin buttonW buttonH];
sfm.applyB = uicontrol('parent', sfm.fig ...
   ,'style','push'...
   ,'String', 'Apply'...
   ,'Callback', 'sf(''Private'',''sfstyler'',''APPLY'');'...
   ,'units','pixels'...
   ,'pos', pos...
   );

pos = [pos(1)-buttonBuff-buttonW 2*yMargin buttonW buttonH];
sfm.helpB = uicontrol('parent', sfm.fig ...
   ,'style','push'...
   ,'String', 'Help'...
   ,'Callback', 'sfhelp;'...
   ,'Enable','on'...
   ,'units','pixels'...
   ,'pos', pos...
   );

pos = [pos(1)-buttonBuff-buttonW 2*yMargin buttonW buttonH];
sfm.cancelB = uicontrol('parent', sfm.fig ...
   ,'style','push'...
   ,'String', 'Cancel'...
   ,'Callback', 'sf(''Private'',''sfstyler'',''CANCEL'');'...
   ,'Enable','on'...
   ,'units','pixels'...
   ,'pos', pos...
   );

pos = [pos(1)-buttonBuff-buttonW 2*yMargin buttonW buttonH];
sfm.okB = uicontrol('parent', sfm.fig ...
   ,'style','push'...
   ,'String', 'OK'...
   ,'Callback', 'sf(''Private'',''sfstyler'',''OK'');'...
   ,'units','pixels'...
   ,'pos', pos...
   );

sfm.schemes.top = uimenu(sfm.fig...
   ,'Label', 'Schemes'...
   );

sfm.schemes.default	= uimenu(sfm.schemes.top...
   ,'Label', 'Default'...
   ,'Callback', 'sf(''Private'',''sfstyler'',''DEFAULT'');'...
   );

sfm.schemes.classic	= uimenu(sfm.schemes.top...
   ,'Label', 'Classic'...
   ,'Callback', 'sf(''Private'',''sfstyler'',''CLASSIC'');'...
   );

sfm.schemes.antique	= uimenu(sfm.schemes.top...
   ,'Label', 'Antique'...
   ,'Callback', 'sf(''Private'',''sfstyler'',''ANTIQUE'');'...
   );
sfm.schemes.rose	= uimenu(sfm.schemes.top...
   ,'Label', 'Rose'...
   ,'Callback', 'sf(''Private'',''sfstyler'',''ROSE'');'...
   );
sfm.schemes.grayscale	= uimenu(sfm.schemes.top...
   ,'Label', 'GrayScale'...
   ,'Callback', 'sf(''Private'',''sfstyler'',''GRAYSCALE'');'...
   );

sfm.schemes.neon	= uimenu(sfm.schemes.top...
   ,'Label', 'Neon'...
   ,'Callback', 'sf(''Private'',''sfstyler'',''NEON'');'...
   );

sfm.schemes.slate	= uimenu(sfm.schemes.top...
   ,'Label', 'Slate'...
   ,'Callback', 'sf(''Private'',''sfstyler'',''SLATE'');'...
   );
sfm.schemes.desert	= uimenu(sfm.schemes.top...
   ,'Label', 'Desert'...
   ,'Callback', 'sf(''Private'',''sfstyler'',''DESERT'');'...
   );

sfm.schemes.valerie	= uimenu(sfm.schemes.top...
   ,'Label', 'Valerie'...
   ,'Callback', 'sf(''Private'',''sfstyler'',''VALERIE'');'...
   );
sfm.schemes.factory	= uimenu(sfm.schemes.top...
   ,'Label', 'Factory'...
   ,'Callback', 'sf(''Private'',''sfstyler'',''FACTORY'');'...
   );

sfm.options.top = uimenu(sfm.fig...
   ,'Label', 'Options'...
   );
sfm.options.setdefaults	= uimenu(sfm.options.top...
   ,'Label', 'Make this the ''Default'' scheme'...
   ,'Callback', 'sf(''Private'',''sfstyler'',''SETDEFAULTS'');'...
   );
sfm.options.savedefaults = uimenu(sfm.options.top...
   ,'Label', 'Save defaults to disk'...
   ,'Callback', 'sf(''Private'',''sfstyler'',''SAVEDEFAULTS'');'...
   );


sfm.boldH = 0;
get_colors(sfm);
get_fonts(sfm);

% compute the label poses after getting the fonts 
sfm.stateLabelPos = get_hg_text_extent_rect(sfm.stateLabelH);
sfm.transLabelPos = get_hg_text_extent_rect(sfm.transLabelH);

% setup the statemachine
sfm.state.main = 'Idle';
sfm.state.focus = 'None';

set_sfm(sfm);

% 
% Setup callbacks and turn visibility on
%
set(sfm.fig ...
   ,'WindowButtonDown', 'sf(''Private'',''sfstyler'',''BD'');'...
   ,'WindowButtonMotion', 'sf(''Private'',''sfstyler'',''BM'');'...
   ,'WindowButtonUp', 'sf(''Private'',''sfstyler'',''BU'');'...
   );

set(sfm.fig, 'vis','on');


%%%%%%%%%%%%%%%%
% color schema %
%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%
function selection(sfm, c)
%
%
%
set(sfm.selectionH, 'color', c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
function highlight(sfm, c)
%
%
%
set(sfm.highlightH, 'color', c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
function error_c(sfm, c)
%
%
%
set(sfm.errorH, 'color', c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
function state(sfm, c)
%
%
%
set(sfm.stateH, 'edgecolor', c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
function state_label(sfm, c)
%
%
%
set(sfm.stateLabelH, 'color', c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
function trans(sfm, c)
%
%
%
set(sfm.transH, 'color', c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
function trans_label(sfm, c)
%
%
%
set(sfm.transLabelH, 'color', c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
function junct(sfm, c)
%
%
%
set(sfm.junctH, 'edgecolor', c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chart(sfm, c)
%
%
% 
set(sfm.axes, 'color', c, 'ycolor', c, 'xcolor', c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function schema_classic(sfm),
%
%
%
selection(sfm, [0 1 0]);
highlight(sfm, [0 1 1]);
error_c(sfm, [1 0 0]);
chart(sfm, [0 0 0]);
state(sfm, [0 1 1]);
state_label(sfm, [1 1 1]);
trans(sfm, [1 1 0]);
trans_label(sfm, [1 1 0]);
junct(sfm, [1 0 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function schema_neon(sfm),
%
%
%
selection(sfm, [1 0 1]);
highlight(sfm, [0 0 1]);
error_c(sfm, [1 0 0]);
chart(sfm, [.25 .25 .25]);
state(sfm, [0 0 1]);
state_label(sfm, [0 0 1]);
trans(sfm, [0 1 0]);
trans_label(sfm, [0 1 0]);
junct(sfm, [1 1 0]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function schema_antique(sfm),
%
%
%
burgandy = [255 0 132]/255;

state(sfm, [0 0 0]);
highlight(sfm, [0 0 1]);
state_label(sfm, [0 0 0]);
trans(sfm, [0.2901960784313726 0.3294117647058824 0.6039215686274509]);
trans_label(sfm, [0.2901960784313726 0.3294117647058824 0.6039215686274509]);
junct(sfm, [0.6823529411764706 0.3294117647058824 0]);
selection(sfm, burgandy);
chart(sfm, [1 0.9607843137254902 0.8823529411764706]);
error_c(sfm, [1 0 0]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function schema_factory(sfm),
%
%
%
schema_antique(sfm);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function schema_default(sfm),
%
%
%
cc = sf('get', 'default', 'chart.chartColor');
stc = sf('get', 'default', 'chart.stateColor');
stlc = sf('get', 'default', 'chart.stateLabelColor');
tc = sf('get', 'default', 'chart.transitionColor');
tlc = sf('get', 'default', 'chart.transitionLabelColor');
jc = sf('get', 'default', 'chart.junctionColor');
sc = sf('get', 'default', 'chart.selectionColor');
hc = sf('get', 'default', 'chart.highlightColor');

state(sfm, stc);
state_label(sfm, stlc);
trans(sfm, tc);
trans_label(sfm, tlc);
junct(sfm, jc);
selection(sfm, sc);
chart(sfm, cc);
error_c(sfm, [1 0 0]);
highlight(sfm, hc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function schema_pastel(sfm),
%
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function schema_grayscale(sfm),
%
%
%
light = [128 128 128]/255;
selection(sfm, [192 192 192]/255);
highlight(sfm, [0 0 0]);
chart(sfm, [1 1 1]);
state(sfm, [0 0 0]);
state_label(sfm, [0 0 0]);
trans(sfm, light);
trans_label(sfm, light);
junct(sfm, light);
error_c(sfm, [1 0 0]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function schema_rose(sfm),
%
%
%
rose = [208 176 184]/255;
darkRose = [128 0 64]/255;
slate =  [74 84 154]/255;

selection(sfm, [1 1 1]);
highlight(sfm, darkRose);
chart(sfm, rose);
state(sfm, darkRose);
state_label(sfm, darkRose);
trans(sfm, slate);
trans_label(sfm, slate);
junct(sfm, darkRose);
yellowy = [245 252 3]/255;
error_c(sfm, yellowy);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function schema_slate(sfm),
%
%
%
slate = [176 192 208]/255;
darkSlate = [62 82 103]/255;
dark2 = [67 90 114]/255;
yellowy = [245 252 3]/255;

selection(sfm, yellowy);
highlight(sfm, darkSlate);
chart(sfm, slate);
state(sfm, darkSlate);
state_label(sfm, darkSlate);
trans(sfm, [0 0 0 ]);
trans_label(sfm, [0 0 0]);
junct(sfm, dark2);
error_c(sfm, [1 0 0]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function schema_valerie(sfm),
%
%
%
greeny = [0 164 82]/255;

selection(sfm, [1 0 0 ]);
highlight(sfm, greeny);
chart(sfm, [1 0.9607843137254902 0.8823529411764706]);
state(sfm, greeny);
state_label(sfm, greeny);
trans(sfm, [0 0 1]);
trans_label(sfm, [0 0 1]);
junct(sfm, [1 0 1]);
error_c(sfm, [1 0 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function schema_desert(sfm),
%
%
%
kaki = [230  224 208]/255;
brown = [102 89 57]/255;
dark2 = [67 90 114]/255;
amber = [196 92 0]/255;

selection(sfm, [128 128 255]/255);
highlight(sfm, brown);
chart(sfm, kaki);
state(sfm, brown);
state_label(sfm, [0 0 0]);
trans(sfm, [0 0 0]);
trans_label(sfm, [0 0 0]);
junct(sfm, amber);
error_c(sfm, [1 0 0]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function set_default_font_in_sf(font, fontField)
%
%
%
sf('set', 'default', ['chart',fontField,'.fontName'], font.FontName);
sf('set', 'default', ['chart',fontField,'.fontWeight'], font.FontWeight);
sf('set', 'default', ['chart',fontField,'.fontAngle'],font.FontAngle);
sf('set', 'default', ['chart',fontField,'.defaultFontSize'], font.FontSize);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function set_defaults(sfm),
%
%
%
cc = get(sfm.axes, 'color');
sc = get(sfm.selectionH, 'color');
hc = get(sfm.highlightH, 'color');
stc = get(sfm.stateH, 'edgecolor');
stlc = get(sfm.stateLabelH, 'color');
tc = get(sfm.transH, 'color');
tlc = get(sfm.transLabelH, 'color');
jc = get(sfm.junctH, 'edgecolor');
ec = get(sfm.errorH, 'color');

sf('set', 'default', 'chart.selectionColor', sc);
sf('set', 'default', 'chart.highlightColor', hc);
sf('set', 'default', 'chart.stateColor', stc);
sf('set', 'default', 'chart.stateLabelColor', stlc);
sf('set', 'default', 'chart.transitionColor', tc);
sf('set', 'default', 'chart.transitionLabelColor', tlc);
sf('set', 'default', 'chart.junctionColor', jc);
sf('set', 'default', 'chart.chartColor', cc);
sf('set', 'default', 'chart.errorColor', ec);

stateFont = get_font_from_hg_text(sfm.stateLabelH);
transFont = get_font_from_hg_text(sfm.transLabelH);

set_default_font_in_sf(stateFont, '.stateFont');
set_default_font_in_sf(transFont, '.transitionFont');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_defaults(sfm),
%
% Saves ALL defaults!
%
try
   sfsave('defaults');
catch
   disp(lasterr);
   slsfnagctlr('ViewNagLog');
end

