function [success]=xpctgboxtest(varargin)
%This function creates test models for xPC TargetBox. 
%Usage:
%XPCTGBOXTEST({'xPCTargetIOOptions','Baseadress','Configuration'},...);
%This function will return success if it successfully creates a model;otherwise it will
%report a failure. 
%
%Valid xPC TargetBox IO Options are:
%{'IO301','IO302','IO303','IO304','IO305','IO306','IO308','LED'};
%Valid Baseaddress entries are:
%Baseadress={'0x200','0x210','0x220','0x230','0x240','0x250','0x260',
%            '0x270','0x280','0x290','0x2A0','0x2B0','0x2C0','0x2D0',
%            '0x2E0','0x300','0x330','0x340','0x350','0x360','0x380',
%            '0x390','0x3A0','0x3C0','0x3E0'};
% Valid Configuration selections are
% IO301 : C11,C12,C13,C14,C21,C22,C23,C24,C31,C32,C33,C34;
% IO302 : C11,C12,C13,C14,C15,C16
%         C21,C22,C23,C24,C25,C26
%         C31,C32,C33,C34,C35,C36
%         C41,C42,C43,C44,C45,C46
%         C51,C52,C53,C54,C55,C56
%         C61,C62,C63,C64,C65,C66
% IO303 : C1111,C1112,C1113
%         C1121,C1122,C1123
%         C1131,C1132,C1133
%         C1211,C1212,C1213
%         C1221,C1222,C1223
%         C1231,C1232,C1233
%         C1311,C1312,C1313
%         C1321,C1322,C1323
%         C1331,C1332,C1333
%
%         C2111,C2112,C2113
%         C2121,C2122,C2123
%         C2131,C2132,C2133
%         C2211,C2212,C2213
%         C2221,C2222,C2223
%         C2231,C2232,C2233
%         C2311,C2312,C2313
%         C2321,C2322,C2323
%         C2331,C2332,C2333
%
%         C3111,C3112,C3113
%         C3121,C3122,C3123
%         C3131,C3132,C3133
%         C3211,C3212,C3213
%         C3221,C3222,C3223
%         C3231,C3232,C3233
%         C3311,C3312,C3313
%         C3321,C3322,C3323
%         C3331,C3332,C3333
%
% I0304,305,306 and 308 does not have any configuration setting.
%
%Examples:
%
%xpctgboxtest({'IO301','0x300','C21'}) 
%  This creates a model with 301 options. The base address will be 0x300.
%
%xpctgboxtest({'IO301','0x300','C21'},{'IO302','0x340','C11'}) 
%  This creates a model with 301 and 302 options. The base address will be 0x300
%  and 0x340 respectively
%
%xpctgboxtest({'IO308','0x300','0xd00000'}) 
%  This creates a model with 308 option. The I/O base address will be 0x300
%  and memory base address '0xd00000'
%
%xpctgboxtest({'LED'}) 
%  With the {'LED'}, this function creates a simple test with xPCTargetBox LEDs.
%

% Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.11.6.5 $  $Date: 2004/04/08 21:03:33 $

if(~length(varargin))
    help xpctgboxtest;
    return
end

ModelStruct=checkarguments(varargin);
% First make sure that the I/O options are correct
[muxinputs,Model]=checkmodel(ModelStruct);

% If  NONE has been specified as an option create a simple model


if(strcmp(Model,'LED'))
    disp('Extra parameters for IO options are ignored')
    bdclose all;
    open_system('ioled');
    success='success';
    return;    
