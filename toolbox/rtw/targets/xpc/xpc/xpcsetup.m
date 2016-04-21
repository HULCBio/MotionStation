function xpcsetup(flag,flag1)

% XPCSETUP - xPC Target Environment GUI
%    XPCSETUP opens the xPC Target Environment window which allows you
%    to set and update the xPC Target environment as well as to create
%    xPC Target Boot-Floppy disks.
%
%    Specific to xPC TargetBox
%    XPCSETUP('xpctargetbox') opens the xPC Target Environment window 
%    specific to xPC TargetBox which allows you to set and update the
%    xPC Target environment as well as select the Boot mode.

%    See also SETXPCENV, GETXPCENV, UPDATEXPCENV, XPCBOOTDISK

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.22.6.3 $ $Date: 2004/04/08 21:05:12 $


set(0,'ShowHiddenHandles','on');
h_main=get(0, 'Children');
opened=strmatch('xPC Target Setup', get(h_main, 'Name'));
set(0,'ShowHiddenHandles','off');

% Initialize this (we use it later)
tcpipdriverlist = {'NE2000','SMC91C9X', 'I82559','RTLANCE'};

if nargin == 0
    flag = 0;
    isflagBox=0;
end
if nargin > 0
    if ~isnumeric(flag)
        isflagBox= strcmpi(flag,'xpctargetbox') | strcmpi(flag,'box');
        if ~isflagBox
            error(['''',flag,'''',' is not a valid argument. Use ''box'' or ''xpctargetbox'' argument to run the xpc TargetBox Setup.'])
        end
    else
        isflagBox=0;
    end
end
    
%execute without arg and with arg for targetbox only
if (isempty(opened)) & ((nargin == 0) | (nargin == 1 & isflagBox))
  xpcinit;
  load(xpcenvdata);

  set(0,'ShowHiddenHandles','on');

  hnew=xpcsetupfig;
  setup.figure=findobj(hnew,'Tag','setupfigure');

  setup.menuload=findobj(hnew,'Tag','menuload');
  setup.menusave=findobj(hnew,'Tag','menusave');
  setup.menuclose=findobj(hnew,'Tag','menuclose');

  setup.pb_update=findobj(hnew,'Tag','pb_update');
  setup.pb_revert=findobj(hnew,'Tag','pb_revert');
  setup.pb_close=findobj(hnew,'Tag','pb_close');
  setup.pb_bootdisk=findobj(hnew,'Tag','pb_bootdisk');

  setup.txt_rlver=findobj(hnew,'Tag','txt_rlver');
  setup.txt_rlpath=findobj(hnew,'Tag','txt_rlpath');

  setup.txt_xpctgstr=findobj(hnew,'Tag','xpcTargetType');
  setup.txt_EmbeddedOpt=findobj(hnew,'Tag','xPCTgEmbeddedOpt');
  
  setup.pop_compiler=findobj(hnew,'Tag','pop_compiler');
  setup.ed_wccompilerpath=findobj(hnew,'Tag','ed_wccompilerpath');
  setup.pop_targetramsizemb=findobj(hnew,'Tag','pop_targetramsizemb');
  setup.ed_targetramsizemb=findobj(hnew,'Tag','ed_targetramsizemb');
  setup.pop_maxmodelsize=findobj(hnew,'Tag','pop_maxmodelsize');
  setup.pop_systemfontsize=findobj(hnew,'Tag','pop_systemfontsize');
  setup.pop_canlibrary=findobj(hnew,'Tag','pop_canlibrary');
  setup.pop_hosttargetcomm=findobj(hnew,'Tag','pop_hosttargetcomm');

  setup.pop_rs232hostport=findobj(hnew,'Tag','pop_rs232hostport');
  setup.pop_rs232baudrate=findobj(hnew,'Tag','pop_rs232baudrate');
  setup.ed_tcpiptargetaddress=findobj(hnew,'Tag','ed_tcpiptargetaddress');
  setup.ed_tcpiptargetport=findobj(hnew,'Tag','ed_tcpiptargetport');
  setup.ed_tcpipsubnetmask=findobj(hnew,'Tag','ed_tcpipsubnetmask');
  setup.ed_tcpipgateway=findobj(hnew,'Tag','ed_tcpipgateway');
  setup.pop_tcpiptargetdriver=findobj(hnew,'Tag','pop_tcpiptargetdriver');
  setup.pop_tcpiptargetbustype=findobj(hnew,'Tag','pop_tcpiptargetbustype');
  setup.ed_tcpiptargetisamemport=findobj(hnew,'Tag','ed_tcpiptargetisamemport');
  setup.pop_tcpiptargetisairq=findobj(hnew,'Tag','pop_tcpiptargetisairq');

  setup.pop_targetscope=findobj(hnew,'Tag','pop_targetscope');
  setup.pop_targetmouse=findobj(hnew,'Tag','pop_targetmouse');
  setup.pop_targetboot=findobj(hnew,'Tag','pop_targetboot');

  scrsize=get(0,'ScreenSize');
  set(setup.figure,'Position',[(scrsize(3)-50)*0.25,(scrsize(4)-50)*0.25,620,460],'Closerequestfcn','xpcsetup(-7,1)');
  if scrsize(3)==640
    set(setup.figure,'Position',[10,10,610,450],'Closerequestfcn','xpcsetup(-7,1)');
  end;

  set(setup.menuload,'CallBack','xpcsetup(-8)');
  set(setup.menusave,'CallBack','xpcsetup(-9)');
  set(setup.menuclose,'CallBack','xpcsetup(-7,0)');

  set(setup.pb_update,'CallBack','xpcsetup(-1,1)','Enable','off');
  set(setup.pb_revert,'CallBack','xpcsetup(-6)','Enable','off');
  set(setup.pb_close,'CallBack','xpcsetup(-7,0)');
  set(setup.pb_bootdisk,'CallBack','xpcsetup(-10)');

  set(setup.pop_compiler,'CallBack','xpcsetup(-100)');
  set(setup.ed_wccompilerpath,'CallBack','xpcsetup(-101)');
  set(setup.pop_targetramsizemb,'CallBack','xpcsetup(-102)');
  set(setup.ed_targetramsizemb,'CallBack','xpcsetup(-103)');
  set(setup.pop_maxmodelsize,'CallBack','xpcsetup(-104)');
  set(setup.pop_systemfontsize,'CallBack','xpcsetup(-105)');
  set(setup.pop_canlibrary,'CallBack','xpcsetup(-106)');
  set(setup.pop_hosttargetcomm,'CallBack','xpcsetup(-107)');

  set(setup.pop_rs232hostport,'CallBack','xpcsetup(-108)');
  set(setup.pop_rs232baudrate,'CallBack','xpcsetup(-109)');
  set(setup.ed_tcpiptargetaddress,'CallBack','xpcsetup(-110)');
  set(setup.ed_tcpiptargetport,'CallBack','xpcsetup(-111)');
  set(setup.ed_tcpipsubnetmask,'CallBack','xpcsetup(-112)');
  set(setup.ed_tcpipgateway,'CallBack','xpcsetup(-113)');
  set(setup.pop_tcpiptargetdriver,'CallBack','xpcsetup(-114)');
  set(setup.pop_tcpiptargetbustype,'CallBack','xpcsetup(-115)');
  set(setup.ed_tcpiptargetisamemport,'CallBack','xpcsetup(-116)');
  set(setup.pop_tcpiptargetisairq,'CallBack','xpcsetup(-117)');

  set(setup.pop_targetscope,'CallBack','xpcsetup(-118)');
  set(setup.pop_targetmouse,'CallBack','xpcsetup(-119)');
  set(setup.pop_targetboot,'CallBack','xpcsetup(-120)');

  setup=set_actpropval(setup,actpropval,newpropval);

  set(hnew,'UserData',setup,'Visible','on');
  %end
else

  set(0,'ShowHiddenHandles','on');
  setup=get(gcf,'UserData');

  if nargin==0 | isflagBox

    figure(h_main(opened));

    %--------------------------------------------------------------------------------


  elseif flag==-100

    compiler=get(setup.pop_compiler,'Value');
    if compiler==1
      str='Watcom';
    else
      str='VisualC';
    end
    setxpcenv('CCompiler',str);

  elseif flag==-101

    wccompilerpath=deblank(get(setup.ed_wccompilerpath,'String'));
    if ~exist(wccompilerpath,'dir')
      load(xpcenvdata);
      errordlg('invalid property value for property CompilerPath: specified directory does not exist');
      set(setup.ed_wccompilerpath,'String',actpropval{4});
    else
      setxpcenv('CompilerPath',wccompilerpath);
    end;

  elseif flag==-102

    targetramsizemb=get(setup.pop_targetramsizemb,'Value');
    if targetramsizemb==1
      str='Auto';
      setxpcenv('TargetRAMSizeMB',str);
      set(setup.ed_targetramsizemb,'Enable','off');
    else
      set(setup.ed_targetramsizemb,'Enable','on');
    end;

  elseif flag==-103

    str=get(setup.ed_targetramsizemb,'String');
    if (str2num(str)<0)
      errordlg('TargetRAMSizeMB must be a positive value');
      set(setup.ed_targetramsizemb,'String','');
      set(setup.ed_targetramsizemb,'Enable','off');
      set(setup.pop_targetramsizemb,'Value',1);
      setxpcenv('TargetRAMSizeMB','Auto');
    else
      setxpcenv('TargetRAMSizeMB',str);
    end;

  elseif flag==-104

    maxmodelsize=get(setup.pop_maxmodelsize,'Value');
    if maxmodelsize==1
      str='1MB';
    elseif maxmodelsize==2
      str='4MB';
    elseif maxmodelsize==3
      str='16MB';
    end;
    setxpcenv('MaxModelSize',str);

  elseif flag==-105

    systemfontsize=get(setup.pop_systemfontsize,'Value');
    if systemfontsize==1
      str='Small';
    else
      str='Large';
    end;
    setxpcenv('SystemFontSize',str);

  elseif flag==-106

    canlibrary=get(setup.pop_canlibrary,'Value');
    if canlibrary==1
      str='None';
    elseif canlibrary==2
      str='200 ISA';
    elseif canlibrary==3
      str='527 ISA';
    elseif canlibrary==4
      str='1000 PCI';
    elseif canlibrary==5
      str='1000 MB PCI';
    elseif canlibrary==6
      str='PC104';
    end;
    setxpcenv('CANLibrary',str);

  elseif flag==-107

    hosttargetcomm=get(setup.pop_hosttargetcomm,'Value');
    if hosttargetcomm==1
      str='RS232';
    elseif hosttargetcomm==2
      str='TcpIp';
    end;
    setxpcenv('HostTargetComm',str);
    if hosttargetcomm==1
      set(setup.pop_rs232hostport,'Enable','on');
      set(setup.pop_rs232baudrate,'Enable','on');
      set(setup.ed_tcpiptargetaddress,'Enable','off');
      set(setup.ed_tcpiptargetport,'Enable','off');
      set(setup.ed_tcpipsubnetmask,'Enable','off');
      set(setup.ed_tcpipgateway,'Enable','off');
      set(setup.pop_tcpiptargetdriver,'Enable','off');
      set(setup.pop_tcpiptargetbustype,'Enable','off');
    else
      set(setup.pop_rs232hostport,'Enable','off');
      set(setup.pop_rs232baudrate,'Enable','off');
      set(setup.ed_tcpiptargetaddress,'Enable','on');
      set(setup.ed_tcpiptargetport,'Enable','on');
      set(setup.ed_tcpipsubnetmask,'Enable','on');
      set(setup.ed_tcpipgateway,'Enable','on');
      if ~strcmp(get(h_main, 'Name'),'xPC TargetBox Setup');
         set(setup.pop_tcpiptargetdriver,'Enable','on');
         set(setup.pop_tcpiptargetbustype,'Enable','on');
     end 
      
    end
    set(setup.ed_tcpiptargetisamemport,'Enable','off');
    set(setup.pop_tcpiptargetisairq,'Enable','off');
    if get(setup.pop_tcpiptargetbustype,'Value')==1 & hosttargetcomm==2
      set(setup.ed_tcpiptargetisamemport,'Enable','on');
      set(setup.pop_tcpiptargetisairq,'Enable','on');
    end

  elseif flag==-108

    rs232hostport=get(setup.pop_rs232hostport,'Value');
    if rs232hostport==1
      str='COM1';
    elseif rs232hostport==2
      str='COM2';
    end;
    setxpcenv('RS232HostPort',str);

  elseif flag==-109

    rs232baudrate=get(setup.pop_rs232baudrate,'Value');
    switch rs232baudrate
     case 1
      str='115200';
     case 2
      str='57600';
     case 3
      str='38400';
     case 4
      str='19200';
     case 5
      str='9600';
     case 6
      str='4800';
     case 7
      str='2400';
     case 8
      str='1200';
    end
    setxpcenv('RS232Baudrate',str);


  elseif flag==-110

    str=get(setup.ed_tcpiptargetaddress,'String');
    setxpcenv('TcpIpTargetAddress',str);

  elseif flag==-111

    str=get(setup.ed_tcpiptargetport,'String');
    if (str2num(str)<20000)
      load(xpcenvdata);
      errordlg('TcpIpTargetPort must be greater than 20000');
      set(setup.ed_tcpiptargetport,'String',actpropval{15});
    else
      setxpcenv('TcpIpTargetPort',str);
    end;

  elseif flag==-112

    str=get(setup.ed_tcpipsubnetmask,'String');
    setxpcenv('TcpIpSubNetMask',str);

  elseif flag==-113

    str=get(setup.ed_tcpipgateway,'String');
    setxpcenv('TcpIpGateway',str);

  elseif flag==-114

    tcpiptargetdriver=get(setup.pop_tcpiptargetdriver,'Value');
    setxpcenv('TcpIpTargetDriver',tcpipdriverlist{tcpiptargetdriver});

  elseif flag==-115

    tcpiptargetbustype=get(setup.pop_tcpiptargetbustype,'Value');
    if tcpiptargetbustype==1
      str='ISA';
    else
      str='PCI';
    end;
    setxpcenv('TcpIpTargetBusType',str);
    if tcpiptargetbustype==2
      set(setup.ed_tcpiptargetisamemport,'Enable','off');
      set(setup.pop_tcpiptargetisairq,'Enable','off');
    else
      set(setup.ed_tcpiptargetisamemport,'Enable','on');
      set(setup.pop_tcpiptargetisairq,'Enable','on');
    end


  elseif flag==-116

    str=get(setup.ed_tcpiptargetisamemport,'String');
    setxpcenv('TcpIpTargetISAMemPort',str);

  elseif flag==-117

    str=num2str(get(setup.pop_tcpiptargetisairq,'Value')+4);
    setxpcenv('TcpIpTargetISAIRQ',str);

  elseif flag==-118

    targetscope=get(setup.pop_targetscope,'Value');
    if targetscope==1
      str='Disabled';
      set(setup.pop_targetmouse,'Enable','off');
    elseif targetscope==2
      str='Enabled';
      set(setup.pop_targetmouse,'Enable','on');
    end;
    setxpcenv('TargetScope',str);



  elseif flag==-119

    targetmouse=get(setup.pop_targetmouse,'Value');
    if targetmouse==1
      str='None';
    elseif targetmouse==2
      str='PS2';
    elseif targetmouse==3
      str='RS232 COM1';
    elseif targetmouse==4
      str='RS232 COM2';
    end;
    setxpcenv('TargetMouse',str);

  elseif flag==-120

    targetboot=get(setup.pop_targetboot,'Value');
    if targetboot==1
      str='BootFloppy';
      set(setup.pb_bootdisk,'Enable','on');
    elseif targetboot==2
      str='DOSLoader';
      set(setup.pb_bootdisk,'Enable','on');
    elseif targetboot==3
      str='StandAlone';
      set(setup.pb_bootdisk,'Enable','off');
    end;
    setxpcenv('TargetBoot',str);


    %--------------------------------------------------------------------------------

  elseif flag==-1

    updatexpcenv('silent');
    set(setup.pb_update,'Enable','off');
    set(setup.pb_revert,'Enable','off');

    %--------------------------------------------------------------------------------

  elseif flag==-6 %revert

    set(setup.pb_update,'Enable','off');
    set(setup.pb_revert,'Enable','off');
    load(xpcenvdata);
    for i=1:length(actpropval)
      newpropval{i}=[];
    end;
    setup=set_actpropval(setup,actpropval,newpropval);
    save(xpcenvdata,'propname','actpropval','newpropval');

    %--------------------------------------------------------------------------------

  elseif flag==-7 %close figure

    if strcmp('on',get(setup.pb_update,'Enable'))
      question{1}='xPC Target environment has not been updated with the current settings';
      question{2}='';
      question{3}='Do you want to exit?';
      answer=questdlg(question, ...
                      'Environment not updated', ...
                      'Yes','No','Yes');

      switch answer,
       case 'Yes',
        delete(setup.figure);
       case 'No'
        return;
      end % switch
    else
      delete(setup.figure);
    end;

    %--------------------------------------------------------------------------------

  elseif flag==-8 %load settings

    [filename, path] = uigetfile('*.mat', 'Load xPC Target Environment');

    if filename ~= 0
      load([path, filename]);
      load(xpcenvdata);
      for i=2:length(actpropval)
        if strcmp(propval{i},actpropval{i})
          newpropval{i}=[];
        else
          newpropval{i}=propval{i};
        end;
      end;
      setup=set_actpropval(setup,actpropval,newpropval);
      save(xpcenvdata,'propname','actpropval','newpropval');
      uptodate=0;
      for i=1:length(actpropval)
        if ~isempty(newpropval{i})
          uptodate=1;
        end;
      end;
      if ~uptodate
        warndlg('xPC Target environemt is up to date');
      end;
    end;


    %--------------------------------------------------------------------------------

  elseif flag==-9 %save settings

    [filename, path] = uiputfile('*.mat', 'Save xPC Target Environment');

    if filename~=0
      propval=get_actpropval(setup,tcpipdriverlist);
      save([path,filename],'propval');
    end;

    %--------------------------------------------------------------------------------

  elseif flag==-10 %BootDisk

    if strcmp('on',get(setup.pb_update,'Enable'))
      question{1}='xPC Target environment has not been updated with the current settings!';
      question{2}='';
      question{3}='Do you want to create a Boot Floppy Disk?';
      answer=questdlg(question, ...
                      'Environment Not Updated', ...
                      'Yes','No','Yes');

      switch answer,
       case 'Yes',
        if strcmp('on',get(setup.pb_update,'Enable'))
          update=1;
        else
          update=0;
        end;
        set(setup.pb_update,'Enable','off');
        set(setup.pb_revert,'Enable','off');
        set(setup.pb_bootdisk,'Enable','off');
        set(setup.pb_close,'Enable','off');
        xpcbootdisk(1);
        if update
          set(setup.pb_update,'Enable','on');
          set(setup.pb_revert,'Enable','on');
        end;
        set(setup.pb_bootdisk,'Enable','on');
        set(setup.pb_close,'Enable','on');
       case 'No'
        return;
      end % switch
    else
      if strcmp('on',get(setup.pb_update,'Enable'))
        update=1;
      else
        update=0;
      end;
      set(setup.pb_update,'Enable','off');
      set(setup.pb_revert,'Enable','off');
      set(setup.pb_bootdisk,'Enable','off');
      set(setup.pb_close,'Enable','off');
      xpcbootdisk(1);
      if update
        set(setup.pb_update,'Enable','on');
        set(setup.pb_revert,'Enable','on');
      end;
      set(setup.pb_bootdisk,'Enable','on');
      set(setup.pb_close,'Enable','on');
    end;

  end;

end;

if nargin~=0 | isflagBox
  if flag~=-7
    load(xpcenvdata);
    set(setup.pb_update,'Enable','off');
    set(setup.pb_revert,'Enable','off');
    for i=1:length(actpropval)
      if ~isempty(newpropval{i})
        set(setup.pb_update,'Enable','on');
        set(setup.pb_revert,'Enable','on');
      end;
    end;
  end;
end;

set(0,'ShowHiddenHandles','off');

if exist('flag','var')
    if strcmpi(flag,'xpctargetbox') | strcmpi(flag,'box') 
       setuptgbox(setup);
    end
end

%--------------------------------------------------------------------------------

function setup=set_actpropval(setup,actpropval,newpropval)
tcpipdriverlist = evalin('caller','tcpipdriverlist');
update=0;

set(setup.txt_rlver,'String',actpropval{1});
set(setup.txt_rlpath,'String',xpcroot);

if isempty(newpropval{3})
  if strcmp(actpropval{3},'Watcom')
    set(setup.pop_compiler,'Value',1);
  else
    set(setup.pop_compiler,'Value',2);
  end;
else
  if strcmp(newpropval{3},'Watcom')
    set(setup.pop_compiler,'Value',1);
  else
    set(setup.pop_compiler,'Value',2);
  end;
  update=1;
end;

if isempty(newpropval{4})
  set(setup.ed_wccompilerpath,'String',actpropval{4});
else
  set(setup.ed_wccompilerpath,'String',newpropval{4});
  update=1;
end;

if isempty(newpropval{7})
  if strcmp(actpropval{7},'Auto')
    set(setup.pop_targetramsizemb,'Value',1);
    set(setup.ed_targetramsizemb,'String','','Enable','off');
  else
    set(setup.pop_targetramsizemb,'Value',2);
    set(setup.ed_targetramsizemb,'String',actpropval{7},'Enable','on');
  end;
else
  if strcmp(newpropval{7},'Auto')
    set(setup.pop_targetramsizemb,'Value',1);
    set(setup.ed_targetramsizemb,'String','','Enable','off');
  else
    set(setup.pop_targetramsizemb,'Value',2);
    set(setup.ed_targetramsizemb,'String',actpropval{7},'Enable','on');
  end;
  update=1;
end;

if isempty(newpropval{8})
  if strcmp(actpropval{8},'1MB')
    set(setup.pop_maxmodelsize,'Value',1);
  elseif strcmp(actpropval{8},'4MB')
    set(setup.pop_maxmodelsize,'Value',2);
  elseif strcmp(actpropval{8},'16MB')
    set(setup.pop_maxmodelsize,'Value',3);
  end;
else
  if strcmp(newpropval{8},'1MB')
    set(setup.pop_maxmodelsize,'Value',1);
  elseif strcmp(newpropval{8},'4MB')
    set(setup.pop_maxmodelsize,'Value',2);
  elseif strcmp(newpropval{8},'16MB')
    set(setup.pop_maxmodelsize,'Value',3);
  end;
  update=1;
end;

if isempty(newpropval{9})
  if strcmp(actpropval{9},'Small')
    set(setup.pop_systemfontsize,'Value',1);
  else
    set(setup.pop_systemfontsize,'Value',2);
  end;
else
  if strcmp(newpropval{9},'Small')
    set(setup.pop_systemfontsize,'Value',1);
  else
    set(setup.pop_systemfontsize,'Value',2);
  end;
  update=1;
end;

if isempty(newpropval{10})
  if strcmp(actpropval{10},'None')
    set(setup.pop_canlibrary,'Value',1);
  elseif strcmp(actpropval{10},'200 ISA')
    set(setup.pop_canlibrary,'Value',2);
  elseif strcmp(actpropval{10},'527 ISA')
    set(setup.pop_canlibrary,'Value',3);
  elseif strcmp(actpropval{10},'1000 PCI')
    set(setup.pop_canlibrary,'Value',4);
  elseif strcmp(actpropval{10},'1000 MB PCI')
    set(setup.pop_canlibrary,'Value',5);
  elseif strcmp(actpropval{10},'PC104')
    set(setup.pop_canlibrary,'Value',6);
  end;
else
  if strcmp(newpropval{10},'None')
    set(setup.pop_canlibrary,'Value',1);
  elseif strcmp(newpropval{10},'200 ISA')
    set(setup.pop_canlibrary,'Value',2);
  elseif strcmp(newpropval{10},'527 ISA')
    set(setup.pop_canlibrary,'Value',3);
  elseif strcmp(newpropval{10},'1000 PCI')
    set(setup.pop_canlibrary,'Value',4);
  elseif strcmp(newpropval{10},'1000 MB PCI')
    set(setup.pop_canlibrary,'Value',5);
  end;
  update=1;
end;

if isempty(newpropval{11})
  if strcmp(actpropval{11},'RS232')
    set(setup.pop_hosttargetcomm,'Value',1);
  else
    set(setup.pop_hosttargetcomm,'Value',2);
  end;
else
  if strcmp(newpropval{11},'TcpIp')
    set(setup.pop_hosttargetcomm,'Value',1);
  else
    set(setup.pop_hosttargetcomm,'Value',2);
  end;
  update=1;
end;

if isempty(newpropval{12})
  if strcmp(actpropval{12},'COM1')
    set(setup.pop_rs232hostport,'Value',1);
  else
    set(setup.pop_rs232hostport,'Value',2);
  end;
else
  if strcmp(newpropval{12},'COM1')
    set(setup.pop_rs232hostport,'Value',1);
  else
    set(setup.pop_rs232hostport,'Value',2);
  end;
  update=1;
end;
if strcmp(actpropval{11},'RS232')
  set(setup.pop_rs232hostport,'Enable','on');
%  set(setup.pop_rs232baudrate,'Enable','on');
else
  set(setup.pop_rs232hostport,'Enable','off');
  set(setup.pop_rs232baudrate,'Enable','off');
end

if isempty(newpropval{13})
  if strcmp(actpropval{13},'115200')
    set(setup.pop_rs232baudrate,'Value',1);
  elseif strcmp(actpropval{13},'57600')
    set(setup.pop_rs232baudrate,'Value',2);
  elseif strcmp(actpropval{13},'38400')
    set(setup.pop_rs232baudrate,'Value',3);
  elseif strcmp(actpropval{13},'19200')
    set(setup.pop_rs232baudrate,'Value',4);
  elseif strcmp(actpropval{13},'9600')
    set(setup.pop_rs232baudrate,'Value',5);
  elseif strcmp(actpropval{13},'4800')
    set(setup.pop_rs232baudrate,'Value',6);
  elseif strcmp(actpropval{13},'2400')
    set(setup.pop_rs232baudrate,'Value',7);
  elseif strcmp(actpropval{13},'1200')
    set(setup.pop_rs232baudrate,'Value',8);
  end;
else
  if strcmp(newpropval{13},'115200')
    set(setup.pop_rs232baudrate,'Value',1);
  elseif strcmp(newpropval{13},'57600')
    set(setup.pop_rs232baudrate,'Value',2);
  elseif strcmp(newpropval{13},'38400')
    set(setup.pop_rs232baudrate,'Value',3);
  elseif strcmp(newpropval{13},'19200')
    set(setup.pop_rs232baudrate,'Value',4);
  elseif strcmp(newpropval{13},'9600')
    set(setup.pop_rs232baudrate,'Value',5);
  elseif strcmp(newpropval{13},'4800')
    set(setup.pop_rs232baudrate,'Value',6);
  elseif strcmp(newpropval{13},'2400')
    set(setup.pop_rs232baudrate,'Value',7);
  elseif strcmp(newpropval{13},'1200')
    set(setup.pop_rs232baudrate,'Value',8);
  end;
  update=1;
end;

if isempty(newpropval{14})
  set(setup.ed_tcpiptargetaddress,'String',actpropval{14});
else
  set(setup.ed_tcpiptargetaddress,'String',newpropval{14});
  update=1;
end;

if isempty(newpropval{15})
  set(setup.ed_tcpiptargetport,'String',actpropval{15});
else
  set(setup.ed_tcpiptargetport,'String',newpropval{15});
  update=1;
end;

if isempty(newpropval{16})
  set(setup.ed_tcpipsubnetmask,'String',actpropval{16});
else
  set(setup.ed_tcpipsubnetmask,'String',newpropval{16});
  update=1;
end;

if isempty(newpropval{17})
  set(setup.ed_tcpipgateway,'String',actpropval{17});
else
  set(setup.ed_tcpipgateway,'String',newpropval{17});
  update=1;
end;

if isempty(newpropval{18})
  set(setup.pop_tcpiptargetdriver,'Value', ...
                    strmatch(actpropval{18}, tcpipdriverlist, 'exact'));
else
  set(setup.pop_tcpiptargetdriver,'Value', ...
                    strmatch(newpropval{18}, tcpipdriverlist, 'exact'));
  update=1;
end;

if isempty(newpropval{19})
  if strcmp(actpropval{19},'PCI')
    set(setup.pop_tcpiptargetbustype,'Value',2);
  else
    set(setup.pop_tcpiptargetbustype,'Value',1);
  end;
else
  if strcmp(newpropval{19},'PCI')
    set(setup.pop_tcpiptargetbustype,'Value',2);
  else
    set(setup.pop_tcpiptargetbustype,'Value',1);
  end;
  update=1;
end;

if isempty(newpropval{20})
  set(setup.ed_tcpiptargetisamemport,'String',actpropval{20});
else
  set(setup.ed_tcpiptargetisamemport,'String',newpropval{20});
  update=1;
end;

if isempty(newpropval{21})
  set(setup.pop_tcpiptargetisairq,'Value',str2num(actpropval{21})-4);
else
  set(setup.pop_tcpiptargetisairq,'Value',str2num(newpropval{21})-4);
  update=1;
end;

if isempty(newpropval{23})
  if strcmp(actpropval{23},'Disabled')
    set(setup.pop_targetscope,'Value',1);
  else
    set(setup.pop_targetscope,'Value',2);
  end;
else
  if strcmp(newpropval{23},'Disabled')
    set(setup.pop_targetscope,'Value',1);
  else
    set(setup.pop_targetscope,'Value',2);
  end;
  update=1;
end;

if isempty(newpropval{24})
  if strcmp(actpropval{24},'None')
    set(setup.pop_targetmouse,'Value',1);
  elseif strcmp(actpropval{24},'PS2')
    set(setup.pop_targetmouse,'Value',2);
  elseif strcmp(actpropval{24},'RS232 COM1')
    set(setup.pop_targetmouse,'Value',3);
  elseif strcmp(actpropval{24},'RS232 COM2')
    set(setup.pop_targetmouse,'Value',4);
  end;
else
  if strcmp(newpropval{24},'None')
    set(setup.pop_targetmouse,'Value',1);
  elseif strcmp(newpropval{24},'PS2')
    set(setup.pop_targetmouse,'Value',2);
  elseif strcmp(newpropval{24},'RS232 COM1')
    set(setup.pop_targetmouse,'Value',3);
  elseif strcmp(newpropval{24},'RS232 COM2')
    set(setup.pop_targetmouse,'Value',4);
  end;
  update=1;
end;


if isempty(newpropval{25})
  if strcmp(actpropval{25},'BootFloppy')
    set(setup.pop_targetboot,'Value',1);
    set(setup.pb_bootdisk,'Enable','on');
  elseif strcmp(actpropval{25},'DOSLoader')
    set(setup.pop_targetboot,'Value',2);
    set(setup.pb_bootdisk,'Enable','on');
  elseif strcmp(actpropval{25},'StandAlone')
    set(setup.pop_targetboot,'Value',3);
    set(setup.pb_bootdisk,'Enable','off');
  end;
else
  if strcmp(newpropval{24},'BootFloppy')
    set(setup.pop_targetboot,'Value',1);
    set(setup.pb_bootdisk,'Enable','on');
  elseif strcmp(newpropval{24},'DOSLoader')
    set(setup.pop_targetboot,'Value',2);
    set(setup.pb_bootdisk,'Enable','on');
  elseif strcmp(newpropval{24},'StandAlone')
    set(setup.pop_targetboot,'Value',3);
    set(setup.pb_bootdisk,'Enable','off');
  end;
  update=1;
end;

if get(setup.pop_tcpiptargetbustype,'Value')==2
  set(setup.ed_tcpiptargetisamemport,'Enable','off');
  set(setup.pop_tcpiptargetisairq,'Enable','off');
else
  set(setup.ed_tcpiptargetisamemport,'Enable','on');
  set(setup.pop_tcpiptargetisairq,'Enable','on');
end
if get(setup.pop_hosttargetcomm,'Value')==1
  set(setup.ed_tcpiptargetaddress,'Enable','off');
  set(setup.ed_tcpiptargetport,'Enable','off');
  set(setup.ed_tcpipsubnetmask,'Enable','off');
  set(setup.ed_tcpipgateway,'Enable','off');
  set(setup.pop_tcpiptargetdriver,'Enable','off');
  set(setup.pop_tcpiptargetbustype,'Enable','off');
  set(setup.ed_tcpiptargetisamemport,'Enable','off');
  set(setup.pop_tcpiptargetisairq,'Enable','off');
else
  set(setup.ed_tcpiptargetaddress,'Enable','on');
  set(setup.ed_tcpiptargetport,'Enable','on');
  set(setup.ed_tcpipsubnetmask,'Enable','on');
  set(setup.ed_tcpipgateway,'Enable','on');
  set(setup.pop_tcpiptargetdriver,'Enable','on');
  set(setup.pop_tcpiptargetbustype,'Enable','on');
  set(setup.ed_tcpiptargetisamemport,'Enable','on');
  set(setup.pop_tcpiptargetisairq,'Enable','on');
end

if strcmp(actpropval{22},'Disabled')
  set(setup.pop_targetscope,'Enable','on');
  set(setup.pop_targetmouse,'Enable','on');
  set(setup.pop_targetboot,'Enable','off');
else
  set(setup.pop_targetscope,'Enable','on');
  if get(setup.pop_targetscope,'Value')==1
    set(setup.pop_targetmouse,'Enable','off');
  else
    set(setup.pop_targetmouse,'Enable','on');
  end
  set(setup.pop_targetboot,'Enable','on');
end


if update
  set(setup.pb_update,'Enable','on');
  set(setup.pb_revert,'Enable','on');
end;


function actpropval=get_actpropval(setup,tcpipdriverlist)


actpropval{1}=get(setup.txt_rlver,'String');
actpropval{2}=get(setup.txt_rlpath,'String');

compiler=get(setup.pop_compiler,'Value');
if compiler==1
  actpropval{3}='Watcom';
else
  actpropval{3}='VisualC';
end;

actpropval{4}=deblank(get(setup.ed_wccompilerpath,'String'));

targetramsizemb=get(setup.pop_targetramsizemb,'Value');
if targetramsizemb==1
  actpropval{7}='Auto';
else
  actpropval{7}=get(setup.ed_targetramsizemb,'String');
end;

maxmodelsize=get(setup.pop_maxmodelsize,'Value');
if maxmodelsize==1
  actpropval{8}='1MB';
elseif maxmodelsize==2
  actpropval{8}='4MB';
elseif maxmodelsize==2
  actpropval{8}='16MB';
end;

systemfontsize=get(setup.pop_systemfontsize,'Value');
if systemfontsize==1
  actpropval{9}='Small';
elseif systemfontsize==2
  actpropval{9}='Large';
end;

canlibrary=get(setup.pop_canlibrary,'Value');
if canlibrary==1
  actpropval{10}='None';
elseif canlibrary==2
  actpropval{10}='200 ISA';
elseif canlibrary==3
  actpropval{10}='527 ISA';
elseif canlibrary==4
  actpropval{10}='1000 PCI';
elseif canlibrary==5
  actpropval{10}='1000 MB PCI';
elseif canlibrary==6
  actpropval{10}='PC104';
end;

hosttargetcomm=get(setup.pop_hosttargetcomm,'Value');
if hosttargetcomm==1
  actpropval{11}='RS232';
elseif hosttargetcomm==2
  actpropval{11}='TcpIp';
end;

rs232hostport=get(setup.pop_rs232hostport,'Value');
if rs232hostport==1
  actpropval{12}='COM1';
elseif rs232hostport==2
  actpropval{12}='COM2';
end;

rs232baudrate=get(setup.pop_rs232baudrate,'Value');
switch rs232baudrate
 case 1
  actpropval{13}='115200';
 case 2
  actpropval{13}='57600';
 case 3
  actpropval{13}='38400';
 case 4
  actpropval{13}='19200';
 case 5
  actpropval{13}='9600';
 case 6
  actpropval{13}='4800';
 case 7
  actpropval{13}='2400';
 case 8
  actpropval{13}='1200';
end

actpropval{14}=get(setup.ed_tcpiptargetaddress,'String');

actpropval{15}=get(setup.ed_tcpiptargetport,'String');

actpropval{16}=get(setup.ed_tcpipsubnetmask,'String');

actpropval{17}=get(setup.ed_tcpipgateway,'String');

tcpiptargetdriver=get(setup.pop_tcpiptargetdriver,'Value');
actpropval{18} = tcpipdriverlist{tcpiptargetdriver};

tcpiptargetbustype=get(setup.pop_tcpiptargetbustype,'Value');
if tcpiptargetbustype==1
  actpropval{19}='ISA';
else
  actpropval{19}='PCI';
end;

actpropval{20}=get(setup.ed_tcpiptargetisamemport,'String');

actpropval{21}=num2str(get(setup.pop_tcpiptargetisairq,'Value')+4);

targetscope=get(setup.pop_targetscope,'Value');
if targetscope==1
  actpropval{23}='Disabled';
else
  actpropval{23}='Enabled';
end;

targetmouse=get(setup.pop_targetmouse,'Value');
if targetmouse==1
  actpropval{24}='None';
elseif targetmouse==2
  actpropval{24}='PS2';
elseif targetmouse==3
  actpropval{24}='RS232 COM1';
elseif targetmouse==4
  actpropval{24}='RS232 COM2';
end;

targetboot=get(setup.pop_targetboot,'Value');
if targetboot==1
  actpropval{25}='BootFloppy';
elseif targetboot==2
  actpropval{25}='DOSLoader';
elseif targetboot==3
  actpropval{25}='StandAlone';
end;


function setuptgbox(setup)
set(setup.figure,'Name','xPC TargetBox Setup')
set(setup.txt_xpctgstr,'String','xPC TargetBox')
%CanLibrary-----
if get(setup.pop_canlibrary,'Value')==6
    set(setup.pop_canlibrary,'enable','off')
end
%tcpiptargetdriver----
if get(setup.pop_tcpiptargetdriver,'Value')==3
    set(setup.pop_tcpiptargetdriver,'enable','off');
    set(setup.pop_tcpiptargetbustype,'enable','off');
    set(setup.ed_tcpiptargetisamemport,'enable','off')
 set(setup.pop_tcpiptargetisairq,'enable','off');
end     
set(setup.txt_EmbeddedOpt,'String','xPC Target')
set(setup.txt_EmbeddedOpt,'Position',[14.7  123.7500  70.2500   12.7500])
set(setup.txt_EmbeddedOpt,'HorizontalAlignment','center')

%--EOF------