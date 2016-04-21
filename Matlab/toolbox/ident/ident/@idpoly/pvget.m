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

%       Author(s): P. Gahinet, 7-8-97
%       Copyright 1986-2001 The MathWorks, Inc.
%       $Revision: 1.6 $  $Date: 2001/04/06 14:22:20 $

if nargin==2,
   % Value of single property: VALUE = PVGET(SYS,PROPERTY)
   % Public IDMODEL properties
   try
      switch Property % First the virtual properties
      case 'a'  
         [a,b,c,d,f]=polydata(sys);
         Value = a;
      case 'b'
         [a,b,c,d,f]=polydata(sys);
         Value = b;
      case 'c'
         [a,b,c,d,f]=polydata(sys);
         Value = c;
      case 'd'
         [a,b,c,d,f]=polydata(sys);
         Value = d;
      case 'f'
         [a,b,c,d,f]=polydata(sys);
         Value = f;
          case 'da'  
         [a,b,c,d,f,da]=polydata(sys);
         Value = da;
      case 'db'
         [a,b,c,d,f,da,db]=polydata(sys);
         Value = db;
      case 'dc'
         [a,b,c,d,f,da,db,dc]=polydata(sys);
         Value = dc;
      case 'dd'
         [a,b,c,d,f,da,db,dc,dd]=polydata(sys);
         Value = dd;
      case 'df'
         [a,b,c,d,f,da,db,dc,dd,df]=polydata(sys);
         Value = df;

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
   [a,b,c,d,f,da,db,dc,dd,df]=polydata(sys);
   Value = [{a;b;c;d;f;da;db;dc;dd;df};IDMPropValues(1:end-1);Validm];
end
