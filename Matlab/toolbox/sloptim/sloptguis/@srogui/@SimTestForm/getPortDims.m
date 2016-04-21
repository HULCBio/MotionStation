function getPortDims(this)
% Gets compiled signal size for active constraint blocks.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:45:12 $
%   Copyright 1986-2004 The MathWorks, Inc.
Model = this.Model;
if ~isempty(this.Specs)
   C = find(this.Specs,'Enable','on');
   for ct=1:length(C)
      hOutport = find_system(Model,...
         'FindAll','on','FollowLinks','on','LookUnderMasks','all',...
         'Type','port','PortType','outport',...
         'DataLoggingName',C(ct).SignalSource.LogID);
      PortDims = get(hOutport,'CompiledPortDimensions');
      if isempty(PortDims)
         % Should never happen
         C(ct).SignalSize = [1 1];
      elseif PortDims(1)<0
         error('Input to SRO blocks cannot be a bus signal.')
      elseif PortDims(1)==1
         C(ct).SignalSize = [PortDims(2) 1];
      else
         C(ct).SignalSize = PortDims(2:end);
      end
   end
end
