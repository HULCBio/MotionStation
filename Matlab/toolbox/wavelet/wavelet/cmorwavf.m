function [psi,X] = cmorwavf(LB,UB,N,Fb,Fc)
%CMORWAVF Complex Morlet wavelet.
%   [PSI,X] = CMORWAVF(LB,UB,N,FB,FC) returns values of
%   the complex Morlet wavelet defined by a positive bandwidth
%   parameter FB, a wavelet center frequency FC, and the expression
%   PSI(X) = ((pi*FB)^(-0.5))*exp(2*i*pi*FC*X)*exp(-(X^2)/FB)
%   on an N point regular grid in the interval [LB,UB].
%
%   Output arguments are the wavelet function PSI
%   computed on the grid X.
%
%   See also WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Jun-99.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/03/15 22:39:54 $

% Check arguments.
%-----------------
nbIn = nargin;
switch nbIn
    case {0,1,2} ,
        error('Not enough input arguments.');
    case 3 ,
        Fc = 1; Fb = 1;
    case 4 ,
        if ischar(Fb)
            label = deblank(Fb);
            ind   = strncmpi('cmor',label,4);
            if isequal(ind,1)
                label([1:4]) = [];
                len = length(label);
                if len>0
                    ind = findstr('-',label);
                    if isempty(ind)
                        Fb = []; % error 
                    else
                        Fb = wstr2num(label(1:ind-1));
                        label(1:ind) = [];
                        Fc = wstr2num(label);    
                    end
                end
            else
                Fc = []; % error 
            end
        else
            Fb = []; Fc = []; % error 
        end
        
    case 5 ,
end
if isempty(Fc) | isempty(Fb) , err = 1; else , err = 0; end
if ~err , err = ~isnumeric(Fc) | ~isnumeric(Fb) | (Fc<=0) | (Fb<=0); end
if err
    error('Invalid Wavelet Number.')
end

% Compute values of the Complex Morlet wavelet.
X = linspace(LB,UB,N);  % wavelet support.
psi = ((pi*Fb)^(-0.5))*exp(2*i*pi*Fc*X).*exp(-(X.*X)/Fb);
