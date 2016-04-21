function scribeaxesdlg(varargin)
%SCRIBEAXESDLG   Axes property dialog helper function for Plot Editor
%   SCRIBEAXESDLG(A)  opens axes property dialog for axes A

%   If the plot editor is active, the SCRIBEAXESDLG edits all
%   currently selected axes.  Alternatively, SCRIBEAXESDLG(S) 
%   explicitly passes a selection list S, a row vector
%   of scribehandle objects, to SCRIBEAXESDLG for editing.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.28 $  $Date: 2002/04/15 04:08:15 $
%   j. H. Roh


persistent localData;

switch nargin
case 1
   arg1 = varargin{1};
   
   if isempty(arg1) | ishandle(arg1) | isa(arg1(1),'scribehandle')
      localData = LInitFig(arg1,localData);
      return
   elseif ischar(arg1)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function localData = showhelp(selection, localData)
try
   helpview([docroot '/mapfiles/plotedit.map'], ...
           'pe_ax_props', 'PlotEditPlain');
catch
   errordlg(['Unable to display help for Axes Properties:' ...
         sprintf('\n') lasterr ]);
end

function localData = button(selection, localData);
switch selection
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

function localData = verifynumber(uic, localData)
iGroup = find(uic==localData.LimCheck);
val = str2double(get(uic,'String'));
if ~isnan(val)
   if length(val)==1
      localData.OldVal{iGroup} = val;
      return
   end
end
% trap errors
set(uic,'String',num2str(localData.OldVal{iGroup}));
fieldName = get(uic,'ToolTip');
errordlg([fieldName ' field requires a single numeric input'],'Error','modal');





function localData = key(fig,localData);
theKey = get(fig,'CurrentCharacter');
if isempty(theKey), return, end

switch theKey
case 13 % return
   scribeaxesdlg button ok;
case 27 % escape
   scribeaxesdlg button cancel;
case 9 % tab
   % next field
end
% manage state of controls


function localData = toggle(uic,localData);

iGroup = find(uic==localData.LimCheck);
Sibling = get(uic,'UserData');

enable = {'off' 'on'};
if isempty(Sibling),
   % Perform as before
   value = get(uic,'Value'); 
   if ~isempty(iGroup),
      set(localData.LimGroup{iGroup},'Enable',enable{value+1});
   end
else
   % See if the extra checkbox was pressed
   if isempty(get(uic,'String')),
      Sibling=uic; % Reset the Sibling as the current UIcontrol
   end
   SibUd = get(Sibling,'UserData');
   % Toggle the extra check box state
   if strcmp(get(Sibling,'enable'),'off');
      set(Sibling,'enable','inactive');
      value = get(Sibling,'Value');
   elseif isequal(SibUd.Value,get(Sibling,'Value')),
      set(Sibling,'value',~get(Sibling,'Value'))      
      value = get(Sibling,'Value');
   else
      set(Sibling,'enable','off','Value',SibUd.Value);
      value = 0;
   end
   if ~isempty(iGroup),
      set(localData.LimGroup{iGroup},'Enable',enable{value+1});
   end
end % if/else isempty(Sibling)


function localData = radio(uic,localData);
iGroup = find(uic==localData.LimCheck);

Sibling = get(uic,'UserData');

enableflag = 1;
if isempty(Sibling),
   % Perform as before
   set(uic,'Value',1);
   set(localData.LimGroup{iGroup},'Value',0);
else
   if ~isempty(get(uic,'String')),
      iGroup = iGroup+2;
      ActiveButton = localData.LimCheck(iGroup);
      value = ~get(ActiveButton,'Value');
   else
      ActiveButton = uic;
      value = get(ActiveButton,'Value');
   end
   udAB = get(ActiveButton,'UserData');
   udLimGroup = get(localData.LimGroup{iGroup},'UserData');
   udLimGroup.Value = 0;
   
   % Toggle the active radio button's state
   if strcmp(get(ActiveButton,'enable'),'off');
      udAB.Value = 1;
      set(ActiveButton,'enable','on','Value',1,'UserData',udAB);
      set(localData.LimGroup{iGroup},'Enable','on');
   elseif udAB.Value,
      udAB.Value = 0;
      set(ActiveButton,'Value',0, ...
         'Enable','off','UserData',udAB)
      set(localData.LimGroup{iGroup},'Value',0, ...
         'Enable','off','UserData',udLimGroup)   
      
      % Store the checkbox state,
      if ~isempty(localData.Enable{iGroup}),
         localData.Disable{iGroup-1}.CheckValue = get(localData.Enable{iGroup}(1),'Value');
      end
      enableflag = 0;
   else
      udAB.Value = 1;
      set(ActiveButton,'Value',1,'UserData',udAB);
      set(localData.LimGroup{iGroup},'Value',0,'UserData',udLimGroup)      
   end % if/else strcmp(Sibling,'enable'...)
