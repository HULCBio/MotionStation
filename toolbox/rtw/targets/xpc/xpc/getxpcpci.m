function result=getxpcpci(flag)

%GETXPCPCI Query target PC for installed PCI-boards.
%
%   GETXPCPCI queries the target PC for installed PCI devices (boards)
%   and displays information about the found PCI devices in the command
%   window. Only devices supported by driver blocks in the xPC Target
%   Block Library are displayed. The information displayed, includes
%   the PCI bus number, slot number, assigned IRQ number,  vendor 
%   (manufacturer) name, device (board) name, device type, vendor's PCI
%   Id, and the device PCI Id itself. The query is only successful, if
%   the host-target communication link is functioning (xpctargetping 
%   must return SUCCESS before GETXPCPCI can be invoked). GETXPCPCI
%   can be invoked when either a target application has been loaded
%   or the loader is active only. The latter is used to query for resources
%   assigned to a specific PCI device which have to be provided to a 
%   driver block dialog box prior to the model build process. This
%   includes PCI bus number, slot number, and assigned IRQ number.
%
%   PCIDEVS=GETXPCPCI returns the result of the query in PCIDEVS as a
%   struct instead of displaying it. PCIDEVS is a struct array with one
%   element for each detected PCI device. Each element combines the 
%   information by a set of fieldnames. The struct contains more
%   information compared to the displayed list, like the assigned
%   base addresses, the base and sub class.
%
%   GETXPCPCI('all') displays information about all detected PCI devices,
%   not only the devices supported by the xPC Target Block Library. This
%   will include Graphics Controller, Network Cards, SCSI Cards and even
%   devices which are part of the motherboard chipset (for example 
%   PCI-to-PCI bridges). 
%
%   PCIDEVS=GETXPCPCI('all') returns the result of the query in a struct
%   instead of displaying it.
%
%   GETXPCPCI('supported') displays a list of all currently supported PCI
%   devices by the xPC Target Block Library. GETXPCPCI does not access
%   the target PC in this case, therefore the host-target communication 
%   link can be down.
%
%   PCIDEVS=GETXPCPCI('supported') returns the supported PCI devices in 
%   a struct instead of displaying it.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.2 $ $Date: 2004/04/08 21:04:16 $


if nargin==1
  if strcmp(lower(flag),'supported')
    pci=getsuppcidev;
    if nargout==1
      result=pci;
      return
    else
      showSupportedPCI(pci);
      return
    end
  end
end

pcis=getsuppcidev;
vendor=zeros(length(pcis),1);
for k=1:length(vendor)
    vendor(k)=hex2dec(pcis(k).VendorID);
end
device=zeros(length(pcis),1);
for k=1:length(vendor)
    device(k)=hex2dec(pcis(k).DeviceID);
end

pcii=getInstalledPCI;

unknown=zeros(length(pcii),1);

for k=1:length(pcii)
    index1=find(vendor==hex2dec(pcii(k).VendorID));
    index2=find(device==hex2dec(pcii(k).DeviceID));
    index=intersect(index1,index2);
    if isempty(index)
        pcii(k).VendorName='*****';
        pcii(k).DeviceName='*****';
        pcii(k).DeviceType=getclass(hex2dec(pcii(k).BaseClass),hex2dec(pcii(k).SubClass));
        unknown(k)=1;
    else
        pcii(k).VendorName=pcis(index).VendorName;
        pcii(k).DeviceName=pcis(index).DeviceName;
        pcii(k).DeviceType=pcis(index).DeviceType;  
    end
end

reduce=1;
if nargin==1
  if strcmp(lower(flag),'all')
      reduce=0;
  end
end

if reduce
    pcii(find(unknown==1))=[];
end

if nargout==1
    result=pcii;
    return
end

showInstalledPCI(pcii);


    
function showSupportedPCI(pci)

fprintf(1,'\nList of supported PCI devices:\n\n');

fprintf(1,'%-30s%-20s%-16s%-10s%-10s\n\n','Vendor','Device','Type','VendorID','DeviceID');

for k=1:length(pci)
  fprintf(1,'%-30s%-20s%-16s%-10s%-10s\n',...
      pci(k).VendorName,...
      pci(k).DeviceName,...
      pci(k).DeviceType,...
      pci(k).VendorID,...
      pci(k).DeviceID);
end

fprintf(1,'\n');

function showInstalledPCI(pci)

fprintf(1,'\nList of installed PCI devices:\n\n');

fprintf(1,'%-5s%-5s%-5s%-30s%-20s%-30s%-10s%-10s\n\n','Bus','Slot','IRQ','Vendor Name','Device Name','Device Type','VendorID','DeviceID');

