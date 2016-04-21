% Commands for creating and debugging code.
% MATLAB Version 7.0 (R14) 05-May-2004 
%
% Writing and managing M-files.
%   edit                   - Edit M-file.
%   notebook               - Open an m-book in Microsoft Word (Windows only).
%   mlint                  - Display inconsistencies and suspicious constructs in M-files.
% 
% Directory tools
%   contentsrpt            - Audit the Contents.m for the given directory
%   coveragerpt            - Scan a directory for profiler line coverage.
%   deprpt                 - Scan a file or directory for dependencies.
%   diffrpt                - Visual directory browser
%   dofixrpt               - Scan a file or directory for all TODO, FIXME, or NOTE messages.
%   helprpt                - Scan a file or directory for help.
%   mlintrpt               - Scan a file or directory for all M-Lint messages.
%   standardrpt            - Visual directory browser
%
% Profiling M-files.
%   profile                - Profile function execution time.
%   profview               - Display HTML profiler interface.
%   profsave               - Save a static version of the HTML profile report
%   profreport             - Generate profile report.
%   profviewgateway        - Profiler HTML gateway function.
%   opentoline             - Open to specified line in function file in the editor.
%   stripanchors           - Remove anchors that evaluate MATLAB code from Profiler HTML.
%
% Debugging M-files.
%   debug                  - Debugging commands.
%   dbstop                 - Set breakpoint.
%   dbclear                - Remove breakpoint.
%   dbcont                 - Continue execution.
%   dbdown                 - Change local workspace context.
%   dbstack                - Display function call stack.
%   dbstatus               - List all breakpoints.
%   dbstep                 - Execute one or more lines.
%   dbtype                 - List M-file with line numbers.
%   dbup                   - Change local workspace context.
%   dbquit                 - Quit debug mode.
%   dbmex                  - Debug MEX-files (UNIX only).
%
% Managing, watching, and editing variables.
%   openvar                - Open a workspace variable for graphical editing.
%   workspace              - View the contents of a workspace.
%
% Managing the file system and search path.
%   filebrowser            - Open the Current Directory browser or bring it to the front.
%   pathtool               - View, modify, and save the MATLAB search path.

% Command Window and Command History window.
%   commandwindow          - Open the Command Window or bring it to the front.
%   commandhistory         - Open the Command History window or bring it to the front.

% GUI Utilities.
%   datatipinfo            - Produce a short description of a variable.
%   editpath               - Modify the search path.
%   mdbstatus              - dbstatus for the Editor/Debugger
%   mdbfileonpath          - Helper function for the Editor/Debugger
%   mdbpublish             - Helper function for the MATLAB Editor/Debugger that calls 
%   workspacefunc          - Support function for Workspace browser component.
%   notebookCaptureFigures - 
%   notebookCompareFigures - Return 0 if no figures have changed; otherwise return 1
%
% Directory tools helper files
%   diff2asv               - Compare file to autosaved version if it exists
%   diffcode               - Global alignment algorithm applied to file diffs
%   fixcontents            - Helper function for CONTENTSRPT
%   fixhelp                - Helper function for HELPRPT
%   fixquote               - Double up any single quotes appearing in a directory name
%   getcallinfo            - Returns called functions and their initial calling lines
%   auditcontents          - Audit the Contents.m for the given directory
%   code2html              - Prepare MATLAB code for display in HTML
%   visdiff                - Compare similarity of two entries
%   visdir                 - Directory reporting HTML gateway function.
%   visdirgateway          - Directory reporting HTML gateway function.
%   makecontentsfile       - Make a new Contents.m file.
%   mfiletemplate          - Template for new M-files
%   newfun                 - Create a new function given the filename and description
%   deleteconfirm          - Confirm the deletion of a file with a dialog box
%
% Publishing helper files
%   publish                - Run a script and save the results.
%   grabcode               - Pull M-code from MATLAB-generated HTML demo files.
%   slide2mx               - Convert a MATLAB style slideshow to MX format.
%   slide2script           - converts playshow-format demos to script-format.
%   snapshot               - Run the file and save resulting picture.
%   takepicture            - Run file, take snapshot, save image
%   all_m_to_html          - Converts all new or updated m-file demos to HTML.
%   m2struct               - Break M-code into cells.
%
% Other files
%   uiimport               - Starts the GUI for importing data (Import Wizard).
%   arrayviewfunc          - Support function for Array Editor component
%   initdesktoputils       - Initialize the MATLAB path for the desktop and desktop tools.
%   makemcode              - Generates readable m-code function based on input object(s)

% Obsolete functions.
%   mexdebug               - Debug MEX-files.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   Generated from Contents.m_template revision 1.1.6.4  $Date: 2003/12/24 19:11:20 $
