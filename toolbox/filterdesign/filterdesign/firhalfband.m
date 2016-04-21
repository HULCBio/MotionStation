function b = firhalfband(N,fp,varargin)
%FIRHALFBAND  Halfband FIR filter design.
%   B = FIRHALFBAND(N,Fo) designs a lowpass N-th order halfband FIR filter
%   with an equiripple characteristic.
%
%   The order, N, must be even. Fo determines the passband edge frequency,
%   it must satisfy 0 < Fo < 1/2 where 1/2 corresponds to pi/2
%   [rad/sample].
%
%   B = FIRHALFBAND(N,WIN) where WIN is an N+1 length vector, uses the
%   truncated and windowed impulse response method instead of the
%   equiripple method. The ideal impulse response is truncated to length N
%   + 1 and then multiplied point-by-point with the window specified in
%   WIN. 
%
%   B = FIRHALFBAND(N,DEV,'dev') designs a lowpass N-th order halfband FIR
%   filter with an equiripple characteristic and maximum passband/stopband
%   ripple given by DEV.
%
%   B = FIRHALFBAND('minorder',Fo,Dev) and B =
%   FIRHALFBAND('minorder',Fo,Dev,'kaiser') design a minimum order filter
%   with passband edge Fo and peak passband and stopband ripple Dev
%   (scalar) using the equiripple and Kaiser window methods respectively.
% 
%   B = FIRHALFBAND(...,'high') returns a highpass halfband FIR filter. For
%   this case, Fo represents the stopband edge frequency.
%
%   B = FIRHALFBAND(...,'minphase') designs a minimum-phase FIR filter such
%   that it is a spectral factor of a halfband filter (H =
%   conv(B,FLIPLR(B)) is a halfband filter). This is useful for the design
%   of perfect reconstruction 2 channel FIR filter banks. This option is
%   not available for window-based designs. For this case, the order must
%   be odd.
%
%   EXAMPLE 1: Design a minimum order halfband filter with given max ripple
%      b = firhalfband('minorder',.45,0.0001);
%      h = dfilt.dfsymfir(b); 
%      impz(h); % The impulse response is zero every other sample
%
%   EXAMPLE 2: Design a halfband filter with given max ripple
%      b = firhalfband(98,0.0001,'dev');
%      h = mfilt.firdecim(2,b); % Create a polyphase decimator
%      freqz(h); % 80 dB attenuation in the stopband
%
%   See also FIRNYQUIST, FIRGR, FIR1, FIRLS, FIRCEQRIP, MFILT, DFILT,
%   FDESIGN/HALFBAND, FDESIGN/NYQUIST.

%   References: 
%     [1] T. Saramaki, Finite impulse response filter design, in 
%          Handbook for Digital Signal Processing. S.K. Mitra and
%          J.F. Kaiser Eds. Wiley-Interscience, N.Y., 1993, Chapter 4.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.13.4.3 $  $Date: 2004/04/12 23:25:27 $

error(nargchk(2,5,nargin));

[flags,msg] = validateNparseinput(N,fp,varargin{:});
error(msg);

if flags.winflag,
    % Design using the window method
    b = windowdesign(N,fp,flags,varargin{:}); % fp is window vector
elseif flags.firceqripflag,
    % Design using firceqrip
    b = firceqripdesign(N,fp,flags); % fp is DEV
else
	% Design via firpm
	b = firpmdesign(N,fp,flags,varargin{:}); % fp is passband frequency
end

% Convert to highpass if so wanted
if ~flags.lowpassflag,
	b = firlp2hp(b); 
end

%-------------------------------------------------------------
function b = windowdesign(N,fp,flags,dev,varargin)
% Design via window method, don't use fir1 so we get exact zeros
% every other sample, and exactly 0.5 at the middle sample

if flags.minphase,
    % Minphase option not supported for window method
    error(generatemsgid('minphaseWin'),...
		'The minimum-phase option is not supported for window-based designs.');    
end

if flags.minordflag,
	% Estimate the required order
	[N,fp] = estimatekaiserord(fp,dev);
end

b = lowpasslband(N,2,fp);


