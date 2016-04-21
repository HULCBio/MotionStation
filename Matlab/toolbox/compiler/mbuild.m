function errorCode = mbuild(varargin)
%MBUILD Compile an executable from C source code.
%   MBUILD [option1 ... optionN] sourcefile1 [... sourcefileN]
%          [objectfile1 ... objectfileN] [libraryfile1 ... libraryfileN]
%          [exportfile1 ... exportfileN]
%   
%   Description:
%     MBUILD compiles and links source files that call functions in the
%     MATLAB Compiler generated shared libraries into a stand-alone
%     executable or shared library.
%     
%     The first filename given (less any file name extension) will be the
%     name of the resulting executable. You can give additional source,
%     object, or library files to satisfy external references. You can
%     specifiy either C or C++ source files when building executables. In
%     addition, you can specify both C and C++ source files at the same
%     time as long as the C files are C++ compatible, and you specify the
%     -lang cpp option (see -lang below).
%     
%     Both an options file and command line options affect the behavior of
%     MBUILD. The options file contains a list of variables that are passed
%     as arguments to various tools such as the compiler, linker, and other
%     platform-dependent tools (such as the resource linker on Windows).
%     Command line options to MBUILD may also affect what arguments are
%     passed to these tools, or may control other aspects of MBUILD's
%     behavior.
%
%   Command Line Options:
%     Options available on all platforms:
%
%     -c
%         Compile only. Creates an object file but not an executable.
%     -D<name>
%         Define a symbol name to the C/C++ preprocessor. Equivalent to a
%         "#define <name>" directive in the source.
%     -D<name>#<value>
%         Define a symbol name and value to the C/C++ preprocessor.
%         Equivalent to a "#define <name> <value>" directive in the source.
%     -f <optionsfile>
%         Specify location and name of options file to use. Overrides
%         MBUILD's default options file search mechanism.
%     -g
%         Create a debuggable executable. If this option is specified,
%         MBUILD appends the value of options file variables ending in
%         DEBUGFLAGS with their corresponding base variable. (For example,
%         the value of LINKDEBUGFLAGS would be appended to the LINKFLAGS
%         variable before calling the linker.) This option also disables
%         MBUILD's default behavior of optimizing built object code.
%     -h[elp]
%         Print this message.
%     -I<pathname>
%         Add <pathname> to the list of directories to search for #include
%         files.
%     -inline
%         Inline matrix accessor functions (mx*). The executable generated
%         may not be compatible with future versions of the MATLAB
%         Compiler.
%     -lang <language>
%         Specify compiler language. <language> can be c or cpp. By
%         default, MBUILD determines which compiler (C or C++) to use by
%         inspecting the source file's extension. This option overrides
%         that default.
%     -n
%         No execute mode. Print out any commands that MBUILD would
%         otherwise have executed, but do not actually execute any of them.
%     -O
%         Optimize the object code by including the optimization flags
%         listed in the options file. If this option is specified, MBUILD
%         appends the value of options file variables ending in OPTIMFLAGS
%         with their corresponding base variable. (For example, the value
%         of LINKOPTIMFLAGS would be appended to the LINKFLAGS variable
%         before calling the linker.) Note that optimizations are enabled
%         by default, are disabled by the -g option, but are reenabled by
%         -O.
%     -outdir <dirname>
%         Place all output files in directory <dirname>.
%     -output <resultname>
%         Create an executable named <resultname>. (An appropriate
%         executable extension is automatically appended.) Overrides
%         MBUILD's default executable naming mechanism.
%     -setup
%         Interactively specify the compiler options file to use as a
%         default for future invocations of MBUILD by placing it in
%         "<UserProfile>\Application Data\MathWorks\MATLAB\<rel_version>"
%         (for Windows) or $HOME/.matlab/<rel_version> (for UNIX). 
%         <rel_version> is the base release version, such as R14. When this
%         option is specified, no other command line input is accepted.
%     -U<name>
%         Remove any initial definition of the C preprocessor symbol
%         <name>. (This is the inverse of the -D option.)
%     -v
%         Print the values for important internal variables after the
%         options file is processed and all command-line arguments are
%         considered. Prints each compile step and final link step fully
%         evaluated to see which options and files were used. This option
%         is very useful for debugging.
%     <name>#<value>
%         Override an options file variable for variable <name>. See the
%         platform-dependent discussion of options files below for more
%         details. This option is processed after the options file is
%         processed and all command-line arguments are considered.
%   
%   Additional options available on Windows platforms:
%   
%     @<rspfile>
%         Include contents of the text file <rspfile> as command line
%         arguments to MBUILD.
%   
%   Additional options available on UNIX platforms:
%   
%     -D<name>=<value>
%         Define a symbol name and value to the C preprocessor. Equivalent
%         to a "#define <name> <value>" directive in the source.
%     -l<name>
%         Link with object library "lib<name>" (for "ld(1)").
%     -L<directory>
%         Add <directory> to the list of directories containing
%         object-library routines (for linking using "ld(1)").
%     <name>=<value>
%         Override an options file variable for variable <name>. See the
%         platform-dependent discussion of options files below for more
%         details.
%   
%   Shared Libraries and Exports Files:
%     MBUILD can also create shared libraries from C source code. If a file
%     or files with the extension ".exports" is passed to MBUILD, then it
%     builds a shared library. The .exports file must be a flat text file,
%     with each line containing either an exported symbol name, or starting
%     with a # or * in the first column (in which case it is treated as a
%     comment line). If multiple .exports files are specified, then all
%     symbol names in all specified .exports files are exported.
%   
%   Options File Details:
%     On Windows:
%       The options file is written as a DOS batch file. If the -f option
%       is not used to specify the options filename and location, then
%       MBUILD searches for an options file named compopts.bat in the
%       current directory, and then the directory
%       "<UserProfile>\Application Data\MathWorks\MATLAB\<rel_version>".
%       <rel_version> is the base release version, such as R14. You can
%       override any variable specified in the options file at the command
%       line by using the <name>#<value> command-line argument. If <value>
%       has spaces in it, then it should be in double quotes (e.g.,
%       COMPFLAGS#"opt1 opt2"). The definition can rely on other variables
%       defined in the options file; in this case the variable referenced
%       should have a prepended "$" (e.g., COMPFLAGS#"$COMPFLAGS opt2").
%   
%     On UNIX:
%       The options file is written as a UNIX shell script. If the -f
%       option is not used to specify the options filename and location,
%       then MBUILD searches for an options file named mbuildopts.sh in the
%       the current directory (.), then $HOME/.matlab/<rel_version>, and
%       then $MATLAB/bin. <rel_version> is the base release version, such
%       as R14. You can override any variable specified in the options file
%       at the command line by using the <name>=<def> command-line
%       argument. If <def> has spaces in it, then it should be in single
%       quotes (e.g., CFLAGS='opt1 opt2'). The definition can rely on other
%       variables defined in the options file; in this case the variable
%       referenced should have a prepended "$" (e.g., CFLAGS='$CFLAGS
%       opt2').
%   
%     Examples:
%   
%       This command will compile "myprog.c" into "myprog.exe" (when run
%       under Windows):
%   
%         mbuild myprog.c
%   
%       When debugging, it is often useful to use "verbose" mode as well
%       as include symbolic debugging information.
%   
%         mbuild -v -g myprog.c
%   
%       This command will compile "mylib.c" into "mylib.dll" (when run
%       under Windows). "mylib.dll" will export the symbols listed in
%       "mylib.exports":
%   
%         mbuild mylib.c mylib.exports
%   
%     See Also:
%       MATLAB Compiler User's Guide

% $Revision: 1.35.4.1 $  $Date: 2004/04/20 23:15:50 $
% Copyright 1984-2004 The MathWorks, Inc.

global MBUILD_RETURN_RESULT_IN_ANS

c = computer;
if isunix
	if (nargin > 0)
		args = sprintf(' "%s"', varargin{:});
	else
		args = '';
	end	
	
	[mexname, setup] = get_mex_opts(varargin{:});
	
        errCode = unix([matlabroot '/bin/mbuild' args]);

elseif strncmp(c, 'PC', 2)
    
    mexname = get_mex_opts(varargin{:});
    matlab_bin_location=[matlabroot '\bin'];
    if exist([matlab_bin_location '\win32\mex.bat'],'file') 
        matlab_bin_location=[matlabroot '\bin\win32'];
    end

    % Loop over all the arguments. Put extra quotes around any that
    % contain spaces.
    
    for i=1:prod(size(varargin))
        if (find(varargin{i} == ' '))
            varargin{i} = [ '"' varargin{i} '"' ];
        end
    end
    
    cmdargs = ['-called_from_matlab' sprintf(' %s', varargin{:})];
    if (any(matlab_bin_location == ' '))
        quote_str = '"';
    else
        quote_str = '';
    end

    cmdtool = [quote_str matlabroot '\sys\perl\win32\bin\perl.exe' quote_str ' ' ... 
               quote_str matlab_bin_location '\mex.pl' quote_str ' -mb'];
    [cmd, rspfile] = make_rsp_file(cmdtool, cmdargs);
    try
        errCode = dos(cmd);
    catch
        disp(lasterr);
        errCode = 1; % failure
    end
    delete(rspfile);
else
    error(['Unknown platform: ' c]);
end

if (nargout > 0) | (~isempty(MBUILD_RETURN_RESULT_IN_ANS)  & ...
        MBUILD_RETURN_RESULT_IN_ANS)
    errorCode = errCode;
elseif (errCode ~= 0)
    error('Unable to complete successfully');
end


%%%%%%%%%%%%%%%%%%%%
%%% SUBFUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%

function result = read_response_file(filename)
%
% Read a response file (a filename that starts with '@')
% and return a cell of strings, one per entry in the response file.
% Use Perl to ensure processing of arguments is the same as mex.bat
%

result = {};

cmd = ['"' matlabroot '\sys\perl\win32\bin\perl" -e "' ...
    'require ''' matlabroot '\\sys\\perl\\win32\\lib\\shellwords.pl'';' ...
    'open(FILE, ''' filename ''') || die ''Could not open ' filename ''';' ...
    'while (<FILE>) {$line .= $_;} ' ...
    '$line =~ s/\\/\\\\/g;' ...
    '@ARGS = &shellwords($line); ' ...
    '$\" = \"\n\";' ...
    'print \"@ARGS\";'];

[s, r] = dos(cmd);

if s == 0
    cr = sprintf('\n');
    while ~isempty(r)
        [result{end+1}, r] = strtok(r, cr);
    end
end

function [mexname, setup] = get_mex_opts(varargin)
%
% GET_MEX_OPTS gets the options from the command line.
%
% name:
% It gets the name of the destination MEX-file.  This has two
% purposes: 
%   1) All platforms need to clear the MEX-file from memory before
%      attempting the build, to avoid problems rebuilding shared
%      libraries that the OS considers "in use".
%   2) Windows MATLAB deletes the MEX-file before the build occurs.
%      It then checks to see whether the MEX-file was created so as
%      to establish error status.
%   This function returns the minimum necessary information.  Further
%   processing is done on the MEX-file name by clear_mex_file to 
%   successfully clear it.
%
% setup:
% It also returns whether or not '-setup' was passed.
%

mexname = '';
outdir = '';
setup = 0;

% First, check for and expand response files into varargin.
v = {};
for count=1:nargin
    arg = varargin{count};
    if arg(1) == '@'
        new_args = read_response_file(arg(2:end));
        v(end+1:end+length(new_args)) = new_args;          
    else
        v{end+1} = arg;
    end
end

varargin = v;

count = 1;
while (count <= nargin)
    arg = varargin{count};
    if isempty(mexname) & arg(1) ~= '-' & ~any(arg=='=') & any(arg=='.')
        %
        % Source file: MEX-file will be built in current directory
        % Only the first source file matters
        %
        mexname = arg;
        fileseps = find(mexname == filesep);
        if any(fileseps)
            mexname = mexname(fileseps(end)+1:end);
        end
        mexname = strtok(mexname, '.');
    elseif strcmp(arg, '-f')
        count = count + 1;
    elseif strcmp(arg, '-output')
        count = count + 1;
        if count > length(varargin)
            error('-output switch must be followed by a filename');
        end
        mexname = varargin{count};
    elseif strcmp(arg, '-outdir')
        count = count + 1;
        if count > length(varargin)
            error('-outdir switch must be followed by a directory name');
        end
        outdir = varargin{count};
    elseif strcmp(arg, '-setup')
        setup = 1;
        break;
    end
    count = count + 1;
end

mexname = fullfile(outdir, mexname);

function [cmd, rspfile] = make_rsp_file(cmdtool, cmdargs)
rspfile = [tempname '.rsp'];
[Frsp, errmsg] = fopen(rspfile, 'wt');
if Frsp == -1
    error(sprintf('Cannot open file "%s" for writing: %s.', rspfile, errmsg))
end
try
    count = fprintf(Frsp, '%s', cmdargs);
    if count < length(cmdargs)
        errmsg = ferror(Frsp);
        error(sprintf('Cannot write to file "%s": %s.', rspfile, errmsg));
    end
    fclose(Frsp);
catch
    fclose(Frsp);
    delete(rspfile);
    error(lasterr);
end

cmd = [cmdtool ' @"' rspfile '"'];

%We may need to know if the desktop is open
function out = desktopOpen
try 
	myDesktop = com.mathworks.ide.desktop.MLDesktop.getMLDesktop;
	if ~isempty(myDesktop),
		out = 1;
	else
		out = 0;
	end
catch
	out = 0;
end
