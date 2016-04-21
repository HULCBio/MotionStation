function Out = axlimdlg(message,OptionFlags,PromptString,AxesHandles,XYZstring,DefLim,ApplyFcn)
%AXLIMDLG Axes limits dialog box.
%   FIG = AXLIMDLG(DlgName,OptionFlags,PromptString, ...
%                  AxesHandles,XYZstring,DefLim,ApplyFcn)
%   creates an axes limit dialog box with name DlgName and with prompts 
%   given by the rows of PromptString.
%   OptionFlags  - row vector of flags
%                  1st column: Auto limits checkbox (1=yes, 0=no)
%                  2nd column: Log scaling checkbox (1=yes, 0=no)
%                  Default is both off.
%   PromptString - string matrix containing prompt text in each row
%   AxesHandles  - a vector of the axes: NaN's separate sets of axes 
%                  according to PromptString.
%   XYZstring    - string matrix with as many rows as PromptString
%   DefLim       - string matrix with as many rows as PromptString
%   ApplyFcn     - single row string prepended to Apply button callback
%                  Useful for extracting strings or limits from the dialog 
%                  before it is destroyed.
%
%   Example 1
%   axlimdlg
%   Produces standard axes limit dialog operating on gca.
%    
%   Example 2
%   axlimdlg('MyName')
%   Produces standard axes limit dialog with Name MyName operating on gca.
%        
%   Example 3
%   axlimdlg('MyName',[1 1])
%   Produces axes limit dialog with Name MyName operating on gca, and
%   included checkboxes to allow auto range limits and log/linear scaling.
%        
%   Example 4
%   Assume GainAx and PhaseAx are axes handles of a Bode plot
%   DlgName = 'Bode axes limit dialog';
%   OptionFlags = [0 0];
%   PromptString = str2mat('Frequency range:','Gain Range:','Phase range:');
%   AxesHandles = [GainAx PhaseAx NaN GainAx NaN PhaseAx];
%   XYZstring = ['x'; 'y'; 'y'];
%   DefLim = [get(GainAx,'XLim'); get(GainAx,'YLim'); get(PhaseAx,'YLim')];
%   axlimdlg(DlgName,OptionFlags,PromptString,AxesHandles,XYZstring,DefLim)
%
%   Notes:
%   1) Do not name the dialog EditCallback or ApplyCallback
%   2) Does create error dialog when trying to set empty or invalid axes
%      handles.  A good applications programmer might prefer to update the
%      axes handles in the dialog or destroy the dialog if appropriate.
%   3) Figure UserData contains handles, one row for each PromptString row 
%      [PromptText EditField AutoCheckbox LogCheckbox]
%   4) PromptText UserData contains axes handles
%   5) EditField UserData contains valid axes limits
%   6) Top frame uicontrol UserData contains XYZstring

%   Author(s): A. Potvin, 10-25-94, 1-1-95
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.19 $  $Date: 2002/04/15 03:26:03 $

ni = nargin;
if ni==0,
   message = 'Axes Limits';
end

% Check if figure is already on screen
if  figflag(message),
   % No need to create new dialog
   return

elseif strcmp(message,'EditCallback'),
   % Check to make sure limits are admissible
   fig = get(0,'CurrentFigure');
   Edit = get(fig,'CurrentObject');

   % Add brackets so that user does not have to.  Should work either way now.
   EditStr = ['[' get(Edit,'String') ']'];
   lim = eval(EditStr,'''foobar''');

   error_str = '';
   if isstr(lim),
      error_str = 'Cannot evaluate edit field input.';
   elseif any(size(lim)~=[1 2]),
      error_str = 'Axis limits must be a 1x2 vector.';
   elseif lim(2)<=lim(1),
      error_str = 'In the 1x2 input, [Lmin Lmax], Lmin must be less than Lmax.';
   end
   if isempty(error_str),
      set(Edit,'UserData',lim)
      % Also uncheck the associated Auto Checkbox (if it exists) 
      ud = get(fig,'UserData');
      ind = find(ud(:,2)==Edit);
      if ud(ind,3)~=0,
         set(ud(ind,3),'Value',0)
      end
   else
      errordlg(error_str);
      set(Edit,'String',mat2str(get(Edit,'UserData')))
   end
   return

