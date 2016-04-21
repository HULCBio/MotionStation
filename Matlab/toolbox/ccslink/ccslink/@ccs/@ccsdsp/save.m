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

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.3.4.3 $ $Date: 2004/04/01 16:02:50 $

error(nargchk(3,3,nargin));
p_errorif_ccarray(cc);

if ~ishandle(cc),
    error('First Parameter must be a CCSDSP Handle');
end

%if ~isempty(filename) ,
%    error('The only supported FILENAME option is [], which saves all files');
%end

if ~isempty(filename) & ~strcmpi(filename,'all'),
    try 
       filename = cc.fileparamparser(filename);
    catch
         % Try anyway
    end
end

if strcmpi(filetype,'project'),
    callSwitchyard(cc.ccsversion,[47,cc.boardnum,cc.procnum,0,0],filename);
elseif strcmpi(filetype,'text'),
    callSwitchyard(cc.ccsversion,[48,cc.boardnum,cc.procnum,0,0],filename);
else
    error('The only supported FILETYPE options are ''project'' and ''text''');
end
% [EOF] save.m
