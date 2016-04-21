function load(dsp,filename,timeout)
%LOAD transfers a program file or a GEL file to the target processor.
%   LOAD(CC,FILENAME,TIMEOUT) loads the specified FILENAME into
%   the DSP processor.  This file can include a full path, or just 
%   the name if it resides in the Code Composer Studio(R)(CCS) 
%   working directory.  Use the CD method to check or modify the 
%   working directory.  This method should only be used with program 
%   files which are created by a Code Composer Studio build.
%      
%   TIMEOUT defines an upper limit on the period this routine will wait
%   for completion of the specified load.  If this period is exceeded, 
%   the routine will return immediately with a timeout error.
%
%   LOAD(CC,FILETYPE) same as above, except the timeout is replaced
%   by the default timeout: cc.timeout
%
%   See also CD, DIR, OPEN

% Copyright 2004 The MathWorks, Inc.
