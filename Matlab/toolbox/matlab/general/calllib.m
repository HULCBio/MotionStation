function [varargout] = calllib(libname,funcname,varargin)
%CALLLIB Call a function in an external library.
%   [X1,...,XN]=CALLLIB('LIBNAME','FUNCNAME',ARG1,...,ARGN) calls 
%   the function FUNCNAME in library LIBNAME, passing input arguments 
%   ARG1 through ARGN.  CALLLIB returns output values obtained from
%   function FUNCNAME in X1 through XN.
%
%   See also LOADLIBRARY, LIBFUNCTIONS, LIBFUNCTIONSVIEW, UNLOADLIBRARY.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/02/07 19:12:19 $
%   Built-in function.
