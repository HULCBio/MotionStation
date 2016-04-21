function ydb = mag2dB(y)
%MAG2DB  Magnitude to dB conversion.
%
%   YDB = MAG2DB(Y) converts magnitude data Y into dB values.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $ $Date: 2004/04/10 23:14:57 $
nzy = (y>0);
ydb = zeros(size(y));
ydb(nzy) = 20*log10(y(nzy));
ydb(~nzy) = -Inf;
