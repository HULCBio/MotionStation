function out=execute(c)
%EXECUTE runs the component during generation

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:59 $
out = '';

if ~rgsf( 'is_parent_valid', c )
   status(c,['Error in Stateflow Object Name - Invalid component parent.'],1);
   return;
end
rptgenSF = zsfmethods;

% assume that every reportable object has Name property.
% (defined in @zsfmethods/rgstoredata)
if c.att.isfullname
   if c.att.issimulinkname
      propName = 'FullPath+Name';
   else
      propName = 'SFPath+Name';
   end
else
   propName = 'Name';
end

needToRestoreObj = 0;
parentClass = rgsf( 'get_parent_class', c );
if strcmp( parentClass, 'csf_chart_loop' )
   % do a little special thing
   % we need to swap current chart id and currentObject id
   % so that rgsf('eval_obj_prop',c) does the right thing
   % and then swap it back
   currentObjectSave = rptgenSF.currentObject;
   chartId = rptgenSF.chartLoop.id;
   currentObject.id = chartId;
   currentObject.typeString = 'chart';
   currentObject.type = rgsf( 'type2num', 'chart' );
   currentObject.hiddenContent = 1;
   rptgenSF.currentObject = currentObject;
	needToRestoreObj = 1;
end
   
nameStruc = rgsf( 'evaluate_object_property', propName, c );
oType = capitalize1( rptgenSF.currentObject.typeString );
   
if needToRestoreObj
   % restore currentObject if we modified it
   rptgenSF.currentObject = currentObjectSave;
   oType = 'Chart';
end

out = nameStruc.printValue{1}{1};


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


function str = capitalize1( str )
if ~isempty(str)
   str(1) = upper( str(1) );
end

