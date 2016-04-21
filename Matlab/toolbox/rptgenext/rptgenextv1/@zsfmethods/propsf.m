function out=propsf(z,action,varargin)
%PROPSF gets Stateflow object properties

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:22 $

switch action
case 'GetFilterList'
   if nargin > 2 & strcmp( varargin{1}, 'get_all' )
      out=rgsf('get_filter_list', varargin{:});
   else
      out{1} = subsref( z, substruct( '.', 'att', '.', 'ObjectType' ) );
   end
   out = [out;out]';
      
   for i = 1:size(out,1)
      out{i,1} = capitalize1( out{i,1} );
      out{i,2} = [ out{i,1} ' properties'];
   end
   
case 'GetPropList'
   out=rgsf('get_property_list', varargin{:});  
case 'GetPropValue'
   out = {};
   propName = varargin{2};
   nameLink = 0;
   if strcmp( lower(propName), 'namelinked' ) 
      % special case: name field should be a link.
      propName = propName(1:4); % it is 'Name', but let's not introduce constants here.
      nameLink = 1;
   else
      rptgenSF = zsfmethods;
   end
   for i = 1:length(varargin{1})
      curObjStruct.id = varargin{1}(i);
      typeString = lower( subsref( z, substruct( '.', 'att', '.', 'ObjectType' ) ) );
      type = rgsf( 'type2num', typeString );
      curObjStruct.typeString = typeString;
      curObjStruct.type = type;
      curObjStruct.hiddenContent = 0;
      setHiddenForCurObj = 0;
      outCur = rgsf('get_property_cell', curObjStruct, propName, z, setHiddenForCurObj);
      if nameLink
         % let's convert the value into a link
         tag = sf( 'get', curObjStruct.id, '.rgTag' );
         if isempty( tag )
            rgsf( 'assign_rg_tag', curObjStruct.id );
            tag = sf( 'get', curObjStruct.id, '.rgTag' );
         end
         %outCur.value in this case should be a cell
         outCur.value=runsubcomponent( ...
            cfrlink('LinkType','Link','LinkID', tag, 'LinkText', outCur.value{1} ),0);
      else
         % if not NameLinked, a link target will be inserted. Note that.
         subsasgn( rptgenSF, substruct( '.', 'linkTargetCreated' ), ...
            [curObjStruct.id,subsref(rptgenSF,substruct('.','linkTargetCreated'))]);
      end
         
      if ~isempty( outCur.value )
         out(i) = {outCur.value};
      else
         out(i) = {[]};
      end
   end
   out = out(:); % this has to be a column
   
end %primary case


function str = capitalize1(str)
if isempty(str), return;
else
   str(1) = upper( str(1));
end
