function [nk,v] = delayest(z1,na,nb,nkmin,nkmax)
%DELAYEST Estimates the delay (deadtime) directly from data.
%   NK = DELAYEST(DATA)
%
%   NK is the estimated delay in samples.
%   DATA is the input/output data as an IDDATA object. 
%      Only single output data is supported.
%
%   NK = DELAYEST(DATA,NA,NB,NKMIN,NKMAX) gives access to
%   NA: The number of denomininator coefficients in the models (Def 2)
%   NB: The number of numerator coefficients used in the tests. (Def 2)
%   NKMIN: A known lower bound for the delay. (Def 0). For data in closed
%        loop (output feedback present) use NKMIN = 1;
%   NKMAX: A known upper bound for the delays (Def NKMIN + 20)

%   L. Ljung 29-12-02
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2003/08/08 19:42:00 $


if isa(z1,'frd')|isa(z1,'idfrd'),
    z1 = iddata(idfrd(z1));
end
[N,ny,nu]=size(z1);
if ny>1
    error('This routine works only for single output data.')
end
if nargin<2
    na = 2;
end
if nargin<3
    nb = 2*ones(1,nu);
end
if nargin < 4
    nkmin = zeros(1,nu);
end
if nargin<5
    nkmax = nkmin+40;
end
nnk=[nkmin(1):nkmax(1)]';
for ku=2:nu
    nk = [nkmin(ku):nkmax(ku)]';
    nr = length(nk);
    [nrn] = size(nnk,1);
    nnk=[repmat(nnk,nr,1),sort(repmat(nk,nrn,1))];
end
lnn = size(nnk,1);
nn=[ones(lnn,1)*na ones(lnn,1)*nb nnk];
v=arxstruc(z1,z1,nn);
nnc = selstruc(v,0);
nk = nnc(2+nu:end);
