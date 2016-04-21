function th = ido2th(m)
%IDO2TH  obsolete function. Transforms new object format to old THETA format.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.11 $ $Date: 2002/02/12 07:36:57 $

if isa(m,'idarx')
    m=idss(m);
end
if isa(m,'idss')|isa(m,'idgrey')
   th =ids2th(m);
elseif isa(m,'idpoly')
   th = idp2th(m);
else
   th=[];
end

function th = ids2th(m)
% IDS2TH Transformation from IDSS object to THETA structure

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.11 $ $Date: 2002/02/12 07:36:57 $

lam = m.NoiseVariance;
try
  Vloss = m.EstimationInfo.LossFcn;
catch
  Vloss =[];
end
if isempty(Vloss)
Vloss =1;
end
th(1,1) = Vloss;
th(1,2) = m.Ts; % Ts
ny=1;nu=1;nn=4;nx=2;%
[ny,nu,nn,nx] = size(m);
th(1,3:5) = [nu ny nn];
if isa(m,'idgrey') 
   ms = m.FileArgument;
else
   ms = modstruc(m.as,m.bs,m.cs,m.ds,m.ks,m.x0s,'old');
end
[rarg,carg]=size(ms);
th(1,[6:7])=[rarg,carg];
if isa(m,'idgrey')%strcmp(m.SSParameterization,'Mfile')
    mname=m.MfileName;
    th(1,[8:7+length(mname)])=real(mname);
 end
 th(2,7)= 21; % Command
 if isa(m,'idgrey')%strcmp(m.SSParameterization,'Mfile')
     if m.cd == 'd'
         th(2,8) = 4; % discrete time should be 5  in continuous time
     else
         th(2,8) = 5;
     end
 else
     th(2,8) = 2; % Discrete time using ssmodx9
     % 1 is cont time using ssmodx9 (zoh)
     % 11 is cont time using ssmodx8 (foh)
     % 3 is MVARX
 end
 par=m.ParameterVector.';
 try
     Ncap = m.EstimationInfo.DataLength;
 catch
     Ncap = inf;
 end
 if isempty(Ncap), Ncap=inf;end
  th(2,1)=th(1,1)*(1+length(par)/Ncap)/(1-length(par)/Ncap); % should be FPE

 th(3,1:nn)=par;
 try
    th(4:3+nn,1:nn)=m.CovarianceMatrix;
 catch
 end
 
 th(4+nn:3+nn+rarg,1:carg)=ms;
 th(4+nn+rarg:3+nn+rarg+ny,1:ny)=m.NoiseVariance;
 
 function  th = idp2th(m)
% IDP2TH Transforms the IDPOLY object to the THETA structure
%
% TH = IDP2TH(IDP)
%

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.11 $ $Date: 2002/02/12 07:36:57 $

th(1,1) = m.NoiseVariance;
th(1,2) = m.Ts; %Ts
nu = size(m,2);
th(1,3) = nu;
th(1,4:6+3*nu) = [m.na m.nb m.nc m.nd m.nf m.nk];
 
th(2,7) = 5;% Command number
par = m.par.'; n=length(par);
 try
     Ncap = m.EstimationInfo.DataLength;
 catch
     Ncap = inf;
 end
  th(2,1)=th(1,1)*(1+length(par)/Ncap)/(1-length(par)/Ncap); % should be FPE
th(3,1:n) = par;
try
   th(4:3+n,1:n)=m.CovarianceMatrix;
catch
end

  
