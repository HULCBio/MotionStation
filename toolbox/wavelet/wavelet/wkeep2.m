function y = wkeep2(x,siz,varargin)
%WKEEP2  Keep part of a matrix.
%   Y = WKEEP2(X,S) extracts the central part of the matrix X. 
%   S is the size of Y.
%   Y = WKEEP2(X,S,[FIRSTR,FIRSTC]) extracts the submatrix of 
%   matrix X, of size S and starting from X(FIRSTR,FIRSTC).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 07-May-2003.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $

% Check arguments.
nbIn = nargin;
if nbIn < 2
  error('Not enough input arguments.');
elseif nbIn > 4
  error('Too many input arguments.');
end
if (siz ~= fix(siz))
    error('Arg2: invalid argument value.');
end

y = x;
sx = size(x);
siz = siz(:)';
siz(siz>sx) = sx(siz>sx);
ok = isempty(find(siz < 0));
if ~ok , return; end

if nbIn<3, OPT = 'c'; else , OPT = lower(varargin{1}); end
if ischar(OPT(1))
    switch OPT(1)
        case 'c'
            if nbIn<4
                if length(OPT)>1 , side = OPT(2:end); else , side = 'l'; end
            else
                side = varargin{2};
            end
            if length(side)<2 , side(2) = 'l'; end
            
            d = (sx-siz)/2;
            for k = 1:2
                switch side(k)
                    case {'u','l','0',0} , 
                        first(k) = 1+floor(d(k)); last(k) = sx(k)-ceil(d(k));
                    case {'d','r','1',1} , 
                        first(k) = 1+ceil(d(k));  last(k) = sx(k)-floor(d(k));
                end
            end

        case {'l','u'} , first = [1 1]; last = siz;
        case {'r','d'} , first = sx-siz+1; last = sx;
    end
else
    first = OPT; last = first+siz-1;
    if ~isequal(first,fix(first)) || any(first<1) || any(last>sx)
        error('Invalid argument value.');
    end
end
y = y(first(1):last(1),first(2):last(2));
