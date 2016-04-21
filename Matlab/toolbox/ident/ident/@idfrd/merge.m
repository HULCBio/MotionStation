function sys1 = merge(varargin)
%MERGE Merges two IDFRD models.
%
%   M = merge(M1,M2,M3,...)
%
%   The models Mi must contain the same frequencies, and the covariance data
%   must be defined
%   M is the statistical average of Mi and delivered in
%   the same format.
%

%
%   $Revision: 1.3 $ $Daet$
%   Copyright 1986-2001 The MathWorks, Inc.


%      Lennart Ljung 96-1-15


sys1 = varargin{1};
Freqs = sys1.Frequency;
Unit = sys1.Units;
[Ny,Nu,Nf] = size(sys1);
for kj = 2:length(varargin)
   
   sysj = idfrd(varargin{kj});
   [ny,nu,nf] = size(sysj);
   if ny~=Ny|nu~=Nu
      error('In MERGE(FR1,FR2), FR1 and FR2 must have the same number of outputs and inputs.')
   end
   try
      [freq,units] = freqcheck(Freqs,Unit,sysj.Frequency,sysj.Units);
   catch
      error(lasterr)
   end
   if ~all(strcmp(sys1.OutputName,sysj.OutputName))|...
         ~all(strcmp(sys1.OutputUnit,sysj.OutputUnit))
      disp('WARNING: OutputName/OutputUnit differ in the models. First Names/Units used.')
   end
   if ~all(strcmp(sys1.InputName,sysj.InputName))|...
         ~all(strcmp(sys1.InputUnit,sysj.InputUnit))
      disp('WARNING: InputName/InputUnit differ in the models. First Names/Units used.')
   end
   %% Now to the merge:
   resp = sysj.ResponseData;
   cov = sysj.CovarianceData;
   Resp = sys1.ResponseData;
   Cov = sys1.CovarianceData;
   spe = sysj.SpectrumData;
   noi = sysj.NoiseCovariance;
   Spe = sys1.SpectrumData;
   Noi = sys1.NoiseCovariance;
   mergespe = 1;
   mergeresp = 1;
   if isempty(spe)|isempty(Spe)
      mergespe = 0;
   end
   if mergespe&(isempty(Spe)|isempty(spe))
      disp('MERGE of spectra cannot be done unless the covariance matrices are defined.')
      mergespe = 0;   
   end
   if isempty(resp)|isempty(Resp)
      mergeresp = 0;
   end
   if mergeresp&(isempty(Cov)|isempty(cov))
      disp('MERGE cannot be used unless the covariance matrices are defined.')
      mergeresp = 0;
   end
   if ~(mergeresp|mergespe)
      error('The models cannot be merged, due to lack of covariance information.')
   end
   
   for kf = 1:Nf
      if mergespe
         for ky=1:ny
            for ku=1:ny
               p1 = spe(ky,ku,kf); 
               p2 =  Spe(ky,ku,kf);
               if ky==ku
                  P1 = noi(ky,ky,kf);
                  P2 = Noi(ky,ky,kf);
               else
                  P1 = sqrt(noi(ky,ky,kf)*noi(ku,ku,kf));
                  P2 = sqrt(Noi(ky,ky,kf)*Noi(ku,ku,kf));
                  % The above is purely ad hoc, due to the fact that IDFRD
                  % does not contain information about the covariance matrix of
                  % the cross spectral estimates.
               end
               P = 1/(1/P1+1/P2);
               p = P*(p1/P1+p2/P2);
               if ky==ku
                  Noi(ky,ky,kf) = P;
               end
               Spe(ky,ku,kf)= p;
            end
         end
      end % if mergespe
      if mergeresp
         for ky=1:ny
            for ku=1:nu
               p1 = [real(resp(ky,ku,kf));imag(resp(ky,ku,kf))];  
               p2 = [real(Resp(ky,ku,kf));imag(Resp(ky,ku,kf))];  
               P1 = squeeze(cov(ky,ku,kf,:,:));
               P2 = squeeze(Cov(ky,ku,kf,:,:));
               iP1=pinv(P1);iP2=pinv(P2);
               P=pinv(iP1+iP2);
               Cov(ky,ku,kf,:,:) = P;
               p = P*(iP1*p1+iP2*p2);
               Resp(ky,ku,kf)=p(1)+i*p(2);
            end
         end
      end % if mergeresp
   end % for kf
   sys1.ResponseData = Resp;
   sys1.CovarianceData = Cov;              
   sys1.SpectrumData = Spe;
   sys1.NoiseCovariance = Noi;
end


