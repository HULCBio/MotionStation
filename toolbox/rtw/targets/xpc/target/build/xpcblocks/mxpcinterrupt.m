function [irq, devid, vendid,slot, handlers] = ...
    mxpcinterrupt(irqNo, b_type, slot)
% MXPCINTERRUPT Helper M-file for mask of Interrupt handling blocks.
%
%   This file is also called during code generation for IRQ handling when
%   xPC Target is driven by an external interrupt.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.13.8.4 $ $Date: 2004/04/08 21:03:14 $

bTypeMapping = [1, 3, 1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 1];

b_type = bTypeMapping(b_type);

if (floor(irqNo) - irqNo)
  error('IRQ Must be an integer')
end
if (irqNo < 2 | irqNo > 15)
  error('IRQ must be between 2 and 15')
end
irq = irqNo;

%% Make sure to keep these four lists in sync!!!

vendidlist = [
    -1                , % NONE
    hex2dec('10B5')   , % CANAC2PCI
    hex2dec('1307')   , % PCI-CTR05
    -1                , % DM6804 
    hex2dec('12BA')   , % AUDIO-PMC+
    hex2dec('11B0')   , % Scramnet
    -1                , % ATI
    -1                , % MM-32
    hex2dec('1057')   , % UEI, needs subvendor and subdevice
    hex2dec('114A')   , % VMIC-5565
    hex2dec('108A')   , % SBS-25x0
    hex2dec('108A')   , % SBS-25x0  
    hex2dec('108A')   , % SBS-25x0  
    hex2dec('108A')   , % SBS-25x0      
];

devidlist = [
    -1                , % NONE
    hex2dec('9050')   , % CANAC2PCI
    hex2dec('0018')   , % PCI-CTR05
    1                 , % DM6804
    hex2dec('002C')   , % AUDIO-PMC+
    hex2dec('4750')   , % Scrament
    1                 , % ATI
    1                 , % MM-32
    hex2dec('1801')   , % UEI
    hex2dec('5565')   , % VMIC-5565
    hex2dec('0100')   , % SBS-25x0
    hex2dec('0101')   , % SBS-25x0  
    hex2dec('0102')   , % SBS-25x0  
    hex2dec('0103')   , % SBS-25x0  
];

hooklist = {
%    PreHookFunction            PostHookFunction     includeFile
    {'NULL'                   , 'NULL',              ''                     }, % NONE
    {'xpccanac2prehook'       , 'NULL',              'xpccanac2hooks'       }, % CANAC2PCI
    {'xpccbpcictr05prehook'   , 'NULL',              'xpccbpcictr05hooks'   }, % PCI-CTR05
    {'xpc6804prehook'         , 'NULL',              'xpc6804hooks'         }, % DM6804
    {'xpcaudpmcprehook'       , 'NULL',              'xpcaudpmchooks'       }, % AUDIO-PMC+
    {'xpcscramnetprehook'     , 'NULL',              'xpcscramnethooks'     }, % Scrament
    {'atiR5prehook'           , 'NULL',              'atihooks'             }, % ATI
    {'xpcmm32prehook'         , 'xpcmm32posthook',   'xpcmm32hooks'         }, % MM-32
    {'xpcueipd2mfxprehook'    , 'NULL',              'xpcueipd2mfxhooks'    }, % UEI
    {'xpcvmic5565prehook'     , 'NULL',              'xpcvmic5565hooks'     }, % VMIC-5565
    {'xpcsbs25x0prehook'      , 'NULL',              'xpcsbs25x0hooks'      }, % SBS-25x0
    {'xpcsbs25x0prehook'      , 'NULL',              'xpcsbs25x0hooks'      }, % SBS-25x0 
    {'xpcsbs25x0prehook'      , 'NULL',              'xpcsbs25x0hooks'      }, % SBS-25x0 
    {'xpcsbs25x0prehook'      , 'NULL',              'xpcsbs25x0hooks'      }, % SBS-25x0 
};

startstoplist = {
%    StartFunction              StopFunction
    {'NULL'                   , 'NULL'               }, % NONE
    {'xpccanac2start'         , 'xpccanac2stop'      }, % CANAC2PCI
    {'xpccbpcictr05start'     , 'xpccbpcictr05stop'  }, % PCI-CTR05
    {'xpc6804start'           , 'xpc6804stop'        }, % DM6804
    {'xpcaudpmcstart'         , 'xpcaudpmcstop'      }, % AUDIO-PMC+
    {'xpcscramnetstart'       , 'xpcscramnetstop'    }, % Scrament
    {'NULL'                   , 'NULL'               }, % ATI
    {'xpcmm32start'           , 'xpcmm32stop'        }, % MM-32
    {'xpcueipd2mfxstart'      , 'xpcueipd2mfxstop'   }, % UEI
    {'xpcvmic5565start'       , 'xpcvmic5565stop'    }, % VMIC-5565    
    {'xpcsbs25x0start'        , 'xpcsbs25x0stop'     }, % SBS-25x0
    {'xpcsbs25x0start'        , 'xpcsbs25x0stop'     }, % SBS-25x0 
    {'xpcsbs25x0start'        , 'xpcsbs25x0stop'     }, % SBS-25x0 
    {'xpcsbs25x0start'        , 'xpcsbs25x0stop'     }, % SBS-25x0     
};

devid    = devidlist(b_type);
vendid   = vendidlist(b_type);
handlers = {hooklist{b_type}{:} startstoplist{b_type}{:}};

sloterror = sprintf(['PCI slot should be either -1 for auto-detection\n' ...
                    'or two nonnegative integers specifying [slot, bus]']);

if (vendid < 0)
  if devid > 0 && length(slot) > 2
    slot = hex2dec(slot(3:end));        % 0x.... , eval the .... part
  else
    slot = 0;
  end
else
  slot = eval(slot);
end
switch length(slot)
 case 1
  if (slot < 0) & slot ~= -1
    error(sloterror);
  end
  return;
 case 2
  if any(slot < 0)
    error(sloterror);
  end
  slot = 256 * slot(1) + slot(2);
 otherwise
  error(sloterror);
end
