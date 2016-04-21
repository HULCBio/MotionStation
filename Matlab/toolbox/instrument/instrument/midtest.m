function midtest(varargin)
%MIDTEST launch GUI for testing MATLAB Instrument Driver.
%
%   MIDTEST opens the MATLAB Instrument Driver Testing Tool.  
%   The MATLAB Instrument Driver Testing Tool provides a graphical 
%   environment for creating a test to verify the functionality of
%   a MATLAB instrument driver. 
%
%   The MATLAB Instrument Driver Testing Tool provides a way to: 
%      1. verify property behavior
%      2. verify function behavior
%      3. save the test as MATLAB code
%      4. export the test results to MATLAB workspace, figure window, 
%         MAT-file or the MATLAB array editor.
%      5. save test results as an html page.
%
%   MIDTEST('TEST.XML') opens the MATLAB Instrument Driver Testing
%   Tool with the test, TEST.XML, loaded. 
%
%   See also ICDEVICE, MIDEDIT.
%    

%   MP 07-11-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/01/16 20:01:42 $

% Error checking.
switch (nargin)
case 0
    name = '';
case 1
    % Determine if the test exists.
    name            = varargin{1};
    createEmptyTest = false;
    [name, errflag] = localFindTest(name);
    
    if (errflag)
        % The test was not found. Prompt the user if they want to 
        % have the test created.
        name = varargin{1};
        [showerror, createEmptyTest] = localShowDialog(name);
        if (showerror)
            rethrow(lasterror);
        end
        if (createEmptyTest == false)
            return;
        end
    end
otherwise
    error('instrument:midtest:tooManyArgs', 'Too many input arguments.');
end

% Determine if the window is hidden. If so, use it.
h = com.mathworks.toolbox.testmeas.browser.Browser.findInstance('MATLAB Instrument Driver Testing Tool');
if ~isempty(h)
    if (nargin == 0)
        h.show;
        return;
    else
        m = com.mathworks.toolbox.instrument.device.guiutil.midtest.MIDTestTool.getInstance;
        m.loadTest(name);
        h.show;
        return;
    end
end

% Create the GUI.
if isempty(name)
    m = com.mathworks.toolbox.instrument.device.guiutil.midtest.MIDTestTool.getInstance; 
else
    m = com.mathworks.toolbox.instrument.device.guiutil.midtest.MIDTestTool.getInstance;
    m.loadTest(name, createEmptyTest);
end

% Add to the frame and update the location of the scrollpanels.
m.addToFrame
pause(0.1);
m.updateLocation;

% -------------------------------------------------------------------
% Find the location of the MATLAB Instrument Driver test.
function [test, errflag] = localFindTest(test)

% Initialize variables.
errflag = false;

% Find the driver.
[pathstr, name, ext] = fileparts(test);
if isempty(ext)
    test = [test '.xml'];
end

if isempty(pathstr)
    testWithPath = which(test);
    
    % If found test, use it.
    if ~isempty(testWithPath)
        test = testWithPath;
    end
end

% If not on MATLAB path, check the drivers directory.
pathstr = fileparts(test);
if isempty(pathstr)
    test = fullfile(matlabroot,'toolbox','instrument','instrument','drivers', test);
end

% Verify that the driver exists.
if ~exist(test)
    errflag = true;
    errorID = 'instrument:midtest:testNotFound';
    lasterr('The specified test was not found.', errorID);
    return;
end

% -------------------------------------------------------------------
function [showerror, okToContinue] = localShowDialog(test)

% Initialize variables.
showerror    = false;
okToContinue = false;

% If a path is specified, error.
[pathstr, name, ext] = fileparts(test);
if isempty(ext)
    test = [test '.xml'];
end

if ~isempty(pathstr)
    showerror = true;
    return;
end

% Show the dialog to the user asking if they want the file to be created.
value = char(com.mathworks.toolbox.instrument.Instrument.getPreferenceFile.read('TestToolPromptTestsDontExist'));
okToContinue = com.mathworks.toolbox.instrument.device.guiutil.midtest.MIDTestTool.createTestNotFoundDialog(test);

if okToContinue == false
    if strcmp(value, 'false')
        showerror = true;
        lasterr('The specified test could not be found.', 'instrument:midtest:testNotFound');
    end
end