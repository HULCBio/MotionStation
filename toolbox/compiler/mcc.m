%MCC Invoke MATLAB to C/C++ Compiler (Version 4.0).
%   MCC [-options] fun [fun2 ...]
%   
%   Prepare fun.m for deployment outside of the MATLAB environment.  
%   Generate wrapper files in C or C++ and optionally build standalone
%   binary files. 
%   
%   Write any resulting files into the current directory, by default.
%   
%   If more than one M-file is specified, a C or C++ function is generated 
%   for each M-file.
%   
%   If C or object files are specified, they are passed to MBUILD along
%   with any generated C files.
%   
%   If conflicting options are presented to MCC, the rightmost conflicting
%   option is used.
%   
%   OPTIONS:
%   
%   a <filename> Add <filename> to the CTF archive.
%   
%   B <filename>[:<arg>[,<arg>]] Specify bundle file. <filename> is a text  
%       file containing Compiler command line options. The Compiler behaves
%       as if the "-B <filename>" were replaced by the contents of the
%       bundle file. Newlines appearing in these files are allowed and are
%       treated as whitespace. The MathWorks provides options files for the
%       following:
%   
%           cpplib    Used for building a C++ library.
%   
%           csharedlib
%                     Used for building a C shared library.
%   
%   c C only. Generate C wrapper code.  This is equivalent to "-T codegen" 
%       as the rightmost argument on the command line.
%   
%   d <directory> Output directory. All generated files will be put in
%       <directory>.
%   
%   f <filename> Override the default options file with the specified
%       options file when calling MBUILD. This allows you to use different
%       ANSI compilers. This option is a direct pass-through to the MBUILD
%       script. See "External Interfaces" documentation for more
%       information.
%   
%   G   Debug only. Simply turn debugging on, so debugging symbol
%       information is included.
%   
%   g   Debug. Include debugging symbol information. 
%   
%   I <path> Include path. Add <path> to the list of paths to search for
%       M-files. The MATLAB path is automatically included when running
%       from MATLAB, but NOT when running from DOS or the UNIX shell. See
%       "help mccsavepath".
%   
%   l   Create function library. This option is equivalent to -W lib  
%       -T link:lib. It generates library wrapper functions for each M-file
%       on the command line and calls your C compiler to build a shared
%       library which exports these functions. The library name is the
%       component name, which is either derived from the name of the first
%       M-file on the command line or specified with the -n option.
%   
%   m   Macro that generates a C stand-alone application. This is 
%       equivalent to the options "-W main -T link:exe", which can be found
%       in the file <MATLAB>/toolbox/compiler/bundles/macro_option_m. 
%   
%   M "<string>" Pass <string> to the MBUILD script to build an
%       executable. If -M is used multiple times, the rightmost occurrence
%       is used.
%   
%   o <outputfilename> Output name. Set the name of the final executable 
%       output (stand-alone application) and CTF archive to 
%       <outputfilename>. A suitable, possibly platform-dependent, 
%       extension is added to <outputfilename> (e.g., ".exe" for Windows 
%       stand-alone applications). See also -W
%   
%   p <functionname> Private function. Do not generate an interface for  
%       this function.
%   
%   R <option> Specify the runtime options for the MATLAB Common Runtime 
%       (MCR) usage:
%       mcc -m -R "-nojvm <args> -nojit <args>" -v foo.m
%       mcc -m -R "-nojvm <args>" -v -R "-nojit <args>" foo.m
%       mcc -m -R -nojvm -R -nojit foo.m
%       mcc -m -R -nojvm -v foo.m
%       mcc -m -R nojvm -R nojit foo.m
%   
%   T <option> Specify target phase and type. The following table shows  
%       valid <option> strings and their effects:
%   
%       codegen            - Generate a C/C++ wrapper file.
%                            (This is the default -T setting.)
%       compile:exe        - Same as codegen, plus compile C/C++ files to 
%                            object form suitable for linking into a
%                            stand-alone executable.
%       compile:lib        - Same as codegen, plus compile C/C++ files to 
%                            object form suitable for linking into a shared 
%                            library/DLL.
%       link:exe           - Same as compile:exe, plus link object files  
%                            into a stand-alone executable.
%       link:lib           - Same as compile:lib, plus link object files  
%                            into a shared library/DLL.
%   
%   v   Verbose. Show compilation steps.
%   
%   w list. List the warning strings that could be thrown by MATLAB 
%       Compiler during compilation. These <msgs> can be used with another
%       form of the w switch to enable or disable the warnings or to throw
%       them as error messages. 
%   
%   w <option>[:<msg>] Warnings. The possible options are "enable", 
%       "disable", and "error". If "enable:<msg>" or "disable:<msg>" is
%       specified, enable or disable the warning associated with <msg>. If
%       "error:<msg>" is specified, enable the warning associated with
%       <msg> and treat any instances of that warning as an error. If the
%       <option> but not ":<msg>" is specified, the Compiler applies the
%       action to all warning messages. For backward compatibility with
%       previous Compiler revisions, "-w" (with no option) is the same as
%       "-w enable".
%   
%   W <option> Wrapper functions. Specify which type of wrapper file
%       should be generated by the Compiler. <option> can be one of
%       "main", "lib:<string>",
%       "com:<component-name>,<class-name>,<version>", or "none"
%       (default). For the lib wrapper, <string> contains the name of the
%       shared library to build.
%   
%   Y <license.dat file> Override default license.dat file with specified
%       argument.
%   
%   z <path> Specify the path to use for library and include files.
%       This option uses the specified path for the Compiler libraries
%       instead of MATLABROOT.
%   
%   ?   Help. Display this help message.
%   
%   EXAMPLES:
%   
%   Make a stand-alone C executable for myfun.m:
%       mcc -m myfun
%   
%   Make stand-alone C executable for myfun.m. Look for
%    myfun.m in the directory /files/source, and put the resulting C files 
%    and executable in the directory /files/target:
%       mcc -m -I /files/source -d /files/target myfun
%   
%   Make a stand-alone C executable from myfun1.m and myfun2.m
%    (using one mcc call):
%       mcc -m myfun1 myfun2
%   
%   Make a shared/dynamically linked library called "liba" from a0.m and
%   a1.m
%       mcc -W lib:liba -T link:lib a0 a1
%   
%   Note: on Windows, filenames ending with .o above would actually end
%   with .obj.
%
%
%   See also COMPILER/FUNCTION, MBUILD, BUILDMCR, INSTALLMCR.

% Copyright 1984-2004 The MathWorks, Inc.

function [varargout] = mcc(varargin)
%#mex
error('MEX file not present');
