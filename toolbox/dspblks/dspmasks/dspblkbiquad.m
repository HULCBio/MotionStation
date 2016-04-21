function varargout = dspblkbiquad(action,sos,frame,nchans)
% DSPBLKBIQUAD Mask dynamic dialog function for Biquad filter

% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/12/23 22:30:38 $

blk=gcb;
if nargin==0, action = 'dynamic'; end
frame_based = get_param(blk, 'frame');

switch action
   case 'icon'
      % Generate icon
      x=[0.05 0.95 NaN .25 .25 .75 .75 NaN .5 .5 NaN .25 .75];
      y=[.75 .75 NaN .75 .15 .15 .75 NaN .75 .15 NaN .45 .45];
	  s = num2str(size(sos,1));
      varargout(1:3)={x,y,s};
      
   case 'init'
      % Reorder and scale SOS matrix:
      %
      % The SOS is an L by 6 matrix which contains the coefficients
      % of each second-order section in its rows:
      %  SOS = [ b01 b11 b21  a01 a11 a21 
      %          b02 b12 b22  a02 a12 a22
      %          ...
      %          b0L b1L b2L  a0L a1L a2L ]
      %
      % We scale and resize follows:
      % h = [ [b01 b11 b21 a11 a21] / a01
      %       [b02 b12 b11 a12 a22] / a02
      %         ...
      %       [b0L b1L b2L a1L a2L ] / a0L ]

      [m,n]=size(sos);
      if (m<1) | (n~=6),
         cr=sprintf('\n');
         error(['Size of SOS matrix must be Mx6.' ...
                cr 'See "zp2sos" or "ss2sos" for details.']);
      end
      
      h = sos(:,[1:3 5 6]);
      for i=1:size(h,1),
         h(i,:)=h(i,:)./sos(i,4);  % Normalize by a0
      end
      h=h.';
      
      % If not frame-based, set number of channels to -1
      if (frame==0), nchans=-1; end
      
      varargout={h,nchans};
      
   case 'dynamic'     
      % Execute dynamic dialogs
      
      % The fourth dialog (checkbox for frame-based inputs)
      % disables/enables the fifth dialog (number of channels).
      
      % Get status of frame checkbox
      mask_enables = get_param(blk,'maskenables');
      mask_enables{4} = frame_based;
      set_param(blk,'maskenables',mask_enables);
      
   otherwise
      error('unhandled case');
end

% end of dspblkbiquad.m
