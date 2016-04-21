%SLRESOLVE resolves the given variable name for a block context.
%   SLRESOLVE('variable_name',BLOCK) resolve 'variable_name' in the context 
%   of the BLOCK. BLOCK must be a valid gcb, or block path.
%
% e.g.   slresolve('k','myModel/Subsystem/Gain');
%        slresolve('k',gcb);
%

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2003/01/22 06:56:44 $

function [resolution,varExists] = slResolve(variable_name, BLOCKNAME)
  persistent RESOLVER;
  
%
% Need to validate given block argument. If it is a block handle,
% it needs to be converted to a full block path.
%
  
if isempty(RESOLVER)
  RESOLVER = get_param('built-in/S-Function','Resolver');
end;

try
  resolution = mexResolveNameInBlock(variable_name, BLOCKNAME, RESOLVER);
  if (nargout > 1)
    varExists = 1;
  end
catch
  if (nargout == 1)
    error(['Can not resolve ' variable_name ' in ' BLOCKNAME]);
  else 
    resolution = [];
    varExists = 0;
  end
end
