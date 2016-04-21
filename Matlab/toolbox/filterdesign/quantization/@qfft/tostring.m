function s = tostring(F)
%TOSTRING  QFFT object to string.
%   S = TOSTRING(F) converts QFFT object F to a string S, such that
%   EVAL(S) would create a QFFT object with the same properties as F.
%
%   Example:
%     F = qfft;
%     s = tostring(F)
%
%   See also QFFT.

%   Thomas A. Bryan, 19 April 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 2002/04/14 15:25:58 $

radix              = ['''Radix'',', num2str(get(F,'radix'))];
len                = ['''Length'',', num2str(get(F,'length'))];
coefficientformat  = ['''CoefficientFormat'',', ...
      tostring(get(F,'coefficientformat'))];
inputformat        = ['''InputFormat'',', tostring(get(F,'inputformat'))];
outputformat       = ['''OutputFormat'',', tostring(get(F,'outputformat'))];
multiplicandformat = ['''MultiplicandFormat'',', tostring(get(F,'multiplicandformat'))];
productformat      = ['''ProductFormat'',', tostring(get(F,'productformat'))];
sumformat          = ['''SumFormat'',', tostring(get(F,'sumformat'))];
scalevalues        = ['''ScaleValues'',[',  num2str(get(F,'scalevalues')),']'];

formats = [coefficientformat,', ',inputformat,', ',outputformat,...
      ', ',multiplicandformat,', ',productformat,', ',sumformat];

s = ['qfft(',radix,', ', len,', ',formats,', ',scalevalues,')'];
