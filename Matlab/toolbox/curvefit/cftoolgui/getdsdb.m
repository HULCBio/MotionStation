function thedsdb=getdsdb(varargin)

%   $Revision: 1.11.2.1 $  $Date: 2004/02/01 21:39:00 $
%   Copyright 2001-2004 The MathWorks, Inc.


thedsdb = cfgetset('thedsdb');

% Create a singleton class instance
if isempty(thedsdb)
   thedsdb = cftool.dsdb;
   cfgetset('thedsdb',thedsdb);
end


