function cmdlnwin(labelList,nameList,figureFlagList)
%CMDLNWIN A demo gateway routine for playing command line demos.
%   CMDLNWIN(LabelList,NameList,FigureFlagList)
%   creates a "Command Line Demos" window which
%   allows you to launch demos that operate from
%   the command window, as opposed to those that   
%   have their own graphic user interface.
%
%   LabelList       contains the descriptive names
%                   of the demos that will be 
%                   displayed in the "Command Line 
%                   Demos" window.
%
%   NameList        contains the actual function names
%                   of the demos.
%
%   FigureFlagList  indicates whether the demo requires
%                   a separate figure window.
%
%   This allows users of The MATLAB Demos to    
%   have access to a number of demos that, for 
%   one reason or another, do not specifically 
%   use the GUI tools.                         
%
%   Remember that these demos will send output 
%   to and accept input from the MATLAB        
%   command window, so you must make sure      
%   that the command window does not get hidden
%   behind any other windows.                  

%   Ned Gulley, 6-21-93, jae Roh 10-15-96
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.15.4.3 $  $Date: 2004/04/10 23:24:26 $

% labelList contains the descriptive names of the demos
% nameList contains the actual function names of the demos
% windowFlagList contains a flag variable that indicates whether
%    or not a window is required for the demo

% oldFigNumber=watchon;

% If no figureFlagList is supplied, assume every demo needs a
% figure window
if nargin<3,
    figureFlagList=ones(size(labelList,1),1);
end

% Now initialize the whole figure...
figNumber=figure( ...
    'Name','Command Line Demos', ...
    'IntegerHandle','off', ...
    'NumberTitle','off');
%    'NextPlot','New', ...

axes('Visible','off','HandleVisibility','callback')
%    'NextPlot','new')

    %===================================
    % Set up the Comment Window
    top=0.30;
    left=0.05;
    right=0.75;
    bottom=0.05;
    labelHt=0.05;
    spacing=0.005;
    promptStr= ...                                                       
       [' The buttons in this window will launch "Command Line '  
        ' Demos". These are demos that use the MATLAB          '  
        ' Command Window for input and output. Make sure the   '  
        ' command window is visible before you run these demos.'];

    % First, the Comment Window frame
    frmBorder=0.02;
    frmPos=[left-frmBorder bottom-frmBorder ...
        (right-left)+2*frmBorder (top-bottom)+2*frmBorder];
    uicontrol( ...
        'Style','frame', ...
        'Units','normalized', ...
        'Position',frmPos, ...
        'BackgroundColor',[0.50 0.50 0.50]);
    % Then the text label
    labelPos=[left top-labelHt (right-left) labelHt];
    uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',labelPos, ...
        'BackgroundColor',[0.50 0.50 0.50], ...
        'ForegroundColor',[1 1 1], ...
        'String','Comment Window');
    % Then the editable text field
    txtPos=[left bottom (right-left) top-bottom-labelHt-spacing];
    txtHndl=uicontrol( ...
        'Style','edit', ...
        'HorizontalAlignment','left', ...
        'Units','normalized', ...
        'Max',10, ...
        'BackgroundColor',[1 1 1], ...
        'Position',txtPos, ...
        'String',promptStr);

%====================================
% Information for all buttons
labelColor=[0.8 0.8 0.8];
yInitPos=0.90;
top=0.95;
bottom=0.05;
left=0.80;
btnWid=0.15;
btnHt=0.10;
% Spacing between the button and the next command's label
spacing=0.04;

%====================================
% The CONSOLE frame
frmBorder=0.02;
yPos=0.05-frmBorder;
frmPos=[left-frmBorder yPos btnWid+2*frmBorder 0.9+2*frmBorder];
h=uicontrol( ...
    'Style','frame', ...
    'Units','normalized', ...
    'Position',frmPos, ...
    'BackgroundColor',[0.5 0.5 0.5]);

%====================================
% The INFO button
labelStr='Info';
callbackStr=['helpwin ' mfilename];
infoHndl=uicontrol( ...
    'Style','pushbutton', ...
    'Units','normalized', ...
    'Position',[left bottom+btnHt+spacing btnWid btnHt], ...
    'String',labelStr, ...
    'Callback',callbackStr);

%====================================
% The CLOSE button
labelStr='Close';
callbackStr='close(gcbf)';
closeHndl=uicontrol( ...
    'Style','pushbutton', ...
    'Units','normalized', ...
    'Position',[left bottom btnWid btnHt], ...
    'String',labelStr, ...
    'Callback',callbackStr);

%====================================
% Information for demo buttons
labelColor=[0.8 0.8 0.8];
btnWid=0.32;
btnHt=0.08;
top=0.95;
bottom=0.35;
right=0.75;
leftCol1=0.05;
leftCol2=right-btnWid;
% Spacing between the buttons
spacing=0.02;
%spacing=(top-bottom-4*btnHt)/3;

%====================================
% Bring the command window forward on demo launch.
if usejava('desktop')
    showCommandWindow = 'uimenufcn(gcbf,''WindowCommandWindow''); ';
else
    showCommandWindow = '';
end

numButtons=size(labelList,1);
col1Count=fix(numButtons/2)+rem(numButtons,2);
col2Count=fix(numButtons/2);

% Lay out the buttons in two columns
for count=1:col1Count,
    
    btnNumber=count;
    yPos=top-(btnNumber-1)*(btnHt+spacing);
    labelStr=deblank(labelList(count,:));
%    callbackStr='eval(get(gco,''UserData''));';
    cmdStr=[showCommandWindow ...
            'figureNeededFlag=',num2str(figureFlagList(count)),'; ', ...
            'cmdlnbgn; ' nameList(count,:) '; cmdlnend;'];

    % Generic button information
    btnPos=[leftCol1 yPos-btnHt btnWid btnHt];
    startHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Callback',cmdStr);
%        'UserData',cmdStr, ...
%        'Callback',callbackStr);

end;

for count=1:col2Count,
    
    btnNumber=count;
    yPos=top-(btnNumber-1)*(btnHt+spacing);
    labelStr=deblank(labelList(count+col1Count,:));
%    callbackStr='eval(get(gco,''UserData''));';
    cmdStr=[showCommandWindow ...
            'figureNeededFlag=',num2str(figureFlagList(count+col1Count)),'; ', ...
            'cmdlnbgn; ' nameList(count+col1Count,:) '; cmdlnend;'];

    % Generic button information
    btnPos=[leftCol2 yPos-btnHt btnWid btnHt];
    startHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Callback',cmdStr);
%        'UserData',cmdStr, ...
%        'Callback',callbackStr);

end;

% watchoff(oldFigNumber);

set(figNumber,'HandleVisibility','off');
