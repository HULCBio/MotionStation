function notebook(fileName, wordVer, wordLoc, templateLoc)
%NOTEBOOK Open an m-book in Microsoft Word (Windows only).
%   NOTEBOOK, by itself, launches Microsoft Word and creates a new m-book
%   called "Document 1."
%
%   NOTEBOOK(FILENAME) launches Microsoft Word and opens the m-book
%   FILENAME. If FILENAME does not exist, it creates a new m-book called
%   FILENAME.
%
%   NOTEBOOK('-SETUP') runs an interactive setup function for the Notebook.
%   The user is prompted for the version of Microsoft Word and the
%   locations of several files.
%
%   NOTEBOOK('-SETUP', WORDVER, WORDLOC, TEMPLATELOC) sets up the
%   Notebook using the specified information.  WORDVER is the version
%   of Microsoft Word (one of '97' or '2000' or '2002'), WORDLOC is the directory
%   containing winword.exe, and TEMPLATELOC is a Microsoft Word template
%   directory.
%
%   Examples:
%      notebook
%      notebook c:\documents\mymbook.doc
%      notebook -setup
%
%      For the case in which Microsoft Word 97 (winword.exe) resides in the
%      C:\Program Files\Microsoft Office 97\Office
%      directory, and the Microsoft Word templates reside in the
%      C:\Program Files\Microsoft Office 97\Templates directory:
%
%      wordver = '97';
%      wordloc = 'C:\Program Files\Microsoft Office 97\Office';
%      templateloc = 'C:\Program Files\Microsoft Office 97\Templates';
%      notebook('-setup', wordver, wordloc, templateloc)

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $

% Only want to instantiate one (private) matlab server, so lock this
% m-file and use a persistent variable to store the server handle
persistent hAppMatlab
mlock  % insure that the persistent variable remains

% Determine how many input arguments were passed in, and act accordingly.
switch (nargin)
   case(0)
      % Create a new m-book
      % First, get the information from matlab.ini, and verify that it is correct.
      [wordPath, wordTempPath] = getAndVerifyNotebookProfl;
      % Then, create the blank m-book
      if ~strcmp(wordPath, '')
         % Make sure there is a MATLAB automation server is running
         hAppMatlab = startMatlabAutomationServer(hAppMatlab);
         % Start Word and bring up an empty notebook
         createNewNotebook(wordTempPath)
      end
   case(1)
      % Two options:
      % The user wants of run an existing m-book, or wants to go into
      % interactive setup mode.
      if ~strcmp(lower(fileName), '-setup')
         % First, get the information from matlab.ini, and verify that it is correct.
         if ~exist(fileName)
            error(sprintf('The specified notebook, ''%s'' , does not exist.', fileName));
         end
         [wordPath, wordTempPath] = getAndVerifyNotebookProfl;

         % Make sure there is a MATLAB automation server is running
         hAppMatlab = startMatlabAutomationServer(hAppMatlab);

         % Then, open the specified file.
         if ~strcmp(wordPath, '')
            dos(['"' wordPath '\winword.exe" "' fileName '"&']);
         end
      else
         % Call notebookSetup with arguments, invoking it in interactive mode.
         notebookSetup
      end
   case(2)
      % Invalid syntax
      error(sprintf('Invalid syntax for %s.  See HELP %s',mfilename, upper(mfilename)));
   case(3)
      % Invalid syntax
      error(sprintf('Invalid syntax for %s.  See HELP %s',mfilename, upper(mfilename)));
   case(4)
      % The user is attempting to set up Notebook non-interactively.
      % First, verify that the arguments are OK.
      if ~(strcmpi(fileName, '-setup') & isstr(wordLoc) & isstr(templateLoc))
         error(sprintf('Invalid syntax for %s.  See HELP %s',mfilename, upper(mfilename)));
      end
      if ~(strcmp(wordVer, '97') | strcmp(wordVer, '2000') | strcmp(wordVer, '2002'))
         error(['Invalid version of Microsoft Word specified.  Must be one of ',...
            '''97'' or ''2000'' or ''2002''']);
      end
      % Call notebookSetup with arguments, invoking it in non-interactive mode.
      notebookSetup(wordVer, wordLoc, templateLoc);
      % Case > 4 will throw errors due to too many arguments.
end

