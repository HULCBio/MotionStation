function [gd_out,w_out] = grpdelay(b,a,n,dum,varargin)
%GRPDELAY Group delay of a digital filter.
%   [Gd,W] = GRPDELAY(B,A,N) returns length N vectors Gd and W
%   containing the group delay and the frequencies (in radians) at which it 
%   is evaluated. Group delay is -d{angle(w)}/dw.  The frequency
%   response is evaluated at N points equally spaced around the upper half
%   of the unit circle.   For an FIR filter where N is a power of two,
%   the computation is done faster using FFTs.  If you don't specify
%   N, it defaults to 512.
%
%   GRPDELAY(B,A,N,'whole') uses N points around the whole unit circle.  
%
%   [Gd,F] = GRPDELAY(B,A,N,Fs) and [Gd,F] = GRPDELAY(B,A,N,'whole',Fs)
%   given sampling frequency Fs in Hz return a vector F in Hz.
%
%   Gd = GRPDELAY(B,A,W) and Gd = GRPDELAY(B,A,F,Fs) return the group delay
%   evaluated at the points in W (in radians/sample) or F (in Hz).
%
%   GRPDELAY(B,A,...) with no output arguments plots the group delay in the
%   current figure window.
%
%   See also FREQZ.

% Group delay algorithm notes:
%
% The Smith algorithm is employed for FIR filters
%  - unpublished algorithm from J. O. Smith, 9-May-1988
%  - faster than the Shpak algorithm, best suited to FIR filters
%
% The Shpak algorithm is employed for IIR filters
%  - it is more accurate than Smith algorithm for "tricky" IIR filters
%  - algorithm converts filter to second-order sections before computation
%  - D. Shpak, 17-Feb-2000
%  - Added special treatment of singularities based on a suggestion
%    from P. Kabal and extended to complex polys.  D. Shpak, 24-Nov-2001
%
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.17 $  $Date: 2002/05/11 17:44:34 $


error(nargchk(1,5,nargin))

% Define parameter defaults:
isWholeUnitCircle = 0;
isNormalizedFreq = 1;
Fs = 1;

% Parse user arguments
if nargin == 1,
    a = 1;  n = 512;
elseif nargin == 2,
    n = 512;
elseif nargin == 3,
    % nothing to do
elseif nargin == 4,
    if isstr(dum),
        if strcmpi(dum, 'whole'),
            isWholeUnitCircle = 1;
        end
    else
        isNormalizedFreq = 0;
        Fs = dum;
    end
elseif nargin == 5,
    if ~isstr(dum),
        error('Invalid input - 4th argument must be a string.');
    end
    Fs = varargin{1};
    if strcmpi(dum, 'whole'),
        isWholeUnitCircle = 1;
    end
    isNormalizedFreq = 0;
end
 
% Choose group-delay computation algorithm:
%
% The Smith method is used for FIR filters
%  - it is faster than the Shpak method and still accurate
% The Shpak method is used for IIR filters
%  - it is more accurate (converts to second-order sections)
%

% Determine if input is FIR
if signalpolyutils('isfir',b,a)
   dlyFcn = @smithDly;
else
   dlyFcn = @shpakDly;
end
n = n(:);
% Make b and a rows
b = b(:).';
a = a(:).';

nb = length(b);
na = length(a);
% Make b and a of equal length
[b,a]=eqtflength(b,a);

% Compute group delay:
[gd,w] = feval(dlyFcn, b,a,n,Fs,isNormalizedFreq,isWholeUnitCircle);

% Compute frequency vector (normalized or  Hz):
if isNormalizedFreq,
    f = w;
else
    f = w * Fs/(2*pi);
end

if nargout == 0,
    % Produce plots of group delay calculations:
    newplot;
    if isNormalizedFreq,
        plot(f/pi,gd)
        xlabel('Normalized Frequency (\times\pi rad/sample)')
    else
        plot(f,gd)
        xlabel('Frequency (Hz)')
    end
    ylabel('Group delay (samples)')
    set(gca,'xgrid','on','ygrid','on')
    
elseif nargout == 1,
    gd_out = gd;
    
elseif nargout == 2,
    gd_out = gd;
    w_out = f;
end


% ------------------------------------------------------------------
function [gd,w] = smithDly(b,a,n,Fs,isNormalizedFreq,isWholeUnitCircle)
%smithDly Computes group delay using the Smith algorithm

na = length(a);
c = conv(b, conj(a(na:-1:1)));
c = c(:).';	% make a row vector
nc = length(c);
cr = c.*(0:(nc-1));

if isWholeUnitCircle, s=1; else s=2; end

if length(n)==1,
   w = (2*pi/s*(0:n-1)/n)';
   if s*n >= nc	% pad with zeros to get the n values needed
      % dividenowarn temporarily supresses warnings to avoid "Divide by zero"
      gd = dividenowarn(fft([cr zeros(1,s*n-nc)]),...
                        fft([c zeros(1,s*n-nc)]));
      gd = real(gd(1:n)) - ones(1,n)*(na-1);
   else	% find multiple of s*n points greater than nc
      nfact = s*ceil(nc/(s*n));
      mmax = n*nfact;
      % dividenowarn temporarily supresses warnings to avoid "Divide by zero"
      gd = dividenowarn(fft(cr,mmax), fft(c,mmax));
      gd = real(gd(1:nfact:mmax)) - ones(1,n)*(na-1);
   end
   gd = gd(:);
else
    if isNormalizedFreq,
       w = n;
    else
       w = 2*pi*n/Fs;
    end
    s = exp(j*w);
    gd = real(polyval(cr,s)./polyval(c,s));
    gd = gd - ones(size(gd))*(na-1);
end
gd = gd(:);


