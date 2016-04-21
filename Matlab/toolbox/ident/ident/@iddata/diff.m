function zd = diff(z,n)
%IDDATA/DIFF applies DIFF to the signals of an IDDATA object
%   ZD = DIFF(Z)  or ZD = DIFF(Z,n)
%   
%   ZD is an IDDATA object with the same characteristics as Z but with
%      DIFF(s,n) (n-differences) applied to all its signals. If an input
%      is denoted as First-order-hold, it is changed to zero-order-hold.
%
%   n = 1 is default

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2003/05/25 15:06:59 $

if nargin < 2
    n = 1;
end
if strcmp(z.Domain,'Frequency')
    error('IDDATA/DIFF does not apply to frequency domain data.')
end
zd = z;
y = z.OutputData;
u = z.InputData;
int =z.InterSample;
for k = 1:length(y)
    yd{k} = diff(y{k},n);
    ud{k} = diff(u{k},n);
    for ku = 1:size(ud{k},2)
        if ~strcmp(lower(int{ku,k}),'bl')
            int{ku,k} = 'zoh';
        end
    end
    if ~isempty(zd.SamplingInstants{k})
    zd.SamplingInstants{k} = zd.SamplingInstants{k}(1+n:end);
end

end
zd = pvset(zd,'OutputData',yd,'InputData',ud,'InterSample',int);
