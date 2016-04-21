
function [maskdisplay, description, devName, boardType, maxADChannel, ...
          maxDAChannel, maxDIChannel, maxDOChannel,gains, sh, maxCVClock] ...
    = mgetueidevice(maskType, boardtype)

gains= [1,2,5,10];
Hgains= [1,2,4,8];
Lgains= [1, 10, 100, 1000];

tmp=get_param(gcb,'MaskValues');
maskdisplay=['disp(''',tmp{1},'\nUEI\n'];
sh = 0;  % 1 if MFS type (sample and hold) board, 0 if MF type board
maxCVClock = 0;  % preset max value.

switch maskType
case {'pd2ao16','pdxiao16'}
    maxADChannel=0;
    maxDAChannel=0;
    maxDIChannel=8;
    maxDOChannel=8;
    switch boardtype    
    case 1
        boardType=hex2dec('14e');
        maxDAChannel=8;
    case 2
        boardType=hex2dec('14f');
        maxDAChannel=16;
    case 3
        boardType=hex2dec('150');
        maxDAChannel=32;
    case 4
        boardType=hex2dec('151');
        maxDAChannel=96;
    end
case {'pd2mfs12','pdximfs12'}
    maxADChannel=0;
    maxDAChannel=2;
    maxDIChannel=16;
    maxDOChannel=16;
    sh = 1;
    maxCVClock = 1.25e6;
    switch boardtype    
    case 1   % PD2-MFS-4-1M/12
        boardType=hex2dec('139');
        maxADChannel=4;
    case 2   % PD2-MFS-4-1M/12DG
        boardType=hex2dec('13b');
        maxADChannel=4;
    case 3   % PD2-MFS-4-1M/12H
        boardType=hex2dec('13c');
        maxADChannel=4;
    case 4   % PD2-MFS-8-1M/12
        boardType=hex2dec('13a');
        maxADChannel=8;
    case 5   % PD2-MFS-8-1M/12DG
        boardType=hex2dec('13d');
        maxADChannel=8;
    case 6   % PD2-MFS-8-1M/12H
        boardType=hex2dec('13e');
        maxADChannel=8;
    end    
case {'pd2mfs14','pdximfs14'}
    maxADChannel=0;
    maxDAChannel=2;
    maxDIChannel=16;
    maxDOChannel=16;
    sh = 1;
    maxCVClock = 0;
    switch boardtype    
    case 1   % PD2-MFS-4-500/14
        boardType=hex2dec('12d');
        maxADChannel=4;
        maxCVClock = 5e5;
    case 2   % PD2-MFS-4-500/14DG
        boardType=hex2dec('12f');
        maxADChannel=4;
        maxCVClock = 5e5;
    case 3   % PD2-MFS-4-500/14H
        boardType=hex2dec('130');
        maxADChannel=4;
        maxCVClock = 5e5;
    case 4   % PD2-MFS-8-500/14
        boardType=hex2dec('12e');
        maxADChannel=8;
        maxCVClock = 5e5;
    case 5   % PD2-MFS-8-500/14DG
        boardType=hex2dec('131');
        maxADChannel=8;
        maxCVClock = 5e5;
    case 6   % PD2-MFS-8-500/14H
        boardType=hex2dec('132');
        maxADChannel=8;
        maxCVClock = 5e5;
    case 7   % PD2-MFS-4-800/14
        boardType=hex2dec('133');
        maxADChannel=4;
        maxCVClock = 8e5;
    case 8   % PD2-MFS-4-800/14DG
        boardType=hex2dec('135');
        maxADChannel=4;
        maxCVClock = 8e5;
    case 9   % PD2-MFS-4-800/14H
        boardType=hex2dec('136');
        maxADChannel=4;
        maxCVClock = 8e5;
    case 10   % PD2-MFS-8-800/14
        boardType=hex2dec('134');
        maxADChannel=8;
        maxCVClock = 8e5;
    case 11   % PD2-MFS-8-800/14DG
        boardType=hex2dec('137');
        maxADChannel=8;
        maxCVClock = 8e5;
    case 12   % PD2-MFS-8-800/14H
        boardType=hex2dec('138');
        maxADChannel=8;
        maxCVClock = 8e5;
    case 13   % PD2-MFS-4-2M/14
        boardType=hex2dec('13f');
        maxADChannel=4;
        maxCVClock = 2.2e6;
    case 14   % PD2-MFS-4-2M/14DG
        boardType=hex2dec('141');
        maxADChannel=4;
        maxCVClock = 2.2e6;
    case 15   % PD2-MFS-4-2M/14H
        boardType=hex2dec('142');
        maxADChannel=4;
        maxCVClock = 2.2e6;
    case 16   % PD2-MFS-8-2M/14
        boardType=hex2dec('140');
        maxADChannel=8;
        maxCVClock = 2.2e6;
    case 17   % PD2-MFS-8-2M/14DG
        boardType=hex2dec('143');
        maxADChannel=8;
        maxCVClock = 2.2e6;
    case 18   % PD2-MFS-8-2M/14H
        boardType=hex2dec('144');
        maxADChannel=8;
        maxCVClock = 2.2e6;
    end    
