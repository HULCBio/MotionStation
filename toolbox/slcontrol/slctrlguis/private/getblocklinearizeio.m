function ios = getblocklinearizeio(block);
%Returns an array of LinearizationIO objects from the specified block.

%  Author(s): John Glass
%  Copyright 1986-2002 The MathWorks, Inc.
   
% Construct the linearization object
h = LinearizationObjects.LinearizationIO; 
ios = [];

ph = get_param(block,'PortHandles');
pc = get_param(block,'PortConnectivity');

for ct = 1:length(ph.Inport)
    SourceParent = get_param(pc(ct).SrcBlock,'Name');
    ios =  [ios;h.copy];
    % Remove the new line and carriage returns in the model/block name
    set(ios(end),...
        'Block',regexprep([get_param(pc(ct).SrcBlock,'Parent'),'/',SourceParent],'\n',' '),...
        'PortNumber',pc(ct).SrcPort+1,...
        'Type','in',...
        'OpenLoop','on');
end

for ct = 1:length(ph.Outport)
    ios =  [ios;h.copy];
    % Remove the new line and carriage returns in the model/block name
    set(ios(end),...
        'Block',regexprep(get_param(ph.Outport(ct),'Parent'),'\n',' '),...
        'PortNumber',get_param(ph.Outport(ct),'PortNumber'),...
        'Type','out',...
        'OpenLoop','off');
end