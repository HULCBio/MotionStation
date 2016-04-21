function frf = freqfunc(sys)
%FREQFUNC  Trnasforms from IDFRF to the FREQFUNC format

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:22:05 $

una = sys.InputName;
yna = sys.OutputName;
[mag,phase,w,sdamp,sdphase] = boderesp(sys);
lw =length(w);
ky = 1;
ku = 1;
frf=[];
while ~isempty(yna)
   yname = yna{1};
   indy = find(strcmp(yname,yna));
   cindy = find(~strcmp(yname,yna));
   yna = yna(cindy);
   while ~isempty(una)
      uname = una{1};
      indu = find(strcmp(uname,una));
      cindu = find(~strcmp(uname,una));
      una = una(cindu);
      for kny = indy
         if norm(phase(kny,kny))==0 % Then sys is a spectrum
            ku1 = 0; indu = kny;
         else
            ku1 = ku; induu = indu;
         end
         
         for knu = induu
            if norm(mag(kny,knu))>0
               
               frfnc(1,1:5)=(ky-1)*1000+[ku1+100,ku1,ku1+50,ku1+20,ku1+70];
               frfnc(2:lw+1,1)=w;
               frfnc(2:lw+1,2)=squeeze(mag(kny,knu,:));
               frfnc(2:lw+1,3)=squeeze(sdamp(kny,knu,:));
               if ku1>0
                  frfnc(2:lw+1,4)=squeeze(phase(kny,knu,:));
                  frfnc(2:lw+1,5)=squeeze(sdphase(kny,knu,:));
               end
               
            end
            frf = [frf,frfnc];
         end
      end
   end
end
