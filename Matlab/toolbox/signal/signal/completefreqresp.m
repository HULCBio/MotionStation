function [resp, w] = completefreqresp(resp, fs, wmin, wmax, varargin)
%COMPLETEFREQRESP Complete the frequency response for the specified range
%   Inputs:
%       resp    -   A filter response from 0 to 2*pi
%       fs      -   The sampling Frequency of that response
%       fmin    -   The minimum frequency to return
%       fmax    -   The maximum frequency to return
%       shift   -   Optional input that shifts positive resps down and
%                   negative resps up
%
%   Example #1:
%
%   [b,a] = butter(5,.5);
%   G = dfilt.df2t(b,a);
%   h = freqz(G, 512, 'whole');
%   [h, w] = completefreqresp(h, 90, -150, 150);
%   plot(w, 20*log10(abs(h)))
%
%   Example #1:
%
%   [b,a] = butter(5,.5);
%   G = dfilt.df2t(b,a);
%   p = phasez(G, 512, 'whole');
%   [pu, w] = completefreqresp(p, 90, -150, 150);
%   [ps, w] = completefreqresp(p, 90, -150, 150, 2*pi);
%   plot(w, pu, w, ps)

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/05/04 01:39:16 $

error(nargchk(4,5,nargin));
opts = parseinputs(varargin{:});

[resp, w] = completeresp(resp, fs, wmin, wmax, opts);
[resp, w] = truncateresp(resp, w,  wmin, wmax);

% ----------------------------------------------------------------
function [resp, w] = completeresp(resp, fs, wmin, wmax, opts)

% Make sure the response is a column vector, this makes calculations easier.
lorig    = length(resp);

period = opts.periodicity;

resp     = resp(:);
fsmax    = max(abs([wmin wmax]));
numresps = ceil(fsmax/(fs*period/2));

if opts.periodicity == 4,
    if opts.flip, m = -1;
    else,         m = 1; end
    resp = [resp; flipud(resp)*m];
end

resp     = repmat(resp, 2*numresps, 1);

w = linspace(0, fs*(numresps*period/2-1/lorig), length(resp)/2)';
w = [w-fs*numresps*period/2; w];

% If there is a shift, apply it
if opts.shift ~= 0,
    
    % Build a shift value for each of the responses calculated above
    shift = [opts.shift*numresps:-opts.shift:-opts.shift*(numresps-1)];
    
    % Expand the shift vector for the length of the response (it is now a
    % matrix)
    shift = repmat(shift, length(resp)/numresps/2, 1);
    
    % Reshape the shift matrix so that it is a vector of the same length as
    % the response.
    shift = reshape(shift, length(resp), 1);
    
    % Add the shift to the response.
    resp  = shift+resp;
end

% ----------------------------------------------------------------
function [resp, w] = truncateresp(resp, w, wmin, wmax)

% Exclude the highest frequency asked for
lindx       = find(w >= wmax);
w(lindx)    = [];
resp(lindx) = [];

% Include the lowest frequency asked for
findx       = find(w < wmin);
w(findx)    = [];
resp(findx) = [];

% ----------------------------------------------------------------
function opts = parseinputs(opts)

if ~nargin, opts = struct('periodicity', 2, 'flip', 0, 'shift', 0); end

if ~isfield(opts, 'periodicity'), opts.periodicity = 2; end
if ~isfield(opts, 'flip'),        opts.flip        = 0; end
if ~isfield(opts, 'shift'),       opts.shift       = 0; end

% [EOF]