case {'pd2mfs16','pdximfs16'}
    maxADChannel=0;
    maxDAChannel=2;
    maxDIChannel=16;
    maxDOChannel=16;
    sh = 1;
    switch boardtype    
    case 1   % PD2-MFS-4-300/16
        boardType=hex2dec('145');
        maxADChannel=4;
        maxCVClock = 3e5;
    case 2   % PD2-MFS-4-300/16DG
        boardType=hex2dec('147');
        maxADChannel=4;
        maxCVClock = 3e5;
    case 3   % PD2-MFS-4-300/16H
        boardType=hex2dec('148');
        maxADChannel=4;
        maxCVClock = 3e5;
    case 4   % PD2-MFS-8-300/16
        boardType=hex2dec('146');
        maxADChannel=8;
        maxCVClock = 3e5;
    case 5   % PD2-MFS-8-300/16DG
        boardType=hex2dec('149');
        maxADChannel=8;
        maxCVClock = 3e5;
    case 6   % PD2-MFS-8-300/16H
        boardType=hex2dec('14a');
        maxADChannel=8;
        maxCVClock = 3e5;
    case 7   % PD2-MFS-4-500/16
        boardType=hex2dec('169');
        maxADChannel=4;
        maxCVClock = 5e5;
    case 8   % PD2-MFS-4-500/16DG
        boardType=hex2dec('16b');
        maxADChannel=4;
        maxCVClock = 5e5;
    case 9   % PD2-MFS-4-500/16H
        boardType=hex2dec('16c');
        maxADChannel=4;
        maxCVClock = 5e5;
    case 10   % PD2-MFS-8-500/16
        boardType=hex2dec('16a');
        maxADChannel=8;
        maxCVClock = 5e5;
    case 11   % PD2-MFS-8-500/16DG
        boardType=hex2dec('16d');
        maxADChannel=8;
        maxCVClock = 5e5;
    case 12   % PD2-MFS-8-500/16H
        boardType=hex2dec('16e');
        maxADChannel=8; 
        maxCVClock = 5e5;
    end
case {'pd2mf12','pdximf12'}
    maxADChannel=0;
    maxDAChannel=2;
    maxDIChannel=16;
    maxDOChannel=16;
    sh = 0;
    maxCVClock = 1.25e6;
    switch boardtype    
    case 1  % PD2-MF-16-1M/12L
        boardType=hex2dec('119');
        maxADChannel=16;
        gains=Lgains;
    case 2  % PD2-MF-16-1M/12H
        boardType=hex2dec('11a');
        maxADChannel=16;
        gains=Hgains;
    case 3  % PD2-MF-64-1M/12L
        boardType=hex2dec('11b');
        maxADChannel=64;
        gains=Lgains;
    case 4  % PD2-MF-64-1M/12H
        boardType=hex2dec('11c');
        maxADChannel=64;
        gains=Hgains;
    end
case {'pd2mf14','pdximf14'}
    maxADChannel=0;
    maxDAChannel=2;
    maxDIChannel=16;
    maxDOChannel=16;
    sh = 0;
    switch boardtype    
    case 1  % PD2-MF-16-400/14L
        boardType=hex2dec('111');
        maxADChannel=16;
        gains=Lgains;
        maxCVClock = 4e5;
    case 2  % PD2-MF-16-400/14H
        boardType=hex2dec('112');
        maxADChannel=16;
        gains=Hgains;
        maxCVClock = 4e5;
    case 3  % PD2-MF-64-400/14L
        boardType=hex2dec('113');
        maxADChannel=64;
        gains=Lgains;
        maxCVClock = 4e5;
    case 4  % PD2-MF-64-400/14H
        boardType=hex2dec('114');
        maxADChannel=64;
        gains=Hgains;
        maxCVClock = 4e5;
    case 5  % PD2-MF-16-800/14L
        boardType=hex2dec('115');
        maxADChannel=16;
        gains=Lgains;
        maxCVClock = 8e5;
    case 6  % PD2-MF-16-800/14H
        boardType=hex2dec('116');
        maxADChannel=16;
        gains=Hgains;
        maxCVClock = 8e5;
    case 7  % PD2-MF-64-800/14L
        boardType=hex2dec('117');
        maxADChannel=64;
        gains=Lgains;
        maxCVClock = 8e5;
    case 8  % PD2-MF-64-800/14H
        boardType=hex2dec('118');
        maxADChannel=64;
        gains=Hgains;
        maxCVClock = 8e5;
    case 9  % PD2-MF-16-2M/14L
        boardType=hex2dec('125');
        maxADChannel=16;
        gains=Lgains;
        maxCVClock = 2.2e6;
    case 10  % PD2-MF-16-2M/14H
        boardType=hex2dec('126');
        maxADChannel=16;
        gains=Hgains;
        maxCVClock = 2.2e6;
    case 11  % PD2-MF-64-2M/14L
        boardType=hex2dec('127');
        maxADChannel=64;
        gains=Lgains;
        maxCVClock = 2.2e6;
    case 12  % PD2-MF-64-2M/14H
        boardType=hex2dec('128');
        maxADChannel=64;
        gains=Hgains;
        maxCVClock = 2.2e6;
    end