%-------------------------------------------------------------
function [N,fp] = estimatekaiserord(fp,Dev)
% Estimate minimum order filter to meet peak ripple


[N,wn,beta] = kaiserord([fp,1-fp],[1 0],[Dev,Dev]);
% Increase N to next integer such that N/2 is odd integer
N = adjustord(N);

fp = kaiser(N+1,beta); % fp is a window vector in windowdesign

%-------------------------------------------------------------
function ddev = computeddev(dev)
ddev = dev^2/2*(0.5+dev^2/2)/0.5;
%-------------------------------------------------------------
function b = computeminphase(bnonneg,ddev)

N = ceil(length(bnonneg)/2);
bnonneg(N) = bnonneg(N) + ddev; % Make zerophase nonnegative
bnonneg = 0.5/(0.5+ddev)*bnonneg; % Normalize to have gain 0.5 at 0.5
b = firminphase(bnonneg);
%-------------------------------------------------------------
function b = firceqripdesign(N,dev,flags)
% Halfband design via firceqrip

ddev = computeddev(dev);
if flags.minphase,
    bnonneg = firceqrip(2*N,0.5,[ddev,ddev]); % Design double-order filter
	b = computeminphase(bnonneg,ddev);	
else
    b = firceqrip(N,0.5,[dev,dev]);
    % Force exact zeros and exact 0.5 in the middle
    b = forcehalfband(b);
end
%-------------------------------------------------------------
function b = firpmdesign(N,fp,flags,dev,varargin)
% Halfband design via firpm

if flags.minphase,
    if flags.minordflag,
        ddev = dev^2/2*(0.5+dev^2/2)/0.5;
        bnonneg = firgr('mineven',[0, fp, 1-fp, 1],[1 1 0 0],[ddev,ddev]);
		b = computeminphase(bnonneg,ddev);
	else
        b = minphasefirpmdesign(N,fp);
    end
else
    
    if flags.minordflag,
        % Estimate the required order
        N = estimatefirpmord(flags,fp,dev);
    end
    
    % If order is multiple of 4, design for order-2 and add 2 zeros
    mult4 = false;
    if rem(N,4) == 0,
        mult4 = true;
        N = N - 2;
    end
    
    % Design a type 2 filter with one band
    btemplate = firgr(N/2,[0 2*fp],[.5 .5],'2');
    
    % Insert zeros every other sample
    b(1:2:N+1) = btemplate;
    
    % Add a discrete impulse of 1/2 height
    b(N/2+1) = 0.5;
    
    % Add two zeros for orders that are multiples of 4
    if mult4,
       b = [0, b, 0];
    end
end
%-------------------------------------------------------------
function N = estimatefirpmord(flags,fp,Dev)
% Estimate minimum order filter to meet peak ripple

N = firpmord([fp,1-fp],[1 0],[Dev,Dev]);

%Increase N to next integer such that N/2 is odd integer
N = adjustord(N);


%-------------------------------------------------------------
function b = minphasefirpmdesign(N,fp)

fedges = [fp, 1-fp];
[bnonneg,err] = firgr(2*N,[0 fedges 1],[1 1 0 0]); % Design double-order filter
b = computeminphase(bnonneg,err);

%-------------------------------------------------------------
function b = forcehalfband(b)
% Force exact zeros and exact 0.5 in the middle
indx = ceil(length(b)/2);
b(indx+2:2:end) = 0;
b(indx-2:-2:1) = 0;
b(indx) = 0.5;

%-------------------------------------------------------------
function N = adjustord(N)
% Increase N to next integer such that N/2 is odd integer

while (N/2 ~= round(N/2)) || ~rem(N/2,2),
	N = N + 1;
end
%-------------------------------------------------------------
function [flags,msg] = validateNparseinput(N,fp,varargin)

% Generate defaults
msg = '';
flags.winflag = 0;
flags.minordflag = 0;
flags.kaiserflag = 0;
flags.lowpassflag = 1;
flags.firceqripflag = 0;
flags.minphase = 0;

% Check if highpass and/or minphase is wanted
if nargin > 2 && ischar(varargin{end}),
    [flags,flagschanged] = checklaststr(flags,varargin{end});
    if flagschanged,
        varargin = {varargin{1:end-1}};    
    end
