function convertedProgID = newprogid(progID)
% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2004/04/15 00:07:00 $

convertedProgID = lower(progID);
convertedProgID = regexprep(progID, '_', '__');
convertedProgID = regexprep(convertedProgID, '-', '___');
convertedProgID = regexprep(convertedProgID, '\.', '_');
convertedProgID = regexprep(convertedProgID, ' ', '____');
convertedProgID = regexprep(convertedProgID, '&', '_____');


