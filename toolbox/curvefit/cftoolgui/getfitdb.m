function fitdb=getfitdb(varargin)
% GETFITDB A helper function for CFTOOL

% $Revision: 1.7.2.1 $  $Date: 2004/02/01 21:39:01 $
% Copyright 2001-2004 The MathWorks, Inc.


thefitdb = cfgetset('thefitdb');

% Create a singleton class instance
if isempty(thefitdb)
   thefitdb = cftool.fitdb;
end

cfgetset('thefitdb',thefitdb);
fitdb=thefitdb;
