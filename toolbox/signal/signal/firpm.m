function [h,err,res] = firpm(order, ff, aa, varargin)
%FIRPM Parks-McClellan optimal equiripple FIR filter design.
%   B=FIRPM(N,F,A) returns a length N+1 linear phase (real, symmetric
%   coefficients) FIR filter which has the best approximation to the
%   desired frequency response described by F and A in the minimax
%   sense. F is a vector of frequency band edges in pairs, in ascending
%   order between 0 and 1. 1 corresponds to the Nyquist frequency or half
%   the sampling frequency. A is a real vector the same size as F
%   which specifies the desired amplitude of the frequency response of the
%   resultant filter B. The desired response is the line connecting the
%   points (F(k),A(k)) and (F(k+1),A(k+1)) for odd k; FIRPM treats the
%   bands between F(k+1) and F(k+2) for odd k as "transition bands" or
%   "don't care" regions. Thus the desired amplitude is piecewise linear
%   with transition bands. The maximum error is minimized.
%
%   For filters with a gain other than zero at Fs/2, e.g., highpass
%   and bandstop filters, N must be even.  Otherwise, N will be
%   incremented by one. Alternatively, you can use a trailing 'h' flag to
%   design a type 4 linear phase filter and avoid incrementing N.
%
%   B=FIRPM(N,F,A,W) uses the weights in W to weight the error. W has one
%   entry per band (so it is half the length of F and A) which tells
%   FIRPM how much emphasis to put on minimizing the error in each band
%   relative to the other bands.
%
%   B=FIRPM(N,F,A,'Hilbert') and B=FIRPM(N,F,A,W,'Hilbert') design filters
%   that have odd symmetry, that is, B(k) = -B(N+2-k) for k = 1, ..., N+1.
%   A special case is a Hilbert transformer which has an approx. amplitude
%   of 1 across the entire band, e.g. B=FIRPM(30,[.1 .9],[1 1],'Hilbert').
%
%   B=FIRPM(N,F,A,'differentiator') and B=FIRPM(N,F,A,W,'differentiator')
%   also design filters with odd symmetry, but with a special weighting
%   scheme for non-zero amplitude bands. The weight is assumed to be equal
%   to the inverse of frequency times the weight W. Thus the filter has a
%   much better fit at low frequency than at high frequency. This designs
%   FIR differentiators.
%
%   B=FIRPM(...,{LGRID}), where {LGRID} is a one-by-one cell array
%   containing an integer, controls the density of the frequency grid. The
%   frequency grid size is roughly LGRID*N/2*BW, where BW is the fraction
%   of the total band interval [0,1] covered by F. LGRID should be no less
%   than its default of 16. Increasing LGRID often results in filters which
%   are more exactly equi- ripple, at the expense of taking longer to
%   compute.
%
%   [B,ERR]=FIRPM(...) returns the maximum ripple height ERR.
%
%   [B,ERR,RES]=FIRPM(...) returns a structure RES of optional results
%   computed by FIRPM, and contains the following fields:
%
%      RES.fgrid: vector containing the frequency grid used in
%                 the filter design optimization
%        RES.des: desired response on fgrid
%         RES.wt: weights on fgrid
%          RES.H: actual frequency response on the grid
%      RES.error: error at each point on the frequency grid (desired - actual)
%      RES.iextr: vector of indices into fgrid of extremal frequencies
%      RES.fextr: vector of extremal frequencies
%
%   % Example of a length 31 lowpass filter:
%   	h=firpm(30,[0 .1 .2 .5]*2,[1 1 0 0]);
%
%   % Example of a low-pass differentiator:
%   	h=firpm(44,[0 .3 .4 1],[0 .2 0 0],'differentiator');
%
%   % Example of a type 4 highpass filter:
%       h=firpm(25,[0 .4 .5 1],[0 0 1 1],'h');
%
%   See also FIRPMORD, CFIRPM, FIRLS, FIR1, FIR2, BUTTER, CHEBY1, CHEBY2,
%            ELLIP, FREQZ, FILTER, and, in the Filter Design Toolbox, FIRGR.

%   FIRPM is now a "function function", similar to CFIRPM, allowing you
%   to write a function which defines the desired frequency response.
%
%   B=FIRPM(N,F,'fresp',W) returns a length N+1 FIR filter which
%   has the best approximation to the desired frequency response
%   as returned by function 'fresp'.  The function is called
%   from within FIRPM using the syntax:
%                    [DH,DW] = fresp(N,F,GF,W);
%   where:
%   N is the filter order.
%   F is the vector of frequency band edges which must appear
%     monotonically between 0 and +1, where 1 is the Nyquist
%     frequency.  The frequency bands span F(k) to F(k+1) for k odd;
%     the intervals  F(k+1) to F(k+2) for k odd are "transition bands"
%     or "don't care" regions during optimization.
%   GF is a vector of grid points which have been linearly interpolated
%     over each specified frequency band by FIRPM, and determines the
%     frequency grid at which the response function will be evaluated.
%   W is a vector of real, positive weights, one per band, for use
%     during optimization.  W is optional; if not specified, it is set
%     to unity weighting before being passed to 'fresp'.
%   DH and DW are the desired complex frequency response and
%     optimization weight vectors, respectively, evaluated at each
%     frequency in grid GF.
%
%   The predefined frequency response function 'fresp' for FIRPM is
%   named 'firpmfrf', but you can write your own.
%   See the help for PRIVATE/FIRPMFRF for more information.
%
%   B=FIRPM(N,F,{'fresp',P1,P2,...},W) specifies optional arguments
%   P1, P2, etc., to be passed to the response function 'fresp'.
%
%   B=FIRPM(N,F,A,W) is a synonym for B=FIRPM(N,F,{'firpmfrf',A},W),
%   where A is a vector of response amplitudes at each band edge in F.
%
%   FIRPM normally designs symmetric (even) FIR filters. B=FIRPM(...,'h') and

