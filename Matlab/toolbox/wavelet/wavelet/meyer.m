function varargout = meyer(LB,UB,N,OPT);
%MEYER Meyer wavelet.
%   [PHI,PSI,T] = MEYER(LB,UB,N) returns Meyer
%   scaling and wavelet functions evaluated on
%   an N point regular grid in the interval [LB,UB].
%   N must be a power of two.
%
%   Output arguments are the scaling function PHI, the
%   wavelet function PSI computed on the grid T.
%   These functions have [-8 8] as effective support.
%
%   A fourth argument is allowed, if only one function
%   is required:
%     [PHI,T] = MEYER(LB,UB,N,'phi')
%     [PSI,T] = MEYER(LB,UB,N,'psi')
%   When the fourth argument is used, but not equal to
%   'phi' or 'psi', outputs are the same as in main option.
%
%   See also MEYERAUX, WAVEFUN, WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $ $Date: 2004/03/15 22:41:16 $

% Check arguments.
switch nargin
  case 3
    OPT = 'two';
  case 4
    if ~(isequal(OPT,'two') | isequal(OPT,'phi') | isequal(OPT,'psi'))
        OPT = 'two';
    end
end
tmp = log(N)/log(2);
if tmp ~= fix(tmp)
    error('N must be a power of two !')
end
tmp = UB-LB;
if tmp<0
    error('The interval [LB,UB] is not valid !')
end

% Transform interval bounds to grid.
lint = (UB-LB)/2/pi; 
x    = [-N:2:N-2]/(2*lint);
xa   = abs(x);

% Scaling function phi.
if OPT == 'phi' | OPT == 'two'

    % Compute support of Fourier transform of phi.
    int1 = find((xa < 2*pi/3));
    int2 = find((xa >= 2*pi/3) & (xa < 4*pi/3));

    % Compute Fourier transform of phi.
    phihat = zeros(1,N);
    phihat(int1) = ones(size(int1));
    phihat(int2) = cos(pi/2*meyeraux(3/2/pi*xa(int2)-1));

    % Compute phi using non standard inverse FFT.
    [phi,t] = instdfft(phihat,LB,UB);
end

% Wavelet function psi.
if OPT == 'psi' | OPT == 'two'

    % Compute support of Fourier transform of psi.
    int1 = find((xa >= 2*pi/3) & (xa < 4*pi/3)); 
    int2 = find((xa >= 4*pi/3) & (xa < 8*pi/3));

    % Compute Fourier transform of psi.
    psihat = zeros(1,N);
    psihat(int1) = exp(i*x(int1)/2).*sin(pi/2*meyeraux(3/2/pi*xa(int1)-1));
    psihat(int2) = exp(i*x(int2)/2).*cos(pi/2*meyeraux(3/4/pi*xa(int2)-1));

    % Compute psi using non standard inverse FFT.
    [psi,t] = instdfft(psihat,LB,UB);
end

% Set output arguments.
switch OPT
    case 'psi' , varargout = {psi,t};
    case 'phi' , varargout = {phi,t};
    otherwise  , varargout = {phi,psi,t};
end
