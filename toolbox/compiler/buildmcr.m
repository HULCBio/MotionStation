function [mcr_zipfile,mcrlist] = buildmcr(mcr_zipfile_dirname, ...
					  mcr_zipfile_filename, ...
                                          use_tmw_b_file, ...
                                          tmw_b_dirpath)
%BUILDMCR	builds a ZIP file of the files required for the
%   MCR.
%
%   MCR_ZIPFILE = BUILDMCR returns the path of the generated
%   ZIP file in MCR_ZIPFILE. Here MCR_ZIPFILE is:
%
%   <matlabroot>/toolbox/compiler/deploy/<arch>/MCRInstaller.zip 
%
%   MCR_ZIPFILE = BUILDMCR(MCR_ZIPFILE_DIRNAME) returns the
%   ZIP file in:
%
%       <MCR_ZIPFILE_DIRNAME>/MCRInstaller.zip
%
%   The directory is created as needed.
%
%   MCR_ZIPFILE = BUILDMCR(MCR_ZIPFILE_DIRNAME,MCR_ZIPFILE_FILENAME)
%   returns the ZIP file in:
%
%       <MCR_ZIPFILE_DIRNAME>/<MCR_ZIPFILE_FILENAME>
%
%   The directory is created as needed.
%
%   [MCR_ZIPFILE,MCRLIST] = BUILDMCR(...) returns the list of
%   the files in the ZIP file in MCRLIST. It is a cell array of
%   paths each relative to the matlabroot.
%
%   If the ZIP file already exists nothing is done and a warning
%   is produced.
%   
%   The required list is constructed from the installer files and
%   pruned appropriately.
%
%   Technically it is the transitive closure of dependencies for the
%   'mclmcr' shared library.
%
%   Example(s),
%
%     buildmcr;
%
%         builds 'MCRInstaller.zip' in the default directory.
%         returns nothing (unless an error or not the first time).
%
%     mcr_zipfile = buildmcr;
%
%         builds 'MCRInstaller.zip' in the default directory.
%         returns mcr_zipfile = ...
%             fullfile(matlabroot,'toolbox','compiler',
%		       'deploy',ARCH,'MCRInstaller.zip');
%
%     mcr_zipfile = buildmcr('.');
%
%         builds 'MCRInstaller.zip' in the current directory.
%         returns mcr_zipfile = fullfile(pwd,'MCRInstaller.zip')
%
%     mcr_zipfile = buildmcr('.','my.zip');
%
%         builds 'my.zip' in the current directory.
%         returns mcr_zipfile = fullfile(pwd,'my.zip')

%   Rajesh Godbole, Martin Knapp-Cordes, Peter Webb
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.15 $ $Date: 2004/05/11 03:17:25 $
%---------------------------------------------------------------------

global mcrversion;

mcr_zipfile = '';

% Each release of the MCR has a unique version number. We use this version
% number to allow multiple versions of the MCR to co-exist on the same 
% machine. However, in order to do so, certain files that are ordinarily
% stored in bin/<arch> need to be moved into runtime/<arch>. 
%
% The mcrversion global constant contains information to help manage this
% process.

% Version number for THIS VERSION of the MCR.
mcrversion.major = '7';
mcrversion.minor = '0';

% This is the string prepended to the directory name where the MCR will
% be installed. All the paths in the ZIP file will start with this string.
mcrversion.string = ['v' mcrversion.major mcrversion.minor];

% Files that contain these patterns are moved from bin/<arch> to 
% runtime/<arch>.
mcrversion.unix = [ mcrversion.major '.' mcrversion.minor ];
mcrversion.pc = [ mcrversion.major mcrversion.minor ];

% Files that match certain other patterns (architecture specific) need to 
% be moved as well. This is platform specific.

% On Windows, move the Microsoft DLLs and non-versioned COM DLLs from from 
% bin/win32 to runtime/win32.
mcrversion.patterns.win32 = {
    'bin/.*mfc.*\.dll' ...
    'bin/.*msvc.*\.dll' ...
    'bin/.*/mwcommgr.dll' ...
    'bin/.*/mwcomutil.dll' ...
 };

% Check the number of input arguments
arg_error = nargchk(0,4,nargin);
if ~isempty(arg_error)
   error('COMPILER:BUILDMCR:NumberOfInputArguments',arg_error);
end

if nargin == 0
  mcr_zipfile_dirname = '';
  mcr_zipfile_filename = '';
  use_tmw_b_file = 0;
  tmw_b_dirpath = '';
elseif nargin == 1
  mcr_zipfile_filename = '';
  use_tmw_b_file = 0;
  tmw_b_dirpath = '';
elseif nargin == 2
  use_tmw_b_file = 0;
  tmw_b_dirpath = '';
elseif nargin == 3
  tmw_b_dirpath = '';
