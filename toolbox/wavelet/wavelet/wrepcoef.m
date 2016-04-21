function varargout = wrepcoef(coefs,longs,levels,notrunc)
%WREPCOEF Replication of coefficients.
%
%   VARARGOUT = WREPCOEF(COEFS,LONGS,LEVELS)
%   VARARGOUT = WREPCOEF(COEFS,LONGS) is equivalent to
%   VARARGOUT = WREPCOEF(COEFS,LONGS,[1:LEVMAX]) where
%   LEVMAX = length(LONGS)-2;
%
%   VARARGOUT = WREPCOEF(COEFS,LONGS,LEVELS,'notrunc')
%

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 07-Sep-98.
%   Last Revision: 07-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/03/15 22:43:26 $

if nargin<4 , trunc = 1; else , trunc = 0; end
len    = longs(end);
levmax = length(longs)-2;
if nargin<3 , levels = [1:levmax]; end
nblev  = length(levels);
first  = cumsum(longs)+1;
first  = first(end-2:-1:1);
tmp    = longs(end-1:-1:2);
last   = first+tmp-1;
longs  = longs(end-1:-1:2);

repcoefs = cell(1,nblev);
for j = 1:length(levels)
    k = levels(j);
    nbind = 2^k;
    nbcfs = nbind*longs(k);
    tmp   = coefs(first(k):last(k));
    tmp   = tmp(ones(1,nbind),:);
    tmp   = tmp(:)';
    if trunc , tmp   = wkeep1(tmp,len); end
    repcoefs{j} = tmp;
end
if trunc
    varargout{1} = cat(1,repcoefs{:});
else
    varargout{1} = repcoefs;
end
