function varargout = dspblktsfw(action, X, nsamps)
% DSPBLKTSFW Signal Processing Blockset Triggered Signal From Workspace block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.7.4.2 $ $Date: 2004/04/12 23:07:28 $

blk = gcb;

switch action
case 'icon'
   % Draw trigger icons:
   [px,py] = dsptrigicon(blk,X);
   varargout={px,py};
   
case 'init'
   if ~isempty(X) & ~isempty(nsamps), 
      [m,n] = size(X);
      if(m==1 | n==1),
         U=X(:);  % input is a vector, force it to be a column
      else 
         U=X;  % Assume multiple columns = multiple signals
      end
      
      if (nsamps~=1),
         if nsamps<=0,
            error('Samples per frame must be > 0.');
         end
         
         % Buffer input to create new output:
         nchans = size(U,2);
         for i=1:nchans,
            V(:,:,i) = buffer(U(:,i),nsamps);
         end
         V = num2cell(V,[1 2]);
         varargout{1} = cat(1,V{:}).';  % one time step per row
      else
         varargout{1} = U;
      end
   else
      varargout{1} = [0,0];
   end
end

return

% -----------------------------------------------------------

function [x,y]=dsptrigicon(blk,trig)
% DSPTRIGICON Compute trigger icon
% BLK is the full path name of block, and TRIG is the
% trigger type, where 1=rising, 2=falling, and 3=either.

% Get block height and width in pixels:
ppos = get_param(blk,'position');
dx=ppos(3)-ppos(1);
dy=ppos(4)-ppos(2);

x0=2;
y0=floor(dy/2);

if trig==1,
   % rising
   x=[0 4 4 8 NaN 2 4 6];
   y=[-3 -3 3 3 NaN -1 1 -1];
elseif trig==2,
   % falling
   x=[0 4 4 8 NaN 2 4 6];
   y=[3 3 -3 -3 NaN 1 -1 1];
else
   % either
   x = [0 2 2 4 NaN 0 2 4 NaN 6 8 8 10 NaN 6 8 10];
   y = [-4 -4 4 4 NaN -2 2 -2 NaN 4 4 -4 -4 NaN 2 -2 2];
end
x=x+x0; y=y+y0;

return

% [EOF] dspblktsfw.m
