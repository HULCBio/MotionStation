function result = is_eml_block(blockHandle)
%IS_EML_BLOCK True if the block is an eML block 
%  IS_EML_BLOCK(BLOCKHANDLE)

% Copyright 1994-2003 The MathWorks, Inc.

result = 0;

if nargin ~= 1 || ~ishandle(blockHandle)
  return;
end

try
  chartId = sf('Private','block2chart', blockHandle);
  
  if ~sf('ishandle',chartId)
    return;
  end  
  result = double(~isempty(sf('find', chartId, 'chart.type', 2)));
end

