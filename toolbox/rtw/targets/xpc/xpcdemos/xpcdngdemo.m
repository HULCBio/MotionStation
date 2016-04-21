function xpcdngdemo
% XPCDNGDEMO How to use the demo Dials & Gauges model with xPC Target
%
%   To run the demo dials and gauges model xpctankpanel together with the
%   model xpctank (running on the xPC Target PC in real-time), execute the
%   following steps. It is assumed that the Target PC is set up properly
%   and is ready to accept the downloaded application.
%
%    1. First, open the model xpctank by typing its name on the command
%       line.
%    2. Build the model by selecting Tools|Real-Time Workshop|Build Model
%       from the menu of the Simulink Window. This should build and
%       download the model, and create a variable called 'tg' in the base
%       MATLAB workspace. This variable is the xpc object, used to
%       communicate with the target machine, start and stop the
%       application, etc.
%    3. Close the model xpctank and open the model xpctankpanel by typing
%       its name at the MATLAB command line.
%    4. While the simulation in Normal mode (shown in the drop down list in
%       the Simulink window, or the checked option in the Simulink menu),
%       select Simulink|Start to start the simulation. This should connect
%       to the real-time application, and show the corresponding results.
%
%   Note the various 'From xPC Target' and 'To xPC Target' blocks in the
%   model xpctankpanel. These are the key to interfacing Dials & Gauges to
%   xPC Target. These may be found in the Simulink Library, by selecting
%   'xPC Target' and then 'Misc' in the Simulink Library browser.
%

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.3 $ $Date: 2002/03/25 04:27:42 $

help(mfilename);