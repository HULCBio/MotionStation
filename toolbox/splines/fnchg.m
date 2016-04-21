function fn = fnchg(fn,part,value)
%FNCHG Change part(s) of a form.
%
%   FNCHG(FN,PART,VALUE) changes the specified PART of FN to the given VALUE.
%   PART can be (the beginning character(s) of)
%      'dimension'     for the dimension of the function's target
%      'interval'      for the basic interval of the function
%
%   Terminating the string PART with the letter z skips any checking
%   of the specified VALUE for PART for consistency with FN.
%
%   Example: FNDIR returns a vector-valued function even when 
%   applied to an ND-valued function. This can be corrected as follows:
%
%      fdir = fnchg( fndir(f,direction), ...
%                    'dim',[fnbrk(f,'dim'),size(direction,2)] );
%
%   See also FNBRK

%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2003/02/13 22:22:42 $

if ~ischar(part)
     error('SPLINES:FNCHG:partnotstr','PART must be a string.'), end

switch part(1)
case 'd'
   if part(end)~='z'
      oldvalue = fnbrk(fn,'dim');
      if prod(value)~=prod(oldvalue)
         error('SPLINES:FNCHG:wrongdim', ...
	      ['The specified target dimension, [',num2str(value),...
               '], does not match the present target dimension, [',...
               num2str(oldvalue),'].'])
      end
   end
   fn.dim = value;
case 'i', fn = fnbrk(fn,value);
otherwise
   error('SPLINES:FNCHG:wrongpart', ...
         'The part ''', part, ''' cannot be reset via FNCHG.')
end
