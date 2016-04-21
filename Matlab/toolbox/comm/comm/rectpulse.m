function y = rectpulse(x,Nsamp)
% RECTPULSE Rectangular pulse shaping.
%   Y = RECTPULSE(X,NSAMP) returns Y, a rectangular pulse shaped version of X,
%   with NSAMP samples per symbol. This function replicates each symbol in
%   X NSAMP times. To insert zeros between each sample of X, see UPSAMPLE.
%   For two-dimensional signals, the function treats each column as 1
%   channel.
%
%   See also INTDUMP, UPSAMPLE, RCOSFLT.

%    Copyright 1996-2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/08/25 05:34:01 $ 

%Check x, Nsamp
if( ~isnumeric(x))
    error('comm:rectpulse:Xnum','X must be numeric.');
end

if(~isreal(Nsamp) || ~isscalar(Nsamp) ||  Nsamp<=0 || (ceil(Nsamp)~=Nsamp) || ~isnumeric(Nsamp) )
    error('comm:rectpulse:nsamp','NSAMP must be a positive integer.');
end

% --- Assure that X, if one dimensional, has the correct orientation --- %
wid = size(x,1);
if(wid ==1)
    x = x(:);
end

h = ones(Nsamp,1);
y = upfirdn(x, h, length(h));

% --- restore the output signal to the original orientation --- %
if(wid == 1)
    y = y.';
end

% --- EOF --- %
