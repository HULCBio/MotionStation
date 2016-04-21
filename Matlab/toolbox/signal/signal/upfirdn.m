function Y = upfirdn(x,h,varargin)
%UPFIRDN  Upsample, apply a specified FIR filter, and downsample a signal.
%   UPFIRDN(X,H,P,Q) is a cascade of three systems applied to input signal X:
%         (1) Upsampling by P (zero insertion).  P defaults to 1 if not 
%             specified.
%         (2) FIR filtering with the filter specified by the impulse response 
%             given in H.
%         (3) Downsampling by Q (throwing away samples).  Q defaults to 1 if not 
%             specified.
%   UPFIRDN uses an efficient polyphase implementation.
%
%   Usually X and H are vectors, and the output is a (signal) vector. 
%   UPFIRDN permits matrix arguments under the following rules:
%   If X is a matrix and H is a vector, each column of X is filtered through H.
%   If X is a vector and H is a matrix, each column of H is used to filter X.
%   If X and H are both matrices with the same number of columns, then the i-th
%      column of H is used to filter the i-th column of X.
%
%   Specifically, these rules are carried out as follows.  Note that the length
%   of the output is Ly = ceil( ((Lx-1)*P + Lh)/Q ) where Lx = length(X) and 
%   Lh = length(H). 
%
%      Input Signal X    Input Filter H    Output Signal Y   Notes
%      -----------------------------------------------------------------
%   1) length Lx vector  length Lh vector  length Ly vector  Usual case.
%   2) Lx-by-Nx matrix   length Lh vector  Ly-by-Nx matrix   Each column of X
%                                                            is filtered by H.
%   3) length Lx vector  Lh-by-Nh matrix   Ly-by-Nh matrix   Each column of H is
%                                                            used to filter X.
%   4) Lx-by-N matrix    Lh-by-N matrix    Ly-by-N matrix    i-th column of H is
%                                                            used to filter i-th
%                                                            column of X.
%
%   For an easy-to-use alternative to UPFIRDN, which does not require you to 
%   supply a filter or compensate for the signal delay introduced by filtering,
%   use RESAMPLE.
%
%   EXAMPLE: Sample-rate conversion by a factor of 147/160 (used to
%     downconvert from 48kHz to 44.1kHz)
%        L = 147; M = 160;                   % Interpolation/decimation factors.
%        N = 24*M;
%        h = fir1(N,1/M,kaiser(N+1,7.8562));
%        h = L*h; % Passband gain = L
%        Fs = 48e3;                           % Original sampling frequency: 48kHz
%        n = 0:10239;                         % 10240 samples, 0.213 seconds long
%        x  = sin(2*pi*1e3/Fs*n);             % Original signal, sinusoid at 1kHz
%        y = upfirdn(x,h,L,M);                % 9408 samples, still 0.213 seconds
%
%        % Overlay original (48kHz) with resampled signal (44.1kHz) in red.
%        stem(n(1:49)/Fs,x(1:49)); hold on 
%        stem(n(1:45)/(Fs*L/M),y(13:57),'r','filled'); 
%        xlabel('Time (sec)');ylabel('Signal value');
%  
%   See also RESAMPLE, INTERP, DECIMATE, FIR1, INTFILT, MFILT/FIRSRC in the
%   Filter Design Toolbox.
  
%   Author(s): Paul Pacheco
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2002/12/19 10:34:29 $

%   This M-file validates the inputs, sets defaults, and then calls the C MEX-file.

% Validate number of I/O args.
error(nargchk(2,4,nargin));
error(nargoutchk(0,1,nargout));

% Force to be a column if input is a vector
[mx,nx] = size(x);
if find([mx nx]==1),
  x = x(:);  % columnize it.
end
[Lx,nChans] = size(x);

% Force to be a column if filter is a vector
if find(size(h)==1),
  h = h(:);  % columnize it.
end
[Lh,hCols] = size(h);

% Validate input args and define defaults.
[p,q,msg] = validateinput(x,h,varargin);
error(msg);

% Call the MEX-file
Y = upfirdnmex(x,h,p,q,Lx,Lh,hCols,nChans);
if mx==1,
  % Convert output to be a row vector.
  Y = Y(:).';
end


%----------------------------------------------------------------------
function [p,q,errmsg] = validateinput(x,h,opts);

% Default values
p = 1;
q = 1;
errmsg = '';

% Validate 1st two input args: signal and filter.
if isempty(x) | issparse(x) | ~isnumeric(x),
  errmsg = 'The input signal X must be a double-precision vector.';
  return;
end
if isempty(h) | issparse(h) | ~isnumeric(h),
  errmsg = 'The filter H must be a double-precision vector.';
  return;
end

% At this point x and h have been columnized if necessary.
% Make sure x and h have the same number of columns.
[Lx,nChans] = size(x);
[Lh,hCols]  = size(h);
if (hCols > 1) & (hCols ~= nChans),
  error('Signal X and filter H must have the same number of columns.');
end

% Validate optional input args: upsample and downsample factors.
nopts = length(opts);
if (nopts >= 1),
    p = opts{1};
    if isempty(p) | ~isnumeric(p) | p<1 | ~isequal(round(p),p), 
        errmsg = 'The upsample factor P must be a positive, double-precision, integer.';
        return;
        
    elseif (nopts == 2),
        q = opts{2};
        if isempty(q) | ~isnumeric(q) | q<1 | ~isequal(round(q),q),
            errmsg = 'The downsample factor Q must be a positive, double-precision, integer.';
            return;
        end
    end
end

% [EOF]

