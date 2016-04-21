function ccsaddsource(boardnum,procnum,srcfile)
%CCSADDSOURCE - Loads a source file in to Code Composer Studio (CCS)
%  CCSADDSOURCE(BDN,PCN,SRC) takes the file SRC and loads it into
%  the project space of the DSP.  Since Code Composer can support
%  multiple DSPs, the desired DSP is specified by the BDN and PCN
%  parameters.  These are the board number and processor number, 
%  respectively, of the desired DSP target.  The SRC file is NOT 
%  added to the active project. Instead it is simply loaded into 
%  the CCS application.  SRC must be a complete path definition or
%  reside on the MATLAB path to be used.  Also it must exist or an
%  error will be generated. 
%
%  See also CCSDSP, FDATOOL

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/04/06 01:05:01 $

error(nargchk(3,3,nargin));

if isempty(fileparts(srcfile)),
    % No path, try to find it !
    fsrcfile = which(srcfile);
else
    fsrcfile = srcfile;
end

if isempty(fsrcfile) | (exist(fsrcfile,'file') ~= 2),
     error(['Source file: ' srcfile 'Not found!']);
end

cc = ccsdsp('boardnum',boardnum,'procnum',procnum);
cc.visible(1);
cc.open(srcfile,'text');
clear cc;