elseif strcmp(message,'ApplyCallback'),
   % Loop and set axes limits
   fig = get(0,'CurrentFigure');
   ud = get(fig,'UserData');
   XYZstring = get(findobj(fig,'Tag','XYZstring'),'UserData');
   for i=1:size(ud,1),
      ax = get(ud(i,1),'UserData');
      BooVec = ishandle(ax);
      if isempty(ax) | ~all(BooVec),
         error_str = str2mat('AXLIMDLG: Empty or invalid axes handles.', ...
          'Try closing and then re-opening the axes limit dialog.');
         errordlg(error_str);
         return
      end
      if ud(i,3)~=0,
         IsAutoChecked = get(ud(i,3),'Value');
      else
         IsAutoChecked = 0;
      end
      if IsAutoChecked,
         % AutoCheckbox is checked, so set appropriate axes LimMode(s) to auto
         if any(XYZstring(i,:)=='x'),
            set(ax,'XLimMode','auto')
            lim = get(ax(1),'XLim');
         end
         if any(XYZstring(i,:)=='y'),
            set(ax,'YLimMode','auto')
            lim = get(ax(1),'YLim');
         end
         if any(XYZstring(i,:)=='z'),
            set(ax,'ZLimMode','auto')
            lim = get(ax(1),'ZLim');
         end
         % Also set edit field to current limits
         set(ud(i,2),'String',mat2str(lim))
      else
         lim = get(ud(i,2),'UserData');
         % Set appropriate limits
         if any(XYZstring(i,:)=='x'),
            set(ax,'XLim',lim)
         end
         if any(XYZstring(i,:)=='y'),
            set(ax,'YLim',lim)
         end
         if any(XYZstring(i,:)=='z'),
            set(ax,'ZLim',lim)
         end
      end
      if ud(i,4)~=0,
         % There is a Log checkbox
         if get(ud(i,4),'Value'),
            Scale = 'log';
         else
            Scale = 'linear';
         end
         if any(XYZstring(i,:)=='x'),
            set(ax,'XScale',Scale)
         end
         if any(XYZstring(i,:)=='y'),
            set(ax,'YScale',Scale)
         end
         if any(XYZstring(i,:)=='z'),
            set(ax,'ZScale',Scale)
         end
      end
   end
   return

elseif strcmp(message,'CancelCallback'),
   % Just delete the dialog
   delete(get(0,'CurrentFigure'))
   return
end

%%%%%%%%%%  Rest of code only executes if Axes Limits dialog is NOT on Screen  %%%%%%%%%%

DlgName = message;
% Error checking
% axlimdlg(message,OptionFlags,PromptString,AxesHandles,XYZstring,DefLim,ApplyFcn)
if ni<2,
   OptionFlags = [0 0];
elseif size(OptionFlags,2)~=2,
   error('OptionFlags must have 2 columns.')
end
if ni<3,
   PromptString = str2mat('X-axis range:','Y-axis range:','Z-axis range:');
   View = get(gca,'View');
   if View(2)==90,
      PromptString(3,:) = [];
   end
elseif isempty(PromptString) | ~isstr(PromptString),
   error('PromptString must be a non-empty string matrix.')
end
TextSize = size(PromptString);
rows = TextSize(1);
if ni<4,
   ax = gca;
   NaNmat = NaN;
   len = 2*rows-1;
   AxesHandles = ax(1,ones(1,len));
   AxesHandles(2:2:len) = NaNmat(1,ones(1,rows-1));
elseif isempty(AxesHandles) | isstr(AxesHandles) | (size(AxesHandles,1)~=1),
   error('AxesHandles must be a non-empty row vector.')
elseif sum(isnan(AxesHandles))~=rows-1,
   error('AxesHandles must contain one less NaN than number of rows in PromptString.')
end
if ni<5,
   XYZstring = ['x'; 'y';'z'];
   XYZstring = XYZstring(rem((1:rows)-1,3)+1,:);
elseif any(size(XYZstring)~=[rows 1]),
   error('XYZstring must have one column and as many rows as PromptString.')
end
if ni<6,
   DefLim = [];
   ind = [1 find(isnan(AxesHandles))+1];
   for i=1:rows,
      DefLim = [DefLim; get(AxesHandles(ind(i)),[XYZstring(i,:) 'Lim'])];
   end
elseif any(size(DefLim)~=[rows 2]),
   error('DefLim must be 2 column matrix with as many rows as PromptString.')
end
if ni<7,
   ApplyFcn = '';
elseif (size(ApplyFcn,1)~=1) | ~isstr(ApplyFcn),
   error('ApplyFcn must be a single row string.')
end
OptionFlagsRows = size(OptionFlags,1);
if OptionFlagsRows==1,
   OptionFlags = OptionFlags(ones(1,rows),:);
elseif OptionFlagsRows~=rows,
   error('OptionFlags must have either one row or as many rows as PromptString.')
end

% Get layout parameters
layout
mLineHeight = mLineHeight+5;
BWH = [mStdButtonWidth mStdButtonHeight];

% Define default position
ScreenUnits = get(0,'Units');
set(0,'Unit','pixels');
ScreenPos = get(0,'ScreenSize');
set(0,'Unit',ScreenUnits);
mCharacterWidth = 7;
Voff = 5;
FigWH = fliplr(TextSize).*[mCharacterWidth 2*(BWH(2)+Voff)] ...
        +[2*(mEdgeToFrame+mFrameToText)+BWH(1)+mFrameToText mLineHeight+BWH(2)+2*Voff];
