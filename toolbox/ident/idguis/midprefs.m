function midprefs(xidpath,dum)
%MIDPREFS Choose directory for IDPREFS.MAT, the IDENT start-up info file.
%
%   MIDPREFS  or MIDPREFS(PATH)
%
%   The Graphical User Interface to the System Identification toolbox
%   uses a file IDPREFS.MAT to store start-up information, like preferred
%   window sizes and locations and most recently used session files.
%   By default this file is stored in the same directory as STARTUP.M,
%   if this file exists.
%
%   To select another directory, use the function MIDPREFS. Simply type
%   the function name and follow the instructions, or give the directory
%   as an argument. Include all directory delimiters.
%
%   Example (PC): midprefs('c:\matlab\toolbox\local\')

%   L. Ljung 1-1-95
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.1 $  $Date: 2004/04/10 23:20:04 $

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');

if exist('idprefs.mat')
   load idprefs.mat
   XID.laypath = XIDlaypath;
   XID.sessions = XIDsessions;
   XID.layout = XIDlayout;
else
   XID.laypath=[];
   if ~exist('XID.sessions'), XID.sessions=[];end   
   if ~exist('XID.layout'), XID.layout=[];end
end

XIDpathold=XID.laypath;
if nargin==1, 
  if ~(xidpath(end)==filesep),xidpath=[xidpath,filesep];end
  tstpath=findstr([path,pathsep],[xidpath(1:end-1),pathsep]); 
  if isempty(tstpath)
    errordlg(['The given path is not on your MATLABPATH. Please ',...
	  'select another path.'],'Error Dialog','modal')
    return
  end
  XID.laypath=xidpath;
elseif nargin==0
  text1='You have currently no file idprefs.mat on your MATLABPATH.';
  text2=['idprefs.mat currently stored in ',XIDpathold.'.'];
  text3=str2mat(['Use the MATLAB file finder to select a directory',...
      ' where to put this file.'],...
      'The directory should be on your regular MATLABPATH.','',...
      'Press Cancel in the file finder to abort.','',...
      'Press Return to open the file finder.','');
  if isempty(XIDpathold)
    disp(str2mat(text1,text3))
  else
    disp(str2mat(text2,text3))
  end
  pause
end  
if nargin==0|nargin==2
  okfile=1;
  while okfile
  [dum,XID.laypath]=uiputfile('idprefs.mat','Directory for start-up file');
  if XID.laypath==0,XID.laypath=[];return;end
  tstpath=findstr(lower(path),lower(XID.laypath(1:end-1)));
%   if isempty(tstpath)
%     click=questdlg(['The given path is not on your MATLABPATH. Please ',...
% 	  'select another path.'],'Warning','OK','Cancel','OK');
%     if strcmp(lower(click),'cancel'),return,end
%   else
    okfile=0;
  %end  
  end
end
err=0;
XIDlaypath =  XID.laypath;
XIDsessions = XID.sessions;
XIDlayout = XID.layout;
eval(['save ',XID.laypath,...
         'idprefs.mat XIDlaypath XIDsessions XIDlayout'],'err=1;')
if err,
       errordlg(['File could not be written. Check writing permissions', ...
	   ' and pathname'],'Error Dialog','modal'),return
end

 set(Xsum,'Userdata',XID);
 
disp(str2mat('',['Ident start-up info stored in ',XID.laypath,'idprefs.mat.'],''))
del=0;
if ~isempty(XIDpathold)
    eval(['delete ',XIDpathold,'idprefs.mat'],''),del=1;
    disp(str2mat(['Old file ',XIDpathold,'idprefs.mat deleted.'],''))
end

