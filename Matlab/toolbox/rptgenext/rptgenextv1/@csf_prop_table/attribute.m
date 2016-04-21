function c=attribute(c,varargin)
%ATTRIBUTE creates options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:21 $

c=attribute(rptproptable,c,varargin{:});

switch varargin{1} % action
case {'start','Update', 'refresh'}
   if ~rgsf('is_parent_valid', c )
      set( c.x.title, 'String', 'Stateflow Property Table' );
      [validity, errMsg] = rgsf( 'is_parent_valid', c );
      statbar(c, sprintf('Error: this component %s', xlate(errMsg)) ,1);
   else
      parent = rgsf( 'get_sf_parent', c ); %if we got here, parent may not be empty
      objType=[upper(parent.att.typeString(1)) parent.att.typeString(2:end)];
      set( c.x.title, 'String',[objType ' Property Table '] );
	   statbar(c, '', 0);
   end  
otherwise
end