end

if nargout == 2
  mcrlist = {};
end

% Environment info
RootDir = matlabroot;
if ispc
    Arch = 'win32';
else
    Arch = lower(computer);
end

% Get pathname of zipfile. An empty pathname means an error
% was thrown in the routine and we should quit.
%
mcr_zipfile = get_mcr_zipfile(Arch,mcr_zipfile_dirname, ...
			      mcr_zipfile_filename);
if isempty(mcr_zipfile)
  return
end

if exist(mcr_zipfile,'file')
  warning('COMPILER:BUILDMCR:AlreadyBuilt',...
            'Zip file already built. Delete first to rebuild.')
  return
end

% prune_list: common for all platforms
prune_list = {'demos/.*';
	      '.*/EmacsLink/.*';
	      '.*/sys/jaws/.*';
	      'jhelp/.*';
              'extern/examples/.*';
              'extern/include/.*';
              'extern/lib/.*';
              'help/.*';
              'notebook/.*';
              'sys/lcc/.*';
              'sys/namespace/.*';
              'toolbox/.*';
              '.*\.csf$'; 
              '.*\.exe$';
              '.*license.txt$';
             '.*/ja/.*';
	     'netbeans.jar';
             'java/jar/test/.*';
             'jhelp/.*';
             'bin/win32/.*opts.*';
             'java/extern/emacslink.*';
             'extern/src/.*';
             '.*\.tlb.*';
	     '.*\.phl';
             'bin/.*/.*qt-mt.*';
             'bin/.*/.*dastudio\..*';
             '.*\.hlp';
             '.*cmdwin.jar';
             '.*jhelp/.*';
             '.*/demo.lic$'};          
 
% prune_list on unix
prune_list_unix  = {'.*/MATLAB'; '1.0.1.0*';
                    'bin/mbuild*';
                    'bin/mex*'};

% prune_list on pc
% We are explicitly excluding the Java Access Bridge JAR files
% and DLLs, because we do not have a license to redistribute them.
prune_list_win32  = {'bin/win32/mex.*';
                     'bin/win32/mbuild.*';
                    '.*\.lnk$';
                    '.*/java/.*/win32/.*/access-bridge.jar';
                    '.*/java/.*/win32/.*/jaccess-1_4.jar';
		    'bin/win32/[JW].*AccessBridge.dll';
                    '^[a-zA-Z]:\\.*'; % to exclude all absolute
                                      % paths starting with drive
                                      % letter "C:\"
                    '^\\\\.*';        % to exclude all UNC paths
                    'bin/matlab.bat';
                    '.*matlab\..*'; % removes matlab.bat, .ico, .el. jdf, phl
                    '.*matlabaddin.*';
                    '.*matlabwizard.*'}; 




% additional_file_list common for all platforms
% The custom version of FigureMenuBar.fig and FigureToolBar.fig
% have been added explicitly to be distributed with the compiled
% application. 

additional_file_list = { ...
     'license.txt';
     fullfile('toolbox','compiler','deploy','MCRInstaller.txt'); 
     fullfile('toolbox','local', 'classloader.txt');
     fullfile('toolbox','local', 'classpath.txt');
     fullfile('toolbox','local', 'librarypath.txt');
     fullfile('toolbox','compiler','deploy', 'FigureMenuBar.fig'); 
     fullfile( 'toolbox','compiler','deploy',  'FigureToolBar.fig') ...
};

% Additional files on Windows
additional_file_list_win32 = { ...
    'bin/win32/mwregsvr.exe' ...
};

if (ispc)
    % The b-file uses / on all platforms, while the productdata.dat file 
    % uses \ on the PC.
    if (use_tmw_b_file == 0)
        prune_list = strrep(prune_list,'/','\\');
 	prune_list_win32 = strrep(prune_list_win32,'/','\\');
        mcrversion.patterns.win32 = ...
              strrep(mcrversion.patterns.win32, '/','\\');
	additional_file_list = strrep(additional_file_list,'/','\\');
	additional_file_list_win32 =  ...
              strrep(additional_file_list_win32,'/','\\');
    else
 	prune_list_win32 = strrep(prune_list_win32,'\\','/');
    end       
end

disp(['Building MCR installer file list for ' Arch]);
disp('...Getting list of shared libraries and other binaries.');

