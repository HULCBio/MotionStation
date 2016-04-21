function varargout = dspblkdf2t2(action, varargin)
% DSPBLKDF2T2 Mask dynamic dialog function for Direct-Form II
% Transpose filter block

% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:57:41 $ $Revision: 1.7 $

switch action
   case 'icon'
      % Generate icon
      varargout{1} = [.2 .8 .7 .7 .5 .5 .3 .3  .7  .3  .3 .7 .3 .3  .7  .3  .3 .7];
      varargout{2} = [.7 .7 .7 .1 .1 .7 .7 .55 .55 .55 .4 .4 .4 .25 .25 .25 .1 .1];
      
   case 'design'
      % Normalize the filter coeffs using double-precision math
      
      b = double(varargin{1});
      a = double(varargin{2});

      [M,N] = size(b);
      blen = length(b);
      if (M*N ~= blen)
        error('Numerator must be a vector');
      end
      
      [M,N] = size(a);
      alen = length(a);
      if (M*N ~= alen)
        error('Denominator must be a vector');
      end
      
      if (a(1) == 0.0)
        error('First denominator coefficient must be non-zero');
      end
      
      b = b ./ a(1);
      a = a ./ a(1);
      
      varargout(1:2) = {b,a};
        
 otherwise
      error('unhandled case');
end

% end of dspblkdf2t2.m
