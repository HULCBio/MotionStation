function node=completenodetstruct(node,opt)
% COMPLETENODESTRUCT   Shared memory node configuration utility
% COMPLETENODESTRUCT(N,OPT) Shared memory nodes (boards) are configured
%  when the XPC target is started.  The Node structure (N) allows the user
%  to configure various modes of the board.  This utility can create a
%  default version of the node structure or it can accept a subset of
%  fields and produce a complete node structure by applying defaults
%  to undefined fields.  
%  
% Scramnet Support - When OPT is empty (or set to 'scramnet'), this utility
%   supports configuration of scramnet boards
%
%  COMPLETENODESTRUCT(N) Extends N (node structure) with default fields
%    for the Scramnet shared memory board
%  COMPLETENODESTRUCT([]) Creates a default node configuration
%    structure for the Scramnet shared memory board
%
% VMIC Support - When OPT is set to '5565', this utility supports memory
%   partitioning for the VMIC 5565 
%
%  COMPLETENODESTRUCT(N,'5565') Extends N (node structure) with 
%    default fields for the VMIC 5565 shared memory board
%  COMPLETENODESTRUCT([],'5565') Creates a default node configuration
%    structure for the VMIC 5565 shared memory board
%
% See also COMPLETEPARTITIONSTRUCT

%  Copyright 2002-2003 The MathWorks, Inc.
%  $Revision: 1.2.4.2 $ $Date: 2004/04/08 21:01:52 $

if nargin >=2, 
    if ischar(opt),
        indx = strmatch(opt,{'5565','scramnet'});
        if isempty(indx),
            error('Shared memory option limited to ''5565'',''scramnet'' or ''TBD''');               
        end
        if indx == 1,
            node = vmic5565net(node);
            return;
        end
    else
        error('Shared memory option limited to ''5565'',''scramnet'' or ''TBD''');
    end
end
node = scramnet(node);

%-----------------------------------------------------
% VMIC 5565 Implementation
%
function [node] = vmic5565net(node)

if isempty(node) | ~isfield(node,'Interface') | isempty(node.Interface)
    
    mode.StatusLEDOff = 'off';             % Off while running or On while running 
    mode.TransmitterDisable= 'off';    
    mode.DarkOnDarkEnable= 'off';
    mode.LoopbackEnable= 'off';
    mode.LocalParityEnable = 'off';
    
    mode.MemoryOffset = '0';       % 0,1,2,3  
    mode.MemorySize='64MByte';   % Memory size of board (must be <= actual board)
    
  %  interrupts.HostInterrupt= 'off'; ?? NO - done by interrupt hodk file
    interrupts.LocalMemoryParity= 'off';     % LIER Bit 13
    interrupts.MemoryWriteInhibited= 'off';  % LIER Bit 12
    interrupts.LatchedSyncLoss = 'off';      % LIER Bit 11
    interrupts.RXFifoFull = 'off';
    interrupts.RXFifoAlmostFull =  'off';
    interrupts.BadData =  'off';
    
    interrupts.PendingInit= 'off';    %
    interrupts.RoguePacket= 'off';
    interrupts.ResetNodeRequest = 'off';
    interrupts.PendingInt3 = 'off';
    interrupts.PendingInt2 = 'off'; 
    interrupts.PendingInt1 = 'off';        
    
    interface.Mode=mode;    
    interface.Interrupts=interrupts;
    interface.NodeID= 'any';         %     
    node.Interface=interface;
end

if ~isfield(node,'Partitions') | isempty(node.Partitions),
    node.Partitions(1)=completepartitionstruct([],'5565');
end

node = fielddefault(node,'Interface',[]);
interface = node.Interface;
interface = fielddefault(interface,'NodeID','any');
interface = fielddefault(interface,'Mode',[]);
interface = fielddefault(interface,'Interrupts',[]);
node.Interface = interface;

mode = node.Interface.Mode;
mode = fielddefault(mode,'StatusLEDOff','off');
mode = fielddefault(mode,'TransmitterDisable','off');
mode = fielddefault(mode,'DarkOnDarkEnable','off');
mode = fielddefault(mode,'LoopbackEnable','off');
mode = fielddefault(mode,'LocalParityEnable','off');
mode = fielddefault(mode,'MemoryOffset','0');
mode = fielddefault(mode,'MemorySize','64MByte');
node.Interface.Mode = mode;