end % if/else length(localData.axes...

% for the linear/log switches
disableGroup = localData.Disable{iGroup};
if ~isempty(disableGroup) & enableflag,
   if any(strcmp(get(disableGroup.Controls,'Enable'),'on')) ,
      set(disableGroup.Controls,'Enable','off');
      % Save the checkbox value
      localData.Disable{iGroup}.CheckValue = get(disableGroup.Controls(1),'Value');
   end
   set(disableGroup.Controls(1),'Value',0);           % uncheck
   Sibling = get(disableGroup.Controls(1),'UserData');
   if ~isempty(Sibling),
      set(Sibling,'Value',0,'Enable','off','HitTest','off');
   end
end
enableGroup = localData.Enable{iGroup};
if ~isempty(enableGroup) & enableflag,
   Sibling = get(enableGroup(1),'UserData');
   if ~isempty(Sibling),
      value = get(Sibling,'Value');
   else
      value = get(enableGroup(1),'Value');
   end
   if ~value
      set(enableGroup(1),'Enable','on',...
         'Value',localData.Disable{iGroup-1}.CheckValue);     % enable checkbox
   else
      set(enableGroup,'Enable','on');  % enable both
      set(enableGroup(1),'Value',localData.Disable{iGroup-1}.CheckValue);
   end % if/else value
   if ~isempty(Sibling),
      set(Sibling,'HitTest','on','Value',localData.Disable{iGroup-1}.CheckValue);
   end
else
   set(enableGroup,'Enable','off'); % disable both
end


function localData = LInitFig(ax,localData)

if isempty(ax)
   LNoAxesError;
   return
end
   
try
   if ishandle(ax)
      fig = get(ax(1),'Parent');
   else
      % might be any selected object
      fig = get(ax(1),'Figure');
   end
catch
   errordlg(['Unable to edit axes properties: invalid axes' ...
              ' handles.']);
   return
end

oldPointer = get(fig,'Pointer'); 
set(fig,'Pointer','watch');

try
   % look for a list of selected objects
   HG = [];
   if ~plotedit(fig,'isactive')
      % plotedit has not been activated and we have a list of HG handles
      HG = ax;     % take the original handle list
      
   else
      % call from the Figure Tools menu or from context menu
      % ax is a selection list
      for aObj = ax
         aHG = get(aObj,'MyHGHandle');
         if strcmp('axes',get(aHG,'Type'))
            HG(end+1) = aHG;
         end
      end
   end
catch
   set(fig,'Pointer',oldPointer);
   errordlg(['Unable to open Axes Properties dialog. ' ...
              'Selection list is invalid:' ...
              10 lasterr]);
   return
end

if isempty(HG)
   LNoAxesError;
   set(fig,'Pointer',oldPointer);   
   return
end

%--temporary:  redirect to Property Editor
%propedit(HG);
%set(fig,'Pointer',oldPointer);   
%return

ax = HG;

try
   % Property constants
   White = [1 1 1];
   Black = [0 0 0];
   
   % Check each axes, if one is 3D
   allViews = get(ax,{'view'});
   f2D = isequal(allViews{:},[0 90]);
   
   bgcolor = get(0,'DefaultUIControlBackgroundColor');
   if bgcolor==Black
      fgcolor = White;
   else
      fgcolor = get(0,'DefaultUIControlForegroundColor');
   end
   
   % adjustment factors for character units
   % work in character units.
   fx = 5;
   fy = 13;
   
   fProps = struct(...
      'Units', get(fig,'Units'),...
      'NumberTitle', 'off',...
      'IntegerHandle', 'off',...
      'Pointer','watch', ...
      'Resize', 'off',...
      'Color', bgcolor,...
      'Visible', 'off',...
      'KeyPressFcn', 'scribeaxesdlg key me',...
      'WindowStyle', 'modal',...
      'Name', 'Edit Axes Properties', ...
      'Position', get(fig,'Position'));
   f = figure(fProps);
   set(f,'Units','character');
   figPos = get(f,'Position');
   
   figWidth = 550/fx;
   figHeight = 325/fy;
   
   % center dialog over the calling window
   figPos(1:2) = figPos(1:2) + (figPos(3:4)-[figWidth, figHeight])/2;
   figPos(3:4) = [figWidth, figHeight];
   set(f,'Position',figPos);
   
   enable = {'off' 'on'};
   
   % geometry
   LMarginW = 15/fx;
   RMarginW = 25/fx;
   ColPadW = 20/fx;
   RowPadH = 9/fy;
   
   RowLabelW = 70/fx;
   if f2D
      nCols = 2;
   else
      nCols = 3;
   end
   data.nCols = nCols;
   setappdata(f,'ScribeAxesDialogData',data);
   
   ColW = (figPos(3)-RowLabelW-LMarginW-RMarginW-nCols*ColPadW)/nCols;
   
   TopMarginH = 20/fy;
   BotMarginH = 20/fy;
   TitleH = 25/fy;
   HeaderH = 30/fy;
   RowH = 30/fy;
   
   buttonW = 72/fx;
   buttonH = RowH-RowPadH;
   buttonPad = 7/fx;
   
   XCol(1) = LMarginW;
   XCol(2) = XCol(1) + RowLabelW + ColPadW;
   XCol(3) = XCol(2) + ColW + ColPadW;
   XCol(4) = XCol(3) + ColW + ColPadW;
   
   
   % defaults for each style
   editProps = struct(...
      'Parent', f,...
      'Style', 'edit',...
      'Units', 'character',...
      'BackgroundColor', White,...
      'ForegroundColor', Black,...
      'HorizontalAlignment', 'left',...
      'Callback', 'scribeaxesdlg verifynumber me');
   
   checkProps = struct(...
      'Parent', f,...
      'Style', 'checkbox',...
      'Units', 'character',...      
      'HorizontalAlignment', 'left',...
      'BackgroundColor', bgcolor,...
      'ForegroundColor', fgcolor,...
      'Callback', 'scribeaxesdlg toggle me');
   
   radioProps = struct(...
      'Parent', f,...
      'Style', 'radio',...
      'Units', 'character',...      
      'HorizontalAlignment', 'left',...
      'BackgroundColor', bgcolor,...
      'ForegroundColor', fgcolor,...      
      'Callback', 'scribeaxesdlg radio me');
   
   tProps = struct(...
      'Parent', f,...
      'Style', 'text',...
      'Units', 'character',...       
      'HorizontalAlignment', 'right',...
      'BackgroundColor', bgcolor,...
      'ForegroundColor', fgcolor);
   
   % get text size
   ut = uicontrol(tProps,...
      'Visible','off',...
      'String','Title');
   charSize = get(ut,'Extent');
   charH = charSize(4);
   delete(ut);
   
   % charOffset = (RowH-charH)/2;
   editH = charH + 4/fy;
   uiH = RowH-RowPadH;
   
   YTitleRow = figPos(4)-TitleH-TopMarginH-uiH;
   
   % Title row
   charOffset = uiH-charH;
   uicontrol(tProps,...
      'FontWeight','bold',...
      'String', 'Title:',...
      'Position', ...
      [ LMarginW  YTitleRow + uiH + uiH - charH ...
         RowLabelW charH]);
      
   % Check for similar titles
   titleHandle = get(ax,{'Title'});
   titleString = get([titleHandle{:}],{'String'});
   if isempty(titleString{1}) | ...
         (length(titleString) > 1 & ~isequal(titleString{:})),
      % use a cell array, so spaces aren't padded out.
      CommonFlag = 0;
      titleString = {};
   else
      CommonFlag  = 1;
      titleString=titleString{1};
   end
   titleU = uicontrol(editProps,...
      'Tag', 'Title',...
      'UserData',CommonFlag, ...
      'Callback', '',...
      'HorizontalAlignment','center',...
      'Max', 2, ... % allow multi line titles
      'String', titleString,...
      'Position', ...
      [ XCol(2)           YTitleRow ...
         nCols*ColW+(nCols-1)*ColPadW  uiH + uiH]);
   
   iGroup=1;
   localData.LimCheck(iGroup)=titleU;
   localData.Prop{iGroup} = 'Title';
   
   % put down the row headings
   
   rowLabelStrings = {...
         '','left',
      'Label:','right',
      'Limits:','right',
      'Tick Step:','right',
      'Scale:','right',
      '','right',
      'Grid:','right',
      '','right',
   };
   nRows = size(rowLabelStrings,1);
   Y = YTitleRow - HeaderH + RowPadH;
   headingPosition = [LMarginW Y RowLabelW charH];
   
   for iRow = 1:nRows,
      if ~isempty(rowLabelStrings{iRow,1})
         headingPosition(2) = Y;
         uicontrol(tProps,...
            'FontWeight', 'bold',...
            'String', rowLabelStrings{iRow,1},...
            'HorizontalAlignment', rowLabelStrings{iRow,2},...
            'Position', headingPosition);
      end 
      Y = Y-RowH;
   end
   
   % fill each column
   
   cCol = ' XYZ';
   for iCol = 2:nCols+1,
      
      X = XCol(iCol);
      col = cCol(iCol);
      
      % heading
      Y = YTitleRow - HeaderH + RowPadH;
      uicontrol(tProps,...
         'Style', 'text',...
         'FontWeight', 'bold',...
         'HorizontalAlignment', 'center',...
         'Position', [X Y-charOffset ColW charH],...
         'String', col);
      
      % label
      Y = Y-RowH;
      
      % Check for similar labels
      labelHandle = get(ax,{[col 'Label']});
      labelString = get([labelHandle{:}],{'String'});
      if isempty(labelString{1}) | ...
            (length(labelString)>1 & ~isequal(labelString{:})),
         % use a cell array, so spaces aren't padded out.
         CommonFlag = 0;
         labelString = {};
      else 
         labelString=labelString{1};
         CommonFlag = 1;
      end
      if size(labelString,1)>1  % multiline label
         multiline = 2;
      else
         multiline = 1;
      end
      labelU = uicontrol(editProps,...
         'Enable', 'on',...
         'Tag', [col 'Label'],...
         'ToolTip', [col 'Label'],...
         'UserData',CommonFlag, ...
         'Position', [X Y ColW uiH ],...
         'String', labelString,...
         'Max', multiline,...
         'Callback', '');
      
      iGroup = iGroup+1;
      localData.LimCheck(iGroup) = labelU;
      localData.Prop{iGroup} = 'Title';
      
      % range
      Y = Y-RowH;
      
      % Check if all axes are manual or auto
      AllMods = strcmp(get(ax, [col 'LimMode']),'manual');
      MultMods = 0;
      if all(~AllMods)
         checkProps.Value = 0;
      elseif all(AllMods)
         checkProps.Value = 1;
      else
         MultMods = 1;
         checkProps.Value = length(find(AllMods))>=length(find(~AllMods));
      end
      
      CheckVal = checkProps.Value;
      clim = uicontrol(checkProps,...
         'String', 'Manual',...
         'Tag', [col 'LimMode'],...
         'ToolTip', [col 'LimMode'],...
         'Position', [X Y ColW/2 uiH]);
      
      % Add a second checkbox when editing multiple axes
      if MultMods,
         % Overwrite the other checkbox, since it's callback will never
         % be invoked
         clim2 = uicontrol(checkProps,...
            'ButtonDownFcn','scribeaxesdlg toggle me', ...
            'Enable','off', ...
            'Tag', [col 'LimMode'],...
            'ToolTip', [col 'LimMode'],...
            'UserData',struct('Value',checkProps.Value,'Sibling',clim), ...
            'Position', [X Y 3 uiH]);
         checkProps.Value = 0;
         set(clim,'UserData',clim2,'Tag','')
      end
      
      % Check for common limits
      lim = get(ax,{[col 'Lim']});
      lim = cat(1,lim{:});
      Umin = unique(lim(:,1));
      Umax = unique(lim(:,2));
      if length(Umin)>1, uminStr = '';
      else, uminStr = num2str(Umin);
      end
      if length(Umax)>1, umaxStr = '';
      else, umaxStr = num2str(Umax);
      end
      
      umin = uicontrol(editProps,...
         'Tag', [col 'LimMin'],...
         'ToolTip', [col ' Min'],...
         'Enable', enable{checkProps.Value+1},...
         'String', uminStr,...
         'Position', [X+ColW/2 Y ColW/4 uiH]);
      
      iGroup=iGroup+1;
      localData.LimCheck(iGroup) = umin;
      localData.OldVal{iGroup} = min(lim);
      
      umax = uicontrol(editProps,...
         'Tag', [col 'LimMax'],...
         'Enable', enable{checkProps.Value+1},...           
         'String', umaxStr,...
         'Position', [X+ColW*3/4 Y ColW/4 uiH],...
         'ToolTip', [col ' Max']);
      iGroup = iGroup+1;
      localData.LimCheck(iGroup) = umax;
      localData.OldVal{iGroup} = max(lim);
      
      iGroup = iGroup+1;
      localData.LimGroup{iGroup} = [umin umax];
      localData.LimCheck(iGroup) = clim;
      localData.Prop{iGroup} = [col 'LimMode'];
      
      if MultMods
         iGroup = iGroup+1;
         localData.LimGroup{iGroup} = [umin umax];
         localData.LimCheck(iGroup) = clim2;
         localData.Prop{iGroup} = [col 'LimMode'];           
      end
      
      % Check if all axes use a linear scale
      AllScales = strcmp(get(ax,[col 'Scale']),'linear');
      MultScales = 0;
      if all(~AllScales)
         linearScale = 0;
      elseif all(AllScales)
         linearScale = 1;
      else
         MultScales = 1;
         linearScale=0;
      end
      
      % tickstep
      Y = Y-RowH;
      
      % Check if all TickModes are manual or auto
      AllMods = strcmp(get(ax, [col 'TickMode']),'manual');
      MultMods = 0;
      if all(~AllMods)
         checkProps.Value = 0;
      elseif all(AllMods)
         checkProps.Value = 1;
      else
         MultMods = 1;
         checkProps.Value = length(find(AllMods))>=length(find(~AllMods));
      end
      
      CheckVal = checkProps.Value;
      clim = uicontrol(checkProps,...
         'String', 'Manual',... 
         'Tag', [col 'TickMode'],...
         'Enable', enable{linearScale+1},...
         'ToolTip', [col 'TickMode'],...
         'Position', [X Y ColW/2 uiH]);
      
      % Add a second checkbox when editing multiple axes
      if MultMods,
         % Overwrite the other checkbox, since it's callback will never
         % be invoked
         clim2 = uicontrol(checkProps,...
            'ButtonDownFcn','scribeaxesdlg toggle me', ...
            'Enable','off', ...
            'Tag', [col 'TickMode'],...
            'ToolTip', [col 'TickMode'],...
            'UserData',struct('Value',checkProps.Value,'Sibling',clim), ...
            'Position', [X Y 3 uiH]);
         checkProps.Value = 0;
         set(clim,'UserData',clim2,'Tag','')
      end
      
      if linearScale
         editProps.Enable = enable{checkProps.Value+1};
         % Check for common tick marks
         tick = get(ax,{[col 'Tick']});
         if (length(tick)>1 & ~isequal(tick{:})) | isempty(tick{1}) | length(tick{1})<2
            tickstep = [];
         else
            tickstep = tick{1}(2)-tick{1}(1);
         end
      else
         editProps.Enable = enable{0+1};
         tickstep = [];
      end
      utick = uicontrol(editProps,...
         'Tag', [col 'TickStep'],...
         'ToolTip', [col ' Tick step size'],...
         'HorizontalAlignment','center',...
         'String', num2str(min(tickstep)),...
         'Position', [X+ColW/2 Y ColW/2 uiH]);
      iGroup = iGroup+1;
      localData.LimCheck(iGroup) = utick;
      localData.OldVal{iGroup} = tickstep;
      
      iGroup = iGroup+1;
      localData.LimGroup{iGroup} = utick;
      localData.LimCheck(iGroup) = clim;
      
      if MultMods,
         iGroup = iGroup+1;
         localData.LimGroup{iGroup} = utick;
         localData.LimCheck(iGroup) = clim2;
      end
      
      % Scale
      Y = Y-RowH;
      radioProps.Value = linearScale;
      rlin = uicontrol(radioProps,...
         'Position', [X Y ColW/2 uiH],...
         'String', 'Linear',...
         'Tag', [col 'ScaleLinear'],...
         'ToolTip',[col 'Scale=''linear''']);
      
      % Add a second set of radio buttons when editing multiple axes
      if MultScales,
         rlin2 = uicontrol(radioProps,...
            'ButtonDownFcn','scribeaxesdlg radio me', ...
            'Enable','off', ...
            'Position', [X Y 3 uiH],...
            'String', '',...
            'Tag', [col 'ScaleLinear'],...
            'ToolTip',[col 'Scale=''linear'''], ...
            'Value',0);
         set(rlin,'UserData',rlin2,'Tag','');
      end
      
      Y = Y-RowH*2/3;
      rlog = uicontrol(radioProps,...
         'Position', [X Y ColW/2 uiH],...
         'String', 'Log',...
         'Value', ~radioProps.Value,...
         'Tag', [col 'ScaleLog'],...
         'ToolTip',[col 'Scale=''log''']);
      
      % Add a second set of radio buttons when editing multiple axes
      if MultScales,
         rlog2 = uicontrol(radioProps,...
            'Enable','off', ...
            'Position', [X Y 3 uiH],...
            'String', '',...
            'Value', ~radioProps.Value,...
            'Tag', [col 'ScaleLog'],...
            'ToolTip',[col 'Scale=''log'''], ...
            'Value',0);
         set(rlog,'UserData',rlog2,'Tag','');
         set(rlin2,'UserData',...
            struct('Value',0,'Sibling',rlin,'OtherRadio',rlog2));
         set(rlog2,'UserData',...
            struct('Value',0,'Sibling',rlog,'OtherRadio',rlin2));
      end
      Y = Y-RowH*1/3;
               
      iGroup = iGroup+1;
      localData.LimGroup{iGroup} = [rlin];
      localData.LimCheck(iGroup) = rlog;
      localData.Enable{iGroup} = [];
      localData.Disable{iGroup} = struct('Controls',[clim utick], ...
         'CheckValue',CheckVal);
      
      iGroup = iGroup+1;
      localData.LimGroup{iGroup} = [rlog];
      localData.LimCheck(iGroup) = rlin;
      localData.Enable{iGroup} = [clim utick];  % checkbox then
      % other control
      localData.Disable{iGroup} = [];
      
      if MultScales
         iGroup = iGroup+1;
         localData.LimGroup{iGroup} = [rlin2];
         localData.LimCheck(iGroup) = rlog2;
         localData.Enable{iGroup} = [];
         localData.Disable{iGroup} = struct('Controls',[clim utick], ...
         'CheckValue',CheckVal);
         
         iGroup = iGroup+1;
         localData.LimGroup{iGroup} = [rlog2];
         localData.LimCheck(iGroup) = rlin2;
         localData.Enable{iGroup} = [clim utick];  % checkbox then 
         % other control
         localData.Disable{iGroup} = [];
      end
      
      % Direction
      Y = Y+RowH;
      
      % Check if all axes use a normal dirction
      AllDirs = strcmp(get(ax, [col 'Dir']),'normal');
      MultDirs = 0;
      if all(~AllDirs)
         radioProps.Value = 0;
      elseif all(AllDirs)
         radioProps.Value = 1;
      else
         MultDirs= 1;
         radioProps.Value = 0;
      end
      
      rnormal = uicontrol(radioProps,...
         'Position', [X+ColW/2 Y ColW/2 uiH],...
         'String', 'Normal',...
         'Tag', [col 'DirNormal'],...
         'ToolTip',[col 'Dir=''normal''']);
      
      if MultDirs
         rnormal2 = uicontrol(radioProps,...
            'ButtonDownFcn','scribeaxesdlg radio me', ...
            'Enable','off', ...
            'Position', [X+ColW/2 Y 3 uiH],...
            'String', '',...
            'Tag', [col 'DirNormal'],...
            'ToolTip',[col 'Dir=''normal''']);
         set(rnormal,'UserData',rnormal2,'Tag','');
      end            
      
      Y = Y-RowH*2/3;
      rreverse = uicontrol(radioProps,...
         'Position', [X+ColW/2 Y ColW/2 uiH],...
         'String', 'Reverse',...
         'Value', ~radioProps.Value,...
         'Tag', [col 'DirReverse'],...
         'ToolTip',[col 'Dir=''reverse''']);
      
      if MultDirs
         rreverse2 = uicontrol(radioProps,...
            'ButtonDownFcn','scribeaxesdlg radio me', ...
            'Enable','off', ...
            'Position', [X+ColW/2 Y 3 uiH],...
            'String', '',...
            'Tag', [col 'DirReverse'],...
            'ToolTip',[col 'Dir=''reverse''']);
         set(rreverse,'UserData',rreverse2,'Tag','');
         set(rreverse2,'UserData',...
            struct('Value',0,'Sibling',rreverse,'OtherRadio',rnormal2));
         set(rnormal2,'UserData',...
            struct('Value',0,'Sibling',rnormal,'OtherRadio',rreverse2));
      end         
      
      
      Y = Y-RowH*1/3;
      
      iGroup = iGroup+1;
      localData.LimGroup{iGroup} = [rnormal];
      localData.LimCheck(iGroup) = rreverse;
      localData.Enable{iGroup} = [];
      localData.Disable{iGroup} = [];
      
      iGroup = iGroup+1;
      localData.LimGroup{iGroup} = [rreverse];
      localData.LimCheck(iGroup) = rnormal;
      localData.Enable{iGroup} = [];
      localData.Disable{iGroup} = [];
      
      if MultDirs
         iGroup = iGroup+1;
         localData.LimGroup{iGroup} = [rnormal2];
         localData.LimCheck(iGroup) = rreverse2;
         localData.Enable{iGroup} = [];
         localData.Disable{iGroup} = [];
         
         iGroup = iGroup+1;
         localData.LimGroup{iGroup} = [rreverse2];
         localData.LimCheck(iGroup) = rnormal2;
         localData.Enable{iGroup} = [];
         localData.Disable{iGroup} = [];
      end
      
      % grid
      
      % Check if all axes grids are on
      AllGrids = strcmpi(get(ax,[col 'Grid']),'on');
      MultGrids = 0;
      if all(~AllGrids)
         checkProps.Value = 0;
      elseif all(AllGrids)
         checkProps.Value = 1;
      else
         MultGrids = 1;
         checkProps.Value = length(find(AllGrids))>=length(find(~AllGrids));
      end
      
      Y = Y-RowH;
      g = uicontrol(checkProps,...
         'String', 'On',... 
         'Tag', [col 'Grid'],...
         'ToolTip', [col 'Grid'],...
         'Position', [X Y ColW/3 uiH],...
         'Callback', 'scribeaxesdlg toggle me');
      
      iGroup = iGroup+1;
      localData.LimGroup{iGroup} = [];
      localData.LimCheck(iGroup) = g;
      localData.Enable{iGroup} = [];
      localData.Disable{iGroup} = [];
      
      if MultGrids
         g2 = uicontrol(checkProps,...
            'ButtonDownFcn','scribeaxesdlg toggle me', ...
            'Enable','off', ...
            'String', '',... 
            'Tag', [col 'Grid'],...
            'ToolTip', [col 'Grid'],...
            'UserData',struct('Value',checkProps.Value,'Sibling',g), ...
            'Position', [X Y 3 uiH],...
            'Callback', 'scribeaxesdlg toggle me');
         set(g,'UserData',g2,'Tag','');
         iGroup = iGroup+1;
         localData.LimGroup{iGroup} = [];
         localData.LimCheck(iGroup) = g2;
         localData.Enable{iGroup} = [];
         localData.Disable{iGroup} = [];
      end
      
      iGroup = iGroup+1;
      
   end   
   
   
   buttonX(1) = (figPos(3)-4*buttonW-3*buttonPad)/2;
   for ib = 2:4
      buttonX(ib) = buttonX(ib-1) + buttonW + buttonPad;
   end
   
   buttonProps = struct(...
      'Parent',f,...
      'Units','character',...
      'BackgroundColor', bgcolor,...
      'ForegroundColor', fgcolor,...
      'Position', [0 BotMarginH buttonW buttonH],...
      'Style', 'pushbutton');
   
   buttonProps.Position(1) = buttonX(1);
   u = uicontrol(buttonProps,...
      'Interruptible', 'off',...
      'String', 'OK',...
      'Callback', 'scribeaxesdlg button ok');
   makedefaultbutton(u);
   
   buttonProps.Position(1) = buttonX(2);
   uicontrol(buttonProps,...
      'Interruptible', 'off',...
      'String', 'Cancel',...
      'Callback', 'scribeaxesdlg button cancel');
   
   buttonProps.Position(1) = buttonX(3);
   uicontrol(buttonProps,...
      'Interruptible', 'off',...
      'String', 'Help',...
      'Callback', 'scribeaxesdlg showhelp me');
   
   buttonProps.Position(1) = buttonX(4);
   uicontrol(buttonProps,...
      'Interruptible', 'on',...
      'String', 'Apply',...
      'Callback', 'scribeaxesdlg button apply');
   
   
   
   % finish opening axes dialog box
   set(fig,'Pointer',oldPointer);
   set(f,'Visible','on','Pointer','arrow');
   localData.axes = ax;
      
      
catch
   set(fig,'Pointer',oldPointer);
   if exist('f')
      delete(f);
   end
   errordlg({'Couldn''t open axes properties dialog:' ...
              lasterr},...
           'Error',...
           'modal');
end

   
function [val,setflag] = getval(f,tag)
uic = findobj(f,'Tag',tag);
setflag = 1; % Flag for setting properties on multiple axes
switch get(uic,'Style')
case 'edit'
   val = get(uic, 'String'); 
   if isempty(val)
      setflag = 0;
   end
case {'checkbox' 'radiobutton'}
   val = get(uic, 'Value');
   setflag = ~strcmp(get(uic,'Enable'),'off');
   if setflag & isstruct(get(uic,'UserData'));
      %---Making a previously non-common property, common
      LdeleteControl(uic)
   end
end   

function val = setval(f,tag,val)
uic = findobj(f,'Tag',tag);
switch get(uic,'Style')
case 'edit'
   set(uic, 'String',val); 
case {'checkbox' 'radiobutton'}
   set(uic, 'Value',val);
end

function localData = LApplySettings(f, localData)
% get the values and set props:

ax = localData.axes;
   
iProp = 0;
try
   % title
   val = getval(f,'Title');
   
   switch class(val)
   case 'char'
      if ~isempty(val) & size(val,1)>1
         % title returns as a string matrix
         % check for blank line at end of multiline title
         nTitleLines = size(val,1);
         if val(nTitleLines,:)==32  % true if all spaces
            val(nTitleLines,:) = [];
            setval(f,'Title',val);
         end
      end
   case 'cell'
      if length(val)>1
         nTitleLines = length(val);
         if isempty(val{nTitleLines}) | val{nTitleLines}==32
            val(nTitleLines) = [];
         end
      end
   end
   
   CommonTitle = get(findobj(f,'Tag','Title'),'UserData');
   if ~(isempty(val) & length(ax)>1) | CommonTitle | length(ax)==1,
      t = get(ax,{'Title'});
      set([t{:}],'String',val);
      if ~CommonTitle, % They are common, now
         set(findobj(f,'Tag','Title'),'UserData',1)
      end
   end
   
   data = getappdata(f,'ScribeAxesDialogData');
   cols = 'XYZ';
   for col = cols(1:data.nCols)
      %label
      CommonLabel = get(findobj(f,'Tag',[col 'Label']),'UserData');
      val = getval(f,[col 'Label']);
      if ~(isempty(val) & length(ax)>1) | CommonLabel | length(ax)==1,
         t = get(ax,{[col 'Label']});
         set([t{:}],'String',val)
         if ~CommonLabel, % They are common, now
            set(findobj(f,'Tag',[col 'Label']),'UserData',1)
         end
      end
      
      % scale
      [mode,setflag] = getval(f,[col 'ScaleLinear']);
      if setflag,
         iProp = iProp+1;
         axProps{iProp} = [col 'Scale'];
         modeswitch = {'log' 'linear'};
         axVals{iProp} = modeswitch{mode+1};
         % update immediately so that we get updated limits and ticks
         set(ax,axProps(iProp),axVals(iProp));
      end % if setflag
      
      linearScale = mode;
      
      %limitmode
      [manual,setflag] = getval(f,[col 'LimMode']);
      valMax=[]; valMin=[];
      limits=[];
      if setflag
         iProp = iProp+1;
         axProps{iProp} = [col 'LimMode'];
         modeswitch = {'auto' 'manual'};
         axVals{iProp} = modeswitch{manual+1};
         if manual
            %limits   
            valMin = str2double(getval(f,[col 'LimMin']));
            valMax = str2double(getval(f,[col 'LimMax']));
            % ranges checked on callbacks
            if ~(isnan(valMax) | isnan(valMin)),
               iProp = iProp+1;
               axProps{iProp} = [col 'Lim'];
               limits = [valMin valMax];
               axVals{iProp} = limits;
            end
         else % auto
            set(ax,[col 'LimMode'],'auto');
            % Check for common limits
            lim = get(ax,{[col 'Lim']});
            lim = cat(1,lim{:});
            Umin = unique(lim(:,1));
            Umax = unique(lim(:,2));
            if length(Umin)>1, uminStr = '';
            else, uminStr = num2str(Umin);
            end
            if length(Umax)>1, umaxStr = '';
            else, umaxStr = num2str(Umax);
            end
            setval(f, [col 'LimMin'], uminStr);
            setval(f, [col 'LimMax'], umaxStr);
         end % if manual
      end % if setflag
      
      %tickmode
      TickInd=[];
      [manual,setflag] = getval(f,[col 'TickMode']);
      if setflag,
         iProp = iProp+1;
         axProps{iProp} = [col 'TickMode'];
         modeswitch = {'auto' 'manual'};
         axVals{iProp} = modeswitch{manual+1};
         
         if linearScale
            if manual
               tickstep = str2double(getval(f,[col 'TickStep']));
               if ~isempty(tickstep), % Make sure something is there
                  if ~isempty(limits),
                     % Only preset ticks when everything is the same
                     iProp = iProp+1;
                     axProps{iProp} = [col 'Tick'];
                     ticks = limits(1):tickstep:limits(2);
                     % ranges checked on callbacks
                     axVals{iProp} = ticks;
                  else
                     TickInd = iProp;
                  end
               end
            else % auto
               set(ax,[col 'TickMode'],'auto');
               if length(ax)==1
                  ticks = get(ax,[col 'Tick']);
                  setval(f, [col 'TickStep'], ticks(2)-ticks(1));
               end
            end % if manual
         else % log scale
            % manual mode disabled for log scale
            set(ax,[col 'TickMode'],'auto');
            setval(f, [col 'TickStep'], '');         
         end
      end % if setflag
      
      % scale direction
      [mode,setflag] = getval(f,[col 'DirNormal']);
      if setflag,
         iProp = iProp+1;
         axProps{iProp} = [col 'Dir'];
         modeswitch = {'reverse' 'normal'};
         axVals{iProp} = modeswitch{mode+1};
      end
      
      % grid
      [mode,setflag] = getval(f,[col 'Grid']);
      if setflag,
         iProp = iProp+1;
         axProps{iProp} = [col 'Grid'];
         modeswitch = {'off' 'on'};
         axVals{iProp} = modeswitch{mode+1};  
      end % if setflag
      
      if ~isempty(TickInd) | isnan(valMax) | isnan(valMin)
         % Going to have to loop thru to set limits/ticks individually
         for ct = 1:length(ax)
            limits = get(ax(ct),[col 'Lim']);
            axPropsCustom{1} = [col 'Lim'];
            if ~isnan(valMax), limits(2) = valMax; end
            if ~isnan(valMin), limits(1) = valMin; end
            axValsCustom{1} = limits;
            
            if ~isempty(TickInd);
               axPropsCustom{2} = [col 'Tick'];
               ticks = limits(1):tickstep:limits(2);
               % ranges checked on callbacks
               axValsCustom{2} = ticks;
            end % if ~isempty(TickInd)
            
            set(ax(ct),axPropsCustom,axValsCustom);
         end % for ct
      end
      
   end  % for col
   set(ax,axProps,axVals)  
catch
   % error somewhere in there...
end % try/catch


function LdeleteControl(OldControl)

ud = get(OldControl,'UserData');
set(ud.Sibling,'Value',get(OldControl,'Value'), ...
   'Tag',get(OldControl,'Tag'),'UserData',[])
if isfield(ud,'OtherRadio'),
   ud2 = get(ud.OtherRadio,'UserData');
   set(ud2.Sibling,'Value',get(ud.OtherRadio,'Value'), ...
      'Tag',get(ud.OtherRadio,'Tag'),'UserData',[])
   delete(ud.OtherRadio)
end
delete(OldControl)
   

function LNoAxesError
errordlg(['No axes are selected.  Click on an axis to select it.']);