switch (Arch)
    
    case 'win32'
        % Read from I/P file Mathworks: MATLABROOT/cdimages/pc/bfiles/matlab_b 
        %                    Customer:  MATLABROOT/uninstall/productdata 

	if (use_tmw_b_file == 0)
            % First extract MATLABROOT/uninstall/productdata.dat from 
            %               MATLABROOT/uninstall/productdata by doing unzip(productdata)

            % extract to temporary directory so that deployment can be done
            % out of a read-only MATLAB install

            tmpDir = tempdir;
            if ~exist(tmpDir)
               tmpDir=tempname;
                mkdir(tmpDir);
                tmpDirCreated = true;
            else
                tmpDirCreated = false;
            end
    
            unzip(fullfile(RootDir,'uninstall','productdata'), tmpDir);
            [file_list] = pc_matlab_pathlist(fullfile(tmpDir,'productdata.dat'));
            delete(fullfile(tmpDir, 'productdata.dat'));
            if tmpDirCreated
                rmdir(tmpDir);
            end

    	else % Use the TMW _b files

	    if (prod(size(tmw_b_dirpath)) > 0)
	        bfileRootDir = tmw_b_dirpath;
            else
	        bfileRootDir = fullfile(matlabroot, 'cdimages', 'pc', 'bfiles');
	    end
	
	    if (exist(bfileRootDir) ~= 7)
	         error(['MathWorks B-file location must be a directory ' ...
                       bfileRootDir ' is not a directory.']);
            end

	    % Need to read from MATLAB, Compiler, COM Builder and 
	    % Excel Builder
	    matlab_b_file = fullfile(bfileRootDir,'matlab_b');
	    compiler_b_file = fullfile(bfileRootDir,'compiler_b');
	    combuilder_b_file = fullfile(bfileRootDir,'combuilder_b');
	    excelbuilder_b_file = fullfile(bfileRootDir,'matlabxl_b');

	    str = sprintf('%s %s %s %s', read_all(matlab_b_file), ...
                                   read_all(compiler_b_file), ...
                                   read_all(combuilder_b_file), ...
                                   read_all(excelbuilder_b_file));

	    % Split the string at whitespaces to create the file list
	    file_list = strread(str, '%s');
        end

        file_list = prune_it(file_list,prune_list);      

        FileArray = [file_list; additional_file_list]; %column vector addition
        FileArray = prune_it(FileArray,prune_list_win32);      
        FileArray = [FileArray; additional_file_list_win32]; 

    otherwise % glnx86, sol2, hpux, mac
	bfileRootDir = matlabroot;

	if (use_tmw_b_file ~= 0)
	    bfilename = 'b';
	    if (~isempty(tmw_b_dirpath))
	        bfileRootDir = tmw_b_dirpath;
	    else
	        % In BaT, the B-files are right above the MATLABROOT
	        bfileRootDir = fullfile(matlabroot, '..');
            end
	    if (exist(bfileRootDir) ~= 7)
	        error(['MathWorks B-file location must be a directory ' bfileRootDir ' is not a directory.']);
            end
	else
	    bfilename = '.b';
        end

        % Read from I/P file MATLABROOT/cdimages/unix/update/pd/matlab/kernel/b
        [file_list1] = read_files(fullfile(bfileRootDir, ...
                                  'update/pd/matlab/kernel',bfilename)); 
        file_list1 = prune_it(file_list1, prune_list);
       
        % Read from I/P file 
        %   MATLABROOT/cdimages/unix/update/pd/matlab/kernel/<arch>/b
        [file_list2] = read_files(fullfile(bfileRootDir, ...
                                  'update/pd/matlab/kernel',Arch,bfilename));
        file_list2 = prune_it(file_list2, prune_list);
        
        % Read from I/P file MATLABROOT/cdimages/unix/update/pd/matlab/b
        [file_list3] = read_files(fullfile(bfileRootDir, ...
                                  'update/pd/matlab',bfilename)); 
        file_list3 = prune_it(file_list3, prune_list);
        
        % Read from I/P file MATLABROOT/cdimages/unix/update/pd/matlab/<arch>/b
        [file_list4] = read_files(fullfile(bfileRootDir, ...
                                  'update/pd/matlab',Arch,bfilename)); 
        file_list4 = prune_it(file_list4, prune_list);
    
        % Additional stuff needed for the compiler (mclmcr specific)
        % Read from I/P file 
        %    MATLABROOT/cdimages/unix/update/pd/toolbox/compiler/<arch>/b
        [file_list5] = read_files(fullfile(bfileRootDir, ...
                                  'update/pd/toolbox/compiler', ...
                                  Arch,bfilename)); 
        file_list5 = prune_it(file_list5, prune_list);

        % TODO: Decide if we need to add file_list6 and prune any of its
        % contents.
        % Read from I/P file 
        %   MATLABROOT/cdimages/unix/update/pd/toolbox/compiler/b
        %[file_list6] = read_files(fullfile(bfileRootDir, ...
        %                          'update/pd/toolbox/compiler',bfilename)); 
        %file_list6 = prune_it(file_list6, prune_list);

	% Concatenate the file lists together
        FileArray = [file_list1;  file_list2; file_list3; file_list4; ...
                     file_list5; additional_file_list]; %column vector addition
        FileArray = prune_it(FileArray,prune_list_unix);