interrupts = node.Interface.Interrupts;
interrupts = fielddefault(interrupts,'LocalMemoryParity','off');
interrupts = fielddefault(interrupts,'MemoryWriteInhibited','off');
interrupts = fielddefault(interrupts,'LatchedSyncLoss','off');
interrupts = fielddefault(interrupts,'RXFifoFull','off');
interrupts = fielddefault(interrupts,'RXFifoAlmostFull','off');
interrupts = fielddefault(interrupts,'BadData','off');

interrupts = fielddefault(interrupts,'PendingInit','off');
interrupts = fielddefault(interrupts,'RoguePacket','off');
interrupts = fielddefault(interrupts,'ResetNodeRequest','off');
interrupts = fielddefault(interrupts,'PendingInt3','off');
interrupts = fielddefault(interrupts,'PendingInt2','off');
interrupts = fielddefault(interrupts,'PendingInt1','off');
node.Interface.Interrupts = interrupts;

% Check bits for LCSR1 Register
LCSR1= 0;
mode=node.Interface.Mode;
tmp = strmatch(lower(mode.StatusLEDOff),{'off','on'},'exact');
if isempty(tmp),
    error('Invalid value for StatusLED in section Mode');
end
LCSR1 = bitor(LCSR1, bitshift(tmp-1,31));

tmp = strmatch(lower(mode.TransmitterDisable),{'off','on'},'exact');
if isempty(tmp),
    error('Invalid value for TransmitterDisable in section Mode');
end
LCSR1 = bitor(LCSR1, bitshift(tmp-1,30));

tmp = strmatch(lower(mode.DarkOnDarkEnable),{'off','on'},'exact');
if isempty(tmp),
    error('Invalid value for DarkOnDarkEnable in section Mode');
end
LCSR1 = bitor(LCSR1, bitshift(tmp-1,29));

tmp = strmatch(lower(mode.LoopbackEnable),{'off','on'},'exact');
if isempty(tmp),
    error('Invalid value for LoopbackEnable in section Mode');
end
LCSR1 = bitor(LCSR1, bitshift(tmp-1,28));

tmp = strmatch(lower(mode.LocalParityEnable),{'off','on'},'exact');
if isempty(tmp),
    error('Invalid value for LocalParityEnable in section Mode');
end
LCSR1 = bitor(LCSR1, bitshift(tmp-1,27));

