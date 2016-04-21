% Simulink
% Version 6.0 (R14) 05-May-2004
%
% Model analysis and construction functions.
%
% Simulation
%   sim              - Simulate a Simulink model.
%   sldebug          - Debug a Simulink model.
%   simset           - Define options to SIM Options structure.
%   simget           - Get SIM Options structure
%
% Linearization and trimming.
%   linmod           - Extract linear model from continuous-time system.
%   linmod2          - Extract linear model, advanced method. 
%   dlinmod          - Extract linear model from discrete-time system.
%   trim             - Find steady-state operating point.
%
% Model Construction.
%   close_system     - Close open model or block.
%   new_system       - Create new empty model window.
%   open_system      - Open existing model or block.
%   load_system      - Load existing model without making model visible.
%   save_system      - Save an open model.
%   add_block        - Add new block.
%   add_line         - Add new line. 
%   delete_block     - Remove block.
%   delete_line      - Remove line.
%   find_system      - Search a model.
%   hilite_system    - Hilite objects within a model.
%   replace_block    - Replace existing blocks with a new block.
%   set_param        - Set parameter values for model or block.
%   get_param        - Get simulation parameter values from model.
%   add_param        - Add a user-defined string parameter to a model.
%   delete_param     - Delete a user-defined parameter from a model.
%   bdclose          - Close a Simulink window.
%   bdroot           - Root level model name.
%   gcb              - Get the name of the current block.
%   gcbh             - Get the handle of the current block.
%   gcs              - Get the name of the current system.
%   getfullname      - get the full path name of a block
%   slupdate         - Update older 1.x models to 3.x.
%   addterms         - Add terminators to unconnected ports.
%   boolean          - Convert numeric array to boolean.
%   slhelp           - Simulink user's guide or block help.
%
% Masking.
%   hasmask          - Check for mask.
%   hasmaskdlg       - Check for mask dialog.
%   hasmaskicon      - Check for mask icon.
%   iconedit         - Design block icons using ginput function.
%   maskpopups       - Return and change masked block's popup menu items.
%   movemask         - Restructure masked built-in blocks as masked subsystems.
%
% Library.
%   libinfo          - Get library information for a system.
%
% Diagnostics.
%   sllastdiagnostic - Last diagnostic array.
%   sllasterror      - Last error array.
%   sllastwarning    - Last warning array.
%   sldiagnostics    - Get block count and compile stats for a model.
%
% Hardcopy and printing.
%   frameedit        - Edit print frames for annotated model printouts.
%   print            - Print graph or Simulink system; or save graph to M-file.
%   printopt         - Printer defaults.
%   orient           - Set paper orientation.
%
% See also BLOCKS and SIMDEMOS.

% The functions listed below this point are utility routines that are
% used by the above functions. They are NOT ordinarily called directly
% by the user.
%
% Conversion functions.
%   dtf2ss           - Discrete transfer function to discrete state-space.
%
% Miscellaneous.
%   plotsim          - Utility called by integrators to plot graphs.
%   simver           - Specify Simulink version in which model is saved.
%   trimfun          - Utility used by TRIM.
%   simcnstr         - Utility used by TRIM.
%   foptions         - Utility used by TRIM and SIMCNSTR.
%   autoline         - Connect two blocks using autorouting.
%   simsizes         - Utility used by S-functions to set their sizes vector.
%   setsysloc        - Set system location
%
% Browser.
%   simbrowse        - Simulink Browser (unix only).
%
% Printing dialog.
%   simprintdlg      - Simulink Printing Dialog.
%   simprintlog      - Simulink print log.
%
% Print Frames.
%   printframe       - Creates and fills print frame files.

% Copyright 1990-2004 The MathWorks, Inc.
% Generated from Contents.m_template revision 1.85.4.1 $Date: 2003/12/31 19:52:33 $
