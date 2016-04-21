function convFactor = tsunitconv(outunits,inunits)
%TSUNITCONV Utility function used to convert time units
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/04 02:36:22 $

factors = [31557600 604800 86400 3600 60 1];        
factIn = factors(find(strcmp(inunits,{'years', 'weeks', ...
        'days', 'hours', 'mins', 'secs'})));
factOut = factors(find(strcmp(outunits,{'years', 'weeks', ...
        'days', 'hours', 'mins', 'secs'})));
convFactor = factIn/factOut;