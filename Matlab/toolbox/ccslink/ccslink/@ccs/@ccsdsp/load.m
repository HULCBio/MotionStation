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

%  Copyright 2000-2003 The MathWorks, Inc.
%  $Revision: 1.5.4.3 $  $Date: 2004/04/08 20:45:51 $

error(nargchk(2,3,nargin));
p_errorif_ccarray(dsp);

if nargin==3,
    if isGel(filename)
        open(dsp,filename,'loadgel',timeout);
    else
        open(dsp,filename,'program',timeout);
    end
else
    if isGel(filename)
        open(dsp,filename,'loadgel');
    else
        open(dsp,filename,'program');
    end
end

%----------------------------------------
function resp = isGel(filename)
[fpath,fname,fext] = fileparts(filename);
if strcmpi(fext,'.gel')
    resp = 1;
else
    resp = 0;
end

% [EOF] load.m