function display(c,showHeader)
%DISPLAY controls how the component is displayed to screen

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:10:57 $

if nargin<2
   showHeader=logical(1);
end

if showHeader
   disp(' ');
   disp([inputname(1), ' = '])
   disp(' ');
end


d=struct(c);
if isfield(d,'rptcomponent')
   %if we are displaying a child object
   
   i=getinfo(c);
   
   nameStr=['  ' i.Name ];
   if isactive(c)
      nameStr=[nameStr '(active)'];
   else
      nameStr=[nameStr '(inactive'];
   end
   
   disp(['  ' i.Name ' - ']);
   disp(d.comp);
   disp('  Attributes - ')
   disp(d.att);
   disp('  Fields - ')
   disp(d);
   %disp('  Children - ') 
else
   %if we are displaying the rptcomponent object
   RPTGENDATA=rgstoredata(c);
   disp(RPTGENDATA)
end

disp(' ');