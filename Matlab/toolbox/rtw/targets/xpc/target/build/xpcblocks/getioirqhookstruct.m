function str = getioirqhookstruct(irqNo, slot, board)
% GETIOIRQHOOKSTRUCT Returns board information for IRQ handling.
%
%   This is a private function and should not be called directly.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.5.8.5 $ $Date: 2004/04/08 21:02:22 $

list = {};
list{end + 1} = 'CB_CIO-CTR05';
list{end + 1} = 'CB_PCI-CTR05';
list{end + 1} = 'Softing_CAN-AC2-104';
list{end + 1} = 'Softing_CAN-AC2-PCI';
list{end + 1} = 'RTD_DM6804';
list{end + 1} = 'AudioPMC+';
list{end + 1} = 'Scramnet_SC150+';
list{end + 1} = 'ATI-RP-R5';
list{end + 1} = 'Diamond_MM-32';
list{end + 1} = 'UEI_MFx';
list{end + 1} = 'VMIC-5565';
list{end + 1} = 'SBS_25x0_ID_0x100';
list{end + 1} = 'SBS_25x0_ID_0x101';
list{end + 1} = 'SBS_25x0_ID_0x102';
list{end + 1} = 'SBS_25x0_ID_0x103';
list{end + 1} = 'None/Other';

if nargin == 0
  str = list;
  return
end
irqNo = eval(irqNo);
if irqNo < 5
  str.HookIncludeFile = '';
  return
end

%boards = strread(list, '%s', 'delimiter', '|');
boards = list;
idx = strmatch(board, boards);
if isempty(idx)
  error(sprintf('Invalid selection ''%s''\n', board));
end

[irq, devid, vendid, slot, handlers] = mxpcinterrupt(irqNo, idx, slot);

str.IRQ              = irq;
str.VendorId         = vendid;
str.DeviceId         = devid;
str.PCISlot          = slot;
str.Preemptable      = 1;
str.PreHookFunction  = handlers{1}; 
str.PostHookFunction = handlers{2}; 
str.HookIncludeFile  = handlers{3};
str.StartFunction    = handlers{4}; 
str.StopFunction     = handlers{5};
