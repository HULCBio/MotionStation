function result = subsref(sys,Struct)
%SUBSREF  Subsref method for IDFRD models
 %   The following reference operations can be applied to an FRD model H:
%    
%      H(Outputs,Inputs)     select subsets of I/O channels.
%      H.Fieldname           equivalent to GET(MOD,'Filedname')
%   These expressions can be followed by any valid subscripted
%   reference of the result, as in H(1,[2 3]).inputname or
%   squeeze(H.cov(25,2,3,:,:))
%
%   The channel reference can be made by numbers or channel names:
%     H('velocity',{'power','temperature'})
%   For single output systems H(ku) selects the input channels ku
%   while for single input systems H(ky) selcets the output 
%   channels ky.
%
%   H('measured') selects just the measured input channels and 
%       ignores the noise inputs, that is only ResponseData and
%       CovarianceData are kept.
%
%   H('noise') extracts SpectrumData and NoiseCovariance.
%
 
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2001/08/03 14:25:33 $

StrucL = length(Struct);

switch Struct(1).type
case '.'
   tmpval = get(sys,Struct(1).subs);
   if StrucL==1
      result = tmpval;
   else
      result = subsref(tmpval,Struct(2:end));
   end  
case '()'
   
   try
      if StrucL==1, 
         result = indexref(sys,Struct(1).subs);
      else
         result = subsref(indexref(sys,Struct(1).subs),Struct(2:end));
      end
   catch
      error(lasterr)
   end
   
   
otherwise
   error(['Unsupported type ' Struct(1).type])
end

function sys = indexref(sys,index)
resp=sys.ResponseData;
covd=sys.CovarianceData;
spect=sys.SpectrumData;
ncov = sys.NoiseCovariance;
[ny,nu,N]=size(sys);

if length(index)>2&strcmp(index{3},'s')
   silent = 1;
else 
   silent = 0;
   end
   if length(index)==1
      if any(strcmp(lower(index{1}(1)),{'n','m'})) %%LL%% if channel name ..
         index{2}=index{1};
         index{1}=':';
      elseif ny==1
         index{2}=index{1};
         index{1}=1;
      elseif any(nu==[0 1])
         index{2}=':';
      end
   end
   
[yind,errflagy] = indmatch(index{1},pvget(sys,'OutputName'),ny,'Output');
if ~silent
   
   error(errflagy)
else
   if ~isempty(errflagy)
      sys =[];
      return
   end
end

if nu == 0
   uind = [];
   flagmea = 0;
   if strcmp(lower(index{2}(1)),'a')
      flagall = 1;
   else
      flagall = 0;
   end
else
   [uind,errflagu,flagmea,flagall] = indmatch(index{2},pvget(sys,'InputName'),...
      nu,'Input',0);
   if ~silent
   error(errflagu)
else
   if ~isempty(errflagu)
      sys =[];
      return
   end
end
end
if isempty(uind)
  sys = tsflag(sys,'set');
end

  nk=sys.InputDelay;
if ~isempty(nk),nk=nk(uind);end
if flagmea
   spect1=zeros(0,0,N);
   ncov1 = spect1;
else
   if isempty(spect)
      spect1 = [];
   else
      
      spect1 = spect(yind,yind,:);
   end
   if isempty(ncov)
      ncov1=[];
      else
         ncov1 = ncov(yind,yind,:);
      end
      
end
   if isempty(resp)
      resp1 = [];
   else
           resp1 = resp(yind,uind,:);
   end
   if isempty(covd)
      covd1=[];
      else
         covd1 = covd(yind,uind,:,:,:);
      end
      

sys = pvset(sys,'ResponseData',resp1,'CovarianceData',covd1,...
   'SpectrumData',spect1,'NoiseCovariance',ncov1,'InputDelay',nk,...
   'InputName',sys.InputName(uind),'InputUnit',sys.InputUnit(uind),...
      'OutputName',sys.OutputName(yind),'OutputUnit',sys.OutputUnit(yind)...
); 

