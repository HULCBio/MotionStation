function tdef = parse(tdobj,tdefeqv,source)
% PARSE. Private. Parses a type string or a function declaration.
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2003/11/30 23:14:08 $

nargchk(2,3,nargin);

if nargin==2
    source = '';
end
% Call parser here
tdef = p_parser(tdobj,tdefeqv); 

% Fill up missing info/fields
tdef = CompleteTypeInfo(tdobj,tdef,'non-arg',source);

%--------------------------------
function tdef = CompleteTypeInfo(tdobj,tdef,opt,src)
switch tdef.uclass
case 'void'
	return;
 
case {'','typedef','structure'...
      'numeric','enum','string',...
      'rnumeric','renum','rstring' } % includes unspecified or unknown
    typeinfo           = GetTypeInfo(tdobj,tdef.type,opt);
    typeinfo.name      = tdef.name;        
    typeinfo.qualifier = tdef.qualifier;        
    typeinfo.size      = SetSize(tdef.size);        
    tdef               = typeinfo;
    
case {'pointer','rpointer'}
    reftypeinfo      = CompleteTypeInfo(tdobj,tdef.referent,opt,src);
    if ~strcmp(tdef.referent.uclass,'function')
        reftypeinfo.size = SetSize(tdef.referent.size);    
    end
    tdef.referent    = reftypeinfo;
    tdef.size = SetSize(tdef.size);
    
case 'function'
    returntypeinfo      = CompleteTypeInfo(tdobj,tdef.returnvar,opt,src);
    returntypeinfo.size = SetSize(tdef.returnvar.size);
    tdef.returnvar      = returntypeinfo;

    if strcmp(src,'function-call')
        return;
    else
        arg = {};
        len = length(tdef.argument);
        for i=1:len
            arg{i}      = CompleteTypeInfo(tdobj,tdef.argument{i},'arg',src);
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
function typeinfo = GetTypeInfo(tdobj,dtype,opt)
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
        if strcmp(opt,'arg')
              error('MATLAB:TYPE:TypedefInArgument',...
                  ['Type ''' dtype ''' cannot be resolved. If a typedef, add ''' dtype ''' and its equivalent type to the TYPE list using ADD.']);
        else
            error(['Type ''' dtype ''' cannot be resolved. If a typedef, add ''' dtype ''' and its equivalent type to the TYPE list using ADD.']);
        end
    end
end

%------------------------------------------------
function siz = SetSize(siz)
if isempty(siz),
    siz = 1;
end    

% [EOF] parse.m