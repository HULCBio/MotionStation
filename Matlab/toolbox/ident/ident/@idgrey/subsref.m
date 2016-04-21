function result = subsref(sys,Struct)
%SUBSREF  Subsref method for IDMODEL models
%   The following reference operations can be applied to any IDMODEL
%   object MOD:
%      MOD(Outputs,Inputs)     select subsets of I/O channels.
%      MOD.Fieldname           equivalent to GET(MOD,'Filedname')
%   These expressions can be followed by any valid subscripted
%   reference of the result, as in MOD(1,[2 3]).inputname or
%   MOD.cov(1:3,1:3)
%
%   The channel reference can be made by numbers or channel names:
%     MOD('velocity',{'power','temperature'})
%   For single output systems MOD(ku) selects the input channels ku
%   while for single input systems MOD(ky) selcets the output 
%   channels ky.
%
%   MOD('measured') selects just the mesured input channels and 
%       ignores the noise inputs.
%   MOD('noise') gives a time series (no measured input channels)
%       description of the additive noise properties of MOD.
%
%   To jointly address measured and noise channels, first convert
%   the noise channels using NOISECNV.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2001/08/03 14:24:32 $

StrucL = length(Struct);

switch Struct(1).type
case '.'
   try
      tmpval = get(sys,Struct(1).subs);
   catch
      error(lasterr)
   end
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
 if isempty(sys)
   return 
end
lam = pvget(sys.idmodel,'NoiseVariance');
%lam1 = lam;
ny = size(lam,1);
[a,b] = ssdata(sys);
nu = size(b,2);
try
[yind,uind,returnflag,flagmea,flagall,flagnoise,flagboth] = ...
   subndeco(sys.idmodel,index,lam);
catch
   error(lasterr)
end
if flagnoise
  sys = tsflag(sys,'set');
end

if flagboth
   sys = setnoime(sys);
   return
end


if returnflag
   if returnflag==2
      sys = idgrey;
   elseif returnflag ==3
      sys = [];
   end
   return
end
ut = pvget(sys,'Utility');
if flagall
   try
      if ut.index.flagall
         return
      end
   catch
   end
   
   in = pvget(sys.idmodel,'InputName');
     ut = pvget(sys.idmodel,'OutputName');
    pre = noiprefi('v');
   for ky = 1:ny
      in =[in;{[pre,ut{ky}]}];
   end

   sys.idmodel = pvset(sys.idmodel,'InputName',in); 
   iu = pvget(sys.idmodel,'InputUnit');
   sys.idmodel = pvset(sys.idmodel,'InputUnit',[iu; ...
		    pvget(sys.idmodel,'OutputUnit')]); 
   sys.idmodel = pvset(sys.idmodel,'InputDelay', ...
		       [pvget(sys.idmodel,'InputDelay');zeros(ny,1)]);
end

if ~flagall
   sys.idmodel=sys.idmodel(yind,uind);
end
 ut=pvget(sys,'Utility');
 ut.index.flagall = flagall;
 ut.index.flagm = flagmea;
 ut.index.uind = uind;
 ut.index.yind = yind;
 ut.index.flag = 1;
 ut.index.lambda = lam;
try
   pol=ut.Idpoly;  
catch
   pol=[];
end
  if ~isempty(pol)
   k1=1;
   for kk=yind
      if isa(pol,'cell')
         polte=pol{kk}; 
      else
         polte=pol;
      end
      if flagall
         pol1{k1}=polte;
      elseif isempty(uind)
         pol1{k1}=polte(1,nu+1:nu+ny);  
      else
         pol1{k1}=polte(1,uind);
      end
      k1=k1+1;
   end
   pol = pol1;
end
 

ut.Idpoly=pol;
sys = pvset(sys,'Utility',ut); 

if flagall|flagmea
  sys.idmodel = pvset(sys.idmodel,'NoiseVariance',zeros(ny,ny));
else 
   sys.idmodel=pvset(sys.idmodel,'NoiseVariance',lam(yind,yind));
end

 
 

