function save(cc,filename,filetype)
%SAVE  Saves file(s) in Code Composer Studio(R)
%   SAVE(CC,FILENAME,FILETYPE) saves the specified file
%   in Code Composer.  FILETYPE defines the type of file
%   to be saved. FILENAME must match the name of the file that
%   is to save.  If the FILENAME is parameter is specified
%   as 'all', every open file of the defined type is saved.
%   A null filename input (i.e. []) will save the
%   currently active (or in focus) file.
%
%   SAVE(CC,'all','project')  - Saves all project files
%   SAVE(CC,'my.pjt','project') - Saves the project: my.pjt
%   SAVE(CC,[],'project')  - Saves the active project
%
%   SAVE(CC,'all','text')  - Save all text files.
%   SAVE(CC,'text.cpp','text') - Saves the specified text file: text.cpp
%   SAVE(CC,[],'text')  - Save the active (in focus) text files.
%
%   See also ADD, OPEN, CD, CLOSE. 

% Copyright 2004 The MathWorks, Inc.
