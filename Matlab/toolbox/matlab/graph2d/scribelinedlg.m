function scribelinedlg(varargin)
%SCRIBELINEDLG   Line property dialog helper function for Plot Editor

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.21 $  $Date: 2002/06/17 13:32:41 $

persistent localData;

switch nargin
case 1
   arg1 = varargin{1};
   
   if isempty(arg1) | ishandle(arg1(1)) | isa(arg1(1), 'scribehandle')
      localData = LInitFig(arg1,localData);
      return
   elseif ischar(arg1(1))
      action = arg1;
      parameter = [];
   end

case 2
   action = varargin{1};
   parameter = varargin{2};

end

if strcmp(parameter,'me')
   parameter = gcbo;
end


localData = feval(action,parameter,localData);

%%%%%%

function localData = LInitFig(objectV,localData)

if isempty(objectV)
   LNoLineError;
   return
end

try
   if ishandle(objectV)
      fig = get(get(objectV(1),'Parent'),'Parent');
   else
      % might be any selected object
      fig = get(objectV(1),'Figure');
   end
catch
   errordlg(['Unable to edit line properties: invalid line' ...
              ' handles']);
   return
end

oldPointer = get(fig,'Pointer');
set(fig,'Pointer','watch');

try
   if ishandle(objectV)
      LineVector = [];
      ArrowVector = [];
      for aHG = objectV
         if strcmp(get(aHG,'Type'),'line')
            LineVector(end+1) = aHG;
         end
      end
   else
      % pick out the line objects from the list
      LineVector = scribehandle([]);
      ArrowVector = scribehandle([]);
      for aObj = objectV
         if isa(aObj,'editline'), 
            LineVector = [LineVector aObj];
            % LineVector(end+1) = aObj;
         elseif isa(aObj,'arrowline')
            ArrowVector = [ArrowVector aObj];
            % ArrowVector(end+1) = aObj;
         end
      end
   end
   if isempty(LineVector)
      IndLine = [];
   else
      IndLine = [1:length(LineVector)];
   end
   HG = [LineVector ArrowVector];
      
catch
   set(fig,'Pointer',oldPointer);
   errordlg(['Unable to open line properties dialog. ' ...
              'Selection list is invalid:' ...
              10 lasterr]);
   return
end

if isempty(HG)
   LNoLineError;
   set(fig,'Pointer',oldPointer);   
   return
end

%--temporary:  redirect to Property Editor
%propedit(get(HG,'MyHGHandle'));
%set(fig,'Pointer',oldPointer);   
%return

%---Set enable flag for marker boxes
if isequal(length(ArrowVector),length(HG)),
   MarkerEnable='off';
else
   MarkerEnable='on';
end

%---Get all object data
for ctHG = 1:length(HG)
   GetData(ctHG) = struct('Selected',get(HG(ctHG),'Selected'), ...
      'Parent',get(HG(ctHG),'Parent'), ...
      'LineStyle',get(HG(ctHG),'LineStyle'), ...
      'LineWidth',get(HG(ctHG),'LineWidth'), ...
      'Marker',get(HG(ctHG),'Marker'), ...
      'MarkerSize',get(HG(ctHG),'MarkerSize'), ...
      'Color',get(HG(ctHG),'Color'));
   % turn off selection so we can see changes in marker style
   set(HG(ctHG),'Selected','off');
end % for ctHG

localData = struct('CommonWidth',1,'CommonStyle',1,'CommonSize',1, ...
   'CommonMarker',1,'CommonColor',1);
localData.Selected = {GetData(:).Selected};

try
% adjustment factors for character units
% work in character units.
fx = 5;
fy = 13;

figWidth = 360/fx;
figHeight = 220/fy;

callerPosition = get(fig,'Position');
callerUnits = get(fig,'Units');

bgcolor = get(0,'DefaultUIControlBackgroundColor');
if bgcolor==[0 0 0]
   fgcolor = [1 1 1];
else
   fgcolor = get(0,'DefaultUIControlForegroundColor');
end

fProps = struct(...
      'Units', callerUnits,...
      'Color', bgcolor,...
      'NumberTitle', 'off',...
      'IntegerHandle', 'off',...
      'Pointer','watch', ...
      'Resize', 'off',...
      'Visible', 'off',...
      'KeyPressFcn', 'scribelinedlg keypress',...
      'HandleVisibility', 'callback',...
      'WindowStyle', 'modal',...
      'CloseRequestFcn', 'scribelinedlg button close',...
      'Name', 'Edit Line Properties',...
      'Position', callerPosition);
f = figure(fProps);
set(f,'Units','character');
figPos = get(f,'Position');

figPos(1:2) = figPos(1:2) + (figPos(3:4)-[figWidth, figHeight])/2;
figPos(3:4) = [figWidth, figHeight];
set(f,'Position',figPos);


