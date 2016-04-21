function symtab=createregobj(cc,info)
% Private. Creates a REGISTEROBJ object from REGNAME.
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.8.2.1 $  $Date: 2003/11/30 23:06:57 $

error(nargchk(2,6,nargin));
if ~ishandle(cc),
    error('First Parameter must be a CCSDSP Handle.');
end

if length(info.regname)==2
    storageunitspervalue = 2;
end

% Call constructor
symtab = createobj(cc,info);

% Assign registers
symtab.regname = info.regname;

% [EOF] createregobj.m