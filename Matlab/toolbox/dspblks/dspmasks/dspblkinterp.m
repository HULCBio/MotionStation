function [b] = dspblkinterp(varargin)
% DSPBLKINTERP Mask dynamic dialog function for Interpolation block

% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/05/14 05:56:13 $ $Revision: 1.5 $

if nargin==0
  action = 'dynamic';   % mask callback
elseif nargin==1 
  action = 'icon';
else
  action = 'init';    % Design the filter
end


switch action
case 'icon'
%   ports = get_labels(gcb);
%   varargout = {ports};
blk = gcb;
b = get_labels(blk);

case 'dynamic'
   % Execute dynamic dialogs  
	mask_enables = get_param(gcb,'maskenables');
	mask_visibilities = get_param(gcb,'maskvisibilities');    
   mode = get_param(gcb, 'InterpMode');
   switch mode
   case 'Linear',
      mask_enables{4} = 'off';
      mask_enables{5} = 'off';
      mask_enables{6} = 'off';
   case 'FIR',
      mask_enables{4} = 'on';
      mask_enables{5} = 'on';
      mask_enables{6} = 'on';
   otherwise
      error('Unknown interpolation method');
   end
   imode = get_param(gcb,'InterpSource');
   switch imode
   case 'Specify via dialog'
	   mask_enables{2} = 'on';
   case 'Input port'
	   mask_enables{2} = 'off';
   otherwise
	   error('Unknown "Interpolation points" source');
   end
   set_param(gcb,'maskenables',mask_enables, ...
   				     'maskvisibilities',mask_visibilities);
      
case 'init'
   
   mode = varargin{1};
   if mode=='init',
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
   
otherwise
   error('unhandled case');
end

% ----------------------------------------------------------
function ports = get_labels(blk)   
mode = get_param(blk,'InterpSource');

% Input port labels:
switch mode
case 'Specify via dialog'
   ports.type1='input';
   ports.port1=1;
   ports.txt1='';
   
   ports.type2='input';
   ports.port2=1;
   ports.txt2='';
   
   ports.type3='output';
   ports.port3=1;
   ports.txt3='';
   
case 'Input port'
   ports.type1='input';
   ports.port1=1;
   ports.txt1='In';
   
   ports.type2='input';
   ports.port2=2;
   ports.txt2='Pts';
   
   ports.type3='output';
   ports.port3=1;
   ports.txt3='Out';
   
end

return
% end of dspblkinterp.m