end

try
  [runtimeFiles FileArray] = get_runtime_files(FileArray, Arch);
  tbx_files = get_tbx_files(mcr_zipfile, Arch);
  ctfzip(mcr_zipfile, FileArray, RootDir, tbx_files, runtimeFiles);
  FileArray = [FileArray ; { tbx_files.src }' ];
  if nargout == 2
    mcrlist = FileArray;
  end
catch
  err = lasterror;
  disp(sprintf('Building ZIP file failed.\n??? %s',err.message));
end

%==========================================================================
function [runtimeFiles, fileList] = get_runtime_files(fileList, Arch)
% GET_RUNTIME_FILES Move files from the bin into the runtime directory.
%  The runtime files are removed from the list, and returned in a 
%  separate list.
%
%  The version strings are different on the PC and UNIX. For the PC we're
%  looking for <anything>70.dll, while on UNIX we're looking for
%  <anything>.so.7.0.

global mcrversion;

    removeList = [];
    search_exp = '';
    runtimeFiles = struct([]);

    disp('...Moving files from bin/<ARCH> to runtime/<ARCH>.');

if ispc
    % Set up the regular expression for the PC
    search_exp = ['(.*' mcrversion.pc '\.dll)'];
else
    % Set up the regular expression for UNIX
    search_exp = ['(.*\.so\.' mcrversion.unix ')'];
end

% Add architecture specific patterns to the search expression
if (isfield(mcrversion.patterns, Arch) && ...
    ~isempty(mcrversion.patterns.(Arch)))

    for i=1:length(mcrversion.patterns.(Arch))
        search_exp = strcat(search_exp, '|(', ...
                            mcrversion.patterns.(Arch){i}, ')' );
    end

end

% Loop over the list of input files. For each match, remember the
% index and save the name of the file in the runtimeFiles list.
vfilecount = 0;
for i=1:length(fileList)
    if (regexp(fileList{i}, search_exp))

	vfilecount = vfilecount + 1;

	% Remember the index of this file in the file list, for later
	% removal.
        removeList(end+1) = i;

	% Get the parts of the file name.
        [path,base,ext] = fileparts(fileList{i});
	basename = [base ext];

	% Create the output structure. src is the full path to the file,
	% dest is the relative path for the file in the ZIP archive.

        runtimeFiles(end+1).src = fullfile(matlabroot, fileList{i});
        runtimeFiles(end).dest = ...
              fullfile(mcrversion.string, 'runtime', ...
                       Arch, basename);
    end
end

% Done searching and creating. Remove the runtime files from the file list.
if (~isempty(removeList))
    fileList(removeList) = [];
end

files = 'files';
if (vfilecount == 1)
    files = 'file';
end;

disp(['...Moved ' num2str(vfilecount) ' ' files '.']);

%==========================================================================
function str = read_all(b_file)
% READ_ALL Read a list of file names from a given text file.

    % Always return a string type
    str = '';

    % Open the file
    fid = fopen(b_file);
    if (fid < 0)
        error(['Cannot open file ' b_file]);
    end

    try
        % Skip the first line
        str = fgetl(fid);

        % Read in all the text, as one giant string. Lines will be
        % separated by spaces.
        str = fread(fid,Inf,'char=>char');
        fclose(fid);
    catch
        disp(lasterr);
        fclose(fid);
    end

%==========================================================================
function files = get_tbx_files(mcr_zipfile, Arch)

global mcrversion;

disp('...Getting list of files from toolbox/matlab.');

% Add the files from toolbox/matlab to the FileArray. The list of files to
% include is stored in toolbox/compiler/mcr/mcrlist.<arch>. The files are
% listed by relative path; convert the relative paths to full paths by adding
% MATLABROOT/toolbox/ to the front of each. This is a LONG list, 
% consisting of thousands of files.

% Read the architecture-specific (MEX files, mostly) files from the 
% architecture-specific file
archfiles = textread([matlabroot '/toolbox/compiler/mcr/mcrlist.' Arch], ...
                     '%s', 'delimiter', '\n', 'whitespace', '');

% Fullpath: prepend MATLABROOT/toolbox/matlab so that we grab these files
% from toolbox/matlab.
files=struct([]);
for i=1:prod(size(archfiles)) 

    % Compute the full path to the source file
    fullsrcpath = [matlabroot '/toolbox/matlab/' archfiles{i}];

    % Don't add the file to the list if it doesn't exist.
    if (exist(fullsrcpath) == 0), continue, end;

    files(end+1).src = fullsrcpath;
    files(end).dest = fullfile(mcrversion.string, 'toolbox', 'matlab', ...
                               archfiles{i});
end

% Read the list of common files from the common file list file
tbxfiles = textread([matlabroot '/toolbox/compiler/mcr/mcrlist.common'], ...
                     '%s', 'delimiter', '\n', 'whitespace', '');

% Fullpath: prepend MATLABROOT/toolbox/compiler/mcr/matlab so that we include
% the encrypted M-files.
for i=1:prod(size(tbxfiles))

    % Compute the full path to the source file
    fullsrcpath = [matlabroot '/toolbox/compiler/mcr/matlab/' tbxfiles{i}];

    % Don't add the file to the list if it doesn't exist.
    if (exist(fullsrcpath) == 0), continue, end;

    files(end+1).src = fullsrcpath;

    % Compute the relative path on the destination machine

    reldestpath = fullfile(mcrversion.string, 'toolbox', 'matlab', ...
                           tbxfiles{i});

    files(end).dest = reldestpath;

end

%==========================================================================
function file_list = prune_it(file_list,prune_regexp)

fprune_regexp = strcat(prune_regexp,'|'); 
fprune_regexp = [fprune_regexp{:}];
fprune_regexp = ['(' fprune_regexp(1:end-1) ')'];   
prune_list = regexp(file_list,fprune_regexp,'match');
prune_list = [prune_list{:}];
file_list = setdiff(file_list,prune_list);
file_list = reshape(file_list,length(file_list),1);
%--------------------------------------------------------------------------
if 0
prune_index = true(length(file_list),1); % true  (1)
for i=1:length(prune_list)
    match = strmatch(prune_list{i}, file_list); 
    if ~isempty(match)
       prune_index(match) = false;       % false (0) found a match
    end
end
file_list = file_list(prune_index);      % get rid of all with the 0
end


%==========================================================================
function pathlist = pc_matlab_pathlist(file)
%PC_MATLAB_PATHLIST	returns PATHLIST a cell array of paths
%   relative to MATLABROOT found in the productdata.dat file
%   on the PC only. The paths returned are associated only with
%   the MATLAB piece.
%
%   Location of file: $MATLAB/uninstall/productdata.dat
%
%   Algorithm:
%   1. Open file and read line by line until line starting with 'Files:'.
%   2. Find the line for the compiler to get the index.
%      Version:1.0
%      Products:
%      ...
%      33,MATLAB Compiler,4.0,Mon Sep 29 02:12:02 EDT 2003,DEMO,1
%   3. Read the rest of the file into memory as a string.
%   4. Use strread to read the file into path and index lists.
%   5. Return the paths with index set to 1.
%
%   Files:
%   toolbox\wavelet\wavelet\ja\meyer.m,65
%   ...
%---------------------------------------------------------------------

  pathlist = {};

  fid = fopen(file);
  if fid < 0
    error ('Cannot open file.');
  end
  n = 0;
  found_compiler = false;
  while 1
    tline = fgetl(fid);
    if ~isempty(strmatch('Files:',tline))
      break
    end
    n = n + 1;
    if n > 2 && ~found_compiler
      [number,name] = strread(tline,'%d%s%*[^\n]','delimiter',',');
      if strcmp(name,'MATLAB Compiler')
        compiler_number = number;
        found_compiler = true;
      end
    end
  end
  str = fread(fid,Inf,'char=>char');
  fclose(fid);
  [pathlist,index] = strread(str,'%s%d','delimiter',',');
  if found_compiler
    pathlist = pathlist(find(index == 1 | index == compiler_number));
  else
    pathlist = pathlist(find(index == 1));
  end
  return
%==========================================================================
function file_list = read_files(file) 
%READ_FILES	opens a .b file on UNIX and reads the file list that
%   starts on line 2 of the file. It returns the file list as a cell
%   array in FILE_LIST.

fid = fopen(file);
if fid < 0
    error (['Cannot open file: "' file '"']);
end
str = fread(fid,Inf,'char=>char');
fclose(fid);
[file_list] = strread(str,'%s%*[^\n]','headerlines',1);

%==========================================================================
% All the code that follows from here onwards is necessary as a 
% work around for bugs in R14Beta2.
% Once these bugs are fixed we do not need the following code   
%    
% 1) exist command does not work in R14Beta2.
%    exist(fullpath(foo,'.VERSION')) : does not work 
%    
%    however
%    
%    cd foo;
%    exist('VERSION') : works 
%    
% 2) .b files on unix
%    The .b files on unix install are not supposed to have directories. 
%    
%==========================================================================

