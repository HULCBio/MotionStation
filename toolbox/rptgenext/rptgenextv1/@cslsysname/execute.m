function out=execute(c)
%EXECUTE runs the component during generation

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:12 $

if strcmp(c.att.ObjectType,'Automatic')
   oType=getparentloop(c);
   if isempty(oType)
      oType='Model';
   end
else
   oType=c.att.ObjectType;
end

h=subsref(c.zslmethods,substruct('.',oType));


if isempty(h)
   status(c,sprintf('Warning - could not find %s for name',oType),2);
   out='';
   return
end

switch oType
case 'Signal'
   try
      sName=get_param(h,'Name');
   catch
      status(c,'Error in Simulink Object Name - Can not get Signal name.',1);
      sName='';
   end
   if isempty(sName)
      sName=num2str(h);
   end
   
   %if c.att.isfullname
   %   try
   %      parentName=get_param(h,'Parent');
   %      parentN
   %   catch
   %      parentName='';
   %   end
   %   sName=[parentName '/' sName];
   %end
   
   out=sName;
      
case {'System' 'Block'}
   if ~c.att.isfullname
      try
         out=get_param(h,'Name');
      catch
         status(c,sprintf('Error in Simulink Object Name - Can not get %s full name.',oType),1);
         out=h;
      end
   else
      try
         out=getfullname(h);
      catch
         status(c,sprintf('Error in Simulink Object Name - Can not get %s name.',oType),1);
         out=h;
      end
   end
   if isnumeric(h)
      out=num2str(h);
   end   
case 'Model'
   try
      out=get_param(h,'Name');
   catch
      status(c,'Error in Simulink Object Name - Can not get Model name.',1);
      if isnumeric(h);
         out=num2str(h);
      else
         out=h;
      end
   end
otherwise
   out='';
   status(c,'Error in Simulink Object Name - Invalid Object Type',1);
end


switch c.att.renderAs
case 't n'
   out=[oType ' ' out];
case 't-n'
   out=[oType ' - ' out];
case 't:n'
   out=[oType ': ' out];
%otherwise %case 'n'
%   out=out;   
end