%--------------------------------
function [wordPath, wordTempPath] = getAndVerifyNotebookProfl
% Get the relevant information from matlab.ini, and insofar as possible,
% validate it.  Only called if we're starting a notebook, not if we're
% in setup mode.

% get Word's startup path
wordPath = getprofl('Notebook Settings','Word path',...
   'c:\msoffice\winword', 'matlab.ini');

% get Word's template path
wordTempPath = getprofl('Notebook Settings','Word dot path',...
   'c:\msoffice\template','matlab.ini');

% Verify that the specified files exist.  If not, prompt to run setup
if ~exist(fullfile(wordPath, 'winword.exe')) | ...
      ~exist(fullfile(wordTempPath, 'm-book.dot'))
   answer = questdlg(['Notebook has not been configured.' 10 'Do you want to configure it now?'], 'Notebook');
   if strcmp(answer, xlate('Yes'))
      notebookSetup
      wordPath = getprofl('Notebook Settings','Word path',...
         'c:\msoffice\winword', 'matlab.ini');
      wordTempPath = getprofl('Notebook Settings','Word dot path',...
         'c:\msoffice\template','matlab.ini');
      % Handle case where user exits setup
      if ~exist(fullfile(wordPath, 'winword.exe')) | ...
            ~exist(fullfile(wordTempPath, 'm-book.dot'))
         wordPath = '';
      end;
   else
      wordPath = '';
   end
end

%--------------------------------
function notebookSetup(wordVer, wordLoc, templateLoc)
% Master function for Notebook setup

% Get data that we can extract without any user interaction.
windir = getenv('windir');
matlab_path = '';
if exist(fullfile(matlabroot, 'bin', 'win32', 'matlab.exe'))
   matlab_path = fullfile(matlabroot, 'bin', 'win32');
else
   ;
end
% If we are in interactive mode, get wordVer, wordLoc, and templateLoc
% If the user exercises a Cancel anywhere along the way, stop.
if nargin == 0
   disp([10 'Welcome to the utility for setting up the MATLAB Notebook']);
   disp(['for interfacing MATLAB to Microsoft Word' 10]);
   wordVer = getWordVer;
   if isnumeric(wordVer)
      return;
   end
   wordLoc = getWordLoc(wordVer);
   if isnumeric(wordLoc)
      return;
   end
   % To make the second uigetfile pop up in the directory that the user
   % specified in the first uigetfile, we cd there, perform the second
   % uigefile, and cd back.
   % First, cache away the cwd.
   cwd = pwd;
   % cd to the directory specified in the first uigetfile
   cd(wordLoc);
   templateLoc = getTemplateLoc(wordVer);
   % Now, return to where we started from
   cd(cwd);
   % Proceed
   if isnumeric(templateLoc)
      return;
   end
end
% Cannonicalize wordLoc, and check for existence of winword.exe.
% If it doesn't exist, inform the user that the setup is going
% poorly, and exit.
wordLoc(wordLoc == '/') = '\';
if wordLoc(end) == '\'
   wordLoc = wordLoc(1:end-1);
end
if ~exist(fullfile(wordLoc, 'winword.exe'))
   error(['Incorrect location specified for winword.exe.  Please run ', ...
      'notebook -setup again.']);
end
% Cannonicalize templateLoc.
templateLoc(templateLoc == '/') = '\';
if templateLoc(end) == '\'
   templateLoc = templateLoc(1:end-1);
end

% Make sure that neither of the locations that the user specified are UNC
% paths.  getprofl won't be able to handle that.
if strcmp(wordLoc(1:2), '\\') | strcmp(templateLoc(1:2), '\\')
   error([sprintf('Microsoft Word and the template directory must be on mounted drives.  '), 10,...
      sprintf('Their locations must not be specified by UNC paths.')]);
end

% Create the new M-Book template, and save changes to the matlab.ini file.
copyMBook(templateLoc);
saveSettings(wordLoc, templateLoc, windir, matlab_path);

%--------------------------------
function wordVer = getWordVer
% Interactive query for version of Word, called from interactive setup mode.
% Keep asking until we get a valid response.

