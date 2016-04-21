function stopFlag=ssinit(figNumber)
%SSINIT Initialize the Slide Show figure
%
%   stopFlag=SSINIT(figNumber) interacts with the function 
%   SSHOW to initialize the Slide Show figure with the appropriate
%   information. Its sole purpose is to exit the demo script after the
%   initial plot and text are displayed, thereby allowing the user
%   to decide if they want to see the demo.

%   Ned Gulley, 6-21-93
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.8 $  $Date: 2002/04/15 03:33:29 $

% If figNumber is zero, the demo will run without the GUI shell.
if figNumber==0,
    % The stopFlag must be set to one even though in this case the demo
    % will NOT stop. This allows the first screen to plot properly when
    % running the demo from the command line.
    stopFlag=1;

else
    figure(figNumber);
    axHndl=gca;
    hndlList=get(figNumber,'UserData');

    startHndl=hndlList(2);
    % The UserData for the Start button is the Init Flag.
    % If it is high, then we SHOULD set stopFlag to high (and thus
    % exit the demo script early).

    if get(startHndl,'UserData'),
        % Set the UserData of the start button.
        set(startHndl, ...
            'UserData',0, ...
            'String','Start', ...
            'Interruptible','on');
        stopFlag=1;
    else
        % If the initialization screen has already been placed,
        % then keep executing the script.
        stopFlag=0;
        % Once we start the slide show, the Start button should
        % change to a "Reset" button. Also, set its "interruptible"
        % property to off so we don't cause problems later on with
        % user double-clicks.
        set(startHndl, ...
            'String','Reset', ...
            'Interruptible','off');
    end;

end    % if figNumber==0 ...
