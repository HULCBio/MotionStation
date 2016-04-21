%function [mag,err] = terpolb(fastfre,fastmag,slowfre)
%   interpolates back after complex cepstrum calculation,
%   from the interpolated, regularly spaced data, to the original
%   frequency response data.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [mag,err] = terpolb(fastfre,fastmag,slowfre)
nptsslo = length(slowfre);
mag = zeros(1,nptsslo);
nptsfst = length(fastfre);
strt = 1;
stop = nptsslo;
lowstuff = find(slowfre<=fastfre(1));
if ~isempty(lowstuff)
    mag(lowstuff) = fastmag(1);
    strt = length(lowstuff) + 1;
end
highstuff = find(slowfre>=fastfre(nptsfst));
if ~isempty(highstuff)
    mag(highstuff) = fastmag(nptsfst);
    stop = nptsslo - length(highstuff);
end
for i=strt:stop
    p = min(find(fastfre>=slowfre(i)));
    rat = (slowfre(i)-fastfre(p-1))/(fastfre(p)-fastfre(p-1));
    mag(i) = rat*fastmag(p) + (1-rat)*fastmag(p-1);
end