function outval = cfgetset(varname,inval)
%CFGETSET Get or set a curve fitting persistent variable

%   $Revision: 1.11.2.1 $  $Date: 2004/02/01 21:38:55 $
%   Copyright 2001-2004 The MathWorks, Inc.

% Get handle to Curve Fitting figure, usually required later on
oldval = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
c = get(0,'Children');
cffig = findobj(c,'flat','Type','figure','Tag','Curve Fitting Figure');
set(0,'ShowHiddenHandles',oldval);
if length(cffig)>1, cffig = cffig(1); end

% If asking for the figure itself, handle that now
if isequal(varname,'cffig')
   if isequal(nargin,1)
      if isequal(class(cffig),'figure')
         cffig = double(cffig);
      end
      outval = cffig;
   elseif ishandle(inval) & isequal(get(inval,'Type'),'figure')
      set(inval,'Tag','Curve Fitting Figure');
   end
   return
end

% Some things need to persist, so they are root properties
if ismember(varname, {'thefitdb' 'thedsdb' 'classinstances' 'theoutlierdb'})
   propname = ['Curve Fitting ' varname];
   hroot = handle(0);
   p = findprop(hroot,propname);
   if isempty(p)
      % Make sure such a property exists
      p = schema.prop(hroot,propname,'MATLAB array');
		p.AccessFlags.Serialize = 'off';
   end

   if nargin==1
      outval = get(hroot,propname);
   else
      set(hroot,propname,inval);
	end

% For other properties, the figure must not be empty
elseif isempty(cffig)
   if nargout>0
      outval = [];
   end

% If the figure is not empty, set or get its property
else
   cffig = handle(cffig);
   p = findprop(cffig,varname);
   if isempty(p)
      % Make sure such a property exists for the figure
      p = schema.prop(cffig,varname,'MATLAB array');
		p.AccessFlags.Serialize = 'off';
   end

   if nargin==1
      outval = get(cffig,varname);
   else
      set(cffig,varname,inval);
	end
end