%   B=FIRPM(...,'d') design antisymmetric (odd) filters. Each frequency
%   response function 'fresp' can tell FIRPM to design either an even or odd
%   filter in the absense of the 'h' or 'd' flags.  This is done with
%         SYM = fresp('defaults',{N,F,[],W,P1,P2,...})
%   FIRPM expects 'fresp' to return SYM = 'even' or SYM = 'odd'.
%   If 'fresp' does not support this call, FIRPM assumes 'even' symmetry.

%   Author(s): L. Shure, 3-27-87
%          L. Shure, 6-8-88, revised
%          T. Krauss, 3-17-93, fixed hilbert bug in m-file version
%          T. Krauss, 3-2-97, consolidated grid generation, function-function

%        D. Shpak, 7-15-99, incorporated C-mex firpm function
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:17:55 $

%   References:
%     [1] "Programs for Digital Signal Processing", IEEE Press
%          John Wiley & Sons, 1979, pg. 5.1-1.
%     [2] "Selected Papers in Digital Signal Processing, II",
%          IEEE Press, 1976, pg. 97.

nargchk(3,6,nargin);

if order < 3
    error('Filter order must be 3 or more.');
end
%
% Define default values for input arguments:
%
ftype = 'f';
wtx = ones(fix((1+length(ff))/2),1);
lgrid = 16;   % Grid density (should be at least 16)
%
% parse inputs and alter defaults
%
%  First find cell array and remove it if present
for i=1:length(varargin)
    if iscell(varargin{i})
        lgrid = varargin{i}{:};
        if lgrid < 16,
            warning('Grid density should be at least 16.');
        end
        if lgrid < 1,
            error('Grid density should be positive.');
        end
        varargin(i) = [];
        break
    end
end
if length(varargin) == 1
    if isstr(varargin{1})
        ftype = varargin{1};
    else
        wtx = varargin{1};
    end
elseif length(varargin)==2
    wtx = varargin{1};
    ftype = varargin{2};
end

if length(ftype)==0, ftype = 'f'; end

if length(ftype) == 1 & ftype(1)=='m'
    error('M-file version of REMEZ is no longer supported.');
end
%
% Error checking
%
if rem(length(ff),2)
    error('The number of frequency points must be even.');
end
if any((ff < 0) | (ff > 1))
    error('Frequencies must lie between 0 and 1.');
end
df = diff(ff);
if (any(df < 0))
    error('Frequencies must be non-decreasing.');
end
if length(wtx) ~= fix((1+length(ff))/2)
    error('There should be one weight per band.');
end

if (any(sign(wtx) == 1) && any(sign(wtx) == -1)) || any(sign(wtx) == 0),
    error('All weights must be greater than zero.');
end

% Determine "Frequency Response Function" (frf)
%
if isstr(aa)
    frf = aa;
    frf_params = {};
elseif iscell(aa)
    frf = aa{1};
    frf_params = aa(2:end);
else
    % Check for valid filter length
    % ideally we would check in all cases, for now we only do it
    % when aa is a vector

    exception = 0;
    if any(strmatch(lower(ftype),{'differentiator','hilbert'})),
        exception = 1;
    end
    [order,msg1,msg2] = firchk(order,ff(end),aa,exception);
    error(msg1);
    if ~isempty(msg2),
        msgtoadd = sprintf(['\nAlternatively, you can pass a trailing ''h'' argument,\n',...
            'as in firpm(N,F,A,W,''h''), to design a type 4 linear phase filter.']);
        msg2 = sprintf('%s%s',msg2,msgtoadd);
    end
    warning(msg2);

    frf = 'firpmfrf';
    frf_params = { aa, strcmp(lower(ftype(1)),'d') };
end


%
% Determine symmetry of filter
%
sign_val = 1.0;
nfilt = order + 1;        % filter length
nodd = rem(nfilt,2);      % nodd == 1 ==> filter length is odd
% nodd == 0 ==> filter length is even

hilbert = 0;
if ftype(1) == 'h' || ftype(1) == 'H'
    ftype = 3;  % Hilbert transformer
    hilbert = 1;
    if ~nodd
        ftype = 4;
    end
