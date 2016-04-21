function [m,d] = aufinfo(filename)
%AUFINFO Text description of AU file contents.
%

% Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/03/05 18:10:32 $

try
    m = 'Sound (AU) file';
    d = auread(filename, 'size');
    d = sprintf('Sound (AU) file containing: %d samples in %d channel(s)', ...
                d(1), d(2));
catch
    m = '';
    d = 'Not an AU file';
end    
