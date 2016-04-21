function [m,d] = wavfinfo(filename)
%WAVFINFO Text description of WAV file contents.
%

% Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:07:05 $

try
    m = 'Sound (WAV) file';
    d = wavread(filename, 'size');
    d = sprintf('Sound (WAV) file containing: %d samples in %d channel(s)', ...
                d(1), d(2));
catch
    m = '';
    d = 'Not a WAVE file';
end    
