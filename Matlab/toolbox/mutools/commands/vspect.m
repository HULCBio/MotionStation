% function P = vspect(x,y,m,noverlap,window)
%
%   Spectral analysis routine modeled after SPECTRUM in the
%   Signal Processing Toolbox.  X (and optionally Y) are VARYING
%   matrices representing time domain sequences.  M point ffts are
%   used with NOVERLAP points of overlap.  WINDOW is an optional
%   string specifying a window (default is 'hanning'). Currently
%   supported options within the Signal Processing toolbox are:
%   'hanning', 'hamming', 'boxcar','blackman','bartlett', and 'triang'.
%
%   The returned VARYING matrix, P, has the following columns
%   [Pxx Pyy Pxy Txy Cxy].  Pxx (Pyy) is the power spectrum of X (Y),
%   Pxy is the cross spectrum, Txy is the transfer function, and
%   Cxy is the coherence.  For a single input sequence only Pxx is
%   returned.  The returned independent variable is frequency in
%   radians/seconds. The signal Y (or X in the single signal case)
%   can be a vector of signals.  The transfer function is calculated
%   for each output. This corresponds to single-input/multi-output
%   transfer function estimation.  Each row of P corresponds to the
%   appropriate row of Y.
%
%   See also: FFT, IFFT, SPECTRUM, VFFT and VIFFT.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

%  30apr92      GJB     modified the code such that if there is only one
%                       input and output of the varying matrix, the SEL
%                       command is NOT called. Speeds code up for this case
%                       by a factor of 2.5.


function P = vspect(x,y,m,noverlap,window)

if nargin == 0,
	disp('usage: P = vspect(x,y,m,noverlap,window)')
	disp('       P = vspect(x,m,noverlap,window)')
	return
	end

if nargin < 2 | nargin > 5
    disp('incorrect number of input arguments')
    disp('usage: P = vspect(x,y,m,noverlap,window)')
    return
    end

[xtype,xnr,xnc,xnpts] = minfo(x);
if xtype ~= 'vary'
    error('input signal must be VARYING matrix')
    return
    end

[ytype,ynr,ync,ynpts] = minfo(y);

%	Use the second argument to determine whether or not
%	we are dealing with a single spectrum case.

if ytype == 'cons',            % single spectrum case.
    if nargin > 4,
        error('too many arguments for single input spectrum')
        return
        end
    if nargin < 4,
        window = 'hanning';
    else
        window = noverlap;
        end
    if nargin < 3,
        noverlap = 0;
    else
        noverlap = m;
        end
    m = y;
    if fix(m/2) ~= m/2,
        error('fft length must be even')
        return
        end

%       now create the window of the appropriate length.

    if ~isstr(window),
        error('window argument must be a string')
        return
    else
        eval(['w = ' window '(m);']);
        end

%      calculate the number of windows and the appropriate
%      normalization factors.

    k = fix((xnpts - noverlap)/(m - noverlap));
    disp([ int2str(k) ' ' window ' windows in averaging calculation']);
    KMU = k*norm(w)^2;

%       calculate a frequency vector for creating the output.

    t = getiv(x);
    tinc = t(2) - t(1);
    finc = 2*pi/(tinc*m);
    omega = [0:finc:finc*(m/2-1)];

%      go through the averaging procedure for each row

    select = [2 2:m/2];
    Pxx = [];
    for i = 1:xnr,
        Pxxcol = [];
        for j = 1:xnc,
            sisoPxx = zeros(m,1);
            index = [1:m];
            if (xnr == 1) & (xnc == 1)
              xdat = vunpck(x);
            else
              xdat = vunpck(sel(x,i,j));
            end
            for l = 1:k,
                xw = w.*detrend(xdat(index));
                index = index + (m - noverlap);
                Xx = abs(fft(xw)).^2;
                sisoPxx = sisoPxx + Xx;
                end
            sisoPxx = vpck((1/KMU)*sisoPxx(select),omega);
            Pxxcol = sbs(Pxxcol,sisoPxx);
            end
        Pxx = abv(Pxx,Pxxcol);
        end
    P = Pxx;

elseif ytype == 'vary',         % cross spectrum case
    if nargin < 5,
        window = 'hanning';
        end
    if nargin < 4,
        noverlap = 0;
        end
    if nargin < 3,
        error('FFT length must be specified')
        return
        end
    if fix(m/2) ~= m/2,
        error('fft length must be even')
        return
        end

