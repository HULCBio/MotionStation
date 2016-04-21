function varargout = playshow(filename,layout)
% PLAYSHOW   Plays a slideshow-style demo.
%   PLAYSHOW FILENAME plays a slide show FILENAME. Slide shows can be created
%   using Codepad in the MATLAB Editor.
%
%   PLAYSHOW FILENAME AXES creates shows the text and graphics in the same window. 
%   PLAYSHOW FILENAME SMALLTEXT creates a small text-only window.
%   PLAYSHOW FILENAME LARGETEXT creats a large text-only window.
%   PLAYSHOW FILENAME ECHO shows the demo in the Command Window.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.35.4.3 $  $Date: 2004/04/10 23:25:04 $

% playshow('intro')
% playshow('intro','smalltext')
% playshow('#autoplay',fig);


if (nargin < 1)
   error('You need to specify the slide show to play, for example: playshow intro');
end

oldVisibility = '';
if strmatch('#',filename)
   % An action on an existing PLAYSHOW.
   action = filename(2:end);
   if (nargin < 2)
      % Coming from a callback.
      fig = gcbf;
   else
      % Being driven from the command line (probably by a test).
      fig = layout;
      oldVisibility = get(fig,'HandleVisibility');
      set(fig,'HandleVisibility','on');
   end
else
   % New PLAYSHOW.
   action = 'initialize';
   if (nargin < 2)
      layout = 'axes';
   end
end

switch action
case 'initialize'
   % Close any other slideshow players.
   openSlideshows = findall(0,'type','figure','Tag','Slideshow Player');
   for i = 1:length(openSlideshows)
      playshow('#close',openSlideshows(i))
   end
   % Check to be sure the layout choice exists.
   switch layout
      case {'axes','smalltext','largetext','echo'}
      otherwise
         error('MATLAB:playshow:unsupportedOption', ...
         'The second argument must be ''axes'',''smalltext'', ''largetext'', or ''echo''.');
   end
   % Punt to ECHODEMO if the layout is 'echo'.
   if isequal(layout,'echo')
      echodemo(filename)
      return
   end
   % Initialize the figure.
   fig = initializeFigure(filename,layout);
   if (nargout == 1)
      varargout{1} = fig;
   end
case 'next'
   doCommand(fig,1);
case 'back'   
   doCommand(fig,-1);
case 'reset'
   slideData = get(fig,'UserData');
   slideData.index = 1;
   set(fig, 'UserData', slideData);
   delete(findobj(fig,'Type','axes'));
   closeOurFigures(slideData);
   slideData.ourFigures = [];
   set(fig,'Colormap',get(0,'DefaultFigureColormap'));
   set(fig,'NextPlot','add'); % freqz in dfiltdemo mucks with this.
   doCommand(fig,0);
case 'close'
      closePlayshowFigure(fig)
      return
end

if ~isempty(oldVisibility)
   set(fig,'HandleVisibility',oldVisibility);
end

%===============================================================================
% initializeFigure

%===============================================================================
function fig = initializeFigure(filename,layout)

slideData = getSlides(filename);

fig=figure( ...
   'Name','Slideshow Player', ...
   'NumberTitle','off', ...
   'IntegerHandle','off', ...
   'Visible','off', ...
   'MenuBar','none', ...
   'Tag','Slideshow Player');

% Store the layout.
slideData.layout = layout;

% The text window
slideData.textHandle=uicontrol('Units','pixels', ...
   'Style','listbox','Max',2,'Min',0,'Value',[],'Enable','inactive', ...
   'BackgroundColor','white','ForegroundColor','black','FontName','fixedwidth');
% The button frame
slideData.frameHandle = uicontrol('Style','frame','Units','pixels', ...
   'BackgroundColor',[0.50 0.50 0.50], ...
   'ForegroundColor',[1 1 1]);
% The slide label
slideData.labelHandle = uicontrol('Style','text','Units','pixels', ...
   'HorizontalAlignment','center','Tag','slide');
if isequal(slideData.layout,'axes')
   set(slideData.labelHandle, ...
      'BackgroundColor',[0.50 0.50 0.50],'ForegroundColor',[1 1 1]);
end

% The Next button
slideData.nextHandle = buildButton('Start >>',[mfilename ' #next'],'next');
% The Reset button
slideData.resetHandle = buildButton('Reset',[mfilename ' #reset'],'reset');
% The View code button
if slideData.isSlideScript
   action = ['edit ' filename];
   slideData.viewHandle = buildButton('View code',action,'info');
