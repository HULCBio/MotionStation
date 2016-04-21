function theoutlierdb=getoutlierdb(varargin)

%   $Revision: 1.4.2.1 $
%   Copyright 2001-2004 The MathWorks, Inc.

theoutlierdb = cfgetset('theoutlierdb');

% Create a singleton class instance
if isempty(theoutlierdb)
   theoutlierdb = cftool.outlierdb;
   cfgetset('theoutlierdb',theoutlierdb);
end


