function tdef = p_parsefcnarg(tdobj,tdef,argOrder)
% (Private) Adds more info into a parsed argument struct info.
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/11/30 23:14:05 $

% Fill up missing info/fields
tdef = CompleteTypeInfo(tdobj,tdef,argOrder);

%--------------------------------
function tdef = CompleteTypeInfo(tdobj,tdef,order)
switch tdef.uclass
case 'void'
	return;
 
case {'','typedef','structure'...
      'numeric','enum','string',...
      'rnumeric','renum','rstring' } % includes unspecified or unknown
    typeinfo           = GetTypeInfo(tdobj,tdef.type);
    typeinfo.name      = tdef.name;        
    typeinfo.qualifier = tdef.qualifier;        
    typeinfo.size      = SetSize(tdef.size);        
    tdef               = typeinfo;
    
case {'pointer','rpointer'}
    reftypeinfo      = CompleteTypeInfo(tdobj,tdef.referent);
    reftypeinfo.size = SetSize(tdef.referent.size);    
    tdef.referent    = reftypeinfo;
    tdef.size = SetSize(tdef.size);
    
case 'function'
    if nargin==3
        arg = {};
        arg      = CompleteTypeInfo(tdobj,tdef.argument{order});
        arg.size = SetSize(tdef.argument{order}.size);
        tdef.argument{order} = arg;
	else
        returntypeinfo      = CompleteTypeInfo(tdobj,tdef.returnvar);
        returntypeinfo.size = SetSize(tdef.returnvar.size);
        tdef.returnvar      = returntypeinfo;

        arg = {};
        len = length(tdef.argument);
        for i=1:len
            arg{i}      = CompleteTypeInfo(tdobj,tdef.argument{i});
            arg{i}.size = SetSize(tdef.argument{i}.size);
        end
        tdef.argument = arg;
	end
    
otherwise
    error('Unrecognized ''uclass'' value.');
end

if isfield(tdef,'qualifier') && ~isempty(strmatch('register',tdef.qualifier,'exact'))
    typeinfo.uclass = ['r' typeinfo.uclass ];
end

%-----------------------------------------------------------
function typeinfo = GetTypeInfo(tdobj,dtype)
typeinfo = p_IsNativeCType(tdobj,dtype);
if ~isempty(typeinfo)
    return;
elseif p_IsTIDefinedType(tdobj,dtype)
    typeinfo = list(tdobj,dtype);
    if strcmp(typeinfo.uclass,'union') % if list() assigns 'union', change to 'structure'
        typeinfo.uclass = 'structure';
    end
else % typedef
    try 
        typeinfo = gettypeinfo(tdobj,dtype);
    catch
          error('MATLAB:TYPE:TypedefInArgument',...
              ['Type ''' dtype ''' cannot be resolved. If a typedef, add ''' dtype ''' and its equivalent type to the TYPE list using ADD.']);
    end
end

%------------------------------------------------
function siz = SetSize(siz)
if isempty(siz),
    siz = 1;
end    

% [EOF] p_parsefcnarg.m