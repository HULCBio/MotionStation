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

 
%       Copyright 1986-2002 The MathWorks, Inc.
%       $Revision: 1.12.4.1 $  $Date: 2004/04/10 23:18:12 $

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

      case 'nk'
         if isempty(sys.Ds)
            Value = zeros(1,0);
         elseif strcmp(sys.SSParameterization,'Structured')
            nks = (sys.Ds~=0);
            if size(nks,1)>1
               nks = max(nks);
            end
            Value = 1-nks;
         else
            Value = findnk(sys.As,sys.Bs,sys.Ds);
         end 
      case 'DisturbanceModel'
         if any(any(isnan(sys.Ks))')
            Value = 'Estimate';
         elseif norm(sys.Ks)==0
            Value = 'None';
         else
            Value = 'Fixed';
         end
         
      case 'InitialState'
         Value = sys.InitialState; 
         %if any(any(isnan(sys.X0s))')
         %   Value = 'Estimate';
         %elseif norm(sys.X0s)==0
         %   Value = 'Zero';
         %else
         %   Value = 'Fixed';
         %end
         
         
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
       if isempty(sys.Ds)
            nk = zeros(1,0);
         elseif strcmp(sys.SSParameterization,'Structured')
            nks = (sys.Ds~=0);
            if size(nks,1)>1
               nks = max(nks);
            end
            nk = 1-nks;
         else
            nk = findnk(sys.As,sys.Bs,sys.Ds);
         end 
%    try
%       nk = ones(1,size(sys.Ds,2))-max(isnan(sys.Ds)); %MORE FANCY DELAYS
%    catch
%       nk =[];
%    end
%    
   if any(any(isnan(sys.Ks))')
      DisturbanceModel = 'Estimate';
   elseif norm(sys.Ks)==0
      DisturbanceModel = 'None';
   else
      DisturbanceModel = 'Fixed';
   end
   
   Value = [{a;b;c;d;k;x0;da;db;dc;dd;dk;dx0};IDMPropValues(1:end-2);...
         {nk;DisturbanceModel; };IDMPropValues(end-1);Validm];
end
