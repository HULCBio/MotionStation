function close(cc,filename,filetype)
%CLOSE  Close file(s) in Code Composer Studio(R)
%   CLOSE(CC,FILENAME,FILETYPE) closes the specified file
%   in Code Composer.  FILETYPE defines the type of file
%   to close. FILENAME must match the name of the file that
%   is to be closed.  If the FILENAME is parameter is 
%   specified as 'all', every open file of the defined type
%   is closed.  A null filename input (i.e. []) will close the
%   currently active (or in focus) file.
%
%   CLOSE(CC,'all','project')  - Closes all project files
%   CLOSE(CC,'my.pjt','project') - Closes the project: my.pjt
%   CLOSE(CC,[],'project')  - Closes the active project
%
%   CLOSE(CC,'all','text')  - Close all text files.
%   CLOSE(CC,'text.cpp','text') - Closes the text file: text.cpp
%   CLOSE(CC,[],'text')  - Closes the active project
%
%   Note - by default, CLOSE does not save the file before
%   closing it.  Thus, any changes since the save operation 
%   will be lost.  Use SAVE to ensure changes are preserved.
%
%   See also ADD, OPEN, CD, SAVE. 

% Copyright 2004 The MathWorks, Inc.
