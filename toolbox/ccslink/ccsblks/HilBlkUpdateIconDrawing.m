function HilBlkUpdateIconDrawing(numInports, inports, numOutports, outports)

blk = gcb;
UDATA = get_param(blk,'UserData');

% if ~isempty(UDATA.funcName),
%     funcNameStr = ['disp(''' UDATA.funcName ''')'];
% else
%     funcNameStr = 'disp(''HIL Function Call'')';
% end
funcNameStr = 'disp(''BETA'')';  % Temporary for version 1.3


X = [ ...
        funcNameStr ...
        sprintf('\n') ...
    ];

for k = 1:numInports,
    k_str = num2str(k);
    X = [X ...
            'port_label(''input'',' k_str ',''' inports(k).name ''');' ...
            sprintf('\n') ...
        ];
end
for k = 1:numOutports,
    k_str = num2str(k);
    X = [X ...
            'port_label(''output'',' k_str ',''' outports(k).name ''');' ...
            sprintf('\n') ...
        ];
end

set_param(blk,'MaskDisplay', X);

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 20:44:35 $
