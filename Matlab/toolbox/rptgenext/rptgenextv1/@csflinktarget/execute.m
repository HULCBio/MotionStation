function out=execute(c)
%EXECUTE generates report contents

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:52 $
out = [];
compInfo = getInfo( c );
if ~rgsf( 'is_parent_valid', c )
		[validity, errMsg] = rgsf( 'is_parent_valid', c );
		status(c, sprintf('%s error: this component %s',compInfo.Name, errMsg) ,1);
	return;
end

rptgenSF = zsfmethods;
parentClass = rgsf( 'get_parent_class', c );
if strcmp( parentClass, 'csf_chart_loop' )
   id = rptgenSF.chartLoop.id;
else
   id = rptgenSF.currentObject.id;
end


if ~ismember( id, rptgenSF.linkTargetCreated )
	linkObj=c.rptcomponent.comps.cfrlink;

	linkObj.att.LinkType='Anchor';
   linkObj.att.LinkID=sf( 'get', id, '.rgTag' );
	linkObj.att.LinkText=c.att.LinkText;

	out=runcomponent(linkObj,0);
   rptgenSF.linkTargetCreated = [id, rptgenSF.linkTargetCreated];
else
   wrnMsg = 'Warning: link target for this component already exists ';
   status(c, [compInfo.Name, wrnMsg] ,2);
end