% Memory Configuration (actually read-only, but we pack it here for
% reference purposes!  We check this at init time
tmp = strmatch(lower(mode.MemorySize),{'64mbyte','128mbyte'},'exact');
if isempty(tmp),
    error('Invalid value for MemorySize in section Mode');
end
LCSR1 = bitor(LCSR1, bitshift(tmp-1,20));

% Memory Offset Setting
tmp = strmatch(lower(mode.MemoryOffset),{'0','1','2','3'},'exact');
if isempty(tmp),
    error('Invalid value for MemoryOffset in section Mode');
end
LCSR1 = bitor(LCSR1, bitshift(tmp-1,16));
node.Interface.Internal.LCSR1= LCSR1;

% Compute required NodeID
if strcmp( lower(node.Interface.NodeID), 'any'),
    INodeID= [];
else
    INodeID = round(eval(node.Interface.NodeID));
    if (INodeID < 0) || (INodeID > 255),
        error('NodeID limited to values between 0 and 255 and must match switch setting of board');
    end
end
node.Interface.Internal.INodeID = INodeID;


% Check bits for LIER Register
interrupts = node.Interface.Interrupts;
LIER= 0;
LIER = checkinterruptonoff(LIER,interrupts,'LocalMemoryParity',13);
LIER = checkinterruptonoff(LIER,interrupts,'MemoryWriteInhibited',12);
LIER = checkinterruptonoff(LIER,interrupts,'LatchedSyncLoss',11);
LIER = checkinterruptonoff(LIER,interrupts,'RXFifoFull',10);
LIER = checkinterruptonoff(LIER,interrupts,'RXFifoAlmostFull',9);
LIER = checkinterruptonoff(LIER,interrupts,'BadData',8);

LIER = checkinterruptonoff(LIER,interrupts,'PendingInit',7);
LIER = checkinterruptonoff(LIER,interrupts,'RoguePacket',6);
LIER = checkinterruptonoff(LIER,interrupts,'ResetNodeRequest',3);
LIER = checkinterruptonoff(LIER,interrupts,'PendingInt3',2);
LIER = checkinterruptonoff(LIER,interrupts,'PendingInt2',1);
LIER = checkinterruptonoff(LIER,interrupts,'PendingInt1',0);
node.Interface.Internal.LIER= LIER;


%-----------------------------------------------------
% Some helper functions to configure fields
%  Configure On/Off fields
function y = checkinterruptonoff(x,interrupts,field,bit)
tmp = strmatch(lower(interrupts.(field)),{'off','on'},'exact');
if isempty(tmp),
    error(['Invalid value for ' field ' in section Interrupt, must be either ''on'' or ''off''']);
end
y = bitor(x, bitshift(tmp-1,bit));

%-----------------------------------------------------
%  Configure Field defaults
function y = fielddefault(x,field,default)
if ~isfield(x,field) | isempty(x.(field))
    x.(field)=default;
end
y =x;
%-----------------------------------------------------
% Scramnet implemenation 
%
function [node] = scramnet(node)

if isempty(node) | ~isfield(node,'Interface') | isempty(node.Interface)
    
    interface.NodeID= '0';
    
    mode.NetworkCommunicationsMode= 'TransmitReceive';
    mode.InsertNode= 'on';
    mode.DisableFiberOpticLoopback= 'on';
    mode.EnableWireLoopback= 'off';
    mode.DisableHostToMemoryWrite= 'off';
    mode.WriteOwnSlotEnable= 'off';
    mode.MessageLengthLimit= '256';
    mode.VariableLengthMessagesOnNetwork= 'off';
    mode.HIPROEnable= 'off';
    mode.MultipleMessages= 'on';
    mode.NoNetworkErrorCorrection= 'on';
    mode.MechanicalSwitchOverride= 'on';
    mode.DisableHoldoff= 'on';
    
    timeout.NumOfNodesInRing= '2';
    timeout.TotalCableLengthInM= '2';
    
    dataFilter.EnableTransmitDataFilter= 'off';
    dataFilter.EnableLower4KBytesForDataFilter= 'off';

    virtualPaging.VirtualPagingEnable= 'off';
    virtualPaging.VirtualPageNumber= '0';
      
    interrupts.HostInterrupt= 'off';
    interrupts.InterruptOnMemoryMaskMatch= 'off';
    interrupts.OverrideReceiveInterrupt= 'off';
    interrupts.InterruptOnError= 'off';
    interrupts.NetworkInterrupt= 'off';
    interrupts.OverrideTransmitInterrupt= 'off';
    interrupts.InterruptOnOwnSlot= 'off';
    interrupts.ReceiveInterruptOverride= 'off';
    
    interface.Mode=mode;
    interface.Timeout=timeout;
    interface.DataFilter=dataFilter;
    interface.VirtualPaging=virtualPaging; 
    interface.Interrupts=interrupts;
    
    node.Interface=interface;
    
end

if ~isfield(node,'Partitions') | isempty(node.Partitions)
    node.Partitions(1)=completepartitionstruct([]);
end

interface=node.Interface;

if ~isa(interface, 'struct')
    error('interface data must be of class ''struct''');
end

if ~isfield(interface,'NodeID') | isempty(interface.NodeID)
    interface.NodeID='0';
end

if ~isfield(interface,'Mode')
    interface.Mode.NetworkCommunicationsMode= 'TransmitReceive';
end
if ~isa(interface.Mode, 'struct')
    error('Mode section of interface data must be of class ''struct''');
end
mode= interface.Mode;
if ~isfield(mode,'NetworkCommunicationsMode') | isempty(mode.NetworkCommunicationsMode)
    mode.NetworkCommunicationsMode='TransmitReceive';
end
if ~isfield(mode,'InsertNode') | isempty(mode.InsertNode)
    mode.InsertNode='on';
end
if ~isfield(mode,'DisableFiberOpticLoopback') | isempty(mode.DisableFiberOpticLoopback)
    mode.DisableFiberOpticLoopback='on';
end
if ~isfield(mode,'EnableWireLoopback') | isempty(mode.EnableWireLoopback)
    mode.EnableWireLoopback='off';
end
if ~isfield(mode,'DisableHostToMemoryWrite') | isempty(mode.DisableHostToMemoryWrite)
    mode.DisableHostToMemoryWrite='off';
end
if ~isfield(mode,'WriteOwnSlotEnable') | isempty(mode.WriteOwnSlotEnable)
    mode.WriteOwnSlotEnable='off';
end
if ~isfield(mode,'MessageLengthLimit') | isempty(mode.MessageLengthLimit)
    mode.MessageLengthLimit='256';
end
if ~isfield(mode,'VariableLengthMessagesOnNetwork') | isempty(mode.VariableLengthMessagesOnNetwork)
    mode.VariableLengthMessagesOnNetwork='off';
end
if ~isfield(mode,'HIPROEnable') | isempty(mode.HIPROEnable)
    mode.HIPROEnable='off';
end
if ~isfield(mode,'MultipleMessages') | isempty(mode.MultipleMessages)
    mode.MultipleMessages='on';
end
if ~isfield(mode,'NoNetworkErrorCorrection') | isempty(mode.NoNetworkErrorCorrection)
    mode.NoNetworkErrorCorrection='on';
end
if ~isfield(mode,'MechanicalSwitchOverride') | isempty(mode.MechanicalSwitchOverride)
    mode.MechanicalSwitchOverride='on';
end
if ~isfield(mode,'DisableHoldoff') | isempty(mode.DisableHoldoff)
    mode.DisableHoldoff='off';
end
interface.Mode=mode;

if ~isfield(interface,'Timeout')
    interface.Timeout.NumOfNodesInRing= '2';
end
if ~isa(interface.Timeout, 'struct')
    error('Timeout section of interface data must be of class ''struct''');
end
timeout= interface.Timeout;
if ~isfield(timeout,'NumOfNodesInRing') | isempty(timeout.NumOfNodesInRing)
    timeout.NumOfNodesInRing='2';
end
if ~isfield(timeout,'TotalCableLengthInM') | isempty(timeout.TotalCableLengthInM)
    timeout.TotalCableLengthInM='2';
end
interface.Timeout=timeout;

if ~isfield(interface,'DataFilter')
    interface.DataFilter.EnableTransmitDataFilter= 'off';
end
if ~isa(interface.DataFilter, 'struct')
    error('Data Filter section of interface data must be of class ''struct''');
end
dataFilter= interface.DataFilter;
if ~isfield(dataFilter,'EnableTransmitDataFilter') | isempty(dataFilter.EnableTransmitDataFilter)
    dataFilter.EnableTransmitDataFilter='off';
end
if ~isfield(dataFilter,'EnableLower4KBytesForDataFilter') | isempty(dataFilter.EnableLower4KBytesForDataFilter)
    dataFilter.EnableLower4KBytesForDataFilter='off';
end
interface.DataFilter=dataFilter;

if ~isfield(interface,'VirtualPaging')
    interface.VirtualPaging.VirtualPagingEnable= 'off';
end
if ~isa(interface.VirtualPaging, 'struct')
    error('Virtual Paging section of interface data must be of class ''struct''');
end
virtualPaging= interface.VirtualPaging;
if ~isfield(virtualPaging,'VirtualPagingEnable') | isempty(virtualPaging.VirtualPagingEnable)
    virtualPaging.VirtualPagingEnable='off';
end
if ~isfield(virtualPaging,'VirtualPageNumber') | isempty(virtualPaging.VirtualPageNumber)
    virtualPaging.VirtualPageNumber='0';
end
interface.VirtualPaging=virtualPaging;

if ~isfield(interface,'Interrupts')
    interface.Interrupts.HostInterrupt= 'off';
end
if ~isa(interface.Interrupts, 'struct')
    error('Interrupts section of interface data must be of class ''struct''');
end
interrupts= interface.Interrupts;
if ~isfield(interrupts,'HostInterrupt') | isempty(interrupts.HostInterrupt)
    interrupts.HostInterrupt='off';
end
if ~isfield(interrupts,'InterruptOnMemoryMaskMatch') | isempty(interrupts.InterruptOnMemoryMaskMatch)
    interrupts.InterruptOnMemoryMaskMatch='off';
end
if ~isfield(interrupts,'OverrideReceiveInterrupt') | isempty(interrupts.OverrideReceiveInterrupt)
    interrupts.OverrideReceiveInterrupt='off';
end
if ~isfield(interrupts,'InterruptOnError') | isempty(interrupts.InterruptOnError)
    interrupts.InterruptOnError='off';
end
if ~isfield(interrupts,'NetworkInterrupt') | isempty(interrupts.NetworkInterrupt)
    interrupts.NetworkInterrupt='off';
end
if ~isfield(interrupts,'OverrideTransmitInterrupt') | isempty(interrupts.OverrideTransmitInterrupt)
    interrupts.OverrideTransmitInterrupt='off';
end
if ~isfield(interrupts,'InterruptOnOwnSlot') | isempty(interrupts.InterruptOnOwnSlot)
    interrupts.InterruptOnOwnSlot='off';
end
if ~isfield(interrupts,'ReceiveInterruptOverride') | isempty(interrupts.ReceiveInterruptOverride)
    interrupts.ReceiveInterruptOverride='off';
end
interface.Interrupts= interrupts;

% build CSRs

CSR0=0;
CSR1=0;
CSR2=0;
CSR3=0;
CSR4=0;
CSR5=0;
CSR6=0;
CSR7=0;
CSR8=0;
CSR9=0;
CSR10=0;
CSR11=0;
CSR12=0;
CSR13=0;
CSR14=0;
CSR15=0;

tmp=str2num(interface.NodeID);
if isempty(tmp)
    error('Invalid NodeID');
end
if tmp<0 | tmp >255
    error('NodeID must be in the range 0..255');
end
CSR3= bitor(CSR3, bitshift(round(tmp),8));

mode=interface.Mode;
if strcmp(lower(mode.NetworkCommunicationsMode),'none')
    tmp=0;
elseif strcmp(lower(mode.NetworkCommunicationsMode),'receiveonly')
    tmp=1;
elseif strcmp(lower(mode.NetworkCommunicationsMode),'transmitonly')
    tmp=2;
elseif strcmp(lower(mode.NetworkCommunicationsMode),'transmitreceive')
    tmp=3;
else
    error('Invalid value for NetworkCommunicationsMode in section Mode');
end
CSR0= bitor(CSR0, bitshift(tmp,0));

if strcmp(lower(mode.InsertNode),'off')
    tmp=0;
elseif strcmp(lower(mode.InsertNode),'on')
    tmp=1;
else
    error('Invalid value for InsertNode in section Mode');
end
CSR0= bitor(CSR0, bitshift(tmp,15));

if strcmp(lower(mode.DisableFiberOpticLoopback),'off')
    tmp=0;
elseif strcmp(lower(mode.DisableFiberOpticLoopback),'on')
    tmp=1;
else
    error('Invalid value for DisableFiberOpticLoopback in section Mode');
end
CSR2= bitor(CSR2, bitshift(tmp,6));

if strcmp(lower(mode.EnableWireLoopback),'off')
    tmp=0;
elseif strcmp(lower(mode.EnableWireLoopback),'on')
    tmp=1;
else
    error('Invalid value for EnableWireLoopback in section Mode');
end
CSR2= bitor(CSR2, bitshift(tmp,7));

if strcmp(lower(mode.DisableHostToMemoryWrite),'off')
    tmp=0;
elseif strcmp(lower(mode.DisableHostToMemoryWrite),'on')
    tmp=1;
else
    error('Invalid value for DisableHostToMemoryWrite in section Mode');
end
CSR2= bitor(CSR2, bitshift(tmp,8));

if strcmp(lower(mode.WriteOwnSlotEnable),'off')
    tmp=0;
elseif strcmp(lower(mode.WriteOwnSlotEnable),'on')
    tmp=1;
else
    error('Invalid value for WriteOwnSlotEnable in section Mode');
end
CSR2= bitor(CSR2, bitshift(tmp,9));

if strcmp(lower(mode.MessageLengthLimit),'1024')
    tmp=1;
elseif strcmp(lower(mode.MessageLengthLimit),'256')
    tmp=0;
else
    error('Invalid value for MessageLengthLimit in section Mode');
end
CSR2= bitor(CSR2, bitshift(tmp,11));

if strcmp(lower(mode.VariableLengthMessagesOnNetwork),'off')
    tmp=0;
elseif strcmp(lower(mode.VariableLengthMessagesOnNetwork),'on')
    tmp=1;
else
    error('Invalid value for VariableLengthMessagesOnNetwork in section Mode');
end
CSR2= bitor(CSR2, bitshift(tmp,12));

if strcmp(lower(mode.HIPROEnable),'off')
    tmp=0;
elseif strcmp(lower(mode.HIPROEnable),'on')
    tmp=1;
else
    error('Invalid value for HIPROEnable in section Mode');
end
CSR2= bitor(CSR2, bitshift(tmp,13));

if strcmp(lower(mode.MultipleMessages),'off')
    tmp=0;
elseif strcmp(lower(mode.MultipleMessages),'on')
    tmp=1;
else
    error('Invalid value for MultipleMessages in section Mode');
end
CSR2= bitor(CSR2, bitshift(tmp,14));

if strcmp(lower(mode.NoNetworkErrorCorrection),'off')
    tmp=0;
elseif strcmp(lower(mode.NoNetworkErrorCorrection),'on')
    tmp=1;
else
    error('Invalid value for NoNetworkErrorCorrection in section Mode');
end
CSR2= bitor(CSR2, bitshift(tmp,15));

if strcmp(lower(mode.MechanicalSwitchOverride),'off')
    tmp=0;
elseif strcmp(lower(mode.MechanicalSwitchOverride),'on')
    tmp=1;
else
    error('Invalid value for MechanicalSwitchOverride in section Mode');
end
CSR8= bitor(CSR8, bitshift(tmp,11));

if strcmp(lower(mode.DisableHoldoff),'off')
    tmp=0;
elseif strcmp(lower(mode.DisableHoldoff),'on')
    tmp=1;
else
    error('Invalid value for DisableHoldoff in section Mode');
end
CSR8= bitor(CSR8, bitshift(tmp,1));

timeout=interface.Timeout;

tmp1=str2num(timeout.NumOfNodesInRing);
if isempty(tmp1)
    error('Invalid NumOfNodesInRing in section Timeout');
end
if tmp1<0 | tmp1>255
    error('NumOfNodesInRing in section Timeout must be in the range 0..255');
end
tmp2=str2num(timeout.TotalCableLengthInM);
if isempty(tmp2)
    error('Invalid TotalCableLengthInM in section Timeout');
end
if tmp2<0
    error('TotalCableLengthInM in section Timeout must be in the range 0..');
end
tmp= tmp1 + (tmp2/50) + 1;
CSR5= ceil(tmp);



dataFilter=interface.DataFilter;

if strcmp(lower(dataFilter.EnableTransmitDataFilter),'off')
    tmp=0;
elseif strcmp(lower(dataFilter.EnableTransmitDataFilter),'on')
    tmp=1;
else
    error('Invalid value for EnableTransmitDataFilter in section DataFilter');
end
CSR0= bitor(CSR0, bitshift(tmp,10));

if strcmp(lower(dataFilter.EnableLower4KBytesForDataFilter),'off')
    tmp=0;
elseif strcmp(lower(dataFilter.EnableLower4KBytesForDataFilter),'on')
    tmp=1;
else
    error('Invalid value for EnableLower4KBytesForDataFilter in section DataFilter');
end
CSR0= bitor(CSR0, bitshift(tmp,11));

virtualPaging=interface.VirtualPaging;

if strcmp(lower(virtualPaging.VirtualPagingEnable),'off')
    tmp=0;
elseif strcmp(lower(virtualPaging.VirtualPagingEnable),'on')
    tmp=1;
else
    error('Invalid value for VirtualPagingEnable in section VirtualPaging');
end
CSR12= bitor(CSR12, bitshift(tmp,0));

tmp=str2num(virtualPaging.VirtualPageNumber);
if isempty(tmp)
    error('Invalid VirtualPageNumber in section VirtualPaging');
end
if tmp<0 | tmp >2047
    error('VirtualPageNumber in section VirtualPaging must be in the range 0..2047');
end
CSR12= bitor(CSR12, bitshift(round(tmp),5));

Interrupts=interface.Interrupts;

if strcmp(lower(Interrupts.NetworkInterrupt),'off')
    tmp=0;
elseif strcmp(lower(Interrupts.NetworkInterrupt),'on')
    tmp=1;
else
    error('Invalid value for NetworkInterrupt in section Interrupts');
end
CSR0= bitor(CSR0, bitshift(tmp,8));

if strcmp(lower(Interrupts.HostInterrupt),'off')
    tmp=0;
elseif strcmp(lower(Interrupts.HostInterrupt),'on')
    tmp=1;
else
    error('Invalid value for HostInterrupt in section Interrupts');
end
CSR0= bitor(CSR0, bitshift(tmp,3));

if strcmp(lower(Interrupts.InterruptOnMemoryMaskMatch),'off')
    tmp=0;
elseif strcmp(lower(Interrupts.InterruptOnMemoryMaskMatch),'on')
    tmp=1;
else
    error('Invalid value for InterruptOnMemoryMaskMatch in section Interrupts');
end
CSR0= bitor(CSR0, bitshift(tmp,5));

if strcmp(lower(Interrupts.OverrideReceiveInterrupt),'off')
    tmp=0;
elseif strcmp(lower(Interrupts.OverrideReceiveInterrupt),'on')
    tmp=1;
else
    error('Invalid value for OverrideReceiveInterrupt in section Interrupts');
end
CSR0= bitor(CSR0, bitshift(tmp,6));

if strcmp(lower(Interrupts.InterruptOnError),'off')
    tmp=0;
elseif strcmp(lower(Interrupts.InterruptOnError),'on')
    tmp=1;
else
    error('Invalid value for InterruptOnError in section Interrupts');
end
CSR0= bitor(CSR0, bitshift(tmp,7));

if strcmp(lower(Interrupts.OverrideTransmitInterrupt),'off')
    tmp=0;
elseif strcmp(lower(Interrupts.OverrideTransmitInterrupt),'on')
    tmp=1;
else
    error('Invalid value for OverrideTransmitInterrupt in section Interrupts');
end
CSR0= bitor(CSR0, bitshift(tmp,9));

if strcmp(lower(Interrupts.InterruptOnOwnSlot),'off')
    tmp=0;
elseif strcmp(lower(Interrupts.InterruptOnOwnSlot),'on')
    tmp=1;
else
    error('Invalid value for InterruptOnOwnSlot in section Interrupts');
end
CSR2= bitor(CSR2, bitshift(tmp,10));

if strcmp(lower(Interrupts.ReceiveInterruptOverride),'off')
    tmp=0;
elseif strcmp(lower(Interrupts.ReceiveInterruptOverride),'on')
    tmp=1;
else
    error('Invalid value for ReceiveInterruptOverride in section Interrupts');
end
CSR8= bitor(CSR8, bitshift(tmp,10));

CSRs=[CSR0, CSR1, CSR2, CSR3, CSR4, CSR5, CSR6, CSR7, CSR8, CSR9, CSR10, CSR11, CSR12, CSR13, CSR14, CSR15];

interface.Internal.CSRs=CSRs;

node.Interface=interface;

%disp(dec2hex(CSRs,4))

% deal with associated partitions

partitions=node.Partitions;

ACRAMinfo=length(partitions);
for i=1:length(partitions)
    partition=partitions(i);
    partition=completepartitionstruct(partition);
    ACRAMinfo=[ACRAMinfo, partition.Internal.NDwords, partition.Internal.Address, partition.Internal.ACRAM];
    partitions1(i)=partition;
end
node.Partitions=partitions1;
node.Interface.Internal.ACRAMinfo=ACRAMinfo;
    
    






    















