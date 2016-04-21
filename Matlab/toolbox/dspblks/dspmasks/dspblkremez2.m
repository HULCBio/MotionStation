function varargout = dspblkremez2(action, varargin)
% DSPBLKREMEZ2 Mask dynamic dialog function for Remez FIR filter block

% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:58:05 $ $Revision: 1.6 $

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
        owarn = warning;  % Remez will warn on "empty" inputs
        warning off;      % Suppress these warnings
        b=remez(s{:});
        warning(owarn);
    catch
        b=1;
    end
    
    h=abs(freqz(b,1,64)); h=h./max(h)*.75;
    w=((1:length(h))-1)/length(h);
    str = 'remez';
     
    varargout = {b,h,w,str};
    
otherwise
    error('Unhandled case');
end

% end of dspblkremez2.m
