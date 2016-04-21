function dat1 = nkshift(dat2,nk,append)
%NKSHIFT Shifts the data
%
%   DATSHIFT = NKSHIFT(DATA,NK)
%   
%   DATA: An IDDATA object
%   NK: Shifts in samples. Both positive and negative shifts are allowed
%       A row vector with as many elements as there are inputs.
%       A positive value of nk means that the inputs are delayed.
%   DATSHIFT: An IDDATA object with input ku shifted nk(ku) steps.
%
%   NKSHIFT lives in symbiosis with the InputDelay property of IDMODEL:
%   m1 = pem(dat,4,'InputDelay',nk) is related to
%   m2 = pem(nkshift(dat,nk),4);
%   such that m1 and m2 are the same models, but M1 stores the delay
%   information for use when frequency responses etc are computed.
%
%   NOTE the difference with the MODEL property NK:
%   m3 = pem(dat,4,'nk',nk) gives a model which itself contains a delay of
%   nk samples
%
%   With Dat1 = NKSHIFT(Dat,NK,'append'), zeros are appended to the input
%   signals, so that Dat1 has the same length as Dat.
%
%   If NK is a cell array of length equal to the number of experiments, different
%   delays will be applied to the different experiments.

%   $Revision: 1.9.4.1 $ $Date: 2004/04/10 23:16:02 $
%   Copyright 1986-2003 The MathWorks, Inc.


if nargin<2
    disp('Usage: Dats = NKSHIFT(Dat,NK).')
    return
end
if nargin<3
    append = 0;
else
    append = 1;
end

[N,ny,nu,Ne] = size(dat2);
if iscell(nk)
    if ~length(nk)==Ne&~length(nk)==1
        error(sprintf(['For multiexperiment data with different delays,',...
                '\nNK must be a cell array of length equal to the number of experiments.']))
    end
    if Ne>1&length(nk)==1
        nk = repmat(nk,1,Ne);
    end
    try
        nk = cat(1,nk{:});
    catch
        error('Each row of NK must be of length Nu.')
    end
else
    if min(size(nk)) == 1
        nk = nk(:)';
        if Ne > 1
            nk = repmat(nk,Ne,1);
        end
    end
end

if all(all(nk==0)')
    dat1 = dat2;
    return
end
nunk = size(nk,2);
if nunk~=nu
    error('NK must have as many columns as there are inputs.')
end
if nu == 0
    error('NKSHIFT can only be used for data sets with an input.')
end
if strcmp(lower(pvget(dat2,'Domain')),'frequency')
    dat1 = nkshift_f(dat2,nk);
    return
end
sampl = pvget(dat2,'SamplingInstants');
uoldc = dat2.InputData; 
yoldc = dat2.OutputData;
for kexp = 1:length(uoldc)
    nk1 = nk(kexp,:);
    uold = uoldc{kexp};
    yold = yoldc{kexp};
    [Ncap,nu] = size(uold);
    Ncc = min([Ncap,Ncap+min(nk1)]);
    for ku = 1:nu
        if append, mn = max([nk1(ku),0]); else mn = max([nk1,0]);end
        u1 = uold(mn-nk1(ku)+1:Ncc-nk1(ku),ku);
        if append
            newsamp = Ncap-length(u1);
            if nk1(ku)>0
                u1= [zeros(newsamp,1);u1];
            else
                u1 = [u1;zeros(newsamp,1)];
            end
        end
        ut(:,ku) = u1;
    end
    unew{kexp} = ut;
    clear ut
    if ~append
        ynew{kexp} = yold(max([nk1+1,1]):min([Ncap,Ncap+min(nk1)]),:);
        samplnew{kexp} = sampl{kexp}(max([nk1+1,1]):min([Ncap,Ncap+min(nk1)]),:);
    else
        ynew{kexp} = yold;
        samplnew{kexp} = sampl{kexp};
    end
end
dat1 = dat2;
dat1.InputData = unew;
dat1.OutputData = ynew;
dat1 = pvset(dat1,'SamplingInstants',samplnew);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dat1 = nkshift_f(dat2,nk)
Freqs = pvget(dat2,'Radfreqs');
uoldc = pvget(dat2,'InputData'); 
Ts = pvget(dat2,'Ts');
if ~iscell(Ts)
    Ts = {Ts};
end
Ne = size(dat2,'Ne');
if length(Ts)~=Ne,
    for kexp=1:Ne,
        Ts{kexp} = Ts{1};
    end
end
for kexp = 1:Ne
    Fre = Freqs{kexp}(:); % Normalize frequencies to [0,pi]
    nk1 = nk(kexp,:);
    if Ts{kexp}>0 %%LL
        nk1 = Ts{kexp}*nk1; %%LL
    end
    uold = uoldc{kexp};
    [N,nu] = size(uold);
    ut = zeros(N,nu);
    for ku = 1:nu
        ut(:,ku) = exp(-i*Fre*nk1(ku)).*uold(:,ku);
    end
    unew{kexp} = ut; 
end
dat1 = dat2;
dat1.InputData = unew;

