% xPC Target
% Version 2.5 (R14) 05-May-2004 
%
% xPC Target Environment
%   getxpcenv       - Gets xPC Target Environment Properties.
%   setxpcenv       - Sets xPC Target Environment Properties.
%   updatexpcenv    - Updates the xPC Target Environment.
%   xpcbootdisk     - Creates xPC Target Boot Floppy Disk.
%
% xPC Target Graphical User Interfaces
%   xpcexplr	  - xPC Target Explorer. 
%   xpcsetup        - GUI to maintain xPC Target Environment.
%   xpcrctool       - xPC Target Remote Control Tool GUI.
%   xpcscope        - xPC Target Host Scope GUI.
%   xpctgscope      - xPC Target Target Scope GUI.
%   xpctargetspy    - Shows the target screen on the host.
%
% xPC Target Object methods
%   xpc             - Construct xPC target object.
%   xpc/get         - Gets value of target object property.
%   xpc/set         - Sets value of target object property.
%   xpc/load        - Loads an application onto the target.
%   unload          - Unloads the current application from the target.
%   xpc/start       - Starts target application execution.
%   xpc/stop        - Stops execution of the target application.
%   addscope        - Adds a scope to the current simulation.
%   getscope        - Gets an xPC scope object.
%   remscope        - Removes a scope from the target.
%   getlog          - Gets part of any of the various simulation logs.
%   getparamid      - Gets the parameter index in the parameter list.
%   getsignalid     - Gets the signal index in the signal list.
%   xpc/close           - Closes the serial port connection to the target.
%   reboot          - Reboots the target system.
%
% xPC Target Scope Object Properties
%   xpcsc/get       - Gets value of scope object property.
%   xpcsc/set       - Sets value of scope object property.
%   xpcsc/start     - Starts xPC Target scope.
%   xpcsc/stop      - Stops xPC Target scope.
%   addsignal       - Adds a (vector of) signal(s) to the scope.
%   remsignal       - Removes signals from scopes.
%   trigger         - (Software) Triggers one or more xPC scopes.
%
% xPC Target Demos
%   scfreerundemo   - Demonstrates FreeRun display mode of xPC Scope.
%   scscopedemo     - Demonstrates scope triggered xPC Scope.
%   scsignaldemo    - Demonstrates signal triggered xPC scope.
%   scsoftwaredemo  - Demonstrates software triggered xPC scope.
%   scprepostdemo   - Demonstrates pre/post triggering of xPC scope.
%   tgscopedemo     - Demonstration of xPC TargetScope.
%   parsweepdemo    - Demonstrates parameter updates in xPC.
%   dataloggingdemo - Demonstrates time- and value-equidistant data logging.
%
%   xpcdngdemo      - How to use the demo gauges model with xPC Target
%   xpcspectrumdemo - How to use the Spectrum Analyzer demo with xPC Target
%   xpcbench        - Execute xPC Target benchmarks and show result
%
% Miscellaneous Functions
%   xpctest         - xPC Target Test Suite.
%   xpctargetping   - 'Ping' the target to test connection.
%   getxpcpci       - Query target PC for installed PCI-boards.
%   xpcwwwenable    - Enables the use of the xPC Target WWW Interface.
%   xpcsliface      - Generates a skeleton Simulink instrumentation Model.

%   Copyright 1996-2004 The MathWorks, Inc.
%   Generated from Contents.m_template revision 1.1.6.2
