/* $Revision: 1.1 $ */




static int rl32eGetPCIInfoExt( unsigned short vendor_id, 
						unsigned short device_id, 
						unsigned short sub_vendor_id, 
						unsigned short sub_device_id, 
						PCIDeviceInfo *pciinfo)
{
    int i,device, bus;
    unsigned short vendid, devid, subvendid, subdevid;
    unsigned long res;

        for (bus=0;bus<256;bus++) {

        for (device=0;device<32;device++) {
            // look for VendorID and DeviceID
            res=0x80000000 | (bus <<16) | (device << 11);
            rl32eOutpDW(0xcf8,res);
            res=rl32eInpDW(0xcfc);
            vendid=res & 0x0000ffff;
            devid=(res & 0xffff0000) >> 16;
			res=0x8000002c | (bus <<16) | (device << 11);
            rl32eOutpDW(0xcf8,res);
            res=rl32eInpDW(0xcfc);
			subvendid=res & 0x0000ffff;
            subdevid=(res & 0xffff0000) >> 16;
            if (vendid==vendor_id && devid==device_id && subvendid==sub_vendor_id && subdevid==sub_device_id) {
                // We have found the correct PCI-device
                // now we read the IO base addresses
                for (i=0;i<6;i++) {
                        // read address base i
                        res=0x80000000 | (bus <<16) | ((i+4) << 2) | (device << 11);
                        rl32eOutpDW(0xcf8,res);
                        res=rl32eInpDW(0xcfc);
                        //printf("%x\n",res);
                        pciinfo->AddressSpaceIndicator[i]=res & 0x1;
                        if (pciinfo->AddressSpaceIndicator[i]) {
                        pciinfo->BaseAddress[i]=(res & 0xfffffffc);
                        pciinfo->MemoryType[i]=-1;
                        pciinfo->Prefetchable[i]=-1;
                        } else {
                        pciinfo->MemoryType[i]=(res & 0x6) >> 1;
                        pciinfo->Prefetchable[i]=(res % 0x8) >> 3;
                        if (pciinfo->MemoryType[i] < 2) {
                                pciinfo->BaseAddress[i]= (res & 0xfffffff0) >> 0;
                        } else {
                                pciinfo->BaseAddress[i]=0x0;
                        }
                        }
                }
                // now we read the intterupt line
                res=0x8000003c | (bus <<16) | (device << 11);
                rl32eOutpDW(0xcf8,res);
                res=rl32eInpDW(0xcfc);
                pciinfo->InterruptLine=res & 0xff;
                // ok
                return 0;
            }
        }
        }
    return -1;
}


static int rl32eGetPCIInfoAtSlotExt(unsigned short vendor_id, unsigned short device_id, unsigned short sub_vendor_id, unsigned short sub_device_id, int slot, PCIDeviceInfo *pciinfo)
{
    int i;
    unsigned short vendid, devid, subvendid, subdevid;
    unsigned long res, busSlot;

    // look for VendorID and DeviceID
    // HIBYTE(slot) == bus number, LOBYTE(slot) = slot number
    busSlot = ((slot & 0xff) << 11) | (((slot >> 8) & 0xff) << 16);
    res=0x80000000 | busSlot;
    rl32eOutpDW(0xcf8,res);
    res=rl32eInpDW(0xcfc);
    vendid=res & 0x0000ffff;
    devid=(res & 0xffff0000) >> 16;
	res=0x8000002c | busSlot;
    rl32eOutpDW(0xcf8,res);
    res=rl32eInpDW(0xcfc);
	subvendid=res & 0x0000ffff;
    subdevid=(res & 0xffff0000) >> 16;
    if (vendid==vendor_id && devid==device_id && subvendid==sub_vendor_id && subdevid==sub_device_id) {
        // We have found the correct PCI-device
        // now we read the IO base addresses
        for (i=0;i<6;i++) {
            // read address base i
            res=0x80000000 | ((i+4) << 2) | busSlot;
            rl32eOutpDW(0xcf8,res);
            res=rl32eInpDW(0xcfc);
            pciinfo->AddressSpaceIndicator[i]=res & 0x1;
            if (pciinfo->AddressSpaceIndicator[i]) {
                pciinfo->BaseAddress[i]=(res & 0xfffffffc);
                pciinfo->MemoryType[i]=-1;
                pciinfo->Prefetchable[i]=-1;
            } else {
                pciinfo->MemoryType[i]=(res & 0x6) >> 1;
                pciinfo->Prefetchable[i]=(res % 0x8) >> 3;
                if (pciinfo->MemoryType[i] < 2) {
                    pciinfo->BaseAddress[i]= (res & 0xfffffff0) >> 0;
                } else {
                    pciinfo->BaseAddress[i]=0x0;
                }
            }
        }
        // now we read the intterupt line
        res=0x8000003c | busSlot;
        rl32eOutpDW(0xcf8,res);
        res=rl32eInpDW(0xcfc);
        pciinfo->InterruptLine=res & 0xff;
        // ok
        return 0;
    }

    return -1;
}


