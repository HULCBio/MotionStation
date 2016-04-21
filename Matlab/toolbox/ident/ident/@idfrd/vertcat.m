function sys1 = vertcat(varargin)
%VERTCAT  Verticalal concatenation of IDFRD models.
%
%   M = VERTCAT(M1,M2,...) performs the concatenation 
%   operation
%         M = [M1 ; M2 ; ...]
% 
%   This operation amounts to appending the outputs 
%   of the IDFRD models M1, M2,...
%   These models must then have the same number of inputs,
%   and be defined for the same frequencies.
%
%   SpectrumData will also  be appended for the new outputs.
%   The cross spectrum between output channels in different
%   Mi will then be set to zero.
% 
%   See also HORZCAT, IDMODEL.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/04/10 23:16:54 $


% Remove all empty arguments
ni = nargin;
nl = length(varargin);
sys1 = varargin{1};
if nl == 1
   return
end
Freqs = sys1.Frequency;
Unit = sys1.Units;
for kj = 2:length(varargin)
   sysj = varargin{kj}; 
   if ~isa(sysj,'idfrd')
       error('All models to be concatenated must be IDFRD objects.')
   end
   [Ny,Nu,Nf] = size(sys1.ResponseData);
   if Nu == 0
      [Ny,dum,Nf] = size(sys1.SpectrumData);
   end
   nameflag = 0;
   outpn = pvget(sys1,'OutputName');
   outpn2 = pvget(sysj,'OutputName');
   for k = 1:length(outpn2)
      ls = strcmp(outpn,outpn2{k});
      if any(ls), 
         nameflag=1;
      end
   end
   if nameflag
      error(sprintf(['The outputnames overlap.\n',...
            'If you want to extend the output responses, first make the\n',...
            'OutputNames unique.']))
   end
   [ny,nu,nf] = size(sysj.ResponseData);
   if nu == 0
      [ny,sum,nf] = size(sysj.SpectrumData);
   end
   if nu~=Nu
      error('In [FR1;FR2], FR1 and FR2 must have the same number of inputs.')
   end
   try
      [freq,units] = freqcheck(Freqs,Unit,sysj.Frequency,sysj.Units);
   catch
      error(lasterr)
   end
   sys1.OutputName = [sys1.OutputName;sysj.OutputName];
   sys1.OutputUnit= [sys1.OutputUnit;sysj.OutputUnit];
   
   if ~all(strcmp(sys1.InputName,sysj.InputName))|...
         ~all(strcmp(sys1.InputUnit,sysj.InputUnit))
      warning('InputName/InputUnit differ in the models. First Names/Units used.')
   end
   if sys1.Ts~=sysj.Ts
      warning('Sampling times differ in the models. First value used.')
   end
   
   resp = sysj.ResponseData;
   cov = sysj.CovarianceData;
   spe = sysj.SpectrumData;
   noi = sysj.NoiseCovariance;
   Spe = sys1.SpectrumData;
   Noi = sys1.NoiseCovariance;
   Resp = sys1.ResponseData;
   Cov = sys1.CovarianceData;
   for ky = Ny+1:Ny+ny
      for ku = 1:Nu
         Resp(ky,ku,:) = resp(ky-Ny,ku,:);
         try%if ~isempty(cov)
         Cov(ky,ku,:,:,:) = cov(ky-Ny,ku,:,:,:);
     end
      end
   end
   if ~isempty(Spe)&~isempty(spe)
      if isempty(noi)
         noi = zeros(ny,ny,nf);
      end
      if isempty(Noi)
         Noi = zeros(Ny,Ny,Nf);
      end
      for ky1 =Ny+1:Ny+ny
         for ky2 = Ny+1:Ny+ny
            Spe(ky1,ky2,:)=spe(ky1-Ny,ky2-Ny,:);
            Noi(ky1,ky2,:) = noi(ky1-Ny,ky2-Ny,:);
         end
      end
      sys1.NoiseCovariance = Noi;
      sys1.SpectrumData = Spe;
   end
   
   sys1.ResponseData = Resp;
   sys1.CovarianceData = Cov;
end

