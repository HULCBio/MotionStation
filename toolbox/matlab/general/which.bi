function [varargout] = which(varargin)
%WHICH  Locate functions and files.
%   WHICH FUN displays the full pathname of the function with the name
%   FUN.  
%
%   If FUN is something other than a function (a variable in the workspace,
%   a loaded Simulink model, a method of a Java class on the classpath), 
%   then WHICH displays a message identifying it as such.  If FUN is a
%   filename, including extension, then WHICH displays the full pathname of
%   that file.
%
%   WHICH FUN -ALL  displays the paths to all functions with the name
%   FUN.  Functions are displayed in order of their precedence.  The first
%   function displayed has precedence over the second, and so on.  This
%   information can be useful when you want to see which implementation of
%   a function would be dispatched to by MATLAB.  See FUNCTION PRECEDENCE,
%   below.  
%
%      You can use -ALL with any syntax for WHICH.
%
%   WHICH FUN(A,B,...) shows which implementation of function FUN would be
%   invoked if you were to call FUN with input arguments A, B, etc.  Use
%   this syntax for overloaded functions.
%
%   WHICH FUN1 IN FUN2 displays the pathname to function FUN1 in the
%   context of the m-file FUN2.  While debugging FUN2, WHICH FUN1 does
%   the same thing.  You can use this to determine if a subfunction or
%   private version of a function is being called instead of a function
%   on the path.
%
%   S = WHICH(...) returns the results of WHICH in the string S. (If WHICH
%   is called on a variable, then S is the string 'variable'.)
%
%   C = WHICH(...,'-ALL') returns the results of the multiple search
%   version of WHICH in the cell array C.  Each row of cell array C
%   identifies a function and the functions are in order of precedence.
%
%   FUNCTION PRECEDENCE:
%   WHICH and WHICH -ALL expose the precedence rules used by MATLAB to 
%   determine which implementation of a multiply-defined function to
%   dispatch to.  MATLAB function precedence rules are described in the
%   M-File Programming chapter of the MATLAB Programming documentation
%   under Calling Functions => Determining Which Function Is Called.
%
%   See also DIR, HELP, WHO, WHAT, EXIST, LOOKFOR.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.20.4.2 $  $Date: 2004/04/16 22:06:55 $
%   Built-in function.

if nargout == 0
  builtin('which', varargin{:});
else
  [varargout{1:nargout}] = builtin('which', varargin{:});
end