repeatQuery = 1;
while(repeatQuery)
   repeatQuery = 0;
   disp('Choose your version of Microsoft Word:');
   disp('[1] Microsoft Word 97');
   disp('[2] Microsoft Word 2000');
   disp('[3] Microsoft Word 2002 (XP)');
   disp(['[4] Exit, making no changes' 10]);
   wordVerNum = input(sprintf('Microsoft Word Version: '));
   switch(wordVerNum)
      case(1)
         wordVer = '97';
      case(2)
         wordVer = '2000';
      case(3)
         wordVer = '2002';
      case(4)
         wordVer = 0;
         return;
      otherwise
         repeatQuery = 1;
         disp([10 sprintf('Invalid selection') 10]);
   end
end

%--------------------------------
function wordLoc = getWordLoc(wordVer)
% Try to automatically locate the location of winword.exe or
% Interactively query the user for the location of winword.exe from interactive
% setup mode.

queryfailed = 0;
missingfile = 0;

try
   % directory containing winword.exe can be obtained from the following registry query for all versions of Word
   appexepath = winqueryreg('HKEY_LOCAL_MACHINE','SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\winword.exe','Path');
catch
   queryfailed = 1;
end

if ~queryfailed
   if exist(fullfile(appexepath,'winword.exe'))
      wordLoc = appexepath;
   else
      missingfile = 1;
   end
end

if queryfailed | missingfile
   disp(sprintf('Unable to automatically locate winword.exe.\n'));

   disp('You will be presented with a dialog box.  Please use it to select');
   sprintf('your copy of the Microsoft Word %s executable (winword.exe).', wordVer);
   disp('Press any key to continue...');
   pause
   [x, wordLoc] = uigetfile('winword.exe', ...
      sprintf('Select your Microsoft Word %s executable (winword.exe)', wordVer));
end

%--------------------------------
function templateLoc = getTemplateLoc(wordVer)
% Try to automatically locate the location of normal.dot or
% Interactively query the user for the location of a template directory from
% interactive setup mode.

queryfailed = 0;
missingfile = 0;

% use winqueryreg to query the Windows registry
switch(wordVer)
   case '97'
      try
         appdatapath = winqueryreg('HKEY_CURRENT_USER','SOFTWARE\Microsoft\Office\8.0\Common\FileNew\LocalTemplates','');
      catch
         queryfailed = 1;
      end
   otherwise
      try
         appdatapath = winqueryreg('HKEY_CURRENT_USER','SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','AppData');
      catch
         queryfailed = 1;
      end
end

if ~queryfailed
   templatepath = [appdatapath '\Microsoft\Templates'];
   if strcmpi(wordVer,'97')
      templatepath = appdatapath;
   end
   if exist(fullfile(templatepath,'Normal.dot'))
      templateLoc = templatepath;
   else
      missingfile = 1;
   end
end

if queryfailed | missingfile
   disp(sprintf('Unable to automatically locate Normal.dot. \n'));

   disp('You will be presented with a dialog box.  Please use it to');
   disp('select the normal.dot file in one of your Microsoft Word template directories.');
   disp('Press any key to continue...');
   pause
   [x, templateLoc] = uigetfile('*.dot', ...
      [sprintf('Select a Microsoft Word template file')]);
end

%--------------------------------
function copyMBook(templateLoc)
% Copy the appropriate m-book into the template directory while in
% setup mode.

% Decide which version to copy.
sourceFile = fullfile(matlabroot, 'notebook', 'pc', 'm-book.dot');

% If the source file doesn't exist, we need to have the user
% re-install it to the HD.
if ~exist(sourceFile)
   error(sprintf('%s does not exist.  Please re-install this file by re-installing MATLAB.',sourceFile));
end
destFile = fullfile(templateLoc, 'm-book.dot');

% If destFile already exists, attempt to delete it.
if exist(destFile)
   origDir = pwd;
   cd(tempdir);
   x = dos(['attrib -R "' destFile '"']);
   cd(origDir);
   delete(destFile)
   if exist(destFile)
      error(sprintf(...
         'Could not delete %s for replacement. \nYou should delete it and run notebook -setup again.',...
         destFile));
   end
end
% Copy the surce file to the template directory as m-book.dot
copyfile(sourceFile, destFile);

%--------------------------------
function saveSettings(wordLoc, templateLoc, windir, matlab_path)
% Make changes to matlab.ini to reflect the new state of things while in setup mode.

% Create a reference to the user's matlab.ini file
matlabini = fullfile(windir, 'matlab.ini');

