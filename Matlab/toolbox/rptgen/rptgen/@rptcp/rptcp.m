function p=rptcp(in)
%RPTCP - Report Generator Component Pointer
%   RPTCP.p is a handle to a UIMENU object.  The object's
%   UserData carries a Report Generator component.  Other
%   properties also have useful information:
%
%   Tag = the CLASS of the component
%   Label = the component's outline string
%
%   Pointers can be referenced to reach their components.
%   p.att.Foo=1 will set the component's "Foo" attribute.
%
%   Components carry references to their own pointers in
%   c.ref.ID

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/22 01:36:29 $

if nargin<1
   in=[];
end


if isa(in,'rptcp')
   p=in;
elseif isa(in,'rptcomponent')
   if isfield(in.ref,'ID')
      p=in.ref.ID;
   else
      p=[];
   end
   
   if ~isa(p,'rptcp')
      if ishandle(p)
         p=rptcp(p);
	  elseif ~isempty(what('rptsp')) %only add to clipboard if rptsp exists
         s=rptsp('clipboard');
         p=rptcp(uimenu('Parent',s.h));
	  else
		  p = in;
		  return;
      end
      in.ref.ID=p;
   end
   
   try
      labelString=outlinestring(in);
   catch
      labelString=in.comp.Class;
   end
   
   set(p.h,...
      'UserData', in             ,...
      'Label'   , labelString    ,...
      'tag'     , in.comp.Class  ,...
      'callback', 'crgp=rptcp(gcbo)');
else
   p.h=in(find(ishandle(in)));
   p=class(p,'rptcp');
   superiorto('rptcomponent'); % was also:,'rptsetupfile');
end
