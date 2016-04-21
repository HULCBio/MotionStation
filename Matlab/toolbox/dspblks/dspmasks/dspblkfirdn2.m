function varargout = dspblkfirdn2(action,varargin)
% DSPBLKFIRDN Mask dynamic dialog function for FIR decimation block

% Copyright 1995-2003 The MathWorks, Inc.
% $Date: 2004/04/12 23:06:31 $ $Revision: 1.9.4.3 $
if nargin==0, action = 'dynamic'; end
blk = gcbh;   % Cache handle to block

switch action
  case 'setup'
      
    h = varargin{1};
    D = varargin{2};
    [M,N] = size(h);
    if (M ~= 1 && N ~= 1)
       error('The filter coefficients must be a non-empty vector'); 
    end
    if (isempty(D) || D < 1 || fix(D) ~= D)
       error('Decimation factor must be a positive integer');
    end
    if(~isempty(h) && ~isempty(D))

      % Need to reshuffle the coefficients into phase order   
      len = length(h);
      h = flipud(h(:));
      if (rem(len, D) ~= 0)
         nzeros = D - rem(len, D);
         h = [zeros(nzeros,1); h];
      end
      len = length(h);
      nrows = len / D;
      % Re-arrange the coefficients
      h = flipud(reshape(h, D, nrows).');
    end
   
    % Gather up outputs
    varargout = {h};
   
  otherwise
    error('unhandled case');
end

% end of dspblkfirdn2.m
