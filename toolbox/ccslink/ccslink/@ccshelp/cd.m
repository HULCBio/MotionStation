function resp = cd(cc,dirname)
%CD Changes the working directory used by Code Composer Studio(R).  
%   CD(CC,DIR) will change the working directory used by Code Composer
%   Studio to the directory passed by the string DIR.  The directory must
%   exist for the change to occur.  Note, relative directory names are
%   applied from the working directory of Code Composer.  
%
%   WD=CD(CC) returns the working directory used by Code Composer Studio.  
%
%   Note, this CC method only impacts the Code Composer Studio application
%   and does not effect any MATLAB paths or directories. Therefore this
%   method alters the default directory for just CC.OPEN and CC.LOAD.
%   Furthermore, the default directory can also be changed (manually) from
%   within Code Composer Studio. For example, loading a workspace file will
%   modify the default directory. 
%
%   Note: CC can be a single CCSDSP handle or vector of CCSDSP handles.
%
%   See also DIR, OPEN, LOAD

% Copyright 2004 The MathWorks, Inc.
