function varargout=impz(obj,varargin)
%IMPZ Quantized filter impulse response.
%   [H,T] = IMPZ(Hq) computes the response of the quantized filter Hq to an
%   impulse.  The response is returned in column vector H and the 
%   corresponding sample times are provided in T (T = [0 1 2 ... N-1]')
%   where N is determined automatically.
%
%   [H,T] = IMPZ(Hq,N) computes N samples of the impulse response.
%   If N is a vector of integers, the impulse response is computed only at
%   those integer values (0 is the origin).
%
%   [H,T] = IMPZ(Hq,N,Fs) computes N samples and scales T so that
%   samples are spaced 1/Fs units apart.  If N is [], N is computed
%   automatically.
%
%   [H,T,Hr] = IMPZ(Hq,...) returns the reference response Hr to an impulse.
%
%   IMPZ(Hq,...) with no output arguments plots the quantized and its
%   corresponding reference impulse response for quantized filter Hq using a
%   STEM plot.  For complex filters, only the real part is plotted.
%
%   Example:
%      [b,a] = butter(3,0.5);
%      Hq = qfilt('df1t',{b a},'format',[8 7]);
%      impz(Hq)
%
%   See also QFILT/FREQZ, QFILT/ZPLANE, QFILT/FILTER.

%   Author: Chris Portal
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.21 $  $Date: 2002/04/14 15:29:58 $

error(nargchk(1,3,nargin))

if nargout>3,
   error('Too many output arguments.')
end

% Parse inputs and defaults setup.
switch nargin
case 1,
   N = lclNdefault(obj);
   Fs = 1;
case 2,
   N = varargin{1};
   Fs = 1;
case 3,
   N = varargin{1};
   Fs = varargin{2};
end

if nargin>1,
   % Error check.
   if ~isnumeric(N) | ~isnumeric(Fs),
      error('N and Fs must contain numeric values.')
   end
   % Catch N = [] case.
   if isempty(N),
      N = lclNdefault(obj);
   end
end

% Initialize variables.
obj = copyobj(obj); % Copy the object because we will be changing properties
NN = [];
M = 0;

% Vector of sample intervals (N) was specified.
% Add one additional interval to catch the largest interval requested
% since intervals are zero based.
% Then locate the starting interval to be the lowest interval requested,
% or 0.
if length(N)>1
   NN = round(sort(N));
   N = max(NN)+1;
   M = min(min(NN),0);
end

% Construct the time vector.
% Zero based interval counting, so subtract one from the total number
% of intervals N.
t=(M:N-1)';

% Pre-quantize the input without warning
w = warning;
warning off;
qinput = quantizer(obj,'input');
ur = double(t==0);                  % Reference input
uq = quantize(qinput,ur);   % Quantized input
warning(w)

% Call the filter with an impulse input.
qoutput = filter(obj,uq);

% Only calculate the doubles for comparison if we will be plotting, or if
% it was requested as an output argument, otherwise, skip this operation.
switch nargout,
case {0,3},
   % Use the doubles mode for comparison.
   set(obj,'Mode','double')
   dbloutput = filter(obj,double(ur));
   if ~isempty(NN),
      % Pull out the specified sample intervals if specific intervals were
      % requested.
      dbloutput = dbloutput(NN-M+1);
   end
end

% Pull out the specified sample intervals if specific intervals were
% requested.
if ~isempty(NN),
   qoutput = qoutput(NN-M+1);
   t = t(NN-M+1);
end

% Space the samples 1/Fs apart.
t = t/Fs;

% Parse output arguments.
switch nargout
case 0,
   % Prepare any existing plots that may already be open:
   newplot
   
   % Turn off zoom in case it is on.  This is a bug that has been gecked (56868):
   zoom off
   
   % Define some variables:
   Figh = gcf;
   Axh = gca;
   
   % Pop the figure forward
   figure(Figh)
   
   % Set the axes such that we can add multiple plots:
   set(Figh,'NextPlot','add')
   
   % Ignore the imaginary parts of the quantized and reference response:
   if ~isreal(qoutput) | ~isreal(dbloutput),
      qoutput = real(qoutput);
      dbloutput = real(dbloutput);      
      warning('Imaginary parts of the impulse response were ignored.')
   end
   
   % Make stem plots for quantized:
   qh = stem(t,qoutput,'sk');
   
   % In case we are zoomed in on the axis, we set the axis nextplot
   % to be add so that the first stem plot will reset the axis limits
   % to the correct x and y lims so that the entire plot is seen.
   % This is equivalent to "hold on"
   set(Axh,'Nextplot','add')
   
   % Make stem plots for unquantized:
   dblh = stem(t,dbloutput,'or');
   
%   % Set the marker sizes:
%   set(qh,'MarkerSize',8)
%   set(dblh,'MarkerSize',5)
   
   % Create the legend and set the axis limits correctly
   set(Axh,'xlim',[t(1) t(end)])
   legend([qh(1) dblh(1)],'Quantized response','Reference response');
   
   % Turn the plot holding to off.
   set(Figh,'NextPlot','replace')
   set(Axh,'NextPlot','replace')
case 1,
   varargout{1} = qoutput;
case 2,
   varargout{1} = qoutput;
   varargout{2} = t;
case 3,
   varargout{1} = qoutput;
   varargout{2} = t;
   varargout{3} = dbloutput;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function N = lclNdefault(obj)
% Use Signal's IMPZ to determine how
% many N samples intervals we need.

% Convert the Hq filter to transfer function form:
[Bq,Aq,Br,Ar] = qfilt2tf(obj);

% Run Signal's IMPZ and calculate N:
[Hsig,Tsig] = impz(Br,Ar);
N = length(Tsig);

% If we have a straight through filter (b and a equal 1),
% then we need one additional sample interval so we can
% determine the correct axis xlim when plotting.
if N==1,
   N = N+1;
end

