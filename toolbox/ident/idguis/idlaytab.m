function name=idlaytab(arg,number)
%IDLAYTAB Handles closing of ident, and the layout values.
%   The argument ARG takes the following values:
%   'figname' : Returns the name of figure number NUMBER
%   'save': Saving the layout-info in a variable XIDlayout on a file
%          idprefs
%   'savepf': Saving the preferences in the variables XIDplotprefs and
%             XIDstyleprefs on a file idprefs.
%   'def': Invoking default values for the layout and preferences.

%   L. Ljung 4-4-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.17.4.1 $ $Date: 2004/04/10 23:19:26 $


sstat = get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
set(0,'showhiddenhandles',sstat)

XID = get(Xsum,'Userdata');
if strcmp(arg,'save')
    iduistat('Saving layout info from the windows...')
end
if strcmp(arg,'savepf')
    iduistat('Saving plot preferences from the windows...')
end

figure_names=str2mat(...
'Time Plot',...                         %1
'Frequency Function',...                %2
'Model Output',...                      %3
'Zeros and Poles',...                   %4
'Transient Response',...                %5
'Residual Analysis',...                 %6
'Noise Spectrum',...                    %7
'Data/model Information',...            %8
'ARX Model Structure Selection');       %9

figure_names=str2mat(figure_names,...
'Model Order Selection',...             %10
'Choice of N4Horizons',...              %11
'',...                                  %12
'Output and Input Spectra',...          %13
'Select Range',...                      %14
'Filter',...                            %15
'ident: Untitled',...                   %16
'Import Model Object',...               %17
'Import Iddata Object');                %18

figure_names=str2mat(figure_names,...
'Import Data',...                       %19
'Parametric Models',...                 %20
'Order Editor',...                      %21
'Iteration Control',...                 %22
'Set Options 1',...                     %23
'Set Options 2',...                     %24
'Set Options 3',...                     %25
'Set Options 4',...                     %26
'Set Axis Scaling');                    %27

figure_names=str2mat(figure_names,...
'Select Channels',...                   %28
'Set Confidence',...                    %29
'',...                                  %30 %extra  boards
'Interactive Demo of ident',...         %31
'Correlation Model',...                 %32
'Spectral Model',...                    %33
'Trash',...                             %34
'Select Experiment',...                 %35
'Merge Experiments',...                 %36
'Process Models',...                    %37
'NLARX Cross Sections',...              %38
'Transform Data',...                    %39
'Frequency Function',...                %40
'Resample',...                          %41
'Estimation Focus');                    %42

if strcmp(arg,'figname')
   name=deblank(figure_names(number,:));
elseif strcmp(arg,'save')
   if isempty(XID.laypath)
      errordlg([...
  'No directory where to store the layout information has been specified. ',...
  'First type HELP MIDPREFS in the command window, and select a directory ',...
  'using the m-file midprefs, before saving the layout again.'],'Error Dialog','modal');
      return
   end
   if isempty(XID.layout)
      XID.layout=zeros(35,4);
   end

   figures=get(0,'children');
   for kf=figures(:)'
     eval('tag=get(kf,''tag'');','tag=[];');
     if length(tag)>4
      if tag(1:4)=='sitb'
           number=eval(tag(5:length(tag)));
           XID.layout(number,:)=get(kf,'pos');
       end
     end
    end
    iduistat(['Layout info saved. '])
    set(Xsum,'UserData',XID);
   idlaytab('save_file');
