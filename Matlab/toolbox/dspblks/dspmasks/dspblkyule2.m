function varargout = dspblkyule2(action, varargin)
% DSPBLKYULE2 Mask dynamic dialog function for Yule-Walker IIR filter block

% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:58:15 $ $Revision: 1.6 $

% Cache the block handle once:
blk = gcb;

switch action
case 'design'
   % Filter and icon design:

   N = varargin{1};
       
   % Check for inf or Nan filter order
   if isnan(N) | isinf(N),
       error('NaN or Inf not allowed for filter order.');
   end
   
   % Check for non-integer filter order
   if ~isequal(floor(N), N),
       error('Filter order must be an integer value.');
   end

   % Check for (filter order < 1)
   if N < 1,
       error('Filter order must be positive.');
   end

   % Inputs (N,F,A) could be empty if the mask failed evaluation
   % Trap errors:
   try
       [b,a] = yulewalk(varargin{:});
   catch
       b=1; a=1;
   end
   
   h = abs(freqz(b,a,64));
   h = h./max(h)*.75;
   w = (0:63)/63;
   str = 'yulewalk';
   
   % Gather up return arguments:
   varargout = {b,a,h,w,str};
   
otherwise
    error('Unhandled case');
end

% end of dspblkyule2.m