% ------------------------------------------------------------------
function [gd,w] = shpakDly(b,a,n,Fs,isNormalizedFreq,isWholeUnitCircle)
%shpakDly Computes group delay using the Shpak algorithm
% Tolerance for classifiying roots as on the unit circle or at the origin
toler = 5*eps;

% Compute frequency vector (normalized or Hz):
if length(n) == 1
   if isWholeUnitCircle, ss=2*pi; else ss=pi; end
   w = (0:n-1)'/n * ss;
elseif isNormalizedFreq,
 	w = n;
else
 	w = 2*pi*n/Fs;
end

T = 1;
cw  = cos(w*T);
cw2 = cos(2*w*T);
sw  = sin(w*T);
sw2 = sin(2*w*T);
gd = zeros(length(w), 1);

if isreal(b) & isreal(a),
    % Get the real-valued second-order sections
    [sos,h0] = tf2sos(b,a);
    [M,N] = size(sos);
else
    % Compute complex-valued second-order sections
    [z,p,gain] = tf2zp(b,a);
    % Remove zeros and poles at the origin. No effect on grpdelay.
    k = find(abs(z) > toler);
    z = z(k);
    k = find(abs(p) > toler);
    p = p(k);
    % Remove any zeros on the unit circle
    k = find(abs(abs(z) - 1) > toler);
    % Each zero on the unit circle adds a half-unit delay
    gd = gd + T*(length(z)-length(k)) / 2;
    z = z(k);
    % Again, but for poles
    k = find(abs(abs(p) - 1) > toler);
    gd = gd - T*(length(p)-length(k)) / 2;
    p = p(k);
    % Set up an array to hold the SOS
    numOrd = length(z);
    denOrd = length(p);
    M = max(ceil(numOrd/2), ceil(denOrd/2));
    sos = zeros(M,6);
    sos(:,1) = 1;
    sos(:,4) = 1;
    % Numerator
    sections = fix(numOrd/2);
    % No sorting, just pairing
    z1 = z(1:2:2*sections);
    z2 = z(2:2:2*sections);
    sos(1:sections,2:3) = [-(z1+z2) z1.*z2];
    if rem(numOrd, 2) == 1
        sos(sections+1,2) = -z(numOrd);
    end
    % Denominator
    sections = fix(denOrd/2);
    z1 = p(1:2:2*sections);
    z2 = p(2:2:2*sections);
    sos(1:sections,5:6) = [-(z1+z2) z1.*z2];
    if rem(denOrd, 2) == 1
        sos(sections+1,5) = -p(denOrd);
    end
end

for k=1:M
    % Numerator
    gd = gd + grpSection(sos(k,1:3),T,cw,sw,cw2,sw2);
    gd = gd - grpSection(sos(k,4:6),T,cw,sw,cw2,sw2);
end

% Compute the group delay for a first- or second-order polynomial
function gd=grpSection(q,T,cw,sw,cw2,sw2)
gd = zeros(length(cw), 1);
br = real(q);
bi = imag(q);
% Tolerance for finding symmetric and anti-symmetric polynomials
% (i.e., roots on the unit circle)
toler = 10*eps;

if q(2:3) == [0 0],
    % Zeroth-order section
    % (nothing to do!)
    
elseif q(3) == 0,
    % First-order section
    if isreal(q) & abs(br(1) - br(2)) < toler
        % Root at z=-1
        gd = T/2;
    elseif isreal(q) & abs(br(1) + br(2)) < toler
        % Root at z=1
        gd = T/2;
    else            
        b1 = br(1); b2 = br(2);
        g1 = bi(1); g2 = bi(2);
        u = g1*cw + b1*sw + g2;
        v = b1*cw - g1*sw + b2;
        du = T*(-g1*sw + b1*cw);
        dv = T*(-b1*sw - g1*cw);
    
        u2v2 = (b1^2 + g1^2 + b2^2 + g2^2) + 2*(b1*b2 + g1*g2)*cw + 2*(b1*g2 - b2*g1)*sw;
    
        % The following division could be zero/zero if we evaluate at a singularity
        k = find(abs(u2v2) > eps^(2/3));
        gd(k) = gd(k) + T - (v(k).*du(k) - u(k).*dv(k))./u2v2(k);
    end
else
    % Second-order section
    % First, check for symmetric and anti-symmetric polynomials
    if isreal(q) & all(abs(br - fliplr(br)) < toler)
        gd = T;
    elseif isreal(q) & all(abs(br + fliplr(br)) < toler)
        gd = T;
    else
        b1 = br(:,1); b2 = br(:,2); b3 = br(:,3);
        g1 = bi(:,1); g2 = bi(:,2); g3 = bi(:,3);
        u = g1*cw2 + b1*sw2 + g2*cw + b2*sw + g3;
        v = b1*cw2 - g1*sw2 + b2*cw - g2*sw + b3;
    
        du =  T*(-2*g1*sw2 + 2*b1*cw2 - g2*sw + b2*cw);
        dv = -T*( 2*b1*sw2 + 2*g1*cw2 + b2*sw + g2*cw);
    
        u2v2 = (b1^2 + g1^2) + (b2^2 + g2^2) + (b3^2 + g3^2) + ...
            2*(b1*b2 + g1*g2 + b2*b3 + g2*g3)*cw + 2*(b1*g2 - b2*g1 + b2*g3 - b3*g2)*sw + ...
            2*(b1*b3 + g1*g3)*cw2 + 2*(b1*g3 - b3*g1)*sw2; 
    
	    % The 2T compensates for using powers of +z rather than -z in the preceding derivatives. 
        k = find(abs(u2v2) > eps^(2/3));
        k = 1:length(v);
        gd(k) = gd(k) + 2*T - (v(k).*du(k) - u(k).*dv(k))./u2v2(k);
    end
end   

% [EOF] grpdelay.m
