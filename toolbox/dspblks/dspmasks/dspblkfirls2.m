function varargout = dspblkfirls2(action, varargin)
% DSPBLKFIRLS2 Mask dynamic dialog function for least-squares FIR filter block

% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:58:08 $ $Revision: 1.6 $

% Cache the block handle once:
blk = gcb;

switch action
case 'design'
    N = varargin{2};

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

    s = {varargin{2:nargin-1}};
    switch varargin{1},
    case 2, s={s{:},'h'};
    case 3, s={s{:},'d'};
    end
    
    % Inputs could be empty if the mask failed evaluation
    % Trap errors:
    try
        b=firls(s{:});
    catch
        b=1;
    end
    
    h=abs(freqz(b,1,64)); h=h./max(h)*.75;
    w=((1:length(h))-1)/length(h); 
    str = 'firls'; 
    
    % Gather up return arguments:
    varargout = {b,h,w,str};
        
otherwise
    error('Unhandled case');
end

% end of dspblkfirls2.m
