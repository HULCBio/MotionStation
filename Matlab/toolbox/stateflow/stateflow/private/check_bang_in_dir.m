function bangWorksInDir = check_bang_in_dir(destDir)
%   BANGWORKSINDIR = CHECK_BANG_IN_DIR(TARGETDIR)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2004/04/15 00:56:12 $

% this function checks if the dos() command works in
% the specified directory or not
% needed to detect the win95 problem with long path names
prevDir = pwd;
cd(destDir);

%try to capture the output of the DOS command cd by using
%evalc. if it is empty then the bang command will not work
%
if(~isempty(evalc('dos(''cd'');')))
   bangWorksInDir = 1;
else
   bangWorksInDir = 0;
end

cd(prevDir);