MinFigW = 2*(BWH(1) +mFrameToText + mEdgeToFrame);
FigWH(1) = max([FigWH(1) MinFigW]);
FigWH = min(FigWH,ScreenPos(3:4)-50);
Position = [(ScreenPos(3:4)-FigWH)/2 FigWH];

% Make the figure
DefUIBgColor = get(0,'DefaultUIControlBackgroundColor');
fig = figure('NumberTitle','off','Name',DlgName,'Units','pixels', ...
 'Position',Position,'MenuBar','none', ...
 'Color',DefUIBgColor,'Visible','off','HandleVisibility','callback');

% Make the 2 frame uicontrols
UIPos = mEdgeToFrame*[1 1 -2 -2] + [0 0 FigWH(1) BWH(2)+mLineHeight];
uicontrol(fig,'Style','frame','Position',UIPos);
UIPos = [UIPos(1:3)+[0 UIPos(4)+mEdgeToFrame 0] FigWH(2)-UIPos(4)-2*mEdgeToFrame];
xyzctl=uicontrol(fig,'Style','frame','Position',UIPos,'Tag','XYZstring','HandleVisibility','callback');

% Make the text, edit, and check uicontrol(s)
UIPos = [mEdgeToFrame+mFrameToText FigWH(2)-mEdgeToFrame-Voff ...
 FigWH(1)-2*mEdgeToFrame-2*mFrameToText mLineHeight];
ud = zeros(rows,4);
AxesHandles = [NaN; AxesHandles(:); NaN];
nans = find(isnan(AxesHandles));
for i=1:rows,
   AutoCheck = OptionFlags(i,1);
   LogCheck  = OptionFlags(i,2);
   UIPos = UIPos - [0 BWH(2) 0 0];
   ax = AxesHandles(nans(i)+1:nans(i+1)-1);
   ud(i,1) = uicontrol(fig,'Style','text','String',PromptString(i,:),'Position',UIPos, ...
    'HorizontalAlignment','left','UserData',ax,'HandleVisibility','callback');
   CheckX = FigWH(1)-BWH(1)-mEdgeToFrame-mFrameToText;
   if AutoCheck | LogCheck,
      if AutoCheck,
         String = 'Auto';
         ind = 3;
         Value = strcmp(get(ax(1),[XYZstring(i,1) 'LimMode']),'auto');
      else
         String = 'Log';
         ind = 4;
         Value = strcmp(get(ax(1),[XYZstring(i,1) 'Scale']),'log');
      end
      ud(i,ind) = uicontrol(fig,'Style','check','String',String, ...
       'Position',[CheckX UIPos(2) BWH],'HorizontalAlignment','left', ...
       'Value',Value,'HandleVisibility','callback');
   end

   UIPos = UIPos - [0 BWH(2)+Voff 0 0];
   EditStr = mat2str(DefLim(i,:));
   if LogCheck & AutoCheck,
      Value = strcmp(get(ax(1),[XYZstring(i,1) 'Scale']),'log');
      ud(i,4) = uicontrol(fig,'Style','check','String','Log', ...
       'Position',[CheckX UIPos(2) BWH],'HorizontalAlignment','left', ...
       'Value',Value,'HandleVisibility','callback');
      EditPos = UIPos -[0 0 BWH(1)+mFrameToText 0];
   else
      EditPos = UIPos;
   end
   ud(i,2) = uicontrol(fig,'Style','edit','String',EditStr,'BackgroundColor','white', ...
    'Position',EditPos,'HorizontalAlignment','left', ...
    'UserData',DefLim(i,:),'Callback','axlimdlg(''EditCallback'')','HandleVisibility','callback');
   UIPos = UIPos -[0 Voff 0 0];
end
set(xyzctl,'UserData',XYZstring)

% Make the pushbuttons
Hspace = (FigWH(1)-2*BWH(1))/3;
ApplyFcn = [ApplyFcn 'axlimdlg(''ApplyCallback'');'];
uicontrol(fig,'Style','push','String','Apply','Callback',ApplyFcn, ...
 'Position',[Hspace mLineHeight/2 BWH],'HandleVisibility','callback');
uicontrol(fig,'Style','push','String','Close','Callback','delete(gcf)', ...
 'Position',[2*Hspace+BWH(1) mLineHeight/2 BWH],'HandleVisibility','callback');

% Finally, make all the uicontrols normalized and the figure visible
set(get(fig,'Children'),'Unit','norm');
set(fig,'Visible','on','UserData',ud)

no = nargout;
if no,
   Out = fig;
end

% end axlimdlg
