function y = wcodemat(x,nb,opt,absol)
%WCODEMAT Extended pseudocolor matrix scaling.
%   Y = WCODEMAT(X,NBCODES,OPT,ABSOL) returns a coded version
%   of input matrix X if ABSOL=0, or ABS(X) if ABSOL is 
%   nonzero, using the first NBCODES integers.
%   Coding can be done row-wise (OPT='row' or 'r'), columnwise 
%   (OPT='col' or 'c'), or globally (OPT='mat' or 'm'). 
%   Coding uses a regular grid between the minimum and 
%   the maximum values of each row (column or matrix,
%   respectively).
%
%   Y = WCODEMAT(X,NBCODES,OPT) is equivalent to
%   Y = WCODEMAT(X,NBCODES,OPT,1).
%   Y = WCODEMAT(X,NBCODES) is equivalent to
%   Y = WCODEMAT(X,NBCODES,'mat',1).
%   Y = WCODEMAT(X) is equivalent to
%   Y = WCODEMAT(X,16,'mat',1).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 26-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.11.4.2 $

% Check arguments.
switch nargin
    case 1 , absol = 1; opt = 'm'; nb = 16;
    case 2 , absol = 1; opt = 'm';
    case 3 , absol = 1;
end
opt = lower(opt(1));

trans = false;
if isequal(opt(1),'r')
    trans = true;
    opt   = 'c';
    x     = x';
end
if absol , x = abs(x); end
switch opt
    case 'm'
        y = ones(size(x));
        x = x - min(min(x));
        maxx  = max(max(x));
        if maxx<eps , return; end
        x = nb*(x/maxx);
        y(:) = 1 + fix(x);

    case 'c'
        [t1,t2] = size(x);
        y = ones(t1,t2);
        minx  = min(x); 
        x = (x - minx(ones(1,t1),:));
        maxx  = max(x);
        echel = maxx(ones(1,t1),:);
        indexs = echel<eps;
        warning('off','MATLAB:divideByZero')
        x = nb*(x./echel);
        y = 1 + fix(x);
        warning('on','MATLAB:divideByZero')
        y(indexs) = 1;

    otherwise , 
        error(['Unknown Option.']);
end
y(y>nb) = nb;
if trans, y = y'; end