else
   action = ['helpwin ' filename];
   slideData.viewHandle = buildButton('More info',action,'info');
end
if slideData.isBogus
   set(slideData.viewHandle,'Enable','off');
end
% The Close button   
slideData.closeHandle = buildButton('Close',@closePlayshowFigure,'close');
set(fig,'CloseRequestFcn',@closePlayshowFigure)

% Now initiate userdata
set(fig, 'UserData', slideData);

layoutFigure(fig,'initialize');
doCommand(fig,0);
set(fig,'ResizeFcn',@layoutFigure)
% % Make the space key move to the next slide.
% set(fig,'KeyPressFcn', ['if isequal(get(gcf,''CurrentCharacter''),'' ''), ' ...
%            mfilename ' #next, end']);

% last thing: turn it on
% we are calling slide show code above, so don't switch HandleVis until we have
% computed the first slide: in case the code calls gcf or some such thing, if
% the demo is invoked from the command line, the fig won't be visible if we set
% handlevis to callback before computing...
if isequal(slideData.layout,'axes')
   set(fig,'Visible','on','HandleVisibility','callback');
else
   set(fig,'Visible','on','HandleVisibility','off');
end

%===============================================================================
function buttonHandle = buildButton(labelStr, callbackStr, uiTag)
% build buttons and check boxes on the right panel
buttonHandle = uicontrol('Style','pushbutton','Units','pixels', ...
   'String',labelStr,'Callback',callbackStr,'Tag',uiTag, ...
   'HorizontalAlignment','center','Interruptible','off'); 

%===============================================================================
function slideData = getSlides(filename)
% GETSLIDES reads the content in from the file.

slideData.slide(1).code={''};
slideData.slide(1).text={''};

try
   % Slurp in the file.
   f = fopen(which(filename));
   err = sprintf('"%s" is not a valid PLAYSHOW file.',filename);
catch
   err = sprintf('"%s" is not on the path.',filename);
end