ut = uicontrol('Style'   , 'text',...
        'Units'   , 'character',...
        'Parent'  , f,...
        'Visible' , 'off',...
        'String'  , 'Title');
charSize = get(ut,'Extent');
charH = charSize(4);
delete(ut);

% geometry
LMarginW = 25/fx;
RMarginW = 25/fx;
ColPadW = 10/fx;

RowLabelW = 65/fx;
ColW = (figPos(3)-2*RowLabelW-LMarginW-RMarginW-3*ColPadW)/2;

TopMarginH = 20/fy;
BotMarginH = 20/fy;
RowH = 30/fy;
RowPadH = 8/fy;

uiH = RowH-RowPadH;
buttonW = 72/fx;
buttonH = RowH-RowPadH;
buttonPad = 7/fx;

charOffset = uiH-charH;

% property defaults
editProps = struct(...
      'Style', 'edit',...
      'Parent'  , f,...
      'Units', 'character',...
      'BackgroundColor', 'w',...
      'ForegroundColor', 'k',...      
      'HorizontalAlignment', 'left');

tProps = struct(...
        'Style','text',...
        'Parent'  , f,...
        'Units', 'character',...
        'HorizontalAlignment', 'right',...
        'BackgroundColor', bgcolor,...
        'ForegroundColor', fgcolor);

prompt = {...
        'Line Width:'    
        'Line Style:'    
        ''               
        'Color:'      
        'Marker Size:'   
        'Marker:'     
        };

properties = {...
        'edit'    'scribelinedlg verifyposnumber me' 'LineWidth'
        'popupmenu'   ''                              'LineStyle'
        ''        ''                              ''
        'frame'   ''     ''        
        'edit'    'scribelinedlg verifyposnumber me' 'MarkerSize'
        'popupmenu'   ''                              'Marker'
        };


linestyles =  {'-'  '--'  ':'  '-.' 'none'};
markers = {'none'  '+'  'o'  '*'  '.'  'x'  'square'  'diamond' ...
      'v' '^'  '>'  '<'  'pentagram'  'hexagram'};

% Find common LineWidth and MarkerSize
CommonWidth = unique([GetData(:).LineWidth]);
if length(CommonWidth)>1, 
   widthStr = '';
   localData.CommonWidth = 0;
else, widthStr = num2str(CommonWidth);
end

CommonSize = unique([GetData(IndLine).MarkerSize]);
if length(CommonSize)>1, 
   sizeStr = '';
   localData.CommonSize = 0;
else, sizeStr = num2str(CommonSize);
end

% Find Common LineStyle
CommonStyle = unique({GetData(:).LineStyle});
if length(CommonStyle)==1, 
   styleVal = find(strcmp(CommonStyle{1},linestyles));
   linestr = {'solid (-)'  'dash (--)'  'dot (:)'  'dash-dot (-.)'  'none'};
else
   styleVal = 1;
   localData.CommonStyle = 0;
   linestyles = [{'Current'},linestyles];
   linestr = {'Current'  'solid (-)'  'dash (--)'  'dot (:)'  'dash-dot (-.)'  'none'};
end
% Find Common Marker
markerVal = 1;
if ~isempty(IndLine),
   CommonMarker = unique({GetData(IndLine).Marker});
   if length(CommonMarker)==1, 
      markerVal = find(strcmp(CommonMarker{1},markers));
   else
      localData.CommonMarker = 0;
      markers = [{'Current'},markers];
   end
end

strings = {...
        widthStr 
        linestr
        ''
        ''
        sizeStr
        markers
        };

values = {...
        0
        styleVal
        0
        0
        0
        markerVal
        };
        
enables = {...
        'on'
        'on'
        'on'
        'on'
        MarkerEnable
        MarkerEnable
        };
        
data = {...
        ''  
        linestyles
        ''  
        ''  
        ''  
        markers  
       };

        
nRows = length(prompt);

% lay down prompts
Y = figPos(4)-TopMarginH-charOffset;
headingPosition = [LMarginW Y RowLabelW uiH];
for iRow=1:nRows
   if iRow==5  % start new column
      Y = figPos(4)-TopMarginH-charOffset;
      headingPosition = [LMarginW+RowLabelW+ColW+2*ColPadW Y RowLabelW uiH];
   end
   Y = Y-RowH;
   if ~isempty(prompt{iRow})
      headingPosition(2) = Y;
      uicontrol(tProps,...
              'String', prompt{iRow,1},...
              'Tag', prompt{iRow,1},...     
              'Enable',enables{iRow}, ...
              'Position', headingPosition);
   end 
end

iGroup = 1;

