function Value = pvget(sys,Property)
%PVGET  Get values of public IDMODEL properties.
%
%   VALUES = PVGET(SYS) returns all public values in a cell
%   array VALUES.
%
%   VALUE = PVGET(SYS,PROPERTY) returns the value of the
%   single property with name PROPERTY.
%
%   See also GET.

%       Copyright 1986-2001 The MathWorks, Inc.
%       $Revision: 1.3 $  $Date: 2001/04/06 14:22:31 $

if nargin==2,
   % Value of single property: VALUE = PVGET(SYS,PROPERTY)
   % Public IDMODEL properties
   try
      switch Property % First the virtual properties
      case 'A'  
         [a,b,c,d,k,x0]=ssdata(sys);
         Value = a;
      case 'B'
         [a,b,c,d,k,x0]=ssdata(sys);
         Value = b;
      case 'C'
         [a,b,c,d,k,x0]=ssdata(sys);
         Value = c;
      case 'D'
         [a,b,c,d,k,x0]=ssdata(sys);
         Value = d;
      case 'K'
         [a,b,c,d,k,x0]=ssdata(sys);
         Value = k;
      case 'X0'
         [a,b,c,d,k,x0]=ssdata(sys);
         Value = x0;
      case 'dA'  
         [a,b,c,d,k,x0,da]=ssdata(sys);
         Value = da;
      case 'dB'
         [a,b,c,d,k,x0,da,db]=ssdata(sys);
         Value = db;
      case 'dC'
         [a,b,c,d,k,x0,da,db,dc]=ssdata(sys);
         Value = dc;
      case 'dD'
         [a,b,c,d,k,x0,da,db,dc,dd]=ssdata(sys);
         Value = dd;
      case 'dK'
         [a,b,c,d,k,x0,da,db,dc,dd,dk]=ssdata(sys);
         Value = dk;
      case 'dX0'
         [a,b,c,d,k,x0,da,db,dc,dd,dk,dx0]=ssdata(sys);
         Value = dx0;
      case 'ParameterVector'
         Value = pvget(sys.idmodel,'ParameterVector');
         %Value = Value(1:2);
      otherwise  
         Value = builtin('subsref',sys,struct('type','.','subs',Property));
      end
   catch
      Value = pvget(sys.idmodel,Property);
   end
   
   
else
   % Return all public property values
   % RE: Private properties always come last in IDMPropValues
   IDMPropNames = pnames(sys,'specific');
   IDMPropValues = struct2cell(sys);
   [Validm]=pvget(sys.idmodel);
   [a,b,c,d,k,x0,da,db,dc,dd,dk,dx0]=ssdata(sys);
   
   %%LL%% Here we should make the same modification of NoiseVariance
   Value = [{a;b;c;d;k;x0;da;db;dc;dd;dk;dx0};IDMPropValues(1:end-1); Validm];
end