% Open the existing matlab.ini file, read it, and close it.
fidOld = fopen(matlabini, 'rt');
contentsOld = fscanf(fidOld, '%c');
fclose(fidOld);
% We want to create a version of matlab.ini without the [Notebook Settings]
% key.  There are three cases to consider: [1] a key already exists, and
% there are keys following it that must be preserved.  [2] A key already
% exists, and it is the final key.  [3] There is no [Notebook Settings]
% key in the existing file.

% Does the old file contain a [Notebook Settings] section?
MSStartLoc = findstr(contentsOld, '[Notebook Settings]');
if ~isempty(MSStartLoc)
   % There was an old key.  Are there any keys after it?
   nextKey = findstr(contentsOld(MSStartLoc+1:end), '[');
   if ~isempty(nextKey)
      % There are further keys.  Where do they start?
      nextKeyStart = nextKey(1) + MSStartLoc;
      % Create the contents of the new file, by including the old contents
      % up to the [Notebook Settings] key and all keys that follow
      % [Notebook Settings].  This leaves us with the contents of the
      % old file, minus the [Notebook Settings] key.
      contentsNew = [contentsOld(1:MSStartLoc-1), ...
         contentsOld(nextKeyStart:end)];
   else
      % There was a [Notebook Settings] key, and it was the last key in the
      % file.  This means that we can simply truncate the contents of
      % the old file to remove this key.
      contentsNew = contentsOld(1:MSStartLoc-1);
   end
else
   % There was no old copy of the [Notebook Settings] key, so we don't have
   % to bother to strip it out.
   contentsNew = contentsOld;
end

% Attempt to delete matlab.ini
warnState = warning;
warning('off','all');
origDir = pwd;
cd(tempdir);
x = dos(['attrib -R "' matlabini '"']);
cd(origDir);
delete(matlabini);
warning(warnState);
% Did we suceed?  If not, inform the user and exit.
if exist(matlabini)
   error([sprintf('Could not make necessary changes to %s.\n', matlabini),...
      sprintf('Make sure that you have permission to change the file,'),...
      sprintf('\nand run notebook -setup again.')]);
else
   % If we successfully deleted the old file, create a new, empty version
   % of the file.  Print the content from the old file that we want to retain,
   % and add in the (new?) [Notebook Settings] key.
   fidNew = fopen(matlabini, 'wt+');
   fprintf(fidNew, '%c', contentsNew);
   % In the process of stripping the keys out, we may have stripped out the
   % final carridge return.  If so, replace it.
   if contentsNew(end) ~= char(10)
      fprintf(fidNew, '\n');
   end
   fprintf(fidNew, '%c', '[Notebook Settings]');
   fprintf(fidNew, '\n');
   fprintf(fidNew, '%c', ['Word path=' wordLoc]);
   fprintf(fidNew, '\n');
   fprintf(fidNew, '%c', ['Word dot path=' templateLoc]);
   fprintf(fidNew, '\n');
   fprintf(fidNew, '%c', ['matlab-path=' matlab_path]);
   fprintf(fidNew, '\n');
   fclose(fidNew);
   disp([10 'Notebook setup is complete.' 10]);
end

%--------------------------------
function hAppMatlab = startMatlabAutomationServer(hAppMatlab)
% Start a MATLAB automation server
if (isempty(hAppMatlab))
   warnState = warning('query', 'backtrace');
   warning('backtrace', 'off');
   try
      feature('AutomationServer',1);
      warning('Notebook:Automation', 'MATLAB is now an automation server');
      hAppMatlab = actxserver('matlab.autoserver');
   catch
      hAppMatlab = actxserver('matlab.application');
   end
   warning(warnState);
end

%--------------------------------
function createNewNotebook(varargin)
% createNewNotebook (wordTempPath) creates a new, unnamed m-book
% createNewNotebook (wordTempPath, docName) creates a new m-book named
% docName.  wordTempPath is the path to m-book.dot.

error(nargchk(1,2,nargin))
wordTempPath = varargin{1};
% start a new copy of word and use m-book.dot as the template
hApp = actxserver('word.application');
set(hApp, 'visible', 1);
templateName = ['' wordTempPath '\m-book.dot' ''];
hApp.Documents.Add(templateName);
if nargin == 2
   % start a new copy of word and use m-book.dot as the template.  Name the new m-book.
   fileName = varargin{2};
   invoke(hApp.Documents.Application.ActiveDocument, 'SaveAs', fileName);
end
