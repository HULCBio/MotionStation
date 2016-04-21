function g = fqf2ido(freqfunc)
%FQF2IDO Obsolete function
%   G = FQF2IDO(FF) Translates the Toolbox's old  FREQFUNC-FORMAT to 
%   an IDFRD object. 
%
%   FF is a matrix of the old FREQFUNC structure, and G is returned as
%   an IDFRD object containing the corresponding information.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.8 $ $Date: 2001/04/06 14:21:37 $
if isa(freqfunc,'idfrd')
   g = freqfunc;
   return
end


info = freqfunc(1,:);
nof = size(freqfunc(:,1),1)-1;
ny=floor(max(info)/1000)+1;
nu=max(rem(info,10)); 
for ky=1:ny
   spec = freqfunc(2:end,find(info==(ky-1)*1000));
   sdspec = freqfunc(2:end,find(info==(ky-1)*1000+50));
   freqs = freqfunc(2:end,find(info==(ky-1)*1000+100));
   for ku=1:nu
      amp=freqfunc(2:end,find(info==(ky-1)*1000+ku));
      phase=freqfunc(2:end,find(info==(ky-1)*1000+ku+20));
      freqs=freqfunc(2:end,find(info==(ky-1)*1000+ku+100));
      sdamp=freqfunc(2:end,find(info==(ky-1)*1000+ku+50));
      sdphase=freqfunc(2:end,find(info==(ky-1)*1000+ku+70));
      
      response(ky,ku,:)=amp.*exp(phase*i*pi/180);
      if ~isempty(sdamp)
         for kf = 1:nof
            mat(1,:) = [real(response(ky,ku,kf)),imag(response(ky,ku,kf))]/...
               abs(response(ky,ku,kf));
            mat(2,:) = 180/pi*[imag(response(ky,ku,kf)),-real(response(ky,ku,kf))]/...
               abs(response(ky,ku,kf))^2;
            cov(ky,ku,kf,:,:)=inv(mat)*[[sdamp(kf)^2,0];[0,sdphase(kf)^2]]*inv(mat');
         end
      end
      
   end
   if ~isempty(spec)
      spd(ky,ky,:) = spec;
   else
      spd = [];
   end
   if ~isempty(sdspec)
      noi(ky,ky,:) = sdspec.^2; 
   else
      noi =[];
      end
end

g = idfrd(response,freqs,'CovarianceData',cov,'SpectrumData',spd,'NoiseCovariance',noi,...
   'InputName',{'u1';'u2'},'OutputName',{'y1','y2'},'InputUnit',{'';''},...
   'OutputUnit',{'';''});



