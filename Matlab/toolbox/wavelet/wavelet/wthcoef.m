function c = wthcoef(o,c,l,niv,percent,sorh)
%WTHCOEF Wavelet coefficient thresholding 1-D.
%   NC = WTHCOEF('d',C,L,N,P) returns coefficients obtained
%   from the wavelet decomposition structure [C,L] (see WAVEDEC),
%   by rate compression defined in vectors N and P. 
%   N contains the detail levels to be compressed and P the
%   corresponding percentages of lower coefficients 
%   to be set to zero. N and P must be of same length.
%   Vector N must be such that 1 <= N(i) <= length(L)-2.
%
%   NC = WTHCOEF('d',C,L,N) returns coefficients obtained
%   from [C,L] by setting all the coefficients of detail
%   levels defined in N to zero.
%
%   NC = WTHCOEF('a',C,L) returns coefficients obtained by
%   setting approximation coefficients to zero.
%
%   NC = WTHCOEF('t',C,L,N,T,SORH) returns coefficients obtained
%   from the wavelet decomposition structure [C,L] by soft
%   (if SORH = 's') or hard (if SORH = 'h') thresholding
%   (see WTHRESH) defined in vectors N and T. N contains the
%   detail levels to be thresholded and T the corresponding
%   thresholds. N and T must be of same length.
%
%   [NC,L] is the modified wavelet decomposition structure.
%
%   See also WAVEDEC, WTHRESH.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.11.4.2 $

% Check arguments.
nbIn = nargin;
if nbIn < 3
  error('Not enough input arguments.');
end
o = lower(o(1));
if o=='a'
    if nbIn>3 , error('Too many input arguments.'); end
    c(1:l(1)) = 0;      
    return; 
end

rmax = length(l);
nmax = rmax-2;
if find((niv < 1) | (niv > nmax) | (niv ~= fix(niv)))
    error('Invalid level(s) number(s).')
end
if o=='d' & nbIn==5
    errLen = (length(niv) ~= length(percent));
    if errLen | ~isempty(find((percent<0) | (percent>100)))
        error('Invalid argument value.')
    end
elseif o=='t'
    errLen = (length(niv) ~= length(percent));
    if errLen | ~isempty(find(percent<0))
        error('Invalid argument value.')
    end
end

first = cumsum(l)+1;
first = first(end-2:-1:1);
ld    = l(rmax-1:-1:2);
last  = first+ld-1;

if o=='d' & nbIn==5
    for k = 1:length(niv)
        p  = niv(k);
        pc = percent(k);

        cfs = c(first(p):last(p));
        [x,ind] = sort(abs(cfs));

        annul = fix(ld(p)*pc/100);
        cfs(ind(1:annul))   = 0;
        c(first(p):last(p)) = cfs;
    end
elseif o=='t'
    for k = 1:length(niv)
        p   = niv(k);
        pc  = percent(k);        % thresholds
        cfs = c(first(p):last(p));
        cfs = wthresh(cfs,sorh,pc);
        c(first(p):last(p)) = cfs;
    end
else
    for p = niv
        c(first(p):last(p)) = 0;
    end
end