try
   F = fread(f);
   fclose(f);
   txt = char(F');
   % Based on the starting "%%", detect if it is old-style "structure" or
   % new-style "slidescript".
   if strmatch('%%',txt)
      slides = m2struct(txt);
      slideData.isSlideScript = true;
   else
      slides = feval(filename);
      slideData.isSlideScript = false;
   end
catch
   slides = [];
   slideData.isSlideScript = false;
end

% If there are no slides, create an error message.
if ~isstruct(slides) || ~isfield(slides,'code') || ~isfield(slides,'text')
   slides.code={'load logo'
      'surf(L,R), colormap(M)'
      'n = length(L(:,1));'
      'axis off, axis([1 n 1 n -.2 .8]), view(-37.5,30)'
      'title(''Invalid PLAYSHOW File Requested'');'};
   slides.text={err};
   slideData.isBogus = true;
else
   slideData.isBogus = false;
end

slideData.slide=slides;
slideData.index=1;
slideData.filename=filename;
slideData.ourFigures = [];

%===============================================================================
function layoutFigure(fig,input2)

slideData = get(fig,'UserData');

% Define spacings.
buttonWidth = 88;
buttonHeight = 25;
margin = 10;
frameWidth = 2*margin+buttonWidth;
screenSize = get(0,'ScreenSize');
if (screenSize(4) > 600)
    textHeight = 200;
else
    textHeight = 100;
end

if ~isempty(input2)
   % This is the initial layout.  Set the figure size and default axes position.
   ax = axes('Parent',fig);
   extraWidth = frameWidth+2*margin;
   extraHeight = textHeight+2*margin;
   set(ax,'Units','pixels');
   defaultPos = get(fig,'Position');
   if isequal(slideData.layout,'smalltext')
      newHeight = extraHeight+buttonHeight+2*margin;
      set(fig,'Position', ...
         defaultPos.*[1 1 1 0]+[0 -newHeight extraWidth newHeight])
   else
      set(fig,'Position',defaultPos+[0 -extraHeight extraWidth extraHeight])
   end
   if ~isequal(slideData.layout,'axes')
      set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'))
      set(fig,'MenuBar','none')
   end
   newPos = get(fig,'Position');

   % Center the figure on the screen.
   newPos(1) = round((screenSize(3)-newPos(3))/2);
   newPos(2) = round((screenSize(4)-newPos(4))/2);
   set(fig,'Position',newPos);

   % The actual growth of the figure, newPos(4)-defaultPos(4) won't be equal to
   % extraHeight when at low resolutions.
   set(ax,'Position',get(ax,'Position')+[0 newPos(4)-defaultPos(4) 0 0])
   set(ax,'Units','normalized');
   set(fig,'DefaultAxesPosition',get(ax,'Position'));
   delete(ax);
end

% Reposition all of the widgets based on the current figure size.
figPos = get(fig,'Position');
if isequal(slideData.layout,'axes')
   set(slideData.textHandle,'Position', ...
      [margin, ...
         margin, ...
         figPos(3)-2*margin, ...
         textHeight]);
   set(slideData.frameHandle,'Position', ...
      [max(figPos(3)-frameWidth-margin,0), ... 
         max(margin+textHeight+margin,0), ...
      frameWidth, ...
         max(figPos(4)-(margin+textHeight+margin+margin),1)]);
   set(slideData.labelHandle,'Position', ...
      [figPos(3)-buttonWidth-margin-margin, ...
         figPos(4)-1*(buttonHeight+margin)-margin, ...
         buttonWidth, ...
         buttonHeight]);
   set(slideData.nextHandle,'Position', ...
      [figPos(3)-buttonWidth-margin-margin, ...
         figPos(4)-2*(buttonHeight+margin)-margin, ...
         buttonWidth, ...
         buttonHeight]);
   set(slideData.resetHandle,'Position', ...
      [figPos(3)-buttonWidth-margin-margin, ...
         figPos(4)-3*(buttonHeight+margin)-margin, ...
         buttonWidth, ...
         buttonHeight]);
   set(slideData.closeHandle,'Position', ...
      [figPos(3)-buttonWidth-margin-margin, ...
         margin+textHeight+margin+margin, ...
         buttonWidth, ...
         buttonHeight]);
   set(slideData.viewHandle,'Position', ...
      [figPos(3)-buttonWidth-margin-margin, ...
         margin+textHeight+margin+margin+buttonHeight+margin, ...
         buttonWidth, ...
         buttonHeight,]);
else
   set(slideData.textHandle,'Position', ...
      [margin, ...
         margin+buttonHeight+margin, ...
         figPos(3)-2*margin, ...
         max(figPos(4)-(margin+buttonHeight+margin)-margin,1)]);
   set(slideData.frameHandle,'Position',[0 0 1 1]);
   set(slideData.labelHandle,'Position', ...
      [2*margin+buttonWidth+margin, ...
         margin, ...
         buttonWidth, ...
         buttonHeight]);
   set(slideData.nextHandle,'Position', ...
      [figPos(3)-2*margin-2*buttonWidth, ...
         margin, ...
         buttonWidth, ...
         buttonHeight]);
   set(slideData.resetHandle,'Position', ...
      [figPos(3)-2*margin-3*buttonWidth, ...
         margin, ...
         buttonWidth, ...
         buttonHeight]);
   set(slideData.closeHandle,'Position', ...
      [figPos(3)-margin-buttonWidth, ...
         margin, ...
         buttonWidth, ...
         buttonHeight]);
   set(slideData.viewHandle,'Position', ...
      [margin, ...
         margin, ...
         buttonWidth, ...
         buttonHeight]);
end  
  
%===============================================================================
function closeOurFigures(slideData)
delete(slideData.ourFigures(ishandle(slideData.ourFigures)));

%===============================================================================
function closePlayshowFigure(fig,null)
if ~isequal(get(fig,'type'),'figure')
    % This close is coming from a button press.
    fig = get(fig,'Parent');
end
if isempty(getappdata(fig,'ISBUSYEVALING'))
    slideData = get(fig,'UserData');
    closeOurFigures(slideData);
    delete(fig)
end

%===============================================================================
% doCommand

%===============================================================================
function doCommand(fig,ichange)
% execute the command in the command window
% when ichange = 1, go to the next slide;
% when ichange = -1, go to the previous slide;
% when ichange = 0, stay with the current slide;

newLine = char(10);
set(fig,'Pointer','watch');

% Retrieve saved information from UserData.
slideData = get(fig,'UserData');
slideNumber = slideData.index+ichange;

buttonsToDisable = [ ...
   slideData.resetHandle, ...
   slideData.nextHandle, ...
   slideData.closeHandle, ...
   slideData.viewHandle];
set(buttonsToDisable,'Enable','off');

% Possibly add a title to the first frame.
if slideData.isSlideScript && isempty(slideData.slide(1).code) && ...
      ~isempty(slideData.slide(1).title) && isequal(slideData.layout,'axes')
   if (slideNumber == 1)
      % Since there is no code, show a title in the axes.
      titleString = slideData.slide(1).title;
      set(fig,'Name',titleString);
      H1 = text(.5,.5,titleString,'Tag','Slideshow Title Text', ...
         'FontSize',20,'HorizontalAlignment','center');
      axis off
      % Make sure the title fits on the axes.  If not, try to break it on
      % spaces until it fits or there are no more spaces.
      spaces = find(titleString==' ');
      numSpaces = length(spaces);      
      lineBreaks = 0;
      while ((get(H1,'extent')*[0;0;1;0]) > 1) && ...
            (lineBreaks <= numSpaces) && (numSpaces ~= 0)
         lineBreaks = lineBreaks + 1;
         spaceIndex = round(linspace(0,length(spaces)+1,2+lineBreaks));
         titleString(titleString == newLine) = ' ';
         titleString(spaces(spaceIndex(2:end-1))) = newLine;
         set(H1,'string',strread(titleString,'%s','delimiter',newLine));
      end
   elseif (slideNumber == 2)
      % Remove the title we created.
      delete(gca)
   end
end

slideshowLength = length(slideData.slide);
% Guarantee the index is always inside the boundary.
slideNumber = min(max(slideNumber,1),slideshowLength);

% Handles both initialization and reset.
if (slideNumber == 1)
   slideData.variables = {};
end

% Massage slide content.
slideText = slideData.slide(slideNumber).text;
slideCode = slideData.slide(slideNumber).code;
if slideData.isSlideScript
   % SLIDESCRIPT DEMOS
   % If this step has a title, add it to the text.
   if isempty(slideData.slide(slideNumber).title)
      newSlideText = {};
   else
      newSlideText = {upper(slideData.slide(slideNumber).title)};
   end
   % If this step has descriptive text, add it to the text.
   if ~isempty(slideText)
      if isempty(newSlideText)
         newSlideText = slideText;
      else
         newSlideText = [newSlideText {''} slideText];
      end
   end
   % Remove any excess newlines from around the code block.
   slideCode = removeExtraNewlines(slideCode);
   % If this step has code, add the code to the text.
   if ~isempty(slideCode)
      codeLines = splitLines(slideCode);
      for i = 1:length(codeLines)
         codeLines{i} = ['>> ' codeLines{i}];
      end
      if isempty(newSlideText)
         newSlideText = codeLines;
      else
         newSlideText = [newSlideText {''} codeLines];
      end
   end
   slideText = newSlideText;
else
   % STRUCTURE DEMOS
   % Wrap all lines to 80 columns.
   newSlideText = {};
   while ~isempty(slideText)
      line = slideText{1};
      if (length(line) <= 80)
         newSlideText{end+1} = line;
         slideText(1)=[];
      else
         spaces = find(line==' ');
         spaces = spaces(spaces <= 80);
         if isempty(spaces)
            newSlideText{end+1} = line;
            slideText(1) = [];
         else
            splitSpace = max(spaces);
            newSlideText{end+1} = line(1:splitSpace-1);
            slideText{1} = line(splitSpace+1:end);
         end
      end
   end
   slideText = newSlideText;
   % Convert cell array of code lines to newline separated string for easy
   % eval'ing.
   newLines = cell(size(slideCode,1),1);
   newLines(:) = {newLine};
   slideCode = [slideCode newLines]';
   % The CHAR ensures that there will be an empty char array, not an empty
   % double, when it comes time to eval it.
   slideCode = char([slideCode{:}]);
end

% Show the slide content in the browser.
set(slideData.textHandle,'String',slideText);
set(slideData.labelHandle, ...
   'String',sprintf('Slide %i of %i',slideNumber,slideshowLength))
drawnow;

% Evaluate the code.
setappdata(fig,'ISBUSYEVALING',true)
oldFigures = get(0,'Children');
[slideData,codeOutput] = evalCode(slideData,slideCode);
newFigures = setdiff(get(0,'Children'),oldFigures);
slideData.ourFigures = union(slideData.ourFigures,newFigures);
rmappdata(fig,'ISBUSYEVALING')

% If player was closed while the code was running, just bail.
if ~ishandle(fig)
    closeOurFigures(slideData);
    return
end

% Display any output the code produced.
if slideData.isSlideScript && ~isempty(codeOutput)
   codeOutput = removeExtraNewlines(codeOutput,'trailing');
   outputLines = splitLines(codeOutput);
   slideText = [slideText outputLines];
   set(slideData.textHandle, 'String', slideText);
end


slideData.index = slideNumber;
set(fig,'UserData',slideData);
set(fig,'Pointer','arrow');
enableButtons(slideNumber,slideData); 

%===============================================================================
function enableButtons(i,slideData)
% control the enable property for Next and Prev. buttons
if (i==1)
   nextString = 'Start >>';
   resetEnable = 'off';
else
   nextString = 'Next >>';
   resetEnable = 'on';
end
if (i==length(slideData.slide))
   nextEnable = 'off';
else
   nextEnable = 'on';
end
set(slideData.nextHandle,'Enable',nextEnable,'String',nextString);
set(slideData.resetHandle,'Enable',resetEnable);
set(slideData.closeHandle,'Enable','on');
set(slideData.viewHandle,'Enable','on');

%===============================================================================
function [slideData,codeOutput] = evalCode(slideData,codeToEval)
% evaluate the whole command window's code

% Load the variables from the last slide.
if ~isempty(slideData.variables)
   for slideShowVariableCount = 1:size(slideData.variables,1);
      eval([slideData.variables{slideShowVariableCount,1} ...
            '=slideData.variables{slideShowVariableCount,2};']);
   end
   clear slideShowVariableCount
end

% Evaluate the code.
slideData.warningState = warning;
warning off backtrace
setappdata(0,'SLIDESHOWDATA',slideData);
setappdata(0,'CODETOEVAL',codeToEval);
clear slideData codeToEval
try
   codeOutput = evalc(getappdata(0,'CODETOEVAL'));
catch
   % Don't throw a "real" error, since we're way down in the stack.  This also
   % allows for it (possibly) proceed to the next slide.
   beep;
   disp(sprintf('\nError in slideshow.\n%s\n',lasterr))
   codeOutput = lasterr;
end
variablesToSave = who;
variablesToSave(strmatch('codeOutput',variablesToSave,'exact')) = [];
slideData = getappdata(0,'SLIDESHOWDATA');
rmappdata(0,'SLIDESHOWDATA');
rmappdata(0,'CODETOEVAL');
warning(slideData.warningState);

% Save the variables for the next slide before this workspace goes away.
% Use an awkward name (variablesToSaveCount) so you don't overwrite any
% variables the code created.
for variablesToSaveCount = 1:length(variablesToSave)
   variablesToSave{variablesToSaveCount,2} = ...
      eval(variablesToSave{variablesToSaveCount});
end
slideData.variables = variablesToSave;


%===============================================================================
function echodemo(filename)
% ECHODEMO   Play a cell script as an echo-and-pause demo.
%   ECHODEMO FILENAME plays a cell script FILENAME.  Cell scripts can be created
%   using Codepad in the MATLAB Editor.
%    
%   See also PLAYSHOW.

% Ned Gulley, March 2001
% Matthew Simoneau, September 2002

% Copyright 1984-2002 The MathWorks, Inc.
% $Revision: 1.35.4.3 $  $Date: 2004/04/10 23:25:04 $

% Read in the file.
f = fopen(which(filename));
if (f == -1)
    error(['"' filename '" is not on the path.']);
end
F = fread(f);
fclose(f);
txt = char(F');

% Parse the char into a structure.
slides = m2struct(txt);

% Setup the demo.
home
clf reset;
uimenufcn(0,'WindowCommandWindow')

for slideNumber = 1:length(slides)
    slideText = slides(slideNumber).text;
    slideCode = slides(slideNumber).code;
    % If this step has a title, add it to the text.
    if isempty(slides(slideNumber).title)
        newSlideText = {};
    else
        newSlideText = {upper(slides(slideNumber).title)};
    end
    % If this step has descriptive text, add it to the text.
    if ~isempty(slideText)
        if isempty(newSlideText)
            newSlideText = slideText;
        else
            newSlideText = [newSlideText {''} slideText];
        end
    end
    % Remove any excess newlines from around the code block.
    slideCode = removeExtraNewlines(slideCode);
    % If this step has code, add the code to the text.
    if ~isempty(slideCode)
        codeLines = splitLines(slideCode);
        for i = 1:length(codeLines)
            codeLines{i} = ['>> ' codeLines{i}];
        end
        if isempty(newSlideText)
            newSlideText = codeLines;
        else
            newSlideText = [newSlideText {''} codeLines];
        end
    end
    slideText = newSlideText;
   
    disp(char(slideText))

    mcodeoutput = evalc('evalin(''base'',slideCode)');
    disp(mcodeoutput)
    
    % Pause between cells
    if (slideNumber < length(slides))
        disp(' ')
        disp('Press any key to continue.')
        disp(' ')
        drawnow
        uimenufcn(0,'WindowCommandWindow')
        pause
        home
    end
end	

disp(' ');
disp('End of demo')
disp(' ');
