function IR=iduinpar(arg,TYpe,MSpa)
%IDUINPAR Performs non-parametric estimation for ident.
%   Arguments:
%   cra Gives correlation analysis using CRA. The options are read from XIDmen(12,1)
%   spa Gives spectral analysis using SPA/ETFE. The options are read from
%       XIDmen(12,1) and from XIDplotw(2,2)
%   The input arguments TYpe and MSpa override the options

%   L. Ljung 4-4-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.18.4.1 $ $Date: 2004/04/10 23:19:51 $

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');

[eDat,eDat_info,eDat_n]=iduigetd('e');
TSamp=pvget(eDat,'Ts'); 
if iscell(TSamp)
    TSamp =TSamp{1}; 
end
[N,ny,nu]=sizedat(eDat); 
usd=get(XID.plotw(16,1),'userdata');
if isa(eDat,'idfrd')
    eDat = iddata(eDat);
end
if strcmp(arg,'cra')
   iduistat('Performing correlation analysis ...')
   if nu==0
      errordlg(['Correlation Analysis cannot be applied to',...'
         ' time series to estimate the impulse response.'],'Error Dialog','modal');
 return
elseif pexcit(eDat)==0
    errordlg(['The input is identically zero.',...'
         ' No impulse response estimate.'],'Error Dialog','modal');
 IR = [];
 return
else
      NA=eval(usd(1,:));
      if isempty(NA)|strcmp(lower(NA(1)),'d')
         NA = 10;
      end
      
      OPt=get(XID.plotw(5,2),'UserData');
      TSpan=eval(deblank(OPt(2,:)));
      IR=[];
      IR = impulse(eDat,[-5 TSpan]*TSamp,'PW',NA);
      IR = pvset(IR,'Name','imp');%IR.Name = 'imp';
      IR = iduiinfo('set',IR,str2mat(eDat_info,...
         [' imp = impulse(',eDat_n,',[-5,',num2str(TSpan)...
            ,'],''PW'',',deblank(usd(1,:)),')']));
      iduiinsm(IR,1);%,eData_n]);
   end
elseif strcmp(arg,'spa')
   iduistat('Performing spectral analysis ...')
   if nargin==1
      OPt=usd([2,3],:);
      TYpe=eval((OPt(2,:)));
      MSpa=eval((OPt(1,:)));
   end
   OPt1=get(XID.plotw(2,2),'Userdata');
   W=eval(deblank(OPt1(4,:)));
   OPt2=get(XID.plotw(7,2),'Userdata');  
   if isempty(W)
      LW=128;
   else
      LW=2^nextpow2(W);  
   end
   if TYpe==2,nam='etf';else nam='spa';end
   if isempty(MSpa)
      nam=[nam,'d'];MSpa1=30;
   else
      sord=num2str(MSpa);sord=sord(1:min(4,length(sord)));
      nam=[nam,sord];MSpa1=MSpa;
   end,
   if TYpe==2
      g = etfe(eDat,MSpa,LW,TSamp); 
      STrcom=[' ',nam,' = etfe(',eDat_n,',',deblank(usd(2,:)),...
            ',',num2str(LW),')'];
      meth='e';
   else
      if isempty(MSpa)&ny>1,MSpa=-1;end
      if ny>1
         textM='[';
         for ky=1:ny
            textM=[textM,int2str(MSpa),' '];
         end
         textM=[textM(1:length(textM)-1),']'];
      else
         textM=deblank(usd(2,:));
      end
      if isempty(MSpa)
         MMSpa = zeros(0,ny);
      else
         MMSpa = MSpa;
      end
      
      g=spa(eDat,MMSpa,W,[],TSamp,1);
      STrcom=[' ',nam,' = spa(',eDat_n,',',textM,',',...
            deblank(OPt1(4,:)),',','[])'];
      meth='s';
   end
   g = iduiinfo('set',g,str2mat(eDat_info,STrcom));
   g = pvset(g,'Name',nam);
   iduiinsm(g,1);
end
