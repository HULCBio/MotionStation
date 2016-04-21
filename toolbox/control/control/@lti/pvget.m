function [Value,ValStr] = pvget(sys,Property)
%PVGET  Get values of public LTI properties.
%
%   VALUES = PVGET(SYS) returns all public values in a cell
%   array VALUES.
%
%   VALUE = PVGET(SYS,PROPERTY) returns the value of the
%   single property with name PROPERTY.
%
%   See also GET.

%       Author(s): P. Gahinet, 7-8-97
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.16 $  $Date: 2002/04/10 05:48:49 $

if nargin==2,
   % Value of single property: VALUE = PVGET(SYS,PROPERTY)
   if strcmp(Property,'Td'),
      % Obsolete Td property
      warning(sprintf([...
            'LTI property TD is obsolete. Use ''InputDelay'' or ''ioDelay''.\n         ' ...
            'See LTIPROPS for details.']))
      if sys.Ts,
         Value = [];
      else
         Value = sys.InputDelay';
      end
   else
      % Public LTI properties
      Value = builtin('subsref',sys,struct('type','.','subs',Property));
   end
   
else
   % Return all public property values
   % RE: Private properties always come last in LTIPropValues
   LTIPropNames = pnames(sys);
   LTIPropValues = struct2cell(sys);
   Value = LTIPropValues(1:length(LTIPropNames));
   if nargout==2,
      ValStr = pvformat(Value);
   end
   
end
