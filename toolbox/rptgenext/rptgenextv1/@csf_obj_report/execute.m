function out=execute(c)
%EXECUTE returns a string during generation

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:16 $

out = [];

if ~rgsf( 'is_parent_valid', c )
		[validity, errMsg] = rgsf( 'is_parent_valid', c );
		compInfo = getInfo( c );
		status(c, sprintf('%s error: this component %s',compInfo.Name, errMsg) ,1);
	return;
end

rptgenSF = zsfmethods;
id = rptgenSF.currentObject.id;
numberOfChildren = length(eval( 'sf( ''ObjectsIn'', id )', '[]' ));

if ~strcmp( c.att.typeString, rptgenSF.currentObject.typeString ) | ...
		(numberOfChildren < c.att.repMinChildren & ...
		 rgsf( 'can_have_children', c.att.typeString ) ...
		)
	return;
end

%Add the reported object to the list of objects that have been
%reported upon

rptgenSF.reportList = [rptgenSF.reportList;id];

if c.att.addAnchor & ~ismember(id, rptgenSF.linkTargetCreated ) 
   tag = sf( 'get', id, '.rgTag' );
   out=runsubcomponent(cfrlink('LinkType','Anchor','LinkID', tag),0);
   rptgenSF.linkTargetCreated = [id, rptgenSF.linkTargetCreated];
else
   %wrnMsg = ' warning: link target for this component already exists ';
   %status(c, [compInfo.Name, wrnMsg] ,2);
end

% alright, the object is of my type, execute whatever I have for it.
out=[out,runcomponent(children(c))];

% if ~rptgenSF.currentObject.hiddenContent
%     status(c,sprintf('Warning - this object contains hidden content and will not be reported'),2);
% 	out = [];
% else
% 	q = 1;
% end

rptgenSF.currentObject.hiddenContent = 0;