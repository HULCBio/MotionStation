function [x,I] = localmax(x,rInit);
%LOCALMAX Compute local maxima.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 05-Oct-96.
%   Last Revision: 25-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/03/15 22:41:01 $

[r,c] = size(x);
if nargin==1 , rInit = r; end

% Regularization of  x (!?)
%--------------------------
regule = 1;
if regule==1
    wav = 'sym4';
    lev = 5;
    [cfs,len] = wavedec(x(rInit,:),lev,wav);
    x(rInit,:) = wrcoef('a',cfs,len,wav);
end
x = [zeros(r,1) diff(abs(x),1,2)];
x(abs(x)<sqrt(eps)) = 0;
x(x<0) = -1;
x(x>0) = 1;
x = [zeros(r,1) diff(x,1,2)];
I = find(x==-2);
x(x>-2) = 0;
x(I) = 1;

% Chain maxima - Eliminate "false" maxima.
%-----------------------------------------
ideb = rInit ; step = -1; ifin = 1;
max_down = find(x(ideb,:));
x(ideb,max_down) = max_down;
if rInit<2 , return; end

for jj = ideb+step:step:ifin
    max_curr = find(x(jj,:));
    val_max  = zeros(size(max_curr));
    for k = 1:length(max_down)
        [nul,ind] = min(abs(max_curr-max_down(k)));
        val_max(ind) = max_down(k);
    end
    x(jj,max_curr) = val_max;
    max_down = max_curr(find(val_max));
end
