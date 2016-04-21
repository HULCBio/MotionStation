function add(cc,filename)
%ADD Places a file in the current Code Composer Project
%   ADD(CC,FILE) - Use this command to add an existing file into the active
%   Code Composer project.  The file must exist and is limited to filetypes
%   supported by Code Composer projects.  The file may be defined with a
%   complete path.  Otherwise, it must reside in the Code Composer working
%   directory or on the MATLAB path. 
%
%   Supported Filetypes for ADD
%    C/C++ source files      : *.cpp, *.c, *.cc, *.cxx or *.sa
%    Asm source files        : *.a*,  *.s*
%    Object and Library files: *.o*, *.lib
%    Linker Command files    : *.cmd
%    DSP/BIOS file           : *.cdb*
%
%   See also REMOVE, OPEN, CD, ACTIVATE.

% Copyright 2004 The MathWorks, Inc.
