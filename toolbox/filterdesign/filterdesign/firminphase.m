function h = firminphase(b, varargin)
%FIRMINPHASE   Minimum-phase FIR spectral factor.
%   H = FIRMINPHASE(B) computes the minimum-phase FIR spectral factor H of
%   a linear phase FIR filter B.  B must be real, have even order and have
%   a nonnegative zero-phase response.
%
%   The maximum-phase spectral factor, G, can be found by simply reversing
%   H, i.e. G = FLIPLR(H) and B = CONV(H,G).
%
%   H = FIRMINPHASE(B,Nz) specifies the number Nz of zeros of B that lie on
%   the unit circle. Nz must be even in order to compute the minimum-phase
%   spectral factor because every root on the unit circle must have even
%   multiplicity. Nz can aid in the computation in some cases. Zeros with
%   multiplicity greater than two on the unit circle will cause problems.
%
%   EXAMPLE: Design a constrained least squares filter with a
%            nonnegative zero-phase response, and compute the
%            minimum-phase factor.
%      f   = [0 0.4 0.8 1];
%      a   = [0 1 0];
%      up  = [0.02 1.02  0.01];
%      lo  = [0 0.98 0]; % The zeros ensure nonnegative zero-phase resp.
%      n   = 32;
%      b   = fircls(n,f,a,up,lo);
%      h   = firminphase(b);
%      fvtool(b,1,h,1); % Overlay original filter and min. phase filter
%
%   See also ZEROPHASE, FIRGR, FIRCLS.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $  $Date: 2004/04/12 23:25:31 $

error(nargchk(1,3,nargin));

% Make sure b is a row
b = b(:).';

msg = checknonnegative(b);
error(msg);

% Find the roots of the filter polynomial
r = roots(b);

% Default tolerance
tol = 1e-15;
if nargin == 3 & strcmpi(varargin{2},'angles'),
    % Use the angles of the zeros to compute the (single multiplicity) zeros
    [ru,Nsz,tol] = computeKnownZeros(varargin{1},b,r,tol);
elseif nargin == 2,
    % Number of double-roots specified
    Nsz = varargin{1}/2;
    [ru,tol] = findUnitCircleZeros(b,r,tol,Nsz);
elseif nargin == 1,
    % Find the unit circle zeros
    [ru,tol,Nsz] = findUnitCircleZeros(b,r,tol);
end

% Find the zeros strictly inside the unit circle
ri = removeUnitCircleZeros(r,Nsz);

% Form vector of single roots on unit circle and all roots inside
rm = [ru;ri];

% Form polynomial
h = poly(leja(rm));
h = real(h); % Polynomial must be real

% Apply gain correction
desired = sqrt(max(abs(freqz(b))));
actual = max(abs(freqz(h)));
h = h * (desired/actual);

%------------------------------------------------------------
function msg = checknonnegative(b)
%CHECKNONNEGATIVE  Check that the zerophase response is nonnegative

msg = '';
warn = warning('off','signal:zerophase:syntaxChanged');
if min(zerophase(b)) < -1e-3,
    warning(warn);
	msg = 'The filter has to have a nonnegative zero-phase response.';
	return
end
warning(warn);

symstr = signalpolyutils('symmetrytest',b,1);
if ~strcmpi(symstr,'symmetric') | ~rem(length(b),2),
	msg = 'Input filter must be symmetric and have even order (odd length).';
	return
end

%------------------------------------------------------------
function [ru,tol,Nsz] = findUnitCircleZeros(b,r,tol,Nsz)
% Find single multiplicity zeros on the unit circle


% Compute the zeros of the derivative
% This will contain the same zeros on the unit circle as b, but not double
rd = roots(polyder(b));

% Initialize flag indicating whether to use the zeros from the derivative
% polynomial or not. Don't use derivative zeros by default.
derivflag = 0;

% Initialize flag
flag = 1;

while tol < 1e-3 & flag,
	% Find the zeros on the unit circle
	ru = r(find(abs(abs(r)-1) < tol));
		
	% Find the zeros on the unit circle corresponding to the derivative
	rdu = rd(find(abs(abs(rd)-1) < tol));
	
    if nargin > 3,
        % Check if number of single zeros found corresponds to number
        % given number of zeros
        if length(rdu) == Nsz,
            flag = 0;
            derivflag = 1;
        elseif ~rem(length(ru),2) & length(ru)/2 == Nsz 
            flag = 0;
        else
            % Decrease the tolerance
            tol = 10*tol;
        end
    elseif ~rem(length(ru),2) & length(rdu) == length(ru)/2 & length(ru) ~= 0,
        % Check that the length of the derivative zeros half of the length of
        % the original zeros on the upper unit circle. If not, decrease
        % tolerance and try again
		flag = 0;
        Nsz = length(rdu);
        if max(abs(polyval(b,ru))) > max(abs(polyval(b,rdu)))
            derivflag = 1;
        end
	else
		% Decrease the tolerance
		tol = 10*tol;
	end
