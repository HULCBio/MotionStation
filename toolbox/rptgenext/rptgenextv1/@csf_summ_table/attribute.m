function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:36 $

c=feval('attribute',c.rpt_summ_table,c,action,varargin{:});

% do some sf-specific post-processing
[isValid, errorMsg] = rgsf('is_parent_valid', c);
if ~isValid
   set( c.x.title, 'String', 'Object Summary Table (Invalid Parent)' );
   statbar( c, sprintf('Error: this component %s', xlate(errorMsg)), 1 );
   return;
end

sfParent = rgsf('get_sf_parent',c);
objType = c.att.ObjectType;

if ~isempty( sfParent ) & strcmp( sfParent.comp.Class, 'csf_chart_loop' )
   enableValue = 'off';
   longStringSuffix = 'current chart defined in Chart Loop';
else
   enableValue = 'on';
   longStringSuffix = 'selected charts';
end

if strcmpi(objType,'Chart')
    shortTypeString = '';
    longTypeString  = '';
else
  	shortTypeString = sprintf('"%s" children ',lower(objType));
    longTypeString  = sprintf('"%s" children of ',lower(objType));
end

shortString = sprintf('Select charts to include %sin table...',shortTypeString);
longString  = sprintf('Summary table contains %s%s',longTypeString,longStringSuffix);

set( c.x.LoopButton,...
    'String',shortString,...
    'Enable',enableValue,...
    'ToolTipString',longString);
statbar(c,longString,0);
