function ident(sessname,pathname)
%IDENT  Starts the Graphical User Interface for the System Identification Toolbox.
%
%   ident   or  ident(SESSION,PATH)
%   
%   IDENT by itself opens the main interface window.
%   SESSION is a SITB session file (typically with extension .sid)
%   PATH is the search path for this file. (Not necessary if on the
%   MATHLABPATH.) When SESSION is specified, the interface opens
%   with this session.
%   
%   When the interface is active, ident(SESSION,PATH) will open the
%   session SESSION.
 
%   L. Ljung 4-4-94
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/05/18 02:29:29 $


 set(0,'showhiddenhandle','on');
Xfake = findobj(get(0,'children'),'flat','tag','sitb16','name','FAKE');
if ~isempty(Xfake)
   close(Xfake);
   end
  XIDmain_win=findobj(get(0,'children'),'flat','tag','sitb16');
set(0,'showhiddenhandle','off');
if isempty(XIDmain_win)
   fprintf('Opening ident .')
   if exist('idprefs.mat')
      load idprefs
      XID.sessions = XIDsessions;
           XID.layout = XIDlayout;    
      try
         XID.laypath = which('idprefs.mat');
         XID.laypath = XID.laypath(1:end-11); 
      catch
         XID.laypath = XIDlaypath;
      end
      try
      XID.plotprefs = XIDplotprefs;
      XID.styleprefs = XIDstyleprefs;
   catch
      XID.plotprefs =[];
      XID.styleprefs = [];
      end
      [nr,nc]=size(XID.sessions);
      if nr<8
         pn1 = which('iddata1.sid'); pn1 = pn1(1:end-11);
         pn2 = which('iddata7.sid'); pn2 = pn2(1:end-11);
         pn3 = which('dryer.sid'); pn3 = pn3(1:end-9);
         pn4 = which('steam.sid'); pn4 = pn4(1:end-9);
         XID.sessions=str2mat('iddata1.sid',pn1,'iddata7.sid',...
            pn2,...
           'dryer.sid',pn3,'steam.sid',pn4);
      end
   else
      XID.laypath=which('startup');
      XID.layout=[];XID.styleprefs=[];XID.plotprefs=[];
       pn1 = which('iddata1.sid'); pn1 = pn1(1:end-11);
         pn2 = which('iddata7.sid'); pn2 = pn2(1:end-11);
         pn3 = which('dryer.sid'); pn3 = pn3(1:end-9);
         pn4 = which('steam.sid'); pn4 = pn4(1:end-9);
         XID.sessions=str2mat('iddata1.sid',pn1,'iddata7.sid',...
            pn2,...
           'dryer.sid',pn3,'steam.sid',pn4);
      err=0;
      lx=length(XID.laypath);
      if lx<10
         err=1; XID.laypath=[];
      else
       XID.laypath=XID.laypath(1:lx-9);
        XIDsessions = XID.sessions;
      XIDlaypath = XID.laypath;
      XIDlayout = XID.layout;
      XIDplotprefs = XID.plotprefs;
      XIDstyleprefs = XID.styleprefs;
       eval(['save ',XIDlaypath,...
           'idprefs.mat XIDlaypath XIDsessions XIDlayout ',...
           'XIDstyleprefs XIDplotprefs'],'err=1;')
       testlay=exist('idprefs.mat');
       if ~testlay&~err,err=1;eval(['delete ',XIDlaypath,'idprefs.mat']);end
      end
      if err==0
          wtext=str2mat('',['Created preference file ',...
               XIDlaypath,'idprefs.mat.'],...
              'Type HELP MIDPREFS if you want to move this file.');
          disp(wtext)
% $$$       else
% $$$          wtext=str2mat('',...
% $$$                'Warning: Could not find idprefs.mat and could not create',...
% $$$                '         PrefDir/idprefs.mat',...
% $$$                ['You may ignore this warning or type HELP',...
% $$$                ' MIDPREFS for your options.']);
% $$$          disp(wtext)
      end
   end
  
   zzz=rand(100,2);
   tic,arx(zzz,[4 4 1]);t=toc;  
   XID.counters(6)=t/2;
    eval('sumboard(XID);')
   eval('idmwwb(1);iduidrop;')
else 
   figure(XIDmain_win)
end
   if nargin>0
       pkt = findstr(sessname,'.');
       if isempty(pkt)
           sessname = [sessname,'.sid'];
       end
      if nargin<2,
         pathname=which(sessname);pathname=pathname(1:end-length(sessname));
      end
      set(0,'showhiddenhandles','on')
      eval('iduisess(''load'',pathname,sessname);')
      set(0,'showhiddenhandles','off')

   end
