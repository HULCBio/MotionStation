function y = slchangelog(varargin)
%SLCHANGELOG Manages Change Log gui
%   It prompts for change description performed in working session.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.7 $

if nargin == 0
   action = 'Create';
else
   action = varargin{1};
end

switch action
case 'Create'
   %
   % Create gui
   %
   LocalCreate
   
case 'Save'
   %
   % Callback for save button
   %
   LocalSave
   
otherwise
   %
   % action represents an invalid option. Error this out
   %
   error([action ' unknown option ']);
   
end

% ====================================================
function LocalCreate
% Creates the gui 

currentRoot = bdroot(gcs);
allData.currentRoot = currentRoot;

%
% get general dimensions
%
z = sluiutil('dimension');
buttonWidth   = z.buttonWidth;
buttonHeight  = z.buttonHeight;
textHeight    = z.textHeight;
leftAlignment = z.leftAlignment;
vertSpacer    = z.vertSpacer;
hScale        = z.hScale;
vScale        = z.vScale;

%
% Define the toplevel dimensions
%
oldUnits   = get(0, 'Units');
set(0, 'Units', 'Characters');
screenSize = get(0, 'ScreenSize');
set(0, 'Units', oldUnits);

toplevelWidth  = 450 * hScale;
toplevelHeight = 300 * vScale;

toplevelLeft   = (screenSize(3) - toplevelWidth) / 2 ;
toplevelBottom = (screenSize(4) - toplevelHeight) / 2 ;

toplevelPosition = [ toplevelLeft, toplevelBottom, ...
      toplevelWidth, toplevelHeight ];
   
% 
% Construct the toplevel
%
windowName = ['Log Change: ', currentRoot];

toplevel = figure('Numbertitle',      'off',...
   'Name',             windowName,...
   'menubar',          'none',...
   'IntegerHandle',    'off', ...
   'Visible',          'off', ...
   'HandleVisibility', 'on', ...
   'Units',            'Characters', ...                  
   'Tag',              'SIMULINK_SLCHANGELOG',...
   'WindowStyle',      'Modal', ...
   'DeleteFcn',        'slchangelog Save;', ...
   'Position',         toplevelPosition);

% 
% Create bottom button ('Save')
%
left = toplevelWidth - leftAlignment - buttonWidth;
position = [ left, vertSpacer, buttonWidth, buttonHeight ];

properties = {'String', 'Save', 'Callback', 'slchangelog Save;'};                  

allData.bottomButton = sluiutil('CreatePushbutton', toplevel, ...
   'on', 'on', position, properties);

% 
% get activ window dimensions
%
fieldLeft  = 160 * hScale;
fieldWidth = toplevelWidth - fieldLeft - leftAlignment;

top = toplevelHeight - vertSpacer;

% 
% checkbox for including changes
%
bottom = 2 * vertSpacer + buttonHeight + textHeight;

text.left = leftAlignment;
text.width = toplevelWidth - 2 * leftAlignment;
string = 'Include "Modified Comments" in "Modified History"';
text.properties = {'String', string, 'Value', 1};
allData.includeCommentCheckbox = sluiutil('CheckboxWidget', toplevel, ...
   bottom, text, 'on', 'on');  

% 
% checkbox for changing updateHistory to NEVER
%
bottom = bottom + textHeight;

text.left = leftAlignment;
text.width = toplevelWidth - 2 * leftAlignment;
string = 'Show this dialog box next time when save';
text.properties = {'String', string, 'Value', 1};
allData.showDialogCheckbox = sluiutil('CheckboxWidget', toplevel, ...
   bottom, text, 'on', 'on');  

% 
% Modified Comment
%
text.left       = leftAlignment;
text.width      = fieldLeft;
text.properties = {'String', 'Modified Comment:'};

edit.left       = leftAlignment;
edit.width      = toplevelWidth - 2 * leftAlignment;
edit.height     = top - bottom - vertSpacer - textHeight;

authorString  = get_param(currentRoot, 'ModifiedBy');
dateString    = get_param(currentRoot, 'ModifiedDate');
versionString = get_param(currentRoot, 'ModelVersion');
versionUpdate = get_param(currentRoot, 'ModelVersionFormat');
versionString = LocIncrementVersion(versionString,versionUpdate);

editString = [authorString ,...
      ' -- ' , dateString ,...
      ' -- Version ' , versionString];

edit.properties = {'String',   editString;...
      'Callback', ''};

allData.log = sluiutil('MultipleLineEditWidget', toplevel, top, 0, ...
   text, edit, 'on', 'on');

%
% add one more empty line
%
string = get(allData.log.edit, 'String');
string = [string; {''}];
set(allData.log.edit, 'String', string);

% 
% final savings
%
allData.toplevel = toplevel;
set( toplevel, 'UserData', allData ) ;

%
% set the visibility of the toplevelhandle
%
set(toplevel, 'HandleVisibility', 'Callback', 'Visible', 'on') ;

uiwait(toplevel);

return  % LocalCreate

% ====================================================
function LocalSave
% Callback for save button

allData = get(gcbf, 'UserData');
currentRoot = allData.currentRoot;

%
% determine new value for UpdateHistory 
%
value = onoff(get(allData.showDialogCheckbox.checkbox, 'Value'));
set_param(currentRoot, 'UpdateHistoryNextTime', value);

%
% determine new value for IncludeLog
%
value = get(allData.includeCommentCheckbox.checkbox, 'Value');
switch value
case 0
   set_param(currentRoot, 'Includelog', 'off');
   
case 1
   set_param(currentRoot, 'IncludeLog', 'on');
   
   %
   % update history
   %
   string = get(allData.log.edit, 'String');
   string = sluiutil('getCharArrayFromCellArray', string);
   set_param(currentRoot, 'ModifiedComment', string);
end

delete(gcbf);  % this also resumes the program execution, 
% stopped by uiwait in LocalCreate function

return  % LocalSave

%--------1---------2---------3---------4---------5---------6---------7---------8

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vString = LocIncrementVersion(vString,vUpdate)
%This function updates the Version string based upon the 
%rules in vUpdate


if isempty(vUpdate)
   return
end

%Search for the beginning tags
beginTag='%<autoincrement:';
tagBeginLoc=findstr(lower(vUpdate),beginTag);
tagBeginLen=length(beginTag);

%Search for the end tags
tagEnd='>';
tagEndLoc=findstr(vUpdate,tagEnd);
tagEndLen=1;

numTags=length(tagBeginLoc);

%We can only parse the update string if there
%are an equal number of beginning and ending tags
if numTags>0
   if numTags==length(tagEndLoc)
      %Add an additional begin tag location at the end of
      %the vUpdate string to capture text after the last tag
      tagBeginLoc(end+1)=length(vUpdate)+1;
      
      %Initialize the revised version string as the text
      %before the first tag
      newString=vUpdate(1:tagBeginLoc(1)-1);
      for i=1:numTags
         %Get the number between the colon and the tag end
         incrementNumber=str2num(...
            vUpdate(tagBeginLoc(i)+tagBeginLen:tagEndLoc(i)-1))...
            +1;
         if isempty(incrementNumber)
            %if the str2num was operating on an invalid string
            %such as a character or empty space, it returns [].
            %In this case, we make the tag number 0
            incrementNumber=0;
         end
         
         %Add text between and after tags
         nextString=vUpdate(tagEndLoc(i)+tagEndLen:tagBeginLoc(i+1)-1);
         
         newString=sprintf('%s%i%s',newString,incrementNumber,nextString);
      end
      vString=newString;
   end
else
   vString=vUpdate;
end
