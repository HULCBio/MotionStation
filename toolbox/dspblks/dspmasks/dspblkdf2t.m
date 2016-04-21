function varargout = dspblkdf2t(action, varargin)
% DSPBLKDF2T Mask dynamic dialog function for Direct-Form II
% Transpose filter block

% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:55:34 $ $Revision: 1.13 $

if nargin==0, action = 'dynamic'; end
frame_based = get_param(gcb, 'frame');

switch action
   case 'icon'
      % Generate icon
      varargout{1} = [.2 .8 .7 .7 .5 .5 .3 .3  .7  .3  .3 .7 .3 .3  .7  .3  .3 .7];
      varargout{2} = [.7 .7 .7 .1 .1 .7 .7 .55 .55 .55 .4 .4 .4 .25 .25 .25 .1 .1];
      
   case 'dynamic'     
      % Execute dynamic dialogs
      
      % The fourth dialog (checkbox for frame-based inputs)
      % disables/enables the fifth dialog (number of channels).
      
      % Get status of frame checkbox
      mask_enables = get_param(gcb,'maskenables');
      mask_enables{5} = frame_based;
      set_param(gcb,'maskenables',mask_enables);
   case 'design'
      % Normalize the filter coeffs
      b = varargin{1};
      a = varargin{2};
      
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
      elseif (a(1) ~= 1.0)
         varargout{1} = b ./ a(1);
         varargout{2} = a ./ a(1);
      else 
         varargout{1} = b;
         varargout{2} = a;
      end
      
      
   otherwise
      error('unhandled case');
end

% end of dspblkdf2t.m
