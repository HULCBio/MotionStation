function respinfo = p_IsNativeCType(td,eqvtype)
% Private. Returns information about a native C data type. Returns empty if
%  data type is not a native C type.
%
% Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.4.6.4 $  $Date: 2004/04/08 20:47:11 $

nativeTypes = { ...
'char',     'signed char',  'unsigned char', ...
'short',    'signed short', 'unsigned short', ...
'int',      'signed int',   'unsigned int', ...
'long',     'signed long',  'unsigned long', ...
'double',   'float',        'long double', ...
'Q0.15',    'Q0.31',...   % defined types
'int64',    'uint64',...
'int32',    'uint32',...
'int16',    'uint16',...
'int8',     'uint8',...
'void',...
};

eqvtype = p_deblank(eqvtype);
if ~isempty(strmatch(eqvtype,nativeTypes,'exact')),
    resp = get_typeinfo(td,eqvtype);
    respinfo = struct(  'type'      ,eqvtype    ,...
                        'size'      ,1          ,...
                        'uclass'    ,'numeric'  ,...
                        'typeprop'  ,resp  );
   if findstr(eqvtype,'char')
        respinfo.uclass = 'string';
    end
else
	respinfo = [];
end

%----------------------------------------
function resp = get_typeinfo(td,eqvtype)

ccinfo = callSwitchyard(td.ccsversion,[16,td.boardnum,td.procnum,0,0]);
family      = ccinfo.family;
subfamily   = ccinfo.subfamily;
revfamily   = ccinfo.revfamily;

if family == 470  %ARM Processor (R1x or R2x)
    resp = typeinfo_Rxx(td,eqvtype);
elseif family == 320
    if subfamily>=96, % C6xx
        resp = typeinfo_C6xx(td,eqvtype);
    elseif subfamily==84, % C54x
        resp = typeinfo_C54x(td,eqvtype);
    elseif subfamily==85, % C55x
        resp = typeinfo_C55x(td,eqvtype);
    elseif subfamily==40, % C28x
        resp = typeinfo_C28x(td,eqvtype);
    elseif subfamily==36, % C24x
        resp = typeinfo_C24x(td,eqvtype);
    elseif subfamily==39, % C27x
        resp = typeinfo_C27x(td,eqvtype);
    else
        error('Processor is not supported.');
    end
else
    error('Processor is not supported.');
end

% [EOF] p_IsNativeCType.m