function open(cc,filename,filetype,timeout)
%OPEN Loads a file into the Code Composer Studio(R) IDE.
%   OPEN(CC,FILENAME,FILETYPE,TIMEOUT) loads the specified FILENAME.
%   This file may include a full path description or just the name 
%   of the file if it resides in the Code Composer Studio working
%   directory.  Use the CC.CD method to view and modify the Code 
%   Composer working directory.  The FILETYPE parameter can override 
%   the default file extension definition. The following FILETYPE 
%   options are supported by this parameter:
%
%   'Text'      - Text file
%   'Workspace' - Code Composer workspace files
%   'Program'   - Target program file (executable)
%   'Project'   - Code Composer project files
%      
%   TIMEOUT defines an upper limit on the period this routine will wait
%   for completion of the specified file load.  If this period is 
%   exceeded, the routine will return immediately with a timeout error.
%   The action (open) may still occur for insufficient TIMEOUT values.
%   A timeout does not undo the 'open', it simply suspends waiting for
%   a confirmation.
%
%   OPEN(CC,FILENAME,FILETYPE) same as above, except the timeout is
%   replaced by the default timeout parameter from the CC object.
%
%   OPEN(CC,FILENAME)     or
%   OPEN(CC,FILENAME,[])  or
%   OPEN(CC,FILENAME,[],TIMEOUT) - same as above, except the file type
%   is derived from the file extension associated with the specified 
%   FILENAME.  File extensions are interpreted as follows:
%
%   .wks - Code Composer workspace file
%   .out - Target program file (executable)
%   .pjt - Code Composer project file
%   (default) all other file extensions will be treated as text files.
%
%   Note, the program files (.out) and project files (.pjt) are always
%   directed to the target DSP processor referenced by the CC object.  
%   However, workspace files are actively coupled to a specific target
%   DSP.  Consequently, the CC.OPEN method will load a workspace file 
%   in the Target processor that was active during the creation of the 
%   workspace file, which may NOT be the DSP processor referenced
%   by the CC object. 
%
%   See also CD, DIR, LOAD.

% Copyright 2004 The MathWorks, Inc.