case {'pd2mf16','pdximf16'}
    maxADChannel=0;
    maxDAChannel=2;
    maxDIChannel=16;
    maxDOChannel=16;
    sh = 0;
    switch boardtype    
    case 1  % PD2-MF-16-50/16L
        boardType=hex2dec('11d');
        maxADChannel=16;
        gains=Lgains;
        maxCVClock = 5e4;
    case 2  % PD2-MF-16-50/16H
        boardType=hex2dec('11e');
        maxADChannel=16;
        gains=Hgains;
        maxCVClock = 5e4;
    case 3  % PD2-MF-64-50/16L
        boardType=hex2dec('11f');
        maxADChannel=64;
        gains=Lgains;
        maxCVClock = 5e4;
    case 4  % PD2-MF-64-50/16H
        boardType=hex2dec('120');
        maxADChannel=64;
        gains=Hgains;
        maxCVClock = 5e4;
    case 5  % PD2-MF-16-100/16L
        boardType=hex2dec('16f');
        maxADChannel=16;
        gains=Lgains;
        maxCVClock = 1.5e5;
    case 6  % PD2-MF-16-100/16H
        boardType=hex2dec('170');
        maxADChannel=16;
        gains=Hgains;
        maxCVClock = 1.5e5;
    case 7  % PD2-MF-64-100/16L
        boardType=hex2dec('171');
        maxADChannel=64;
        gains=Lgains;
         maxCVClock = 1.5e5;
   case 8  % PD2-MF-64-100/16H
        boardType=hex2dec('172');
        maxADChannel=64;
        gains=Hgains;
        maxCVClock = 1.5e5;
    case 9  % PD2-MF-16-333/16L
        boardType=hex2dec('121');
        maxADChannel=16;
        gains=Lgains;
        maxCVClock = 3.33e5;
    case 10  % PD2-MF-16-333/16H
        boardType=hex2dec('122');
        maxADChannel=16;
        gains=Hgains;
        maxCVClock = 3.33e5;
    case 11  % PD2-MF-64-333/16L
        boardType=hex2dec('123');
        maxADChannel=64;
        gains=Lgains;
        maxCVClock = 3.33e5;
    case 12  % PD2-MF-64-333/16H
        boardType=hex2dec('124');
        maxADChannel=64;
        gains=Hgains;
        maxCVClock = 3.33e5;
    case 13  % PD2-MF-16-500/16L
        boardType=hex2dec('129');
        maxADChannel=16;
        gains=Lgains;
        maxCVClock = 5e5;
    case 14  % PD2-MF-16-500/16H
        boardType=hex2dec('12a');
        maxADChannel=16;
        gains=Hgains;
        maxCVClock = 5e5;
    case 15  % PD2-MF-64-500/16L
        boardType=hex2dec('12b');
        maxADChannel=64;
        gains=Lgains;
        maxCVClock = 5e5;
    case 16  % PD2-MF-64-500/16H
        boardType=hex2dec('12c');
        maxADChannel=64;
        gains=Hgains;
        maxCVClock = 5e5;
    end
end

switch maskType
case 'pd2ao16'
    description= 'PD2-AO series';
case 'pdxiao16'
    description= 'PDXI-AO series';
    boardType= boardType + hex2dec('100');
case 'pd2mfs12'
    description= 'PD2-MFS 12bit series';
case 'pdximfs12'
    description= 'PDXI-MFS 12bit series';
    boardType= boardType + hex2dec('100');
case 'pd2mfs14'
    description= 'PD2-MFS 14bit series';
case 'pdximfs14'
    description= 'PDXI-MFS 14bit series';
    boardType= boardType + hex2dec('100');
case 'pd2mfs16'
    description= 'PD2-MFS 16bit series';
case 'pdximfs16'
    description= 'PDXI-MFS 16bit series';
    boardType= boardType + hex2dec('100');
case 'pd2mf12'
    description= 'PD2-MF 12bit series';
case 'pdximf12'
    description= 'PDXI-MF 12bit series';
    boardType= boardType + hex2dec('100');
case 'pd2mf14'
    description= 'PD2-MF 14bit series';
case 'pdximf14'
    description= 'PDXI-MF 14bit series';
    boardType= boardType + hex2dec('100');
case 'pd2mf16'
    description= 'PD2-MF 16bit series';
case 'pdximf16'
    description= 'PDXI-MF 16bit series';
    boardType= boardType + hex2dec('100');
end
    

devName= ['UEI ',description];


%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/11/20 11:57:43 $