Y = figPos(4)-TopMarginH;
headingPosition = [LMarginW+RowLabelW+ColPadW Y ColW uiH];
for iRow=1:nRows
   if iRow ==5 % start new column
      Y = figPos(4)-TopMarginH;
      headingPosition = [LMarginW+2*RowLabelW+ColW+3*ColPadW Y ColW uiH];
   end
   Y = Y-RowH;
   if ~isempty(prompt{iRow})
      headingPosition(2) = Y;
      uic = uicontrol(editProps,...
              'Style', properties{iRow,1},...
              'Callback', properties{iRow,2},...
              'Tag', properties{iRow,3},...
              'ToolTip', properties{iRow,3},...              
              'String', strings{iRow},...
              'Value', values{iRow},...
              'UserData', data{iRow},...
              'Enable',enables{iRow}, ...
              'Position', headingPosition);
      localData.LimCheck(iGroup) = uic;
      localData.Prop{iGroup} = properties{iRow,3};
      if strcmp(properties{iRow,1},'edit')  % edit text box
         localData.OldVal{iGroup} = str2double(strings{iRow});
      end
      iGroup = iGroup + 1;      
   end 
end

% set color on color button
% Check for common color, otherwise use white
col  = cat(1,GetData(:).Color);
col = unique(col,'rows');
if size(col,1)>1, 
   BGC = [1 1 1];
   localData.CommonColor = 0;
   ColVis='off';
else, 
   BGC = col;
   ColVis='on';
end

Y = figPos(4)-TopMarginH-4*RowH;
headingPosition = [LMarginW+RowLabelW+ColPadW+(.1067*ColW) Y+(.164*uiH) ...
      ColW-(.205*ColW) uiH-(.3*uiH)];

colorSwatch = uicontrol(editProps,...
   'BackgroundColor',BGC, ...
   'Style','frame', ...
   'Tag','Color', ...
   'ToolTip', 'Color', ...            
   'Visible',ColVis, ...
   'Position', headingPosition);

headingPosition = [LMarginW+RowLabelW+ColW+2*ColPadW Y RowLabelW uiH];
uicontrol(editProps,...
        'Style', 'pushbutton',...
        'Callback', 'scribelinedlg getcolor me',...
        'Tag', '',...
        'BackgroundColor',bgcolor,...
        'ForegroundColor',fgcolor,...
        'Horiz','center', ...
        'String', 'Select...',...
        'UserData', colorSwatch,...
        'Position', headingPosition);



% OK, Apply, Cancel, Help
buttonX(1) = (figPos(3)-4*buttonW-2*buttonPad)/2;
for ib = 2:4
   buttonX(ib) = buttonX(ib-1) + buttonW + buttonPad;
end

buttonProps = struct(...
        'Parent', f,...
        'Units','character',...
        'BackgroundColor', bgcolor,...
        'ForegroundColor', fgcolor,...      
        'Position', [0 BotMarginH buttonW buttonH],...
        'Style', 'pushbutton');

buttonProps.Position(1) = buttonX(1);
u = uicontrol(buttonProps,...
        'Interruptible', 'off',...
        'String', 'OK',...
        'Callback', 'scribelinedlg button ok');
makedefaultbutton(u);

buttonProps.Position(1) = buttonX(2);
uicontrol(buttonProps,...
        'Interruptible', 'off',...
        'String', 'Cancel',...
        'Callback', 'scribelinedlg button cancel');

buttonProps.Position(1) = buttonX(3);
uicontrol(buttonProps,...
        'Interruptible', 'off',...
        'String', 'Help',...
        'Callback', 'scribelinedlg showhelp me');

buttonProps.Position(1) = buttonX(4);
uicontrol(buttonProps,...
        'Interruptible', 'on',...
        'String', 'Apply',...
        'Callback', 'scribelinedlg button apply');

set(fig,'Pointer',oldPointer);
set(f,'Visible','on','Pointer','arrow');
localData.HG = HG;

catch
   if exist('f')
      delete(f);
   end
   set(fig,'Pointer',oldPointer);
   for ct=1:length(HG),
      set(HG,'Selected',localData.Selected{ct});
   end
   lasterr
end

function localData = keypress(selection, localData)
key = double(get(gcbf,'CurrentCharacter'));
switch key
case 13 % enter
   localData = button('ok',localData);
case 27  % escape
   localData = button('cancel',localData);
end


function localData = showhelp(selection, localData)
try
   helpview([docroot '/mapfiles/plotedit.map'], ...
           'pe_line_change_props', 'PlotEditPlain');
catch
   errordlg(['Unable to display help for Line Properties:' ...
         sprintf('\n') lasterr ]);
end

function localData = button(selection, localData);
switch selection
case 'close'
   for ct=1:length(localData.HG)
      set(localData.HG(ct),'Selected',localData.Selected{ct});
   end
   delete(gcbf);
   localData = [];
