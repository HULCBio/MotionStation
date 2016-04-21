function set_mask_display(chartId, varargin)

% Copyright 2002-2004 The MathWorks, Inc.

[chartType,isEncrypted] = sf('get', chartId, 'chart.type','chart.encryption.enabled');
hBlock = chart2block(chartId);

if isempty(hBlock) || hBlock == 0 || ~ishandle(hBlock)
    % Early return if we don't get a valid block handle
    return;
end

maskDispStr = '';

switch(chartType)
    case 0 % Stateflow chart
        if(isEncrypted)
            set_param(hBlock, 'MaskIconFrame', 'on');
            maskDispStr = 'disp(''Chart\n(encrypted)'');';
        else      
            maskDispStr = ['plot(sf(''Private'',''sfblk'',''xIcon''),' ...
                    'sf(''Private'',''sfblk'',''yIcon''));' ...
                    'text(0.5,0,sf(''Private'', ''sfblk'', ''tIcon''),' ...
                    '''HorizontalAl'',''Center'',''VerticalAl'',''Bottom'');'];
        end
    case 1 % Truthtable chart
        set_param(hBlock, 'MaskIconFrame', 'on');
        if(isEncrypted)
            maskDispStr = 'disp(''Truthtable\n(encrypted)'');';
        else
            maskDispStr = 'disp(''Truthtable'');';
        end
    case 2 % eML chart
        emlFcnName = '';
        
        if nargin > 1
            emlFcnName = varargin{1};
        else
            emlFcnName = sf('get', chartId, 'chart.eml.name');
        end
        
        if isempty(emlFcnName)
            emlFcnName = 'fcn'; % FMS: XXX - dubious choice.
        end
        
        set_param(hBlock, 'MaskIconFrame', 'on');
        if(isEncrypted)
            maskDispStr = ['disp(''' emlFcnName '\n(encrypted)'');'];
        else
            maskDispStr = ['disp(''' emlFcnName ''');'];
        end         
    otherwise
        error('Unknown chart type.');
end

set_param(hBlock, 'MaskDisplay', maskDispStr);