end
% Check AGAIN if highpass and/or minphase is wanted
if 2 + length(varargin) > 2 && ischar(varargin{end}),
    [flags,flagschanged] = checklaststr(flags,varargin{end});
    if flagschanged,
        varargin = {varargin{1:end-1}};    
    end
end

% At this point the possible trailing 'low','high', or 'minphase' flags
% have been removed
switch 2+length(varargin),
    case 2,
        % (N,Fp) or (N,win)
        [flags,msg] = parse2inputs(flags,N,fp);
        if ~isempty(msg), return; end
        
    case {3,4},
        % (N,DEV,'dev') or ('minorder',Fo,Dev) or ('minorder',Fo,Dev,'kaiser')
        [flags,msg] = parse3inputs(flags,N,fp,varargin{:});
        if ~isempty(msg), return; end
    end
    
%------------------------------------------------------------------------
function bol = isvalidscalar(a)

bol = true;

if length(a) > 1 || ~isnumeric(a) || isnan(a) || isinf(a) || isempty(a),
	bol = false;
end
%------------------------------------------------------------------------
function [flags,flagschanged] = checklaststr(flags,str)

flagschanged = 0;

stringOpts = {'low','high','minphase'};
lpindx = strmatch(lower(str),stringOpts);
if ~isempty(lpindx) && lpindx == 1,
    flagschanged = 1;
elseif ~isempty(lpindx) && lpindx == 2,
    flags.lowpassflag = 0;
    flagschanged = 1;
elseif ~isempty(lpindx) && lpindx == 3,
    flags.minphase = 1;
    flagschanged = 1;
end
%------------------------------------------------------------------------
function [flags,msg] = parse2inputs(flags,N,fp)

msg = '';

if ischar(N) && ~isempty(strmatch(lower(N),'minorder')),
    msg = 'You must specify a peak ripple for minimum order design.';
    return
end
msg = checkvalidorder(N,flags);
if ~isempty(msg), return; end

if length(fp) > 1,
    % Window specified, make sure it is of the right length
    if length(fp) ~= N + 1,
        msg = 'The length of the window specified must exceed the filter order by one.';
        return
    end
    flags.winflag = 1;
else
    if ~isvalidscalar(fp),
        msg = 'Unrecognized passband edge frequency specified.';
        return
    end
    
    % Make sure fp is in the right range
    if fp <= 0 || fp >= 0.5,
        msg = 'The band-edge frequency must satisfy 0 < Fo < 1/2.';
        return
    end
end

%------------------------------------------------------------------------
function [flags,msg] = parse3inputs(flags,N,fp,varargin)

msg = '';

orderrmsg = 'Unrecognized order specified.';
if ischar(N),
    ordindx = strmatch(lower(N),'minorder');
    if ~isempty(ordindx),
        flags.minordflag = 1;
        
        if ~isvalidscalar(varargin{1}),
            msg = 'Peak ripple must be a scalar.';
            return
        end
        
        if nargin > 4 && ischar(varargin{2}),
            % If a peak ripple is wanted, check if you want a Kaiser window design
            mthdindx = strmatch(lower(varargin{2}),'kaiser');
            if ~isempty(mthdindx),
                flags.kaiserflag = 1;
                flags.winflag = 1;
            end
        end
    else
        msg = orderrmsg;
        return
    end
    
else
    msg = checkvalidorder(N,flags);
    if ~isempty(msg), return; end
    
    if ~ischar(varargin{1}),
        msg = 'Peak ripple can only be specified with the minorder option.';
        return
    end
    if isempty(strmatch(lower(varargin{1}),'dev')),
        msg = 'Unrecognized third input specified.';        
        return
    end
    flags.firceqripflag = 1;
end
%------------------------------------------------------------------------
function msg = checkvalidorder(N,flags)
msg = '';
if ~isvalidscalar(N),
    msg = 'Unrecognized order specified.';
    return
end
if ~flags.minphase && rem(N,2),
    msg = 'The order, N, must be even.';
    return
elseif flags.minphase && ~rem(N,2),
    msg = 'For minimum-phase designs, the order must be odd.';
    return
end

% [EOF]