else
    % Otherwise create a test model using IOoptions
    checkbaseaddres(ModelStruct);     
    % Just create an empty model
    params=createemptymodel;
    % Initial positions for the blocksa
    
    xpos=100;
    ypos=40;
    xpos1=140;
    ypos1=100;
    offsetx=150;
    offsety=0;
    load_system('xpclib');
    % Main loop. This loop creates the model
    load_system('simulink');
    
    % Add a mux and set the number of inputs
    add_block('simulink/Signal Routing/Mux',[params.TestModel '/Mux' int2str(i)])
    set_param([params.TestModel '/Mux' int2str(i)],'position',[xpos+2*offsetx ypos+offsety xpos1+2*offsetx ypos1+3*offsetx]);
    set_param([params.TestModel '/Mux' int2str(i)],'Inputs',int2str(muxinputs));
    set_param([params.TestModel '/Mux' int2str(i)],'DisplayOption','none');
    
    % Add a Led and set the number of inputs
    add_block('xpclib/LED/MathWorks/LED ',[params.TestModel  '/LED']);
    set_param([params.TestModel '/LED'],'position',[xpos+3*offsetx+100 ypos+1.5*offsetx xpos1+3*offsetx+100 ypos1+1.5*offsetx]);
    set_param([params.TestModel '/LED'],'leds','[1 2]');
    temp=strmatch('IO301',Model,'exact');
    if((length(Model)>1) | (length(Model)==1 & ~isempty(temp) ))
        % Add AND and set the number of inputs
        add_block('simulink/Logic and Bit Operations/Logical Operator',[params.TestModel '/AND' ])
        set_param([params.TestModel '/AND'],'position',[xpos+2*offsetx+80 ypos+1.5*offsetx xpos1+2*offsetx+80 ypos1+1.5*offsetx]);
        set_param([params.TestModel '/AND'],'Inputs','1');
    end
    
    % Add Data Type conversion Block 
    add_block('simulink/Signal Attributes/Data Type Conversion',[params.TestModel  '/Conversion']);    
    set_param([params.TestModel '/Conversion'],'position',[xpos+2*offsetx+160 ypos+1.5*offsetx xpos1+2*offsetx+160 ypos1+1.5*offsetx]);
    
    % Add the Pulse 
    add_block('simulink/Sources/Step',[params.TestModel '/pulse' int2str(i+1)]);
    %set_param([params.TestModel '/LED'],'position',[xpos+3*offsetx+120 ypos+1.5*offsetx xpos1+3*offsetx+120 ypos1+1.5*offsetx]);
    set_param([params.TestModel '/pulse' int2str(i+1)],'position',[xpos+2*offsetx+160 ypos+2*offsetx xpos1+2*offsetx+160 ypos1+2*offsetx]);
    stop_time=str2num(params.StopTime);
    set_param([params.TestModel '/pulse' int2str(i+1)],'Time',int2str((stop_time-1)));
    
    
    add_block('simulink/Sources/Step',[params.TestModel '/pulse' int2str(i+2)]);
    %set_param([params.TestModel '/LED'],'position',[xpos+3*offsetx+120 ypos+1.5*offsetx xpos1+3*offsetx+120 ypos1+1.5*offsetx]);
    set_param([params.TestModel '/pulse' int2str(i+2)],'position',[xpos+2*offsetx+80 ypos+.5*offsetx xpos1+2*offsetx+80 ypos1+.5*offsetx]);
    stop_time=str2num(params.StopTime);
    set_param([params.TestModel '/pulse' int2str(i+2)],'Time',int2str((stop_time-1)));
    set_param([params.TestModel '/pulse' int2str(i+2)],'Before','1');
    set_param([params.TestModel '/pulse' int2str(i+2)],'After','0');
    
    
    add_block('simulink/Signal Routing/Switch',[params.TestModel '/Switch'])
    set_param([params.TestModel '/Switch'],'position',[xpos+2*offsetx+160 ypos+.5*offsetx xpos1+2*offsetx+160 ypos1+.5*offsetx]);
    set_param([params.TestModel '/Switch'],'Criteria','u2 ~= 0');
    
    
    %Add the stop simulation
    add_block('simulink/Sinks/Stop Simulation',[params.TestModel '/Stop']);
    set_param([params.TestModel '/Stop'],'position',[xpos+3.5*offsetx+160 ypos+1.5*offsetx xpos1+3.5*offsetx+160 ypos1+1.5*offsetx]);
    % wire them together
    temp=strmatch('IO301',Model,'exact');
    if((length(Model)>1) | (length(Model)==1 & ~isempty(temp) ))
        add_line([params.TestModel],['Mux0','/1'],['AND','/1'],'autorouting','on');
        add_line([params.TestModel],['AND','/1'],['Conversion','/1'],'autorouting','on');
    else
        add_line([params.TestModel],['Mux0','/1'],['Conversion','/1'],'autorouting','on');
    end
    add_line([params.TestModel],['pulse',int2str(i+1),'/1'],['LED','/2'],'autorouting','on');   
    add_line([params.TestModel],['pulse',int2str(i+1),'/1'],['Stop','/1'],'autorouting','on'); 
    add_line([params.TestModel],['pulse',int2str(i+2),'/1'],['Switch','/1'],'autorouting','on'); 
    add_line([params.TestModel],['pulse',int2str(i+2),'/1'],['Switch','/2'],'autorouting','on'); 
    add_line([params.TestModel],['Conversion','/1'],['Switch','/3'],'autorouting','on'); 
    add_line([params.TestModel],['Switch','/1'],['LED','/1'],'autorouting','on'); 
    
    
    
    muxi=0;
    for ii=1:length(Model)
        ModelType=char(Model(ii)); 
        switch ModelType
            
            case 'IO301'
                load_system('io301');
                base=ModelStruct(ii).addresses;
                % add the io301 model and set the positions
                add_block('io301/MM32AD',[params.TestModel '/MM32AD' int2str(ii)]);
                set_param([params.TestModel '/MM32AD' int2str(ii) '/AO'],'baseaddress',base);
                set_param([params.TestModel '/MM32AD' int2str(ii) '/AI'],'base',base);
                set_param([params.TestModel '/MM32AD' int2str(ii)],'position',[xpos-75 ypos xpos1-75 ypos1]);
                tempbase=base(3:end); %get the base address info

                configoption=ModelStruct(ii).configoption;
                checkconfigoption('IO301',configoption);
                
                ChannelCoupling=[{'1-32 SE '},{'1-16 DI'},{'1-8 SE  9-16 DI  17-24 SE '}];
                VoltagerangeA0=[{'+-10V'},{'+-5V'},{'0-10V'},{'0-5V'}];
                VoltagerangeAI=[{'-10V to +10V'},{'-5V to 5V'},{'0 to 10V'},{'0 to 5V'}];
                rangevalue=str2num(configoption(3));
                
                set_param([params.TestModel '/MM32AD' int2str(ii) '/AO'],'range',char(VoltagerangeA0(rangevalue)));
                set_param([params.TestModel '/MM32AD' int2str(ii) '/AI'],'range',char(VoltagerangeAI(rangevalue)));   
                
                configvalue=str2num(configoption(2));
                set_param([params.TestModel '/MM32AD' int2str(ii) '/AI'],'configuration',char(ChannelCoupling(configvalue)));   
                
                % Add a scope and wire it to AD option
                add_block('xpclib/Misc./Scope (xPC) ',[params.TestModel  '/MM32ADScope' int2str(ii)])
                set_param([params.TestModel '/MM32ADScope' int2str(ii)],'position',[xpos+offsetx ypos+offsety xpos1+offsetx ypos1+offsety]);
                               
                muxi=next(muxi);
                add_block('Simulink/Math Operations/Gain',[params.TestModel  '/Gain' int2str(muxi)])
                set_param([params.TestModel '/Gain' int2str(muxi)],'position',[xpos-10 ypos+40 xpos+10 ypos+60]);
                set_param([params.TestModel '/Gain' int2str(muxi)],'Gain',['[301.1;',tempbase,']']);
                
                add_line([params.TestModel],['MM32AD',int2str(ii),'/1'],['Mux0','/',int2str(muxi)],'autorouting','on');
                add_block('simulink/Signal Attributes/Data Type Conversion',[params.TestModel  '/Conversion' int2str(muxi)]);    
                set_param([params.TestModel '/Conversion' int2str(muxi)],'position',[xpos+35 ypos+40 xpos+60 ypos+60]);
                add_block('simulink/Signal Routing/Mux',[params.TestModel '/Mux' int2str(muxi)])
                set_param([params.TestModel '/Mux' int2str(muxi)],'position',[xpos+95 ypos+40 xpos+100 ypos+60]);

                 add_line([params.TestModel],['Mux',int2str(muxi),'/1'],['MM32ADScope',int2str(ii),'/1'],'autorouting','on');
                 add_line([params.TestModel],['MM32AD',int2str(ii),'/2'],['Gain',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['MM32AD',int2str(ii),'/1'],['Conversion',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['Gain',int2str(muxi),'/1'],['Mux',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['Conversion',int2str(muxi),'/1'],['Mux',int2str(muxi),'/2'],'autorouting','on');
                
                
                [xpos,ypos,xpos1,ypos1]=incrementpos(xpos,ypos,xpos1,ypos1);    
                
                % Add DIO option and set the parameters
                add_block('io301/MM32DIO',[params.TestModel '/MM32DIO' int2str(ii)]);
                set_param([params.TestModel '/MM32DIO' int2str(ii)],'position',[xpos-75 ypos xpos1-75 ypos1]);
                set_param([params.TestModel '/MM32DIO' int2str(ii)  '/DO'],'baseaddress',base);
                set_param([params.TestModel '/MM32DIO' int2str(ii)  '/DI'],'baseaddress',base);
                
                % add a scope and wire it to the DIO block
                add_block('xpclib/Misc./Scope (xPC) ',[params.TestModel  '/MM32DIOScope' int2str(ii)])
                set_param([params.TestModel '/MM32DIOScope' int2str(ii)],'position',[xpos+offsetx ypos+offsety xpos1+offsetx ypos1+offsety]);
              
                
                
                % add the output to the mux.
                muxi=next(muxi);
                add_block('Simulink/Math Operations/Gain',[params.TestModel  '/Gain' int2str(muxi)])
                set_param([params.TestModel '/Gain' int2str(muxi)],'Gain',['[301.2;',tempbase,']']);
                
                set_param([params.TestModel '/Gain' int2str(muxi)],'position',[xpos-10 ypos+40 xpos+10 ypos+60]);
                add_block('simulink/Signal Attributes/Data Type Conversion',[params.TestModel  '/Conversion' int2str(muxi)]);    
                set_param([params.TestModel '/Conversion' int2str(muxi)],'position',[xpos+35 ypos+40 xpos+60 ypos+60]);
                add_line([params.TestModel],['MM32DIO',int2str(ii),'/1'],['Mux0','/',int2str(muxi)],'autorouting','on');
                add_block('simulink/Signal Routing/Mux',[params.TestModel '/Mux' int2str(muxi)])
                set_param([params.TestModel '/Mux' int2str(muxi)],'position',[xpos+95 ypos+40 xpos+100 ypos+60]);
                
                 add_line([params.TestModel],['Mux',int2str(muxi),'/1'],['MM32DIOScope',int2str(ii),'/1'],'autorouting','on');
                 add_line([params.TestModel],['MM32DIO',int2str(ii),'/2'],['Gain',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['MM32DIO',int2str(ii),'/1'],['Conversion',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['Gain',int2str(muxi),'/1'],['Mux',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['Conversion',int2str(muxi),'/1'],['Mux',int2str(muxi),'/2'],'autorouting','on');
                % wire them together
               
                
                [xpos,ypos,xpos1,ypos1]=incrementpos(xpos,ypos,xpos1,ypos1);
                close_system('io301');
                
                
            case 'IO302'
                load_system('io302');
                base=ModelStruct(ii).addresses;
                % Add io302 option
                add_block('io302/RUBYMM1612DIO',[params.TestModel '/RUBYMM1612DIO' int2str(ii)]);
                set_param([params.TestModel '/RUBYMM1612DIO' int2str(ii)],'position',[xpos-75 ypos xpos1-75 ypos1]);
                set_param([params.TestModel '/RUBYMM1612DIO' int2str(ii) '/AO'],'base',base);
                set_param([params.TestModel '/RUBYMM1612DIO' int2str(ii) '/DI'],'baseaddress',base);
                tempbase=base(3:end); %get the base address info
                
                configoption=ModelStruct(ii).configoption;
                checkconfigoption('IO302',configoption);
                rangevalue=str2num(configoption(2));
                VoltagerangeA01=[{'-10V to 10V'},{'-5V to 5V'},{'-2.5V to 2.5V'},{'0 to 10V'},{'0 to 5V'},{'0 to 2.5V'}];
                set_param([params.TestModel '/RUBYMM1612DIO' int2str(ii) '/AO'],'range1',char(VoltagerangeA01(rangevalue)));
                
                rangevalue=str2num(configoption(3));
                set_param([params.TestModel '/RUBYMM1612DIO' int2str(ii) '/AO'],'range2',char(VoltagerangeA01(rangevalue)));
                % add a scope and wire it to the io302 option, do th esame for mux.
                
                add_block('xpclib/Misc./Scope (xPC) ',[params.TestModel  '/RUBYMM1612DIOScope' int2str(ii)])
                set_param([params.TestModel '/RUBYMM1612DIOScope' int2str(ii)],'position',[xpos+offsetx ypos+offsety xpos1+offsetx ypos1+offsety]);
             
                muxi=next(muxi);
                add_line([params.TestModel],['RUBYMM1612DIO',int2str(ii),'/1'],['Mux0','/',int2str(muxi)],'autorouting','on');
                add_block('Simulink/Math Operations/Gain',[params.TestModel  '/Gain' int2str(muxi)]);
                set_param([params.TestModel '/Gain' int2str(muxi)],'Gain',['[302;',tempbase,']']);
                
                add_block('simulink/Signal Attributes/Data Type Conversion',[params.TestModel  '/Conversion' int2str(muxi)]);    
                set_param([params.TestModel '/Conversion' int2str(muxi)],'position',[xpos+35 ypos+40 xpos+60 ypos+60]);
                set_param([params.TestModel '/Gain' int2str(muxi)],'position',[xpos-10 ypos+40 xpos+10 ypos+60]);
                add_block('simulink/Signal Routing/Mux',[params.TestModel '/Mux' int2str(muxi)])
                set_param([params.TestModel '/Mux' int2str(muxi)],'position',[xpos+95 ypos+40 xpos+100 ypos+60]);
                
                 add_line([params.TestModel],['Mux',int2str(muxi),'/1'],['RUBYMM1612DIOScope',int2str(ii),'/1'],'autorouting','on');
                 add_line([params.TestModel],['RUBYMM1612DIO',int2str(ii),'/2'],['Gain',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['RUBYMM1612DIO',int2str(ii),'/1'],['Conversion',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['Gain',int2str(muxi),'/1'],['Mux',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['Conversion',int2str(muxi),'/1'],['Mux',int2str(muxi),'/2'],'autorouting','on');
                [xpos,ypos,xpos1,ypos1]=incrementpos(xpos,ypos,xpos1,ypos1);    
                
                close_system('io302');
                
            case 'IO303'
                load_system('io303');
                base=ModelStruct(ii).addresses;
                % add the io303 option block and set the parameters
                add_block('io303/RUBYMM416DIO',[params.TestModel '/RUBYMM416DIO' int2str(ii)]);
                set_param([params.TestModel '/RUBYMM416DIO' int2str(ii)],'position',[xpos-75 ypos xpos1-75 ypos1]); 
                set_param([params.TestModel '/RUBYMM416DIO' int2str(ii) '/AO'],'base',base);
                set_param([params.TestModel '/RUBYMM416DIO' int2str(ii) '/DI'],'baseaddress',base);
                tempbase=base(3:end); %get the base address info
                
                configoption=ModelStruct(ii).configoption;
                checkconfigoption('IO303',configoption);
                
                VoltagerangeA01=[{'-10'},{'-5'},{'10'}];
                for j=1:2
                    rangevalue=str2num(configoption(j+1));       
                    Voltage(j)= VoltagerangeA01(rangevalue);
                end
                s=sprintf('[%s,%s]',Voltage{1},Voltage{2});
                set_param([params.TestModel '/RUBYMM416DIO' int2str(ii) '/AO'],'range',s);
                
                % Add the Scope and wire it to the io303 option 
                add_block('xpclib/Misc./Scope (xPC) ',[params.TestModel  '/RUBYMM416DIOScope' int2str(ii)])
                set_param([params.TestModel '/RUBYMM416DIOScope' int2str(ii)],'position',[xpos+offsetx ypos+offsety xpos1+offsetx ypos1+offsety]);
                muxi=next(muxi);
                add_line([params.TestModel],['RUBYMM416DIO',int2str(ii),'/1'],['Mux0','/',int2str(muxi)],'autorouting','on');
                add_block('Simulink/Math Operations/Gain',[params.TestModel  '/Gain' int2str(muxi)]);
                add_block('simulink/Signal Attributes/Data Type Conversion',[params.TestModel  '/Conversion' int2str(muxi)]);    
                set_param([params.TestModel '/Conversion' int2str(muxi)],'position',[xpos+35 ypos+40 xpos+60 ypos+60]);
                set_param([params.TestModel '/Gain' int2str(muxi)],'position',[xpos-10 ypos+40 xpos+10 ypos+60]);
                set_param([params.TestModel '/Gain' int2str(muxi)],'Gain',['[303;',tempbase,']']);
                add_block('simulink/Signal Routing/Mux',[params.TestModel '/Mux' int2str(muxi)])
                set_param([params.TestModel '/Mux' int2str(muxi)],'position',[xpos+95 ypos+40 xpos+100 ypos+60]);
                
                 add_line([params.TestModel],['Mux',int2str(muxi),'/1'],['RUBYMM416DIOScope',int2str(ii),'/1'],'autorouting','on');
                 add_line([params.TestModel],['RUBYMM416DIO',int2str(ii),'/2'],['Gain',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['RUBYMM416DIO',int2str(ii),'/1'],['Conversion',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['Gain',int2str(muxi),'/1'],['Mux',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['Conversion',int2str(muxi),'/1'],['Mux',int2str(muxi),'/2'],'autorouting','on');
                [xpos,ypos,xpos1,ypos1]=incrementpos(xpos,ypos,xpos1,ypos1);  
                
                
                close_system('io303');
            case 'IO304'
                load_system('io304');
                base=ModelStruct(ii).addresses;
                
                % add the io304 option and sett the parameters
                add_block('io304/ONYXMMDIO',[params.TestModel '/ONYXMMDIO' int2str(ii)]);
                set_param([params.TestModel '/ONYXMMDIO' int2str(ii)],'position',[xpos-75 ypos xpos1-75 ypos1]);
                set_param([params.TestModel '/ONYXMMDIO' int2str(ii) '/DO'],'baseaddress',base);
                set_param([params.TestModel '/ONYXMMDIO' int2str(ii) '/DI'],'baseaddress',base);
               tempbase=base(3:end); %get the base address info
                
                % add scope and wire it to the io403 option
                add_block('xpclib/Misc./Scope (xPC) ',[params.TestModel  '/ONYXMMDIOScope' int2str(ii)])
                set_param([params.TestModel '/ONYXMMDIOScope' int2str(ii)],'position',[xpos+offsetx ypos+offsety xpos1+offsetx ypos1+offsety]);
              
                muxi=next(muxi);
                add_line([params.TestModel],['ONYXMMDIO',int2str(ii),'/1'],['Mux0','/',int2str(muxi)],'autorouting','on');
                add_block('Simulink/Math Operations/Gain',[params.TestModel  '/Gain' int2str(muxi)])
                add_block('simulink/Signal Attributes/Data Type Conversion',[params.TestModel  '/Conversion' int2str(muxi)]);    
                set_param([params.TestModel '/Conversion' int2str(muxi)],'position',[xpos+35 ypos+40 xpos+60 ypos+60]);
                set_param([params.TestModel '/Gain' int2str(muxi)],'position',[xpos-10 ypos+40 xpos+10 ypos+60]);
                set_param([params.TestModel '/Gain' int2str(muxi)],'Gain',['[304;',tempbase,']']);
                add_block('simulink/Signal Routing/Mux',[params.TestModel '/Mux' int2str(muxi)])
                set_param([params.TestModel '/Mux' int2str(muxi)],'position',[xpos+95 ypos+40 xpos+100 ypos+60]);
                
                 add_line([params.TestModel],['Mux',int2str(muxi),'/1'],['ONYXMMDIOScope',int2str(ii),'/1'],'autorouting','on');
                 add_line([params.TestModel],['ONYXMMDIO',int2str(ii),'/2'],['Gain',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['ONYXMMDIO',int2str(ii),'/1'],['Conversion',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['Gain',int2str(muxi),'/1'],['Mux',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['Conversion',int2str(muxi),'/1'],['Mux',int2str(muxi),'/2'],'autorouting','on');
                 
                [xpos,ypos,xpos1,ypos1]=incrementpos(xpos,ypos,xpos1,ypos1);  
                
                close_system('io304');
            case 'IO305'
                load_system('io305');
                base=ModelStruct(ii).addresses;
                % add the io305 option and set the parameters
                add_block('io305/QUARTZDIO',[params.TestModel '/QUARTZDIO' int2str(ii)]);
                set_param([params.TestModel '/QUARTZDIO' int2str(ii)],'position',[xpos-75 ypos xpos1-75 ypos1]);  
                set_param([params.TestModel '/QUARTZDIO' int2str(ii) '/DO'],'baseAddressIn',base);
                set_param([params.TestModel '/QUARTZDIO' int2str(ii) '/DI'],'baseAddressIn',base);
                tempbase=base(3:end); %get the base address info
                
                % add the scope
                add_block('xpclib/Misc./Scope (xPC) ',[params.TestModel  '/QUARTZDIOScope' int2str(ii)])
                set_param([params.TestModel '/QUARTZDIOScope' int2str(ii)],'position',[xpos+offsetx ypos+offsety xpos1+offsetx ypos1+offsety]);
        
                muxi=next(muxi);
                add_line([params.TestModel],['QUARTZDIO',int2str(ii),'/1'],['Mux0','/',int2str(muxi)],'autorouting','on');
                add_block('Simulink/Math Operations/Gain',[params.TestModel  '/Gain' int2str(muxi)])
                set_param([params.TestModel '/Gain' int2str(muxi)],'Gain',['[305;',tempbase,']']);

                set_param([params.TestModel '/Gain' int2str(muxi)],'position',[xpos-10 ypos+40 xpos+10 ypos+60]);
                add_block('simulink/Signal Attributes/Data Type Conversion',[params.TestModel  '/Conversion' int2str(muxi)]);    
                set_param([params.TestModel '/Conversion' int2str(muxi)],'position',[xpos+35 ypos+40 xpos+60 ypos+60]);
                add_block('simulink/Signal Routing/Mux',[params.TestModel '/Mux' int2str(muxi)])
                set_param([params.TestModel '/Mux' int2str(muxi)],'position',[xpos+95 ypos+40 xpos+100 ypos+60]);
                
                 add_line([params.TestModel],['Mux',int2str(muxi),'/1'],['QUARTZDIOScope',int2str(ii),'/1'],'autorouting','on');
                 add_line([params.TestModel],['QUARTZDIO',int2str(ii),'/2'],['Gain',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['QUARTZDIO',int2str(ii),'/1'],['Conversion',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['Gain',int2str(muxi),'/1'],['Mux',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['Conversion',int2str(muxi),'/1'],['Mux',int2str(muxi),'/2'],'autorouting','on');
                 
                [xpos,ypos,xpos1,ypos1]=incrementpos(xpos,ypos,xpos1,ypos1);  
                close_system('io305');
            case 'IO306'
                
                load_system('io306');
                base=ModelStruct(ii).addresses;
                % add the io305 option and set the parameters
                add_block('io306/RTD6814',[params.TestModel '/RTD6814' int2str(ii)]);
                set_param([params.TestModel '/RTD6814' int2str(ii)],'position',[xpos-75 ypos xpos1-75 ypos1]);  
                set_param([params.TestModel '/RTD6814' int2str(ii) '/DO'],'baseHex',base);
                set_param([params.TestModel '/RTD6814' int2str(ii) '/ENC'],'baseHex',base);
                set_param([params.TestModel '/RTD6814' int2str(ii) '/DO1'],'baseHex',base);
                set_param([params.TestModel '/RTD6814' int2str(ii) '/ENC1'],'baseHex',base);
                set_param([params.TestModel '/RTD6814' int2str(ii) '/DO2'],'baseHex',base);
                set_param([params.TestModel '/RTD6814' int2str(ii) '/ENC2'],'baseHex',base);
                
                tempbase=base(3:end); %get the base address info
                
                % add the scope
                add_block('xpclib/Misc./Scope (xPC) ',[params.TestModel  '/RTD6814Scope' int2str(ii)])
                set_param([params.TestModel '/RTD6814Scope' int2str(ii)],'position',[xpos+offsetx ypos+offsety xpos1+offsetx ypos1+offsety]);
                muxi=next(muxi);
                add_line([params.TestModel],['RTD6814',int2str(ii),'/1'],['Mux0','/',int2str(muxi)],'autorouting','on');
                add_block('Simulink/Math Operations/Gain',[params.TestModel  '/Gain' int2str(muxi)])
                set_param([params.TestModel '/Gain' int2str(muxi)],'Gain',['[306;',tempbase,']']);

                set_param([params.TestModel '/Gain' int2str(muxi)],'position',[xpos-10 ypos+40 xpos+10 ypos+60]);
                add_block('simulink/Signal Attributes/Data Type Conversion',[params.TestModel  '/Conversion' int2str(muxi)]);    
                set_param([params.TestModel '/Conversion' int2str(muxi)],'position',[xpos+35 ypos+40 xpos+60 ypos+60]);
                add_block('simulink/Signal Routing/Mux',[params.TestModel '/Mux' int2str(muxi)])
                set_param([params.TestModel '/Mux' int2str(muxi)],'position',[xpos+95 ypos+40 xpos+100 ypos+60]);
                
                 add_line([params.TestModel],['Mux',int2str(muxi),'/1'],['RTD6814Scope',int2str(ii),'/1'],'autorouting','on');
                 add_line([params.TestModel],['RTD6814',int2str(ii),'/2'],['Gain',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['RTD6814',int2str(ii),'/1'],['Conversion',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['Gain',int2str(muxi),'/1'],['Mux',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['Conversion',int2str(muxi),'/1'],['Mux',int2str(muxi),'/2'],'autorouting','on');
                 
                [xpos,ypos,xpos1,ypos1]=incrementpos(xpos,ypos,xpos1,ypos1);  
                close_system('io306');
                
            case 'IO308'
                load_system('io308');
                base=ModelStruct(ii).addresses;
                cancount=ModelStruct(ii).canoption;
                if (isempty(ModelStruct(ii).configoption))
                    memorybase='0xd0000';
                    cancount=1;
                else
                    memorybase=ModelStruct(ii).configoption;
                end
                
                add_block('io308/CANPC104',[params.TestModel '/CANPC104' int2str(ii)]);
                set_param([params.TestModel '/CANPC104' int2str(ii)],'position',[xpos-75 ypos xpos1-75 ypos1]);
                set_param([params.TestModel '/CANPC104' int2str(ii) '/Setup '],'ioBaseAddressL',base);
                set_param([params.TestModel '/CANPC104' int2str(ii) '/Setup '],'board',num2str(cancount));
                set_param([params.TestModel '/CANPC104' int2str(ii) '/Setup '],'memBaseAddressL',memorybase);
                set_param([params.TestModel '/CANPC104' int2str(ii) '/Send '],'board',num2str(cancount));
                set_param([params.TestModel '/CANPC104' int2str(ii) '/Receive '],'board',num2str(cancount));
          
                
                tempbase=base(3:end); %get the base address info
                
                add_block('xpclib/Misc./Scope (xPC) ',[params.TestModel  '/CANPC104Scope' int2str(ii)])
                set_param([params.TestModel '/CANPC104Scope' int2str(ii)],'position',[xpos+offsetx ypos+offsety xpos1+offsetx ypos1+offsety]);
                muxi=next(muxi);
                add_block('Simulink/Math Operations/Gain',[params.TestModel  '/Gain' int2str(muxi)])
                set_param([params.TestModel '/Gain' int2str(muxi)],'Gain',['[308;',tempbase,']']);

                set_param([params.TestModel '/Gain' int2str(muxi)],'position',[xpos-10 ypos+40 xpos+10 ypos+60]);
                add_block('simulink/Signal Attributes/Data Type Conversion',[params.TestModel  '/Conversion' int2str(muxi)]);    
                set_param([params.TestModel '/Conversion' int2str(muxi)],'position',[xpos+35 ypos+40 xpos+60 ypos+60]);
    
                add_block('simulink/Signal Routing/Mux',[params.TestModel '/Mux' int2str(muxi)])
                set_param([params.TestModel '/Mux' int2str(muxi)],'position',[xpos+95 ypos+40 xpos+100 ypos+60]);
                            
                [xpos,ypos,xpos1,ypos1]=incrementpos(xpos,ypos,xpos1,ypos1);   
                
                add_block('simulink/Signal Attributes/Rate Transition',[params.TestModel '/Transition' int2str(ii)]);
                set_param([params.TestModel '/Transition' int2str(ii)],'position',[xpos+offsetx ypos+offsety xpos1+offsetx ypos1+offsety]);
                add_line([params.TestModel],['CANPC104',int2str(ii),'/1'],['Transition',int2str(ii),'/1'],'autorouting','on');
                
                add_line([params.TestModel],['Transition',int2str(ii),'/1'],['Mux0','/',int2str(muxi)],'autorouting','on');
                
                 add_line([params.TestModel],['Mux',int2str(muxi),'/1'],['CANPC104Scope',int2str(ii),'/1'],'autorouting','on');
                 add_line([params.TestModel],['CANPC104',int2str(ii),'/2'],['Gain',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['CANPC104',int2str(ii),'/1'],['Conversion',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['Gain',int2str(muxi),'/1'],['Mux',int2str(muxi),'/1'],'autorouting','on');
                 add_line([params.TestModel],['Conversion',int2str(muxi),'/1'],['Mux',int2str(muxi),'/2'],'autorouting','on');
                 
                setxpcenv('CAN','PC104');
                updatexpcenv('silent');
                close_system('io308');
                
            otherwise
                errmsg = ['Please specify correct Model Type. ',ModelType,' is not a valid option'];
                errordlg(errmsg)
                
        end
    end
    % make sure that we did not exceed the maximum allowable Target Scope
    % number
    
    checknumberofscope(params.TestModel); 
    close_system('xpclib');
    close_system('simulink');
    
end
try
    % Try to simulate the model.
    open_system(params.TestModel);
    success='success';
    sim(params.TestModel);
    
catch
    % Something is wrong
    success='failure';
    disp('There is an error in the model. Please check the base addresses and voltage ranges');
    disp(lasterr)
end
    setxpc;
    
function checknumberofscope(model)
numofscopes=length(find_system(model,'Regexp','on','name','Scope'));
if (numofscopes>10)
    warning('Number of target scopes is more then 10. Please delete extra scopes'); 
end
scopes=find_system(model,'Regexp','on','name','Scope');
for ii=1:numofscopes
    set_param(scopes{ii},'viewmode','Numerical');
    set_param(scopes{ii},'nosamples','3');
end

function [muxinputs,Model]=checkmodel(IModels)

ValidModels=[{'IO301'},{'IO302'},{'IO303'},{'IO304'},{'IO305'},{'IO306'},...
        {'IO308'},{'LED'}];
muxinputs=0;
for ii=1:length(IModels)
    Model{ii}=upper(char(IModels(ii).models));
    if(strmatch('IO301',Model{ii},'exact'))
        muxinputs=muxinputs+2;
    else
       muxinputs=muxinputs+1;
    end
end

for jj=1:length(ValidModels)
    for k=1:length(Model)
        index=strmatch(char(ValidModels(jj)),Model{k},'exact');
    end
    if ~isempty(index)
        break
    end
end

if(length(Model)>1 )
    for ii=1:length(Model)
        if (strcmp(char(Model{ii}),'LED'))
            warning('Incompatible options. The model will be created only with LED blocks')
            Model='LED'
        end
    end
end

if isempty(index)
    errmsg = ['Please specify correct Model. ',char(Model(k)),' is not a valid option'];
    errordlg(errmsg);
end



function baseaddress=checkbaseaddres(ModelStruct);

AcceptableAdresses={'0x200','0x210','0x220','0x230','0x240', ...
                    '0x250', '0x260','0x270', '0x280', '0x290', ...
                    '0x2A0', '0x2B0', '0x2C0', '0x2D0', '0x2E0', ...
                    '0x300', '0x330', '0x340', '0x350',...
                    '0x360', '0x380', '0x390', '0x3A0',...
                    '0x3C0', '0x3E0','0x244','0x248','0x24C'};

totalfind=0;
for k=1:length(ModelStruct)
    found=0;
    for ii=1:length(AcceptableAdresses)
        index=strmatch(char(AcceptableAdresses(ii)),ModelStruct(k).addresses,'exact');
        if(~isempty(index))
            found=1;
            totalfind=totalfind+1;
            ModelStruct(k).addresses;
            break;
        end
    end
    if(~found)
        warndlg(['The specified base address, ' ModelStruct(k).addresses,' is not valid'])
    end
    
end

uniqueaddress={};
for ii=1:length(ModelStruct)
    addresses{ii}=ModelStruct(ii).addresses;
end

% Process if the address info is passed as empty parameter
uniqueaddress=unique(addresses);
if(length(uniqueaddress)~=length(addresses))
    warndlg('Base address clash. Your application may not run');
end


function params=createemptymodel
% Create a valid xpc Model for testing
   params.TestModel='xpctbtst'; 
   params.StopTime='5';
   params.nodownload=1;

    
   try
    bdclose all
    s=get_param(gcs,'name');
    if(strcmp(params.TestModel,s))
        bdclose(params.TestModel)
    end
   catch
    
   end
    new_system(params.TestModel); 
    load_system(params.TestModel);

    h=Simulink.ConfigSet;
    h.name='xpcconfig1';
    attachConfigSet(params.TestModel,h);
    switchTarget(h, 'xpctarget.tlc',[]);
    setActiveConfigSet(params.TestModel,h.name);
    set_param(h,'TemplateMakefile','xpc_default_tmf');
    
    set_param(h,'ExtMode','on');
    set_param(h,'ForceParamTrailComments','off');
    set_param(h,'InlineInvariantSignals','on');
    set_param(h,'InlineParams','off');
    set_param(h,'RL32IRQSourceModifier','Timer');
    set_param(h,'RL32LogBufSizeModifier','100000');
    set_param(h,'RL32LogTETModifier','off');
    set_param(h,'RL32ModeModifier','Real-Time');
    set_param(h,'RL32ObjectName','tg');
    set_param(h,'RTWVerbose','on');
    set_param(h,'RollThreshold','5');
    set_param(h,'ShowEliminatedStatement','on');    
    
   
    set_param(h,'OptimizeBlockIOStorage','off');
    set_param(h,'BufferReuse','off');
    set_param(h,'ParameterPooling','off');
    set_param(h,'BooleanDataType','off');
    set_param(h,'BlockReduction','off');
    set_param(h,'SaveState','off');

    set_param(h,'Solver','FixedStepDiscrete');
    set_param(h,'FixedStep','0.001');
    set_param(h,'StopTime',params.StopTime);
    

function [xpos,ypos,xpos1,ypos1]=incrementpos(xpos,ypos,xpos1,ypos1)
% Adjust the positions of the blocks
incy=100;
xpos=xpos;
xpos1=xpos1; 
% if(xpos>550)
%     xpos=100;
%     xpos1=140;
% else
ypos=ypos+incy;
ypos1=ypos1+incy;



function [ModelStruct]=checkarguments(varargin)
% Check the inputs
% Each cell must have at least two values 

for varind = 1:length(varargin{1})
    
    inputcell = varargin{1}{varind};
    
    inplength = length(inputcell); %number of elements in the input cell
    if (inplength==1 && strcmp('LED',upper(char(inputcell{1}))))
        ModelStruct(varind).models=['LED'];
        ModelStruct(varind).addresses=[];
        return
    end
    if ((inplength ~= 2) & ...
            ((inplength < 2) |  ~isa(inputcell,'cell')))
        errmsg = ['Inputs to xpctgboxtest must be cells at least two elements, or, ' ...
                'It should be {''LED''}' ' See HELP xpctgboxtest'];
        error(errmsg);
        
    else
        
    end
    
end
for varind = 1:length(varargin{1})
    %
    % Check the inputs
    % Each cell must have at least two values
    inputcell = varargin{1}{varind};
    ModelStruct(varind).models=inputcell{1};
    if (~exist('k'))
        k=1;
    else
        k=k+1;
    end
    
    if(strcmp('IO308',upper(char(inputcell{1}))))
         ModelStruct(varind).canoption=k;
         ModelStruct(varind).configoption=[];
     end
        
    ModelStruct(varind).addresses=inputcell{2};
    if length(inputcell)==3
        ModelStruct(varind).configoption=inputcell{3};
    end
end
function success=checkconfigoption(model,configoption)
success=0;
switch model
    
    case 'IO301'
        if length(configoption)~=3 
            error('wrong config option');
            return
        end
        
        rangevalue=str2num(configoption(2));
        
        if ~(rangevalue>0 && rangevalue<4)
            error('wrong config option');
        end    
        
        rangevalue=str2num(configoption(3));
        
        if ~(rangevalue>0 && rangevalue<5)
            error('wrong config option');
            
        end    
        
        success=1;
        
    case 'IO302'
        if length(configoption)~=3
            error('wrong config option');
            return
        end
        
        rangevalue=str2num(configoption(2));
        
        if ~(rangevalue>0 && rangevalue<7)
            error('wrong config option');
        end    
        
        rangevalue=str2num(configoption(3));
        
        if ~(rangevalue>0 && rangevalue<7)
            error('wrong config option');
            
        end    
        success=1;
    case 'IO303'
        if length(configoption)~=5
            error('wrong config option');
            return
        end
        
        for ii=2:5
            rangevalue=str2num(configoption(ii));
             if ~(rangevalue>0 && rangevalue<4)
                error('wrong config option');
            end    
        end
        success=1;
    otherwise
end

function a=next(a)
a=a+1;

function  setxpc
modify=0;
props=getxpcenv('HostTargetComm','TcpIpTargetDriver','TargetScope');
%driver=getxpcenv('TcpIpTargetDriver');
%scope=getxpcenv('TargetScope');
if(~strcmp('TcpIp',props{1}))
    s=sprintf('Your xPC Target Communication setting has been changed from %s to TCP/IP',props{1});
    disp(s);
    modify=1;
end
if(~strcmp('I82559',props{2}))
    s=sprintf('Your xPC Target Network Driver setting has been changed from %s to I82559',props{2});
    disp(s);
    modify=1;
end
if(~strcmp('Enabled',props{3}))
    s=sprintf('Your xPC Target Scope setting has been changed from %s to Enabled',props{3});
    disp(s);
    modify=1;
end
% See if it is read only, otherwise go ahead and change it.
s=['attrib ', xpcenvdata];
[errorhappens,attrib]=dos(s);
if ~((errorhappens)| isempty(strfind(attrib,'A    R ')))
    modify=0
end
if(modify)
setxpcenv('HostTargetComm','TCP');
setxpcenv('TcpIpTargetDriver','I82559');
setxpcenv('TargetScope','Enabled');
updatexpcenv;
end











