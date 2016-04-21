function [varargout] = inmem(varargin)
%INMEM List functions in memory. 
%   M = INMEM returns a cell array of strings containing the names
%   of the M-files that are in the P-code buffer.
%
%   M = INMEM('-completenames') is similar, but each element of
%   the cell array has the directory, file name, and file extension.
%
%   [M,MEX]=INMEM also returns a cell array containing the names of
%   the MEX files that have been loaded.
%
%   [M,MEX,J]=INMEM also returns a cell array containing the names of
%   the Java classes that have been loaded. 
%
%   Examples:
%      clear all % start with a clean slate
%      erf(.5)
%      m = inmem
%   lists the m-files that were required to run erf.
%      m1 = inmem('-completenames')
%   lists the same files, each with directory, name, and extension.
%
%   See also WHOS, WHO.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.3 $  $Date: 2004/04/10 23:26:05 $
%   Built-in function.

[varargout{1:nargout}] = builtin('inmem', varargin{:});
