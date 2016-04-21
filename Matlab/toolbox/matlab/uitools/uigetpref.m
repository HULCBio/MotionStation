function [val, dlgShown]=uigetpref(prefGroup, prefPref, dlgTitle, dlgQuestion,prefOptions, varargin)
%UIGETPREF question dialog box with preference support
%  VALUE=UIGETPREF(GROUP, PREF, TITLE, QUESTION, PREF_CHOICES)
%  Returns one of the strings in PREF_CHOICES, either by prompting the user with
%  a multiple-choice question dialog box, or by returning a previous answer
%  stored in the preferences database.  By default, the dialog box is shown each
%  time, with each choice on a different pushbutton, and with a checkbox controlling
%  whether the returned value should be stored in preferences and automatically reused
%  in subsequent invocations.  When the user clicks the checkbox before choosing one
%  of the pushbuttons, the pushbutton choice is stored in preferences and returned.
%  Subsequent calls to UIGETPREF detect that the last choice was stored in preferences,
%  and return that choice immediately without displaying the dialog.  If the user does
%  not click the checkbox before choosing a pushbutton, a special value is stored in
%  preferences which indicates that subsequent calls to UIGETPREF should display
%  the dialog box.
%
%  GROUP and PREF define the preference.  If the preference does not already exist,
%  UIGETPREF creates it.
%
%  TITLE defines the string displayed in the dialog's titlebar.
%
%  QUESTION is a descriptive paragraph displayed in the dialog, specified as a string
%  array or cell array of strings.  This should contain the question the user is being
%  asked, and should be detailed enough to give the user a clear understanding of their
%  choice and its impact.  UIGETPREF inserts line breaks between rows of the string array,
%  between elements of the cell array of strings, or between '|' or newline characters in the
%  string vector.
%
%  PREF_CHOICES is either a string, cell array of strings, or '|'-separated string
%  specifying the strings to be displayed on the pushbuttons.  Each string element is
%  displayed in a separate pushbutton.  The string on the selected pushbutton is returned.
%  If the checkbox has been clicked, that string is also stored in preferences.  If the
%  checkbox has not been clicked, a special value is stored in preferences.
%
%  PREF_CHOICES may also be an 2xN cell array of strings, if the internal preference
%  values should be different than the strings displayed on the pushbuttons.  The first
%  row should contain the preference strings, and the second row should contain the
%  related pushbutton strings.  Note that the preference values are still returned in VALUE,
%  not the button labels.
%
%  [VAL,DLGSHOWN] = UIGETPREF(...)  will return whether or not the dialog was shown.
%
%  Additional arguments may be passed in as parameter-value pairs:
%
%  (...'CheckboxState',0 or 1) sets the initial state of the checkbox,
%                              either checked or unchecked.  By default it is not checked.
%
%  (...'CheckboxString',CBSTR) sets the string on the checkbox.  By default
%                              it is 'Never show this dialog again'
%
%  (...'HelpString',HSTR)      sets the string on the help button.  By default the string
%                              is empty and there is no help button.
%
%  (...'HelpFcn',HFCN)         sets the callback that is executed when the help button is
%                              pressed.  By default it is doc('uigetpref').  Note that if
%                              there is no 'HelpString', a button will not be created.
%
%  (...'ExtraOptions',EO)      creates extra buttons which are not mapped to any preference
%                              settings.  Can be a string or a cell array of strings.  By
%                              default it is {} and no extra buttons are created.
%
%  (...'DefaultButton',DB)     sets the button value that is returned if the dialog is closed.
%                              By default, it is the first button.  Note that DB does not have
%                              to correspond to a preference or ExtraOption.
%
%  Example:
%
%  [selectedButton,dlgShown]=uigetpref('graphics','savefigurebeforeclosing',...
%       'Closing Figure',...
%       {'Do you want to save your figure before closing?'
%         ''
%	      'You can save your figure manually by typing ''hgsave(gcf)'''},...
%       {'always','never';'Yes','No'},...
%       'ExtraOptions','Cancel',...
%       'DefaultButton','Cancel',...
%       'HelpString','Help',...
%       'HelpFcn','doc(''closereq'');')
%
%  SEE ALSO UISETPREF, GETPREF, SETPREF, ADDPREF, RMPREF

%  Copyright 1999-2003 The MathWorks, Inc.
%  $Revision: 1.12.4.4 $


dlgShown=logical(0);
askVal='ask';