elseif ftype(1) == 'd' || ftype(1) == 'D'
    ftype = 4;  % Differentiator
    sign_val = -1;
    if nodd
        ftype = 3;
    end
else
    % If symmetry was not specified, call the fresp function
    % with 'defaults' string and a cell-array of the actual
    % function call arguments to query the default value.
    h_sym = eval(...
        'feval(frf, ''defaults'', {order, ff, [], wtx, frf_params{:}} )',...
        '''even''');

    if ~any(strcmp(h_sym,{'even' 'odd'})),
        error(['Invalid default symmetry option "' h_sym '" returned ' ...
            'from response function "' frf '".  Must be either ' ...
            '''even'' or ''odd''.']);
    end

    switch h_sym
        case 'even'
            ftype = 1;  % Regular filter
            if ~nodd
                ftype = 2;
            end
        case 'odd'
            ftype = 3;  % Odd (antisymmetric) filter
            if ~nodd
                ftype = 4;
            end
    end
end

if (ftype == 3 || ftype == 4)
    neg = 1;  % neg == 1 ==> antisymmetric imp resp,
else
    neg = 0;  % neg == 0 ==> symmetric imp resp
end


%
% Create grid of frequencies on which to perform firpm exchange iteration
%
grid = firpmgrid(nfilt,lgrid,ff,neg,nodd);
while length(grid) <= nfilt,
    lgrid = lgrid*4;  % need more grid points
    grid = firpmgrid(nfilt,lgrid,ff,neg,nodd);
end
%
% Get desired frequency characteristics at the frequency points
% in the specified frequency band intervals.
%
% NOTE! The frf needs to see normalized frequencies in the range
% [0,1].
[des,wt] = feval(frf,...
    order, ff, grid, wtx, frf_params{:});

%
% Call remezmex
%
if (exist('remezmex') == 3)     % Call MEX-file
    [h,err,iext,ret_code,iters] = remezmex(nfilt,ff,grid,des,wt,ftype);
else                                   % Call M-file
    error('Unable to find remezmex executable');
end

if ret_code == -1
    error(sprintf('%s\n%s\n%s\n%s%s', ...
         'Design did not converge:', ...
         '1) Check specs.', ...
         '2) Try a higher filter order.', ...
         '3) For multiband filters, could try making the transition ',...
            'regions more similar in width.'));
elseif ret_code == -2        
    msg1 = '  *** FAILURE TO CONVERGE ***';
    msg2 = '  Possible cause is machine rounding error';
    msg3 = '  but please check your filter specifications\n';
    msg4 = '  Number of iterations = ';
    msg5 = '  If the number of iterations exceeds 3, the design may';
    msg6 = '  be correct, but should be verified with freqz.';
    msg7 = '  If err is very small, filter order may be too high.';
    warning(sprintf('%s\n%s\n%s\n%s%d\n%s\n%s\n%s', ...
            msg1, msg2, msg3, msg4, iters(1), msg5, msg6, msg7));
end

err = abs(err);

h = h * sign_val;

%
% arrange 'results' structure
%
if nargout > 2
    res.fgrid = grid(:);
    res.H = freqz(h,1,res.fgrid*pi);
    if neg  % asymmetric impulse response
        linphase = exp(sqrt(-1)*(res.fgrid*pi*(order/2) - pi/2));
    else
        linphase = exp(sqrt(-1)*res.fgrid*pi*(order/2));
    end
    if hilbert == 1  % hilbert
        res.error = real(des(:) + res.H.*linphase);
    else
        res.error = real(des(:) - res.H.*linphase);
    end
    res.des = des(:);
    res.wt = wt(:);
    res.iextr = iext(1:end);
    res.fextr = grid(res.iextr);  % extremal frequencies
    res.fextr = res.fextr(:);
end

%--------------------------------------------------------------------------
function grid = firpmgrid(nfilt,lgrid,ff,neg,nodd);
% firpmgrid
%    Generate frequency grid
nfcns = fix(nfilt/2);
if nodd == 1 & neg == 0
    nfcns = nfcns + 1;
end
grid(1) = ff(1);
delf = 1/(lgrid*nfcns);
% If value at frequency 0 is constrained, make sure first grid point
% is not too small:
if neg ~= 0 & grid(1) < delf
    grid(1) = delf;
end
j = 1;
l = 1;
while (l+1) <= length(ff)
    fup = ff(l+1);
    grid = [grid (grid(j)+delf):delf:(fup+delf)];
    jend = length(grid);
    grid(jend-1) = fup;
    j = jend;
    l = l + 2;
    if (l+1) <= length(ff)
        grid(j) = ff(l);
    end
end
ngrid = j - 1;
% If value at frequency 1 is constrained, remove that grid point:
if neg == nodd & (grid(ngrid) > 1-delf)
    if ff(end-1) < 1-delf
        ngrid = ngrid - 1;
    else
        grid(ngrid) = ff(end-1);
    end
end
grid = grid(1:ngrid);

% EOF

