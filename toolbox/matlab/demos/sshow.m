function sshow(action,sshowType)
%SSHOW A slide show shell.
%   SSHOW works with the helper functions SSINIT, SSDISP, and SSPAUSE
%   to build a graphical user interface around a linear, page by page
%   demo.
%
%   (This function is obsolete.  Use MAKESHOW and PLAYSHOW instead.)
%
%   See also SSINIT, SSDISP, SSPAUSE, MAKESHOW, PLAYSHOW

%   Ned Gulley, 6-21-93
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.12 $  $Date: 2002/04/15 03:32:29 $

% UserData usage:
% The figure UserData contains a list of all uicontrol handles.
% The axis UserData holds the pause status for the demos.
% The text window UserData holds the name of the current script.

% Possible actions:
% startreset
% info
 
% Possible sshowTypes:
% mixed
% graphic
% text

if nargin < 2,
    sshowType='mixed';
end;

% sshow will automatically assume that the argument it is passed 
% is the name of a demo script if it is NOT EQUAL to either
% the reserved words "start" or "info".

% Information regarding the play status will be held in
% the axis user data according to the following table:
play = 1;
wait = 0;
stop = -1;

% The variable SlideShowGUIFlag is used to let the demo script know that
% it is being called from within the GUI shell of sshow. Otherwise, the
% demo script will echo text to the command window.
SlideShowGUIFlag=1;

if strcmp(action,'startreset'),
    figNumber=gcf;
    hndlList=get(gcf,'Userdata');
    txtHndl=hndlList(1);
    startHndl=hndlList(2);
    if strcmp(get(startHndl,'String'),'Start'),
        sshow start
    else
        % We must be resetting the demo ...
        scriptName=get(txtHndl,'UserData');
        % Reset the Init Flag to force redrawing the initial screen.
        set(startHndl,'UserData',1);
        eval(scriptName);
    end

elseif strcmp(action,'start'),
    figNumber=gcf;
    axHndl=gca;
    set(axHndl,'Userdata',wait);
    hndlList=get(gcf,'Userdata');
    txtHndl=hndlList(1);
    startHndl=hndlList(2);
    contHndl=hndlList(3);
    stopHndl=hndlList(4);
    autoHndl=hndlList(5);
    infoHndl=hndlList(6);
    closeHndl=hndlList(7);
    set([startHndl infoHndl closeHndl contHndl],'Enable','off');
    set([contHndl stopHndl],'Enable','on');

    % ====== Start of Demo
    
    set(figNumber,'Pointer','watch');
    scriptName=get(txtHndl,'UserData');
    eval(scriptName);
    set(figNumber,'Pointer','arrow');

    % ====== End of Demo
    set([startHndl infoHndl closeHndl contHndl],'Enable','on');
    set([stopHndl contHndl],'Enable','off');

elseif strcmp(action,'info'),
    hndlList=get(gcf,'Userdata');
    txtHndl=hndlList(1);
    ttlStr='Slide Show Info';
    hlpStr1= ...                                                       
        {'                                                '  
         ' This window is known as a Slide Show Player.   '  
         ' It works with files written in the Slide Show  '  
         ' format to create a graphic user interface for  '  
         ' viewing standard demonstrations.               '  
         '                                                '  
         ' The actions of the buttons are summarized      '
         ' below:                                         '  
         '                                                '  
         ' "Start" begins the slide show.                 '  
         ' "Next" proceeds to the next slide.             '  
         ' "Stop" halts the slide show.                   '  
         ' "Autoplay" lets the show play automatically.   '
         '                                                '};
    hlpStr2= ...                                                
        {'                                                  '  
         ' You should be aware that when you are            '  
         ' running a slide show (from the time after you    '  
         ' press the "Start" button until either the slide  '  
         ' show is complete or you end the slide show       '  
         ' with the "Stop" button) you will NOT be able     '  
         ' to execute commands from the command line,       '  
         ' since MATLAB will be busy executing a            '  
         ' demo script.                                     '  
         '                                                  '  
         ' For this reason it is strongly recommended       '  
         ' that you finish the slide show or end it by      '  
         ' pushing the "Stop" button before you begin       '  
         ' any other demos.                                 '};

    scriptName=get(txtHndl,'UserData');
    hlpStr1=cat(1, hlpStr1,{[' Now playing: ',scriptName,'.m']});
    
    helpwin(cat(1, hlpStr1, hlpStr2), ttlStr);                                           

