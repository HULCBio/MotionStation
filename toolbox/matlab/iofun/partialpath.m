%PARTIALPATH Partial pathnames.
%   A partial pathname is a MATLABPATH relative pathname that is used to
%   locate private and method files which are usually hidden or to
%   restrict the search for files when more than one file with the given
%   name exists.  
%
%   A partial pathname contains the last component, or last several
%   components, of the full pathname separated by '/'. For example,
%   "matfun/trace", "private/children", "inline/formula", and
%   "demos/clown.mat" are valid partial pathnames.  Specifying the
%   "@" in method directory names is optional so "funfun/inline/formula"
%   is also a valid partial pathname.
%
%   Many commands accept partial pathnames instead of a full pathname.
%   Here's a (partial) list of such commands
%       HELP, TYPE, LOAD, EXIST, WHAT, WHICH, EDIT,
%       DBTYPE, DBSTOP, and DBCLEAR, FOPEN.
%
%   Partial pathnames make it easy to find toolbox or MATLAB relative
%   files on your path in a portable way that is independent of
%   where MATLAB is installed.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/06/17 13:26:27 $