elseif strcmp(arg,'savepf')
    pd=zeros(12,15);
    for kw=[1,14]
       usd=get(XID.plotw(kw,2),'userdata');
       pd(12,kw)=eval(usd);
    end
    for kw=[2,7,13,15]
       usd=get(XID.plotw(kw,2),'userdata');
       pd(2,kw)=eval(usd(1,:));
       pd(3,kw)=eval(usd(2,:));
       pd(1,kw)=eval(usd(3,:));
       if kw>10,pd(11,kw)=eval(usd(5,:));end
    end
    usd=get(XID.plotw(3,2),'userdata');
    pd(4,3)=eval(usd(1,:));
    pd(5,3)=eval(usd(2,:));
    pd(6,3)=eval(usd(4,:));
    usd=get(XID.plotw(5,2),'userdata');
    pd(8,5)=eval(usd(1,:));
    pd(9,5)=eval(usd(2,:));
    pd(7,5)=eval(usd(3,:));
    usd=get(XID.plotw(6,2),'userdata');
    pd(10,6)=eval(usd(1,:));
    XID.plotprefs=pd;

    if isempty(XID.styleprefs),XID.styleprefs=idlayout('figdefs');end
    wins=[1:7,9,10,13,14,15];
    for kw=wins
      if iduiwok(kw)
        ch=findobj(XID.plotw(kw,1),'tag','confonoff');
        if ~isempty(ch),XID.styleprefs(5,kw)=strcmp(get(ch,'checked'),'on');end
        ch=findobj(XID.plotw(kw,1),'tag','grid');
        if ~isempty(ch),XID.styleprefs(4,kw)=strcmp(get(ch,'checked'),'on');end
        ch=findobj(XID.plotw(kw,1),'tag','zoom');
        if ~isempty(ch),XID.styleprefs(6,kw)=strcmp(get(ch,'checked'),'on');end
        ch=findobj(XID.plotw(kw,1),'tag','solls');
        if ~isempty(ch),XID.styleprefs(2,kw)=strcmp(get(ch,'checked'),'on');end
        ch=findobj(XID.plotw(kw,1),'tag','xnormal');
        if ~isempty(ch),XID.styleprefs(1,kw)=strcmp(get(ch,'checked'),'on');end
      end
    end
set(Xsum,'UserData',XID);
    idlaytab('save_file')
elseif strcmp(arg,'def')
  XID.layout=[];XID.plotprefs=[]; XID.styleprefs=[];
   pd=idlayout('plotdefs');pd=pd(:);
   pd=pd*ones(1,15);
set(XID.plotw(1,2),'userdata',int2str(pd(12,1)));
set(XID.plotw(14,2),'userdata',int2str(pd(12,14)));
set(XID.plotw(2,2),'UserData',...
     str2mat(int2str(pd(2,2)),int2str(pd(3,2)),int2str(pd(1,2)),'[]'));
set(XID.plotw(3,2),'UserData',...
     str2mat(int2str(pd(4,3)),int2str(pd(5,3)),'[]',int2str(pd(6,3))));
set(XID.plotw(5,2),'UserData',...
     str2mat(int2str(pd(8,5)),num2str(pd(9,5)),int2str(pd(7,5))));
set(XID.plotw(6,2),'UserData',num2str(pd(10,6)));
set(XID.plotw(7,2),'UserData',...
     str2mat(int2str(pd(2,7)),int2str(pd(3,7)),int2str(pd(1,7)),'[]'));
set(XID.plotw(13,2),'userdata',...
     str2mat(int2str(pd(2,13)),int2str(pd(3,13)),...
             int2str(pd(1,13)),'[]',int2str(pd(11,13))));
set(XID.plotw(15,2),'userdata',...
     str2mat(int2str(pd(2,15)),int2str(pd(3,15)),int2str(pd(1,15)),'[]',...
            int2str(pd(11,15))));
%   for kwin=1:15
%       if iduiwok(kwin),iduiclpw(kwin);end
%   end

  str=...
   ['Windows that are created from now on will be given default sizes',...
   ' and style and plot preferences. Already created ones are not affected.',...
   ' You can Quit windows using the window manager and open them again',...
   ' for default values.'];
helpdlg(str,'Default Window Sizes');
 set(Xsum,'UserData',XID);

  idlaytab('save_file');
 elseif strcmp(arg,'save_file')
   XID = get(Xsum,'UserData');
   if isempty(XID.laypath)
      return
   else
      err=0;
      XIDlaypath = XID.laypath;
      XIDsessions = XID.sessions;
      XIDlayout = XID.layout;
      XIDplotprefs = XID.plotprefs;
      XIDstyleprefs = XID.styleprefs;
    eval(['save ',XID.laypath,...
        'idprefs.mat XIDlaypath XIDsessions XIDlayout ',...
        'XIDplotprefs XIDstyleprefs'],'err=1;')
    if err,
       iduistat('Saving start-up info failed. Type HELP MIDPREFS for your options')
    else
       iduistat([' ',XID.laypath,'idprefs.mat saved.'],1);
    end
   end

end % if save
