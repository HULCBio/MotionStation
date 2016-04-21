function ctx_toggle_smart
%
% Stateflow context menu callback to toggle transition
% line smartness.
%

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2004/04/15 00:56:31 $ 

editorId = sf('CtxEditorId');
selection = sf('Selected', editorId);
WIRE = sf('get', 'default', 'trans.isa');
wires = sf('find', selection, '.isa', WIRE);

if isempty(wires), return; end;

sf('CtxPushSmartBitForUndo', editorId);   

switch lower(get(gcbo, 'checked')),
    case 'on',
        sf('set', wires, '.drawStyle', 'STATIC');
    case 'off',
        sf('set', wires, '.drawStyle', 'SMART');
end;


