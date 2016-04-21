function [gt,d]=findmax2(data, flag)
%FINDMAX2 Interpolates the maxima in a matrix of data.
%
%   Function used for returning all the maxima in a set of
%   data (matrices). The maxima are calculated by
%   quadratic interpolation.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.16.4.1 $  $Date: 2004/02/07 19:13:08 $

if nargin < 2, flag = 0, end
% 2-D
d = [1.5, 1.5];
[m,n]=size(data);
% Factor for error control:    
factor = 5;  % Keep error five times less than nearest constraint

% Constants
diagix = [-1 -1 1 1];
diagix2 = [1 -1 -1 1];
% Use point [0,0], [1,0], [0,1], [0, -1], [-1 0] and [1,1] on grid:
diagix3 = [0 1 0 0 -1 1 ];
diagix4 = [0 0 1 -1 0 1 ];
% Point [-1, -1] used to check goodness of quadratic fit. 
xerr = [-1; -1];

invH = [  ... 
-1.0000    0.5000         0         0    0.5000         0
0.5000   -0.5000   -0.5000         0         0    0.5000
-1.0000         0    0.5000    0.5000         0         0
0    0.5000         0         0   -0.5000         0
0         0    0.5000   -0.5000         0         0
1.0000         0         0         0         0         0
];

% Find the peaks
crmax = (data>[data(1,:)-1;data(1:m-1,:)]) & (data>=[data(2:m,:);data(m,:)-1]) & ...
    (data>[data(:,1)-1,data(:,1:n-1)]) & (data>=[data(:, 2:n),data(:,n)-1]);

f = find(crmax);
for i = f'
    ni = 1 + floor((i-0.5)/m);
    mi = i - (ni-1)*m;
    ix = mi - diagix;
    iy = ni - diagix2;
    fix = find(ix > 0 & ix <= m & iy > 0 & iy <= n); 
    if any(data(mi, ni) <= data(ix(fix), iy(fix)))
        crmax(mi, ni) = 0; 
    end
end
f = find(crmax)';
H =zeros(2,2); 
% Fit a quadratic
cnt = 0; 
for i = f
    cnt = cnt + 1;
    ni = 1 + floor((i-0.5)/m);
    mi = i - (ni-1)*m;
    if (mi > 1 & mi < m & ni > 1 & ni < n) 
        ix = mi - diagix3;
        iy = ni - diagix4;
        for k = 1:6
            y(k,1) = data(ix(k),iy(k)); 
        end
        coeffs = invH*y; 
        H(1,1) = coeffs(1);
        H(1,2) = coeffs(2);
        H(2,1) = H(1,2);
        H(2,2) = coeffs(3); 
        b = coeffs(4:5);
        c = coeffs(6);
        x = -0.5 * (H\b); 
        gt(cnt,1) = x'*H*x + b'*x + c;
% Error control 
        if flag 
            err2 = abs(xerr'*H*xerr + b'*xerr + c - data(mi+1, ni+1 ));
            mult = 1; 
            if err2 < 1/20*abs(gt(cnt))
                mult = 1.25;
            elseif err2 > (5*abs(gt(cnt))+1e-5)
                mult = 0.75;
            end

            pky = quad2(data(mi-1:mi+1,ni));
            f = abs((pky + 1.1e-5) /(factor *(data(mi,ni)-pky) + 1e-5));
            d(1,2) = min(d(1,2), mult * ((f>=0.3) + (0.7 + f)*(f< 0.3) +(f>1)*(log(f)/100)));
            pkx =  quad2(data(mi, ni-1:ni+1)');
            f = abs((pkx + 1.1e-5) /(factor  *(data(mi,ni) - pkx) + 1e-5));
            d(1,1) = min(d(1,1), mult * ((f>=0.3) + (0.7 + f)*(f< 0.3) +(f>1)*(log(f)/100)));
        end
    elseif mi > 1 & mi < m
        gt(cnt,1) = quad2(data(mi-1:mi+1,ni));
        if flag 
            pky = gt(cnt);
            f = abs((pky + 1.1e-5) /(factor *(data(mi,ni) - pky) + 1e-5));
            d(1,2) = min(d(1,2), (f>=0.3) + (0.7 + f)*(f< 0.3) +(f>1)*(log(f)/100));
            if (pky > -1e-5), d(1,1) = min(1, d(1,1)); end
        end
    elseif ni > 1 & ni < n
        gt(cnt,1) = quad2(data(mi, ni-1:ni+1)');
        if flag 
            pkx = gt(cnt); 
            f = abs((pkx + 1.1e-5) /(factor  *(data(mi,ni) - pkx) + 1e-5));
            d(1,1) = min(d(1,1), (f>=0.3) + (0.7 + f)*(f< 0.3) +(f>1)*(log(f)/100));
            if (pkx > -1e-5), d(1,2) = min(1, d(1,2)); end
        end
    else
        gt(cnt,1) = data(mi, ni);
        if (gt(cnt) > -1e-5), 
            d(1,1) = min(1, d(1,1)); 
            d(1,2) = min(1, d(1,2)); 
        end
    end
end
