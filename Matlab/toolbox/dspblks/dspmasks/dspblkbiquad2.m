function varargout = dspblkbiquad2(action,sosmatrix)
% DSPBLKBIQUAD2 Mask dynamic dialog function for Biquad filter

% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.6 $ $Date: 2002/12/23 22:30:39 $

switch action
   case 'icon'
      % Generate icon
      x=[0.05 0.95 NaN .25 .25 .75 .75 NaN .5 .5 NaN .25 .75];
      y=[.75 .75 NaN .75 .15 .15 .75 NaN .75 .15 NaN .45 .45];
		s = num2str(size(sosmatrix,1));
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

      [m,n]=size(sosmatrix);
      if ((m<1) | (n~=6))
         cr=sprintf('\n');
         error(['Size of SOS matrix must be Mx6.' ...
                cr 'See "zp2sos" or "ss2sos" for details.']);
      end
      
      h = double(sosmatrix(:,[1:3 5 6]));
      for i=1:size(h,1),
        h(i,:)=h(i,:)./double(sosmatrix(i,4));  % Normalize by a0
      end
      h=h.';
      
      varargout = {h};
   otherwise
      error('unhandled case');
end

% end of dspblkbiquad2.m