for k=1:length(pci)
  fprintf(1,'%-5s%-5s%-5s%-30s%-20s%-30s%-10s%-10s\n',...
      num2str(pci(k).Bus),...
      num2str(pci(k).Slot),...
      num2str(pci(k).Interrupt),...
      pci(k).VendorName,...
      pci(k).DeviceName,...
      pci(k).DeviceType,...
      pci(k).VendorID,...
      pci(k).DeviceID);
end

fprintf(1,'\n');

function pci=getInstalledPCI

string = xpcgate('sendmsg','1070;', 4096);

if ~isempty(findstr(string,'Time Out -'))
    error(string);
end

  v = strread(string,'%f','delimiter',',');
 
  i=0;
  k=1;
  while i<length(v)
    pci(k).Bus=(v(1+i));
    pci(k).Slot=(v(2+i));
    pci(k).VendorID=dec2hex(v(3+i));
    pci(k).DeviceID=dec2hex(v(4+i));
    pci(k).BaseClass=dec2hex(v(5+i));
    pci(k).SubClass=dec2hex(v(6+i));
    pci(k).Interrupt=v(7+i);
   for n=1:6
     	pci(k).BaseAddresses(n).AddressSpaceIndicator=v(8+i);
     	pci(k).BaseAddresses(n).BaseAddress=dec2hex(v(9+i));
     	pci(k).BaseAddresses(n).MemoryType=v(10+i);
     	pci(k).BaseAddresses(n).Prefetchable=v(11+i);
    end
  k=k+1;
  i=i+31;
    
  end


function name=getclass(baseclass, subclass)

switch baseclass
case 0
    switch subclass
    case 0
        name='Non VGA';
    case 1
        name='VGA';
    end
case 1
    switch subclass
    case 0
        name='SCSI Bus Controller';
    case 1
        name='IDE Controller';
    case 2
        name='Floppy Disk Controller';    
    case 3
        name='IPI Bus Controller';
    case 4
        name='Raid Controller';
    otherwise
        name='Mass Storage Controller';
    end
 case 2
    switch subclass
    case 0
        name='Ethernet Controller';
    case 1
        name='Token Ring Controller';
    case 2
        name='FDDI Controller';    
    case 3
        name='ATM Controller';
    otherwise
        name='Network Controller';
    end   
case 3
    switch subclass
    case 0
        name='VGA comp. Controller';
    case 1
        name='XGA Controller';
    otherwise
        name='Display Controller';
    end   
case 4
    switch subclass
    case 0
        name='Video Controller';
    case 1
        name='Audio Controller';
    otherwise
        name='Multimedia Controller';
    end   
case 5
    switch subclass
    case 0
        name='Memory Controller (RAM)';
    case 1
        name='Memory Controller (FLASH)';
    otherwise
        name='Memory Controller';
    end
case 6
    switch subclass
    case 0
        name='Host Bridge';
    case 1
        name='ISA Bridge';
    case 2
        name='EISA Bridge';    
    case 3
        name='MC Bridge';
    case 4
        name='PCI-to-PCI Bridge';
    case 5
        name='PCMCIA Bridge';
    case 6
        name='NuBus Bridge';
    case 7
        name='CardBus Bridge';
    otherwise
        name='PCI Bridge';
    end
case 7
    switch subclass
    case 0
        name='Serial Port Controller';
    case 1
        name='Parallel Port Controller';
    otherwise
        name='Communications Controller';
    end
case 8
    switch subclass
    case 0
        name='Interrupt Controller';
    case 1
        name='DMA Controller';
    case 2
        name='System Timer';    
    case 3
        name='Real Time Clock';
    otherwise
        name='Generic System Peripheral';
    end
case 9
    switch subclass
    case 0
        name='Keyboard Controller';
    case 1
        name='Digitizer (Pen) Controller';
    case 2
        name='Mouse Controller';    
    otherwise
        name='Input Device Controller';
    end
case 10
    switch subclass
    case 0
        name='Generic Docking Station';
    otherwise
        name='Docking Station';
    end
case 11
    switch subclass
    case 0
        name='386 CPU';
    case 1
        name='486 CPU';
    case 2
        name='Pentium CPU';  
    case 3
        name='Alpha CPU';
    case 4
        name='Co-processor';    
    otherwise
        name='Processor';
    end
case 12
    switch subclass
    case 0
        name='Firewire Controller';
    case 1
        name='ACCESS Bus Controller';
    case 2
        name='SSA Contoller';    
    otherwise
        name='Serial Bus Contoller';
    end
otherwise
	name='Unknown Device';
end



    
    
    
    
    