%       check that the x and y vectors are over the same
%       independent variables.

    if indvcmp(x,y) > 1,
        error('INDEPENDENT VARIABLEs of the signals do not match')
        return
        end

%       check that y is a row vector.  If necessary perform its
%       transpose.  This is done so that selecting different
%       elements is faster.

    [ytype,ynr,ync,ynpts] = minfo(y);
    if ynr > 1 & ync > 1,
        error('output signal (y) is a matrix')
        return
    elseif ynr > 1,
        y = transp(y);
        [ytype,ynr,ync,ynpts] = minfo(y);
        end

%       make sure that x is a 1 x 1 VARYING matrix.  This means
%       that we can only do SISO or SIMO spectrum cases.

    if xnr~= 1 | xnc ~= 1,
        error('the input signal (x) cannot be a vector')
        return
        end

%       now create the window of the appropriate length.

    if ~isstr(window),
        error('window argument must be a string')
        return
    else
        eval(['w = ' window '(m);']);
        end

%      calculate the number of windows and the appropriate
%      normalization factors.

    k = fix((xnpts - noverlap)/(m - noverlap));
    disp([ int2str(k) ' ' window ' windows in averaging calculation']);
    KMU = k*norm(w)^2;


    [xdat,xptr,t] = vunpck(x);
    [ydat,yptr,t] = vunpck(y);

%      go through the averaging procedure x.  The results of the fft
%      are stored side by side for each k in Xxstack.  This is so
%      that they can be used to calculate Pxy when going through
%      the averaging procedure for y.

    Pxx = zeros(m,1);
    Xxstack = [];
    index = [1:m];
    for i = 1:k,
        xw = w.*detrend(xdat(index));
        index = index + (m - noverlap);
        Xx = fft(xw);
        Xxstack = [Xxstack Xx ];
        Pxx = Pxx + abs(Xx).^2;
        end
    select = [2 2:m/2];
    Pxx = Pxx(select);

    Pyy = [];
    Pxy = [];
    for j = 1:ync,
        Pyycol = zeros(m,1);
        Pxycol = zeros(m,1);
        index = [1:m];
        for i = 1:k,
            yw = w.*detrend(ydat(index,j));
            index = index + (m - noverlap);
            Yy = fft(yw);
            Xy = Yy .* conj(Xxstack(:,i));
            Pyycol = Pyycol + abs(Yy).^2;
            Pxycol = Pxycol + Xy;
            end
        Pyycol = Pyycol(select);
        Pyy = [Pyy Pyycol];
        Pxycol = Pxycol(select);
        Pxy = [Pxy Pxycol];
        end

%        calculate the transfer function and coherence

    Txy = [];
    Cxy = [];
    for j = 1:ync,
        Txy = [Txy Pxy(:,j)./Pxx];
        Cxy = [Cxy (abs(Pxy(:,j).^2)./(Pxx.*Pyy(:,j)))];
        end

%      form a frequency vector for appending to the
%      result.

    tinc = t(2) - t(1);
    finc = 2*pi/(tinc*m);
    omega = [0:finc:finc*(m/2-1)];

%      Put together the final spectrum and do a transpose to
%      get it back in column vector form.  Pxx is padded with
%      zeros to get everything dimensionally correct.

    if ync > 1,
        Pxx = Pxx * [1 zeros(1,ync-1)];
        end
    vPxx = vpck((1/KMU)*Pxx,omega);
    vPxx = transp(vPxx);
    vPyy = vpck((1/KMU)*Pyy,omega);
    vPyy = transp(vPyy);
    vPxy = vpck((1/KMU)*Pxy,omega);
    vPxy = transp(vPxy);
    vTxy = vpck(Txy,omega);
    vTxy = transp(vTxy);
    vCxy = vpck(Cxy,omega);
    vCxy = transp(vCxy);

%      stick all the bits together so each row of the output
%      has
%                [ Pxx Pyy Pxy Txy Cxy]

P = sbs(vPxx, sbs(vPyy, sbs(vPxy, sbs(vTxy,vCxy))));

else                            % error -  it must be a system matrix
    error('SYSTEM matrix arguments are not allowed')
    return
    end
%
%