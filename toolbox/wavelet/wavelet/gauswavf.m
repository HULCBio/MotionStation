function [psi,X] = gauswavf(LB,UB,N,NumWAW)
%GAUSWAVF Gaussian wavelet.
%   [PSI,X] = GAUSWAVF(LB,UB,N,P) returns values of the Pth 
%   derivative of the Gaussian function F = Cp*exp(-x^2) on 
%   an N point regular grid for the interval [LB,UB]. Cp is 
%   such that the 2-norm of the Pth derivative of F is equal 
%   to 1.  P can be integer values from 1 to 8.
%
%   Output arguments are the wavelet function PSI
%   computed on the grid X.
%   [PSI,X] = GAUSWAVF(LB,UB,N) is equivalent to
%   [PSI,X] = GAUSWAVF(LB,UB,N,1).
%
%   These wavelets have an effective support of [-5 5].
%
%   ----------------------------------------------------
%   If you have access to the Extended Symbolic Toolbox,
%   you may specify a value of P > 8. 
%   ----------------------------------------------------
%
%   See also CGAUSWAVF, WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/03/15 22:40:36 $

% Check arguments.
%-----------------
nbIn = nargin;
switch nbIn
  case 0 ,
   if ~exist('maple') , nmax = 8; else , nmax = 45; end
   psi = nmax;
   % psi contains the number max for Gaussian wavelets.
   % This number depends of Symbolic Toolbox
   
  case 2 , error('Not enough input arguments.');
      
  case 3 , NumWAW = 1;
      
  case 4 ,
   if ischar(NumWAW)
       [fam,NumWAW] = wavemngr('fam_num',NumWAW);
       NumWAW = wstr2num(NumWAW);
   end
   
  otherwise  , 
      error('Too many input arguments.');
end
if errargt(mfilename,NumWAW,'int') , error('*'); end

% Compute values of the Gauss wavelet.
X = linspace(LB,UB,N);  % wavelet support.
if find(NumWAW==[1:8])
  X2 = X.^2;
  F0 = (2/pi)^(1/4)*exp(-X2);
end

switch NumWAW
  case 1
    psi = -2*X.*F0;

  case 2    
    psi = 2/(3^(1/2)) * (-1+2*X2).*F0;

  case 3
    psi = 4/(15^(1/2)) * X.* (3-2*X2).*F0;
                
  case 4
    psi = 4/(105^(1/2)) * (3-12*X2+4*X2.^2).*F0;

  case 5
    psi = 8/(3*(105^(1/2))) * X.* (-15+20*X2-4*X2.^2).*F0;  

  case 6
    psi = 8/(3*(1155^(1/2))) * (-15+90*X2-60*X2.^2+8*X2.^3).*F0; 

  case 7
    psi = 16/(3*(15015^(1/2))) *X.*(105-210*X2+84*X2.^2-8*X2.^3).*F0; 

  case 8
    psi = 16/(45*(1001^(1/2))) * (105-840*X2+840*X2.^2-224*X2.^3+16*X2.^4).*F0;

  otherwise
    if ~exist('maple')
        msg = '*** The Extended Symbolic Toolbox is required ***';
        errargt(mfilename,msg,'msg')
        error(msg);
    end
    y = sym('t');
    f = exp(-y.*y);
    d = diff(f,NumWAW);
    n = sqrt(int(d*d,-Inf,Inf));
    d = d/n;
    for j = 1:length(X)
        t = X(j);
        psi(j) = eval(d);
    end
end
switch rem(NumWAW,4)
    case {2,3} , psi = -psi;
end
