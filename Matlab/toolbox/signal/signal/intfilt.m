function [h,a]=intfilt(R,L,freqmult,type);
%INTFILT Interpolation (and Decimation) FIR Filter Design
%   B = INTFILT(R,L,FREQMULT) designs a linear phase FIR filter which, when 
%   used on a sequence interspersed with R-1 consecutive zeros every 
%   R samples, performs ideal bandlimited interpolation using the nearest 
%   2*L non-zero samples and assuming an original bandlimitedness of 
%   FREQMULT times the Nyquist frequency.  B is length 2*R*L-1.
%
%   B = INTFILT(R,N,'Lagrange') designs an FIR filter which performs Nth 
%   order Lagrange polynomial interpolation on a sequence that is inter-
%   spersed with R-1 consecutive zeros every R samples.  B is length 
%   (N+1)*R-1 for N odd and (N+1)*R for N even.  If both N and R are even, 
%   the filter designed is NOT linear phase.
%
%   Both types of filters are basically lowpass and are meant to be used
%   for interpolation and decimation.
%
%   See also INTERP, DECIMATE, RESAMPLE.

%   Reference:   Oetken, Parks, and Schuessler, "New Results in the
%      design of digital interpolators," IEEE Trans. Acoust., Speech,
%      Signal Processing, vol. ASSP-23, pp. 301-309, June 1975.

%   Author(s): T. Krauss, 3-24-92
%   	   T. Krauss, 4-21-93, revisited and merged with "lagrange"
%   Copyright 1988-2003 The MathWorks, Inc.
%       $Revision: 1.6.4.2 $  $Date: 2004/04/13 00:18:03 $

error(nargchk(3,4,nargin))
if nargin == 3,
    if isstr(freqmult),
        type = freqmult;
        n = L;
    else
        type = 'b';
    end
end 

if strcmp(type(1),'b')|strcmp(type(1),'B'),
        
    n=2*R*L-1;

    if freqmult == 1
        M = [R R 0 0];
        F = [0 1/(2*R) 1/(2*R) .5];
    else
        M=R*[1 1];
        F=[0 freqmult/2/R];

        for f=(1/R):(1/R):.5,
            F=[F f-(freqmult/2/R) f+(freqmult/2/R)];
            M=[M 0 0];
        end;

        if (F(length(F))>.5),
            F(length(F))=.5;
        end;
    end

    h=firls(n-1,F*2,M);

elseif strcmp(type(1),'l')|strcmp(type(1),'L'),

% Inputs:
%    n   order of polynomial interpolation  (should be ODD!!!!)
%    R   discrete time sampling period (input to filter assumed 0 else)

    if n == 0
        h = ones(1,R);
        return
    end

    if ~(rem(n,2)|rem(R,2))
       disp('Warning: linear phase filter not possible for both R and N even');
    end

    t=0:n*R+1;
    l=ones(n+1,length(t));
    for i=1:n+1
        for j=1:n+1
            if (j~=i)
                l(i,:)=l(i,:).*(t/R-j+1)/(i-j);
            end;
        end;
    end;

%    plot(t/R,l')
%    title('Langrange Polynomials');
%    xlabel('time/R');
%    grid
%    l
%    pause;

    h=zeros(1,(n+1)*R);  

    for i=0:R-1
        for j=0:n
            h(j*R+i+1)=l((n-j)+1,round((n-1)/2*R+i+1));
        end;
    end;

    if h(1) == 0,
        h(1) = [];
    end

else
    error('Sorry, this type of filter is not recognized')
end

if nargout > 1
    a = 1;
end