function zip(zipFilename, files, rootDir, aliases)
%ZIP Create a zip file.
%   ZIP(ZIPFILE,FILES, ROOTDIR, ALIASES) creates a zip file with the name 
%   ZIPFILE from the list of files specified in FILES, a string or a cell 
%   array of strings.  Paths specified in FILES must be either relative to 
%   the current directory or absolute.  Directories recursively include 
%   all of their content. ALIASES is optional. If specified, it consists of 
%   a structure with two fields: SRC and DEST. SRC is the full path name to
%   a file. The contents of this file is copied into the ZIP file, with
%   the entry name as specified in DEST, thus effectively renaming SRC to
%   DEST when the contents of the ZIP file are extracted.
%
%   ZIP(ZIPFILE,FILES,ROOTDIR) allows the path for FILES to be specified
%   relative to ROOTDIR rather than the current directory. ROOTDIR processing
%   is not done on the files in aliases.
%
%   See also UNZIP.

% Matthew J. Simoneau, 15-Nov-2001
% Copyright 1984-2002 The MathWorks, Inc.
%
% Modified to add ALIASES by Peter Webb, Feb. 2004.
%

import java.io.*;
import java.util.zip.*;
import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

% Work around file problems in the UNIX file lists.
% the if isunix block can go away 
if isunix
    files = prune_duplicates(files,rootDir);
