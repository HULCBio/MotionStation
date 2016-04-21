function blnkdstrng = p_deblank(string)
% O = P_DEBLANK(S) (Private) 
% Removes trailing blanks from both sides of string S, by flipping it twice.
%
% Example:  
% string = '   Life is unsure,always eat your dessert first  ';
% blnkdstrng = p_deblank(string);

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/11/30 23:13:27 $

if ischar(string),
    blnkdstrng = fliplr(deblank(fliplr(deblank(string))));
else
    error('Input must be a string.')
end

% [EOF] p_deblank.m