function [gt,d]=findmax(data, flag)
%FINDMAX Interpolates the maxima in a vector of data.
%
%   Function used for returning all the maxima in a set of
%   data (vector or matrices). The maxima are calculated by
%   cubic or quadratic interpolation.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.13.4.1 $  $Date: 2004/02/07 19:13:07 $

[m,n]=size(data);
if nargin < 2, flag = 1; end
% 1-D
d = [2, 2];
if m==1 | n==1
    data=data(:);
    n=max([n,m]);
    ind=find( (data>[data(1)-1;data((1:n-1)')]) ...
           & (data>=[data((2:n)');data(n)-1]) );
    s=length(ind);
    gt=zeros(s,1);
    for i=1:s
        ix=ind(i);
        factor = 1;
        err = 0;  % Smoothness factor
        if (ix==1 | ix==n);
            gt(i)=data(ix);
        elseif ix>n-3 | ix<4
            if data(ix-1)==data(ix)&data(ix+1)==data(ix)
                gt(i)=data(ix);
            else
                gt(i)=quad2(data(ix-1:ix+1));
            end
        elseif data(ix+2)<data(ix+1) 
            [gt(i), err] = cubic(data(ix-1:ix+2), data(ix-2), 0);
        elseif data(ix-2)<data(ix-1) 
            gt(i)=cubic(data(ix-2:ix+1));
        elseif data(ix)>data(ind(i+1))
            gt(i)=quad2(data(ix-1:ix+1));
            factor = 0.75; 
        else
            gt(i)=data(ix);
            factor = 0.5;
        end

% Discretization interval estimation
% Aim: keep error less than 1/10 of abs(constraint) greater than 0
%   or  1/50 of smoothness factor.
% error = data(ix) - gt(i)
        if flag 
            if ~err
                err = data(ix) - gt(i);
            end
            f = abs((gt(i) + 1.1e-5) /(10 * err + 1e-5));
            d(1,1) = min(d(1,1), factor * ((f>=0.3) + (0.7 + f)*(f< 0.3) +(f>1)*(log(f)/100)) );
        end
    end
else
% 2D
    [gt, d] = findmax2(data, flag); 
end
if (m*n)<4, d=[0.5,0.5]; end