val=getpref(prefGroup, prefPref, askVal); 

if ~ischar(val) | ~strcmp(val, askVal)
    return;
end
dlgShown=logical(1);

dlgQuestion=locParseQuestion(dlgQuestion);

[pValues,pNames]=locParseOptions(prefOptions);
uisetpref('addpref',prefGroup,prefPref,pValues);

checkboxInitState=locParseInputs(varargin,'CheckboxState',0);
checkboxString=locParseInputs(varargin,'CheckboxString','Do not show this dialog again');

defaultButton=locParseInputs(varargin,'DefaultButton',pNames{1});

extraButtons=locParseInputs(varargin,'ExtraOptions',{});
if ischar(extraButtons)
    extraButtons={extraButtons};
end

helpString=locParseInputs(varargin,'HelpString','');
if ~isempty(helpString)
    helpFcn=locParseInputs(varargin,'HelpFcn','');
    if isempty(helpFcn)
        helpTopic=locParseInputs(varargin,'HelpTopic','uigetpref');
        helpFcn=['doc(''' helpTopic ''');'];
    end
else
    helpFcn='';
end

%build dialog
hFig=dialog(                                                   ...
    'KeyPressFcn'     ,{@doFigureKeyPress, defaultButton}    , ...
    'Name'            ,dlgTitle                              , ...
    'Pointer'         ,'arrow'                               , ...
    'Tag'             ,dlgTitle                              , ...
    'Visible'         ,'off'                                 , ...
    'WindowStyle'     ,'normal'                                ... 
    );

hQuestion=uicontrol( ...
    'Style'                 ,'text'                                 , ...
    'HorizontalAlignment'   ,'left'                                 , ...
    'KeyPressFcn'           ,{@doControlKeyPress, defaultButton}    , ...
    'String'                ,dlgQuestion                            , ...
    'Parent'                ,hFig                                     ...
);

hCheckbox=uicontrol( ...
    'Style'           ,'checkbox'                             , ...
    'KeyPressFcn'     ,{@doControlKeyPress, defaultButton}    , ...
    'String'          ,checkboxString                         , ...
    'Value'           ,checkboxInitState                      , ...
    'Parent'          ,hFig                                     ...
);

for i=1:length(pNames)
    optButton(i)=uicontrol( ...
        'Style'       ,'pushbutton'                           , ...
        'KeyPressFcn' ,{@doControlKeyPress, defaultButton}    , ...
        'String'      ,pNames{i}                              , ...
        'Callback'    ,{@doCallback, pValues{i}}              , ...
        'Parent'      ,hFig                                     ...
        );
end

%create additional buttons
for i=1:length(extraButtons)
    optButton(end+1)=uicontrol( ...
        'Style'       ,'pushbutton'                           , ...
        'KeyPressFcn' ,{@doControlKeyPress, defaultButton}    , ...
        'String'      ,extraButtons{i}                        , ...
        'Callback'    ,{@doCallback, extraButtons{i}}         , ...
        'Parent'      ,hFig                                     ...
        );
end

if ~isempty(helpString)
    hHelp = uicontrol( ...
        'Style'       ,'pushbutton'                           , ...
        'KeyPressFcn' ,{@doControlKeyPress, defaultButton}    , ...
        'String'      ,helpString                             , ...
        'Callback'    ,{@doHelp, helpFcn}                     , ...
        'Parent'      ,hFig                                     ...
        );
else
    hHelp=[];
end

%position controls
textExtent=get(hQuestion,'Extent');
checkExtent=get(hCheckbox,'Extent');

if ~isempty(hHelp)
    helpExtent = get(hHelp,'Extent');
else
    helpExtent=[0 0 0 0];
end

btnMargin=1.4;
horizExtent(length(optButton)+1)=45;
for i=length(optButton):-1:1
    ex=get(optButton(i),'Extent');
    horizExtent(i)=ex(3)*btnMargin;
end
btnHeight=ex(4)*btnMargin;
pad = btnHeight/3;

%cumHorizExtent=sum(horizExtent)+pad*(length(optButton)-1);
cumHorizExtent=max(horizExtent)*length(optButton)+pad*(length(optButton)-1);
horizSize=max([cumHorizExtent, checkExtent(3), textExtent(3), helpExtent(3)]);

numRows=2+~isempty(hHelp);
vertSize=(btnHeight+pad)*numRows+textExtent(4);

FigPos    = get(0,'DefaultFigurePosition');
FigPos(3) = horizSize + 2*pad;
FigPos(4) = vertSize  + 2*pad;

set(hFig,'position',getnicedialoglocation(FigPos, get(hFig,'Units')));

set(hQuestion,'position',[pad (btnHeight+pad)*numRows+pad textExtent(3) textExtent(4)]);

helpButtonWidth=max(helpExtent(3)*btnMargin, max(horizExtent));
set(hHelp,...
    'position',[horizSize+pad-helpButtonWidth,...
        (btnHeight+pad)*2+pad,...
        helpButtonWidth,...
        btnHeight]);

set(hCheckbox,'position',[pad (btnHeight+pad)+pad, horizSize, btnHeight]);

rightPos=horizSize+2*pad;
for i=length(optButton):-1:1
    %rightPos=rightPos-horizExtent(i)-pad;
    %set(optButton(i),'position',[rightPos pad, horizExtent(i), btnHeight]);
    
    rightPos=rightPos-max(horizExtent)-pad;
    set(optButton(i),'position',[rightPos, pad, max(horizExtent), btnHeight]);

    if strcmp(get(optButton(i),'String'), defaultButton)
        h1 = optButton(i);
        old_units = get(h1,'Units');
        set(h1,'Units','pixels');
        pos = get(h1,'Position');
        set(h1,'Units',old_units);
        l = pos(1) - 1;
        b = pos(2) - 1;
        w = pos(3) + 2;
        h = pos(4) + 2;
        h1 = uicontrol(get(h1,'Parent'), ...
                  'BackgroundColor','k', ...
                  'Style','frame', ...
                  'Position',[l b w h]);
        uistack(h1,'bottom')
    end

end

% make sure we are on screen
movegui(hFig)

%Activate dialog
set(hFig,'UserData',0);


% if there is a figure out there and it's modal, we need to be modal too
if ~isempty(gcbf) && strcmp(get(gcbf,'WindowStyle'),'modal')
    set(hFig,'WindowStyle','modal');
end

set(hFig,'visible','on');
drawnow

waitfor(hFig,'UserData');

if ishandle(hFig)
    val=get(hFig,'UserData');
    newCheckValue=get(hCheckbox,'value');
    delete(hFig);
else
    val=defaultButton;
    newCheckValue=checkboxInitState;
end


if newCheckValue ~= checkboxInitState
    %the checkbox state has been tripped.  We will need to set preferences
    valIndex=find(strcmp(val,pValues));
    if ~isempty(valIndex)
        newPref=pValues{valIndex(1)};
        setpref(prefGroup,prefPref,newPref);
        uisetpref('addpref',prefGroup,prefPref,pValues);
    end
end
val=lower(val);


%%%%%%%%%%%%%%%%%%
function val=locParseInputs(inputs, key, default)

keyIndex=find(strcmpi(inputs(1:2:end-1),key));
if isempty(keyIndex)
    val=default;
else
    val=inputs{2*keyIndex(1)};
end

%%%%%%%%%%%
function dlgQuestion=locParseQuestion(dlgQuestion)

dlgQuestion=strrep(dlgQuestion,'|',sprintf('\n'));

%%%%%%%%%%%
function [pValues,pNames]=locParseOptions(prefOptions)

if iscell(prefOptions)
    if min(size(prefOptions))>1
        pValues=prefOptions(1,:);
        pNames=prefOptions(2,:);
    else
        pValues=prefOptions;
        pNames=prefOptions;
    end
else %input is a pipe-delimited string
    pipeLoc=findstr(prefOptions,'|');
    pipeLoc=[0,pipeLoc, length(prefOptions)+1];
    
    pNames=cell(1,length(pipeLoc)-1);
    for i=1:length(pipeLoc)-1
        pNames{i}=prefOptions(pipeLoc(i)+1:pipeLoc(i+1)-1);
    end
    pValues=pNames;
end

function doFigureKeyPress(obj, evd, default)
switch(evd.Key)
 case {'return','space','escape'}
  delete(gcbf);
end

function doControlKeyPress(obj, evd, default)
switch(evd.Key)
 case {'return','escape'}
  delete(gcbf);
end

function doCallback(obj, evd, button)
set(gcbf,'UserData',button);

function doHelp(obj, evd, helpFcn)
set(gcbf,'Pointer','watch');
try
    eval(helpFcn); 
end
set(gcbf,'Pointer','arrow');
