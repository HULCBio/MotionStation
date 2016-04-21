function idfn = fcat(varargin)
%IDFRD/FCAT Concatanation of IDFRDs along the frequency dimension
%   MC = FCAT(M1,M2,...Mn)
%   
%   M1, M2 ... are IDFRD's, all with the same number of inputs and outputs.
%   MC is an IDFRD that contains all the responses of M1, M2, ...
%
%   See also IDFRD/FSELECT.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:16:41 $

if ischar(varargin{end})
    srt = 0;
    varargin = varargin(1:end-1);
else
    srt = 1;
end

freq = [];
resp = [];
spe = [];
cov = [];
noi = [];
id  = varargin{1};
inpn = id.InputName;
outn = id.OutputName;
[ny,nu,dum,ns] = size(id);
inpu = id.InputUnit;
outu = id.OutputUnit;
ts = id.Ts;
un = id.Units;
 idfn = id;
for kd = 1:length(varargin)
    id = varargin{kd};
    if ~isa(id,'idfrd')
        error('All argumnets of FCAT must the IDFRD objects.')
    end
    
    [ny1,nu1,dum,ns1] = size(id);
    if ny1~=ny|nu1~=nu|ns1~=ns
        error(['The IDFRDs to be concatenated must have the same number of',...
                ' input, output, and spectrum channels.'])
    end
    if ~strcmp(cat(2,inpn{:}),cat(2,id.InputName{:}))|...
            ~strcmp(cat(2,outn{:}),cat(2,id.OutputName{:}))
        warning(['The concatenated IDFRDs have different channel names. Those of the',...
            ' first one are used.'])
    end
    if ~strcmp(cat(2,inpu{:}),cat(2,id.InputUnit{:}))|...
            ~strcmp(cat(2,outu{:}),cat(2,id.OutputUnit{:}))
        warning(['The concatenated IDFRDs have different channel units. Those of the',...
            ' first one are used.'])
    end
    
    if ~strcmp(un,id.Units)
        error(['The concatenated IDFRDs have different frequency units.']) 
    end
    if ts~=id.Ts
        error(['The concatenated IDFRDs have different sampling intervals.'])
    end
    freq = [freq;id.Frequency];
    resp = [resp;permute(id.ResponseData,[3 1 2])];
    spe = [spe;permute(id.SpectrumData,[3 1 2])];
    if ~isempty(cov)
        cov = [cov;permute(id.CovarianceData,[3 1 2 4 5])];
    end
    if ~isempty(noi)
        noi = [noi;permute(id.NoiseCovariance,[3 1 2])];
    end
end
if srt
    [freq,ind] = sort(freq);
    resp = resp(ind,:,:);
    spe = spe(ind,:,:);
    try
        cov = cov(ind,:,:,:,:);
        noi = noi(ind,:,:);
    end
end

idfn.Frequency = freq;
idfn.ResponseData = permute(resp,[2 3 1]);
idfn.SpectrumData = permute(spe,[2 3 1]);
idfn.CovarianceData = permute(cov,[2 3 1 4 5]);
idfn.NoiseCovariance = permute(noi,[2 3 1]);
