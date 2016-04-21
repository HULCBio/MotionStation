function refBlockName = sf_get_reference_block_name(blockName)
%SF_GET_REFERENCE_BLOCK_NAME(blockName) 
%   Used by runtime library to bind SF blocks to chart instances in the
%   generated code.

%   Vijay G. Raghavan
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.8.2.1 $  $Date: 2004/04/15 00:59:34 $

parent = get_param(blockName,'parent');
refBlockName = get_param(parent,'referenceblock');
if(isempty(refBlockName))
    return;
end
refBlockName = [refBlockName,'/ SFunction '];

