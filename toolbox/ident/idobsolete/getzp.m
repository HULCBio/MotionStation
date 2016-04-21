function [z,p,zsd,psd] = getzp(zepo,ku,ky)
%GETZP  Extracts the zeros and the poles from the ZEPO-format created by TH2ZP.
%   OBSOLETE function. Use ZPKDATA instead. See HELP IDMODEL/ZPKDATA.
%
%[Z,P] = GETZP(ZEPO,KU,KY)
%
%   Z : The zeros
%   P : The poles
%   ZEPO: The matrix of zeros and poles, resulting from th2zp
%   KU : The input number (default 1). Noise source #ju is represented as
%        input number -ju.
%
%   KY : The output number (default 1).
%
%   If several entries in ZEPO correspond to the same input-output
%   relation, then Z and P will contain one column for each model.
%   Z and P will be stripped from spurious 'inf':s and zeros as far
%   as possible.
%
%   [Z,P,Zsd,Psd] = GETZP(ZEPO,KU,KY) gives access to the standard
%   deviations of the zeros and poles, respectively.

%   L. Ljung 20-8-90,26-9-93
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.9 $ $Date: 2001/04/06 14:21:38 $

if nargin < 1
   disp('Usage: [ZEROS, POLES] = GETZP(ZEPO)')
   disp('       [ZEROS, POLES, SDzeros, SDpoles] = GETZP(ZEPO,INPUT,OUTPUT)')
   return
end

if nargin<3, ky=[];end
if nargin<2, ku=[];end
if isempty(ky), ky=1;end
if isempty(ku), ku=1;end
if ku==0,ku=-1;end
if ku<0, ku=500+abs(ku);end
[rzepo,czepo]=size(zepo);
if rzepo==1,
   Z=[];P=[];Zsd=[];Psd=[];
   return,
end
zind = find(abs(zepo(1,:))==(ky-1)*1000+ku);
zindsd = find(abs(zepo(1,:))==(ky-1)*1000+ku+60);
if isempty(zindsd),
   nozsd=1;
else 
   nozsd=0;
end
pind = find(abs(zepo(1,:))==(ky-1)*1000+ku+20);
pindsd = find(abs(zepo(1,:))==(ky-1)*1000+ku+80);
if isempty(pindsd),
   nopsd=1;
else 
   nopsd=0;
end
if isempty(zind),
   disp('No zeros corresponding to this input/output pair found'),
else
   zer = zepo(:,zind);  zersd = zepo(:,zindsd);
   
   [zr,zc]=size(zer); disc=zer(1,1)>0;
   zer=zer(2:zr,:);
   if ~nozsd,
      zersd=zersd(2:zr,:);
   end
   z=[]; zsd=[];
   for kc=1:zc
      z1 = zer(find(zer(:,kc)~=inf),kc);
      if ~nozsd,
         z1sd = zersd(find(zersd(:,kc)~=inf),kc);
      end
      if disc, 
         if ~isempty(z1),
            z1 = zer(find(zer(:,kc)~=inf),kc);
            if ~nozsd
              z1sd = z1sd(find(z1sd~=0));
            end,
         end, 
      end %corr 930424
      l1=length(z1);[zzr,zzc]=size(z);mr=max(l1,zzr);
      z = [[z;ones(mr-zzr,zzc)+inf],[z1;ones(mr-l1,1)+inf]];
      if ~nozsd,
         zsd = [[zsd;ones(mr-zzr,zzc)+inf],[z1sd;ones(mr-l1,1)+inf]];
      end
   end,
end
if isempty(pind),
   disp('No poles corresponding to this input/output pair found'),
else
   pol = zepo(:,pind); polsd= zepo(:,pindsd);
   [zr,zc]=size(pol); disc=pol(1,1)>0;
   pol=pol(2:zr,:);
   if ~nopsd,
      polsd=polsd(2:zr,:);
   end
   p=[];psd=[];
   for kc=1:zc
      z1 = pol(find(pol(:,kc)~=inf),kc);
      if ~nopsd,
         z1sd=polsd(find(polsd(:,kc)~=inf),kc);
      end
      if disc, 
         if ~isempty(z1),z1 = z1(find(z1~=0));
         end,
      end
      l1=length(z1);[zzr,zzc]=size(p);mr=max(l1,zzr);
      p = [[p;ones(mr-zzr,zzc)+inf],[z1;ones(mr-l1,1)+inf]];
      if ~nopsd,
         psd = [[psd;ones(mr-zzr,zzc)+inf],[z1sd;ones(mr-l1,1)+inf]];
      end
   end,
end
