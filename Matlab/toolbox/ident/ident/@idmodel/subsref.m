function L = subsref(L,Struct)
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
%   $Revision: 1.10 $ $Date: 2001/08/03 14:25:23 $

ni = nargin;
if ni==1,
   result = sys;
   return
end
StructL = length(Struct);

% Peel off first layer of subreferencing
switch Struct(1).type
case '.'
   % The first subreference is of the form sys.fieldname
   % The output is a piece of one of the system properties
   try
      if StructL==1,
         result = get(L,Struct(1).subs);
      else
         result = subsref(get(L,Struct(1).subs),Struct(2:end));
      end
      L = result;
   catch
      error(lasterr)
   end
case '()'
   indices = Struct(1).subs;
   indrow = indices{1};
   indcol = indices{2};
   
   
   % Set output names and output groups
   L.OutputName = L.OutputName(indrow);%,1);
   L.OutputUnit = L.OutputUnit(indrow);%,1);
   
   
   % Set input names and input groups
   L.InputName = L.InputName(indcol);%,1);
   L.InputUnit = L.InputUnit(indcol);%,1);
   L.InputDelay = L.InputDelay(indcol);
   L.NoiseVariance = L.NoiseVariance(indrow,indrow);
   
otherwise
   error(['Unknown reference type: ' Struct(1).type])
end
