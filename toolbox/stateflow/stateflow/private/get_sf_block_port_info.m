function portInfo = get_sf_block_port_info(sfunId,varargin)

% Copyright 2003 The MathWorks, Inc.

blockId = get_param(sfunId, 'parent');
chartId = block2chart(blockId);
portInfo = sf('Cg','get_chart_port_info',chartId,varargin{:});

