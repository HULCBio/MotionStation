function [b,str] = dspblkvfdly2(varargin)
% DSPBLKVFDLY Mask dynamic dialog function for variable fractional delay block

% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:59:01 $ $Revision: 1.4 $

if nargin==0
  action = 'dynamic';   % mask callback
else
  action = 'design';    % Design the filter
end

switch action
case 'dynamic'
   % Execute dynamic dialogs  
	mask_enables = get_param(gcb,'maskenables');
	mask_visibilities = get_param(gcb,'maskvisibilities');    
   mode = get_param(gcb, 'mode');
   switch mode
   case 'Linear Interpolation',
      mask_visibilities{3} = 'off';
      mask_visibilities{4} = 'off';
      mask_visibilities{5} = 'off';
   case 'FIR Interpolation',
      mask_visibilities{3} = 'on';
      mask_visibilities{4} = 'on';
      mask_visibilities{5} = 'on';
   otherwise
      error('Unknown interpolation method');
   end
        
	set_param(gcb,'maskenables',mask_enables, ...
   				     'maskvisibilities',mask_visibilities);
      
case 'design'
   
   mode = varargin{1};
   if mode==2,
      R = varargin{2};
      L = varargin{3};
      alpha = varargin{4};
      if isempty(R) | isempty(L) | isempty(alpha),
         b = [];
      else
         b=intfilt(R,L,alpha);
         blen=length(b); bcols = ceil(blen/2/L);
         b = [zeros(bcols*2*L-blen,1);b(:)];
         b = flipud(reshape(b,bcols,2*L)');
      end
   else
      b = [];
   end  
   
   str = 'Fractional\nDelay';
   
otherwise
   error('unhandled case');
end
% end of dspblkvfdly2.m