end

% Parse arguments.
error(nargchk(2,4,nargin))
if (nargin < 3)
    rootDir = pwd;
end

if ischar(files)
    files = {files};
end

% If no extension is given for output, add ".zip".
[null,null,zipFilenameExt]=fileparts(zipFilename);
if isempty(zipFilenameExt)
    zipFilename = [zipFilename '.zip'];
end

% Create a structure of the inputs.
inputs = [];
for i = 1:length(files)
    filename = files{i};
    if isAbsolute(filename)
        [path,base,ext] = fileparts(filename);
        inputs(i).path = path;
        inputs(i).file = [base ext];
    else
        inputs(i).path = rootDir;        
        inputs(i).file = filename;
    end
end

% Build up list of entries.
entries = [];
while ~isempty(inputs)
    % Pop the next entry off the stack.
    path = inputs(1).path;
    file = inputs(1).file;
    inputs(1) = [];

    filePath = fullfile(path,file);
%================================
% fprintf('%s %s\n',path,file);
%================================
    if ~isempty(find(file == '*'))
        dirContents = dir(filePath);
        listing = {dirContents.name};
        listing = setdiff(listing,{'.','..'});
        % Push all matches onto the stack.
        for i = 1:length(listing)
            inputs(end+1).path = path;
            inputs(end).file = fullfile(fileparts(file),listing{i});
        end        
    elseif exist2(filePath,'dir')
        dirContents = dir(filePath);
        listing = {dirContents.name};
        listing = setdiff(listing,{'.','..'});
        % Push directory contents onto the stack.
        for i = 1:length(listing)
            inputs(end+1).path = path;
            inputs(end).file = fullfile(file,listing{i});
        end
    elseif ~exist2(filePath,'file')
        error('File "%s" does not exist.',filePath);
    else
        entries(end+1).file = filePath;
        if ispc
            file = strrep(file,'\','/');
        end
        entries(end).entry = file;
    end
end

% If there is nothing to do, error.  There is no such thing as an "empty zip".
if isempty(entries)
    error('Nothing to zip.')
end

% Check for duplicate entry names.
allNames = {entries.entry};
[uniqueNames,i] = unique(allNames);
if length(uniqueNames) < length(entries)
    firstDup = allNames{min(setdiff(1:length(entries),i))};
    error('Tried to add two files as "%s" in zip.',firstDup);
end

% Open output stream.
try
    fileOutputStream = FileOutputStream(zipFilename);
catch
    error('Could not open "%s" for writing.',zipFilename);
end
zipOutputStream = ZipOutputStream(fileOutputStream);

% This InterruptibleStreamCopier is unsupported and may change without notice.
interruptibleStreamCopier = ...
    InterruptibleStreamCopier.getInterruptibleStreamCopier;

disp(['...Adding platform-specific binaries (' ...
      num2str(prod(size(entries))) ' files). Please wait.']);

% Add each entry to the zip.
for i = 1:length(entries)
    file = File(entries(i).file);
    fileInputStream = FileInputStream(file);
    zipEntry = ZipEntry(entries(i).entry);
    zipOutputStream.putNextEntry(zipEntry);
    interruptibleStreamCopier.copyStream(fileInputStream,zipOutputStream);
    fileInputStream.close;
    zipOutputStream.closeEntry;
end

disp(['...Adding toolbox/matlab content (' num2str(prod(size(aliases))) ...
      ' files). Please wait.']);

for i = 1:length(aliases)
    file = File(aliases(i).src);
    inputStream = FileInputStream(file);
    zipEntry = ZipEntry(aliases(i).dest);
    zipOutputStream.putNextEntry(zipEntry);
    interruptibleStreamCopier.copyStream(inputStream, zipOutputStream);
    inputStream.close;
    zipOutputStream.closeEntry;
end

%  Close streams.
zipOutputStream.close;
fileOutputStream.close;


%===============================================================================
function status = isAbsolute(file)
if ispc
    status = ~isempty(regexp(file,'^[a-zA-Z]*:\\')) || strncmp(file,'\\',2);
else
    status = strncmp(file,'/',1);
end

%===============================================================================
function state = exist2(file,type)
%EXIST2 is a workaround for EXIST for R14beta2.
%   There is a major bug (184108) in which exist does not work
%   with files that start with '.' and include a partial path.
%   If you are in the directory where the '.' file exists and give the
%   simple filename it works.

  state = exist(file,type);

%state = 0;
%[d,f,e] = fileparts(file);
%if isempty(f)

  % Starts with a . Move to that directory and run the command
  % Remove when gecko 184108 is fixed.
  %
%  oldpwd = pwd;
%  cd(d);
%  state = exist(e,type);
%  cd(oldpwd);
%else
%  state = exist(file,type);
%end

%===============================================================================
function pathlist = prune_duplicates(pathlist,rootdir)
%PRUNE_DPLICATES is a workaround for problems with the .b files in R14beta2.
%   The .b files contain directories names as well as some files in those
%   directories resulting in duplicates being found by zip().

% Remove the obvious directories
%
pathlist = sort(pathlist);
for i=2:length(pathlist)
  if strmatch([pathlist{i-1} filesep],pathlist{i})
     pathlist{i-1} = '';
  end
end
pathlist = pathlist(~strcmp(pathlist,''));

% Now go through and handle the rest I can't figure out.
% use the code from zip. 

% Run through the initial pathlist
%
extra = {};
for i=1:length(pathlist)
  if exist2(fullfile(rootdir,pathlist{i}),'dir')
    dirContents = dir(fullfile(rootdir,pathlist{i}));
    listing = {dirContents.name};
    listing = setdiff(listing,{'.','..'});
    if length(listing) > 0
      for j = 1:length(listing)
        extra{end+1,1} = fullfile(pathlist{i},listing{j});
      end
      pathlist{i} = '';
    end
  end
end
pathlist = pathlist(~strcmp(pathlist,''));

% Recursively run through the extra list
%
n = 0;
while length(extra) > n
  n = n + 1;
  if exist2(fullfile(rootdir,extra{n}),'dir')
    dirContents = dir(fullfile(rootdir,extra{n}));
    listing = {dirContents.name};
    listing = setdiff(listing,{'.','..'});
    if length(listing) > 0
      for i = 1:length(listing)
        extra{end+1,1} = fullfile(extra{n},listing{i});
      end
      extra{n} = '';
    end
  end
end
extra = extra(~strcmp(extra,''));

%================================
% fprintf('length(extra) = %d\n',length(extra));
%================================
pathlist = unique([pathlist; extra]);

%==========================================================================
function mcr_zipfile = get_mcr_zipfile(Arch,mcr_zipfile_dirname, ...
			               mcr_zipfile_filename)
%GET_MCR_ZIPFILE	determines the location where to put the ZIP file.
%   fore achitecture ARCH.
%
%   If MCR_ZIPFILE_DIRNAME is empty then use:
%
%   <matlabroot>/toolbox/compiler/deploy/<arch>/MCRInstaller.zip 
%
%   If MCR_ZIPFILE_FILENAME is empty then use:
%
%   <MCR_ZIPFILE_DIRNAME>/MCRInstaller.zip 
%
%   If neither are empty then use:
%
%   <MCR_ZIPFILE_DIRNAME>/<MCR_ZIPFILE_FILENAME>
%
%   The directory is created as needed.

mcr_zipfile = '';
%
if isempty(mcr_zipfile_dirname)
  mcr_zipfile_dirname = fullfile(matlabroot,'toolbox', ...
				 'compiler','deploy',Arch);
end
if ~exist(mcr_zipfile_dirname,'dir')
  [status,msg] = mkdir(mcr_zipfile_dirname);
  if ~status
    disp(sprintf('Directory for ZIP file could not be built.\n??? %s',msg));
    return
  end
end
if isempty(mcr_zipfile_filename)
  mcr_zipfile_filename='MCRInstaller.zip';
end
mcr_zipfile = fullfile(mcr_zipfile_dirname,mcr_zipfile_filename);

%==========================================================================

function [entries, found] = addentry(entries, path, file, entryname);
% Add a file entry to the list of file entries. Modifies the input
% list and returns it.

    global mcrversion;

    filePath = fullfile(path, file);
    if ispc
        filePath = strrep(filePath,'/','\');
    end
    fileType = exist2(filePath,'file');
    if (fileType == 0)
	warning('COMPILER:BUILDMCR:NoSuchFile',...
                '"%s" does not exist.', filePath);
	found = false;
    elseif (fileType < 2 || fileType > 6)
	warning('COMPILER:BUILDMCR:WrongFileType',...
                '"%s" cannot be put into a ZIP file.', filePath);
	found = false;
    else
        entries(end+1).file = filePath;
        entries(end).entry = fullfile(mcrversion.string, entryname);
	found = true;
    end

%==========================================================================

function [entries, notfound] = adddirectory(entries, filePath, filename)
% Add all the files in the directory, and all those in all the subdirectories
% to the file list.

notfound = 0;
dirContents = dir(filePath);
listing = {dirContents.name};

% Remove . and .. from the list 
listing = setdiff(listing,{'.','..'});

% Add directory entries to the list of inputs
for j = 1:length(listing)

    fullPath = fullfile(filePath, listing{j});

    % If the directory entry is a subdirectory, add it to the
    % list of files to be processed. Files is the variable that
    % controls the execution of this loop.

    if (exist2(fullPath, 'dir'))
       entries = adddirectory(entries, fullPath, ...
                              fullfile(filename, listing{j}));

    % Plain file, add to entry list
    else 
        % The entry name should be relative to the original
        % directory as specified in the file list.
	[entries, found] = addentry(entries, filePath, listing{j}, ...
                                    fullfile(filename, listing{j}));
	if (found == false)
	    notfound = notfound + 1;
        end
    end
end

%==========================================================================

function ctfzip(zipFilename, files, rootDir, aliases, runtimeFiles)
% Use CTFARCHIVER to create a ZIP file

% Load the CTFARCHIVER library -- do this first, because if it fails, all the 
% rest of the work below is meaningless.
platform = computer;
headerRelPath = '/toolbox/compiler/ctfarchiver.h';
if ispc
    headerRelPath = strrep(headerRelPath, '/', '\');
end

% The name of the CTFARCHIVER library differs on Windows and UNIX platforms.
if ispc
    ziplibname = 'ctfarchiver';
else
    ziplibname = 'libmwctfarchiver';
end

if (libisloaded(ziplibname) == false)
    [notfound, perlout] = loadlibrary(ziplibname, ...
                                      [matlabroot headerRelPath]);
    if (~isempty(notfound))
        error('Could not load ZIP library ctfarchiver.');
    end
end

% Work around file problems in the UNIX file lists.
% the if isunix block can go away 
if isunix
    files = prune_duplicates(files,rootDir);
end

% Parse arguments.
error(nargchk(2,5,nargin))
if (nargin < 3)
    rootDir = pwd;
end

if ischar(files)
    files = {files};
end

% If no extension is given for output, add ".zip".
[null,null,zipFilenameExt]=fileparts(zipFilename);
if isempty(zipFilenameExt)
    zipFilename = [zipFilename '.zip'];
end

% Create a structure of the inputs.
entries = {};
inputs = [];
missing = 0;
for i = 1:length(files)
    filename = files{i};
    if isAbsolute(filename)
        [path,base,ext] = fileparts(filename);
        file = [base ext];
    else
        path = rootDir;        
        file = filename;
    end

    filePath = fullfile(path, file);

    % If the filename is a directory, add all the files in the directory
    % to the list.
    if exist2(filePath,'dir')
        [entries, notfound] = adddirectory(entries, filePath, filename);
	missing = missing + notfound;
    else
	[entries, found] = addentry(entries, path, file, filename);
	if (found == false)
	    missing = missing + 1;
        end
    end

end

% If there is nothing to do, error.  There is no such thing as an "empty zip".
if isempty(entries)
    error('Nothing to zip.')
end

if (missing ~= 0)
    warning('COMPILER:BUILDMCR:MissingFiles',...
            ['Attempted to add ' num2str(missing) ' files that were not found.']);
end

% Check for duplicate entry names.
allNames = {entries.entry};
[uniqueNames,i] = unique(allNames);
if length(uniqueNames) < length(entries)
    firstDup = allNames{min(setdiff(1:length(entries),i))};
    error('Tried to add two files as "%s" in zip.',firstDup);
end

disp(['...Target ZIP file: ' zipFilename]);
disp(['...Adding platform-specific binaries (' ...
      num2str(prod(size(entries))) ' files) and toolbox/matlab']);
disp(['...content (' num2str(prod(size(aliases))) ...
      ' files). Please wait. This process cannot be interrupted.']);

srcFiles = [ {entries.file} {aliases.src} ];
zipEntries = [ {entries.entry} {aliases.dest} ];

% If the list of runtime files is not empty, add the runtime files
% to the archive.
if (~isempty(runtimeFiles))
    srcFiles = [ srcFiles {runtimeFiles.src} ];
    zipEntries = [ zipEntries {runtimeFiles.dest} ];
end

success = calllib(ziplibname, 'ctfCreateZipFile', zipFilename, srcFiles, ...
                  zipEntries, prod(size(srcFiles)));


