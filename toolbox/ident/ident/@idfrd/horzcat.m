function sys1 = horzcat(varargin)
%HORZCAT  Horizontal concatenation of IDFRD models.
%
%   M = HORZCAT(M1,M2,...) performs the concatenation 
%   operation
%         M = [M1 , M2 , ...]
% 
%   This operation amounts to appending the inputs and 
%   adding the outputs of the IDFRD models M1, M2,...
%   These models must then have the same number of outputs,
%   and be defined for the same frequencies.
%
%   SpectrumData will be ignored and M will contain no
%   SpectrumData.
% 
%   See also IDFRD/VERTCAT.

%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.12.4.1 $ $Date: 2004/04/10 23:16:45 $

ni = nargin;
nl = length(varargin);
sys1 = varargin{1};
if nl == 1
   return
end
sys1.SpectrumData = [];
sys1.NoiseCovariance = [];

sys2 = varargin{2};
inpn = pvget(sys1,'InputName');
inpn2 = pvget(sys2,'InputName');
oldflag = 0;
if length(inpn) == 0 & length(inpn2) == 0
   oldflag = 1;
end
for k = 1:length(inpn2)
   ls = strcmp(inpn,inpn2{k});
   if any(ls), 
      oldflag=1;
   end
end
if oldflag
   disp(sprintf(['  InputNames overlap in the IDFRD models to be concatenated.',...
         '\n  This is interpreted in old syntax as a multiplot of several models.',...
         '\n  In the new syntax use BODE(m1,m2,m3,..) instead.',...
         '\n  If you really want to concatenate the models, change InputName in the',...
         '\n  models to be non-overlapping.']))
   sys1 = varargin;
   return
end
Freqs = sys1.Frequency;
Unit = sys1.Units;
[Ny,Nu,Nf] = size(sys1.ResponseData);
for kj = 2:length(varargin)
   
   sysj = idfrd(varargin{kj});
   [ny,nu,nf] = size(sysj.ResponseData);
   if ny~=Ny&nu>0
      error('In [FR1,FR2], FR1 and FR2 must have the same number of outputs.')
   end
   try
      [freq,units] = freqcheck(Freqs,Unit,sysj.Frequency,sysj.Units);
   catch
      error(lasterr)
   end
   
   sys1.InputName = [sys1.InputName;sysj.InputName];
   sys1.InputUnit= [sys1.InputUnit;sysj.InputUnit];
   
   if ~all(strcmp(sys1.OutputName,sysj.OutputName))|...
         ~all(strcmp(sys1.OutputUnit,sysj.OutputUnit))
      disp('WARNING: OutputName/OutputUnit differ in the models. First Names/Units used.')
   end
   if sys1.Ts~=sysj.Ts
      disp('WARNING: Sampling times differ in the models. First value used.')
   end
   
   resp = sysj.ResponseData;
   cov = sysj.CovarianceData;
   Resp = sys1.ResponseData;
   Cov = sys1.CovarianceData;
   for ky = 1:Ny
      for ku = Nu+1:Nu+nu
         Resp(ky,ku,:) = resp(ky,ku-Nu,:);
         try
         Cov(ky,ku,:,:,:) = cov(ky,ku-Nu,:,:,:);
     end
         
      end
   end
   sys1.ResponseData = Resp;
   sys1.CovarianceData = Cov;
   sys1.InputDelay = [sys1.InputDelay;sysj.InputDelay];
end

