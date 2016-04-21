function outval = dfgetset(varname,inval)
%DFGETSET Get or set a distribution fitting persistent variable

%   $Revision: 1.1.6.3 $  $Date: 2004/01/24 09:33:19 $
%   Copyright 2001-2004 The MathWorks, Inc.

% Get handle to Distribution Fitting figure, usually required later on
oldval = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
c = get(0,'Children');
dffig = findobj(c,'flat','Type','figure','Tag','Distribution Fitting Figure');
set(0,'ShowHiddenHandles',oldval);
if length(dffig)>1, dffig = dffig(1); end

% If asking for the figure itself, handle that now
if isequal(varname,'dffig')
   if isequal(nargin,1)
      if isequal(class(dffig),'figure')
         dffig = double(dffig);
      end
      outval = dffig;
   elseif ishandle(inval) & isequal(get(inval,'Type'),'figure')
      set(inval,'Tag','Distribution Fitting Figure');
   end
   return
end

if nargin==1
   if isequal(varname,'dsdb')
      outval = getdsdb;
      return;
   elseif isequal(varname,'fitdb')
      outval = getfitdb;
      return
   end
end

% Some things need to persist, so they are root properties
if ismember(varname, ...
      {'thefitdb' 'thedsdb' 'classinstances' 'theoutlierdb' 'alldistributions'})
   propname = ['Distribution Fitting ' varname];
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
elseif isempty(dffig)
   if nargout>0
      outval = [];
   end

% If the figure is not empty, set or get its property
else
   dffig = handle(dffig);
   p = findprop(dffig,varname);
   if isempty(p)
      % Make sure such a property exists for the figure
      p = schema.prop(dffig,varname,'MATLAB array');
		p.AccessFlags.Serialize = 'off';
   end

   if nargin==1
      outval = get(dffig,varname);
   else
      set(dffig,varname,inval);
	end
end
