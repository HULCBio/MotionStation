function dateNum = sf_date_num(dateStr)
% DATENUMVAL = SF_DATE_NUM(DATESTR)
% wrapper around datenum

% Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.6.2.2 $  $Date: 2004/04/15 00:59:21 $

% Must get rid of this function once G56149 is fixed.
% Calls datenum in a try catch and if there is an error
% (i.e, on international UNIX machines) reverts to
% returning 0.0
%

persistent sDateNumError

if(isequal(sDateNumError,1))
   dateNum = 0.0;
else
   [prevErrMsg, prevErrId] = lasterr;
   try,
      dateNum = datenum(dateStr);
   catch,
      lasterr(prevErrMsg, prevErrId);
      dateNum = 0.0;
      sDateNumError = 1;
   end
end
