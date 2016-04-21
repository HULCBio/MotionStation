function isconf = isconfigurable(libName,block)
%Test if block is a configurable subsystem created by model discretizer

% $Revision: 1.2 $ $Date: 2002/04/10 18:56:58 $
% Copyright 1990-2002 The MathWorks, Inc.

isconf = 0;
try
    template =  get_param(block,'templateblock');
    choice = get_param(block,'blockchoice');
    member = get_param(block,'memberblocks');
    if ~isempty(strmatch(libName,template))
       isconf = 1;
    end
catch
    isconf = 0;
end

%end isconfigurable