case 'cancel'
   close(gcbf);
case 'ok'
   set(gcbf,'Pointer','watch');
   localData = LApplySettings(gcbf,localData);
   close(gcbf);
case 'apply'
   set(gcbf,'Pointer','watch');
   localData = LApplySettings(gcbf,localData);
   set(gcbf,'Pointer','arrow');
end


function val = getval(f,tag)
uic = findobj(f,'Tag',tag);
switch get(uic,'Style')
case 'edit'
   val = get(uic, 'String');  
case {'checkbox' 'radiobutton'}
   val = get(uic, 'Value');
case 'popupmenu'
   choices = get(uic, 'UserData');
   val = choices{get(uic,'Value')};
case 'frame'
   val = get(uic, 'BackgroundColor');
end   


function val = setval(f,tag,val)
uic = findobj(f,'Tag',tag);
switch get(uic,'Style')
case 'edit'
   set(uic, 'String',val); 
case {'checkbox' 'radiobutton' 'popupmenu'}
   set(uic, 'Value',val);
end


function localData = verifyposnumber(uic, localData)
iGroup = find(uic==localData.LimCheck);
val = str2double(get(uic,'String'));
if ~isnan(val)
   if length(val)==1 & val>0
      % if it's a single number greater than zero, then it's fine
      localData.OldVal{iGroup} = val;
      return
   end
end
% trap errors
set(uic,'String',num2str(localData.OldVal{iGroup}));
fieldName = get(uic,'ToolTip');
errordlg([fieldName ' field requires a single positive numeric input'],...
           'Error',...
           'modal');


function localData = getcolor(uic, localData)
colorSwatch = get(uic,'UserData');
currentColor = get(colorSwatch,'BackgroundColor');
c = uisetcolor(currentColor);

%---Trap when cancel is pressed. 
if ~isequal(c,currentColor)
   set(colorSwatch,'BackgroundColor',c,'Visible','on');
end

function localData = LApplySettings(f, localData)

HG = localData.HG;

try
      
   %---Only change LineWidth if not set to Current
   LW = str2double(getval(f,'LineWidth'));
   if ~isnan(LW),
      lineSettings.LineWidth = LW;
      localData.CommonWidth = 1;
   end % if strcmp(Marker...'Current')
   
   %---Only change Linestyle if not set to Current
   if ~strcmp(getval(f,'LineStyle'),'Current'),
      lineSettings.LineStyle = getval(f,'LineStyle');
      if ~localData.CommonStyle,
         StylePopup = findobj(f,'Tag','LineStyle');
         StyleVal = get(StylePopup,'Value');
         ud=get(StylePopup,'UserData');
         str = get(StylePopup,'String');
         set(StylePopup,'UserData',ud(2:end),'String',str(2:end), ...
            'Value',StyleVal-1);
         localData.CommonStyle= 1;
      end
   end % if strcmp(Linestyle...'Current')
   
   %---Only change the color if the colorswatch is visible
   colorSwatch = findobj(f,'Tag','Color');
   if strcmp(get(colorSwatch,'Visible'),'on');
      lineSettings.Color = getval(f,'Color');
   end % if colorswatch is visible
   
   %---Store subset for arrows
   arrowSettings = lineSettings;
   
   %---Only change the MarkerSize if on is actually entered
   MS = str2double(getval(f,'MarkerSize'));
   if ~isnan(MS),
      lineSettings.MarkerSize = MS;
   end % if strcmp(Marker...'Current')
   
   %---Only change Marker if not set to Current
   if ~strcmp(getval(f,'Marker'),'Current'),
      lineSettings.Marker= getval(f,'Marker');
      if ~localData.CommonMarker,
         StylePopup = findobj(f,'Tag','Marker');
         StyleVal = get(StylePopup,'Value');
         ud=get(StylePopup,'UserData');
         str = get(StylePopup,'String');
         set(StylePopup,'UserData',ud(2:end),'String',str(2:end), ...
            'Value',StyleVal-1);
         localData.CommonMarker = 1;
      end
   end % if strcmp(Marker...'Current')   
     
   for ctHG=1:length(HG)
      if ishandle(HG(ctHG))
         set(HG(ctHG), lineSettings);
      else
         if isa(HG(ctHG),'editline'),
            settings = lineSettings;
         elseif isa(HG(ctHG),'arrowline'),
            settings = arrowSettings;
         end  % if/else isa(HG...
         props = fieldnames(settings)';
         for i = props
            i=i{1};
            set(HG(ctHG),i,settings.(i));
         end % for i
      end
      legend(get(HG(ctHG),'Parent'));
   end
   
catch
   lasterr
   errordlg('Unable to set line properties.');
end


function LNoLineError
errordlg(['No lines are selected.  Click on an line to select it.']);
