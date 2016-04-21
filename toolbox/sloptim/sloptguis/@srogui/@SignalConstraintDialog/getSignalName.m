function SigName = getSignalName(this)
% Gets signal name

%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:44:21 $
%   Copyright 1986-2004 The MathWorks, Inc.
blk = this.Block;
ph = get_param(blk,'PortHandles');
pName = get(ph.Inport,'Name');
if isempty(pName)
   ParentName = get_param(get_param(blk,'Parent'),'Name');
   SigName = sprintf('Input to %s/%s',ParentName,get_param(blk,'Name'));
else
   SigName = sprintf('Signal "%s"',pName);
end
SigName = strrep(SigName,sprintf('\n'),' ');