else 
    % Turn the watch on for the old figure
    oldFigNumber=watchon;

    % Since the variable "action" is neither the word "start" nor the
    % word "info", it must be the name of a demo script.
    scriptName=action;

    %===================================
    % Now initialize the whole figure...
    pos=get(0,'DefaultFigurePosition');
    pos=[pos(1) pos(2)-40 560 460];
    %screenSize=get(0,'ScreenSize');
    figNumber=figure( ...
        'Name','Slide Show Player', ...
        'NumberTitle','off', ...
        'Position',pos, ...
        'DefaultAxesUserData', 1, ...
        'Visible','off');

    %====================================
    % Display mixed, text, or graphics only based on sshowType
    % If the figure is to be text only, hide the axis.
    % If it is to be graphics only, hide the comment window.
    % Otherwise, we'll assume that figure is mixed
    if strcmp(sshowType,'text'),
        axesVisStatus='off';
        textVisStatus='on';
        textBoxTop=0.97;
        defaultAxesPos=[0.45 0.45 0.1 0.1];
    elseif strcmp(sshowType,'graphic'),
        axesVisStatus='on';
        textVisStatus='off';
        textBoxTop=0.35;
        defaultAxesPos=[0.10 0.10 0.65 0.8];
    else
        axesVisStatus='on';
        textVisStatus='on';
        textBoxTop=0.40;
        defaultAxesPos=[0.10 0.50 0.65 0.43];
    end;

    set(figNumber,'DefaultAxesPosition',defaultAxesPos);

    %===================================
    % Set up the axes
    axHndl=axes( ...
        'Units','normalized', ...
        'Userdata',stop, ...
        'Visible','off');

    %===================================
    % Set up the Comment Window
    top=textBoxTop;
    left=0.03;
    right=0.77;
    bottom=0.03;
    labelHt=0.00;
    spacing=0.005;

    % First, the MiniCommand Window frame
    frmBorder=0.015;
    frmPos=[left-frmBorder bottom-frmBorder ...
        (right-left)+2*frmBorder (top-bottom)+2*frmBorder];
    frmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','normalized', ...
        'Position',frmPos, ...
        'Visible',textVisStatus, ...
        'BackgroundColor',[0.5 0.5 0.5]);
    % Then the editable text field
    txtPos=[left bottom (right-left) top-bottom-labelHt-spacing];
    txtHndl=uicontrol( ...
        'Style','edit', ...
        'HorizontalAlignment','left', ...
        'Units','normalized', ...
        'Max',10, ...
        'BackgroundColor',[1 1 1], ...
        'Visible',textVisStatus, ...
        'Position',txtPos);
    % Save the name of the file for future use
    set(txtHndl,'UserData',scriptName);

    %====================================
    % Information for all buttons
    labelColor=[0.8 0.8 0.8];
    yInitPos=0.90;
    top=0.97;
    left=0.82;
    right=0.97;
    btnWid=right-left;
    btnHt=0.08;
    % Spacing between the button and the next command's label
    spacing=0.04;
    
    %====================================
    % The CONSOLE frame
    frmBorder=0.015;
    yPos=bottom-frmBorder;
    frmPos=[left-frmBorder yPos btnWid+2*frmBorder (top-bottom)+2*frmBorder];
    h=uicontrol( ...
        'Style','frame', ...
        'Units','normalized', ...
        'Position',frmPos, ...
        'BackgroundColor',[0.5 0.5 0.5]);

    %====================================
    % The START/RESET button
    btnNumber=1;
    yPos=top-(btnNumber-1)*(btnHt+spacing);
    labelStr='Start';
    callbackStr='sshow startreset';

    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    startHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Interruptible','on', ...
        'UserData',1, ...
        'Callback',callbackStr);

    %====================================
    % The NEXT button
    btnNumber=2;
    yPos=top-(btnNumber-1)*(btnHt+spacing);
    labelStr='Next';
    % Setting userdata to 1 (=play) will continue the demo.
    callbackStr='set(gca,''Userdata'',1);';
    
    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    contHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'Enable','off', ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %====================================
    % The STOP button
    btnNumber=3;
    yPos=top-(btnNumber-1)*(btnHt+spacing);
    labelStr='Stop';
    % Setting userdata to -1 (=stop) will stop the demo.
    callbackStr='set(gca,''Userdata'',-1)';
    
    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    stopHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'Enable','off', ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %====================================
    % The AUTOPLAY button
    btnNumber=4;
    yPos=top-(btnNumber-1)*(btnHt+spacing);
    labelStr='AutoPlay';
    % Setting this checkbox will run demo w/o stopping.
    
    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    autoHndl=uicontrol( ...
        'Style','checkbox', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'Enable','on', ...
        'String',labelStr);

    %====================================
    % The INFO button
    labelStr='Info';
    callbackStr='sshow info';
    infoHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[left bottom+btnHt+spacing btnWid btnHt], ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %====================================
    % The CLOSE button
    labelStr='Close';
    callbackStr='close(gcf)';
    closeHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[left bottom btnWid btnHt], ...
        'String',labelStr, ...
        'Callback',callbackStr);

    % The next line is a workaround for a Windows bug
    set([contHndl stopHndl],'Enable','off');
    hndlList=[txtHndl startHndl contHndl stopHndl ...
         autoHndl infoHndl closeHndl];
    set(figNumber, ...
        'Visible','on', ...
        'UserData',hndlList);

    % Uncommenting the next command makes the (left) mouse button act like a 
    % slide show advance button. When not over a uicontrol, pressing
    % the mouse button has the same effect as clicking on the
    % "Next" button.
    %set(figNumber,'WindowButtonDownFcn','set(gca,''UserData'',1)');

    % Executing the demo script is required now in order to initialize
    % the info text and the initial prompting text
    set(figNumber,'Pointer','watch');
    eval(scriptName);
    set(figNumber,'Pointer','arrow');
    
    watchoff(oldFigNumber);
    figure(figNumber);

end;    % if strcmp(action, ...
