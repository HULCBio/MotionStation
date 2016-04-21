function varargout = dspblksfw(action, varargin)
% DSPBLKSFW Signal Processing Blockset Signal From Workspace block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.9.4.2 $ $Date: 2004/04/12 23:07:13 $

blk = gcb;

switch action
case 'init'
   X = varargin{1};
   Ts = varargin{2};
   nsamps = varargin{3};
   
   if ~isempty(X) & ~isempty(Ts) & ~isempty(nsamps), 
     [m,n] = size(X);
     if(m==1 | n==1),
       U=X(:);  % input is a vector, force it to be a column
     else 
       U=X;  % Assume multiple columns = multiple signals
     end
     
     if (nsamps ~= 1)
       if nsamps<=0,
         error('Samples per frame must be > 0.');
       end
       
       % Buffer input to create new output:
       nchans = size(U,2);
       for i=1:nchans,
         V(:,:,i) = buffer(U(:,i),nsamps);
       end
       V = num2cell(V,[1 2]);
       U = cat(1,V{:}).';  % one time step per row
     end
     
     % Update sample time for output:
     newTs = Ts * nsamps;
     
     % Form structure input for Simulink From Workspace block
     s.time           = [];
     s.signals.values = U;
    else
     % Form structure input for Simulink From Workspace block
     s.time           = [];
     s.signals.values = 0;
     newTs            = Ts;
   end
   varargout(1:2) = {s, newTs};
end
% [EOF] dspblksfw.m