end

% If max tolerance has been reached and number of unit circle zeros has not
% been specified, use the zeros on the unit circle found from the original
% polynomial (not the derivative)
if tol >= 1e-3 & nargin < 4,
    Nsz = length(ru)/2;
end  

if ~isempty(ru)
    if derivflag,
        % Use unit circle zeros from derivative
        ru = rdu;
    else
        ru = getsinglezeros(ru,Nsz);
    end
    
    if tol < 1e-3,
        % Force length of zeros to be exactly one, keep the angle the same
        ru = exp(i*angle(ru));
    end
else
    Nsz = 0;
end

%------------------------------------------------------------
function [ru,Nsz,tol] = computeKnownZeros(zangles,b,r,tol)

% Make sure the input is a column vector
zangles = zangles(:);

% Compute the approximate complex zeros
k = find(sin(zangles) > eps);
ru = [cos(zangles(k))+i*sin(zangles(k)); cos(zangles(k))-i*sin(zangles(k))];

% And any real zeros
k = find(sin(zangles) <= eps);
ru = [ru; cos(zangles(k))];

% Compute number of single zeros on unit circle
Nsz = length(ru);

% Compute unit circle zeros to compare
[ruc,tol] = findUnitCircleZeros(b,r,tol,Nsz);

% Keep the best zeros
if max(abs(polyval(b,ru))) > max(abs(polyval(b,ruc)))
    ru = ruc;
end

%-------------------------------------------------------------
function rus = getsinglezeros(ru,Nsz)
% Get single zeros on unit circle

if isempty(ru),
    rus = [];
    return
end

% From the double zeros on the unit circle, we find does closest
% to the unit circle on the upper half of it. Any complex one is
% complemented with its complex conjugate
ruupper = ru(find(imag(ru) >= 0));

% Sort by angle
[a,k] = sort(angle(ruupper));
rutemp = ruupper(k(1:2:end));
rutemp2 = ruupper(k(2:2:end));

% If odd number of zeros, there must be a real one, find it
if rem(length(k),2),
    rureal = rutemp(end);
else
    rureal = []; % No real zeros
end

% Preallocate 
rus = zeros(floor(length(k)/2),1);

% Compare one by one which root is closer to unit circle
for n = 1:floor(length(k)/2),
    if abs(1-abs(rutemp(n))) < abs(1-abs(rutemp2(n))),
        rus(n) = rutemp(n);
    else
        rus(n) = rutemp2(n);
    end
end

% Find complex roots
rusc = rus(find(imag(rus)~=0));

% Append complex conjugate zeros and real zero
rus = [rus;conj(rusc);rureal];

% Sanity check
if length(rus) ~= Nsz,
    error('Incorrect number of zeros on unit circle. Algorithm failed.');
end

%-------------------------------------------------------------
function ri = removeUnitCircleZeros(r,Nsz)
% Get zeros strictly inside unit circle

% Get total number of zeros
N = length(r);

% Sort roots by magnitude
[dummy,k] = sort(abs(r));

% Get N/2 - Nsz smallest roots
rs = r(k);
ri = rs(1:N/2-Nsz);
%--------------------------------------------------------------
function [x_out] = leja(x_in)
%
%    Program orders the values x_in (supposed to be the roots of a 
%    polynomial) in this way that computing the polynomial coefficients
%    by using the m-file poly yields numerically accurate results.
%    Try, e.g., 
%               z=exp(j*(1:100)*2*pi/100);
%    and compute  
%               p1 = poly(z);
%               p2 = poly(leja(z));
%    which both should lead to the polynomial x^100-1. You will be
%    surprised!
%
%    leja is by Markus Lang, and is available from the
%    Rice University DSP webpage: www.dsp.rice.edu




x = x_in(:).'; n = length(x);

a = x(ones(1,n+1),:);
a(1,:) = abs(a(1,:));

[dum1,ind] = max(a(1,1:n));  
if ind~=1
  dum2 = a(:,1);  a(:,1) = a(:,ind);  a(:,ind) = dum2;
end
x_out(1) = a(n,1);
a(2,2:n) = abs(a(2,2:n)-x_out(1));

for l=2:n-1
  [dum1,ind] = max(prod(a(1:l,l:n)));  ind = ind+l-1;
  if l~=ind
    dum2 = a(:,l);  a(:,l) = a(:,ind);  a(:,ind) = dum2;
  end
  x_out(l) = a(n,l);
  a(l+1,(l+1):n) = abs(a(l+1,(l+1):n)-x_out(l));
end
x_out = a(n+1,:);


