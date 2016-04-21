%FILTER Execute ("run") adaptive filter.
%   Y = FILTER(H,X,D) applies an adaptive filter H to the input signal
%   in  the vector X and the desired signal in the vector D. The estimate
%   of the desired response signal is returned in Y.  X and D must be of
%   the same length.
%
%   [Y,E]   = FILTER(H,X,D) also returns the prediction error E.
%
%   If H.ResetBeforeFiltering is 'on' (default), the properties of H that
%   are updated when filtering (such as COEFFICIENTS and STATES) are set to
%   the value specified at construction before filtering (see examples
%   below). This is useful for reproducing the same outputs given the same
%   inputs and for "starting from scratch" every time.
%
%   To filter data in streaming mode (in a loop), set H.ResetBeforeFiltering
%   'off' so the history of the filter is conserved when invoking FILTER.
%
%    
%   EXAMPLE: (Adaptive linear prediction)
%     % Reset filter before reuse
%     x = randn(1000,1);        % Input
%     d1 = filter(1,[1,-.2],x); % Desired signal (AR signal)
%     mu = 0.005;               % Step size
%     h = adaptfilt.sd(2,mu);   % 2 tap sign-data adaptive filter
%     [y1,e1] = filter(h,x,d1); % Estimate of d1 and error
%     d2 = filter(1,[1,-.3],x); % New desired signal
%     [y2,e2] = filter(h,x,d2); % Filter coefficients and states are reset
%                               % to zero (default) prior to filtering.
% 
%     % Keep filter history
%     reset(h);                         % Start from zero again
%     h.ResetBeforeFiltering = 'off';   % Don't reset
%     [y1a,e1a]=filter(h,x,d1);         % Estimate and error
%     [y2a,e2a]=filter(h,x,d2);         % Estimate and error
%     plot([[e1;e2],[e1a;e2a]]);
%     legend('Prediction error when resetting filter',...
%       'Prediction error without resetting filter');
%
%   See also ADAPTFILT/RESET ADAPTFILT/MSESIM.

%   Author: R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/31 17:26:17 $

% Help for the ADAPTFILT filter method.

% [EOF]
