% called by LMIEDIT

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.12.2.3 $

function str=lmireq(hdl,task,aux)
str=[];

if strcmp(task,'load'),
  set(hdl(17),'str','MATLAB string to be loaded:');
  set(hdl(18),'str','  ');
  set(hdl(19),'callb',...
     ['ssztmp=dblnk(get(ZZZ_ehdl(18),''str''));' ...
      'if ~isempty(ssztmp),' ...
      '  if exist(ssztmp)~=1, lmireq(ZZZ_ehdl,''voidstr'',ssztmp);' ...
      '  else lmireq(ZZZ_ehdl,''loadstr'',eval(ssztmp)); end,' ...
      'end,clear ssztmp;']);
  set(hdl(16:20),'vis','on');
  set(hdl(14:15),'enable','off')

elseif strcmp(task,'voidstr'),

  parslerr(hdl,['The string ' aux ' does not exist']);

elseif strcmp(task,'loadstr'),

  if isempty(aux), return, end

  set(hdl(16:20),'vis','off');
  [s1,s2,s3,s4,s5,fail]=spltstr(hdl,aux);
  set(hdl(2),'str',s1);
  set(hdl(8),'str',cellstr(s2));
  set(hdl(9),'str',cellstr(s3));
  set(hdl(10),'str',cellstr(s4));
  set(hdl(14),'str',cellstr(s5));
  set(hdl(14:15),'enable','on')
  set(hdl([5:10,14]),'vis','on');
  set(hdl([11,15]),'vis','off');
  set(hdl([4,13]),'value',0);
  set(hdl([3,12]),'value',1);
  if ~fail, set(hdl([5,14]),'userd',1); end


elseif strcmp(task,'save'),
  set(hdl(17),'str','Save in string:');
  set(hdl(18),'str','  ');
  set(hdl(19),'callb',...
     ['ssztmp=get(ZZZ_ehdl(18),''str'');' ...
      'if ~isempty(dblnk(ssztmp)), '...
         'eval([ssztmp ''=lmireq(ZZZ_ehdl,''''savestr'''');'']);' ...
         'set(ZZZ_ehdl(16:20),''vis'',''off'');' ...
      'end, clear ssztmp;']);
  set(hdl(16:20),'vis','on');
  set(hdl(14:15),'enable','off')


elseif strcmp(task,'savestr'),

  str=str2mat(get(hdl(2),'str'),'*%',...
              char(get(hdl(8),'str')),'*%',...
              char(get(hdl(9),'str')),'*%',...
              char(get(hdl(10),'str')),'*%',...
              char(get(hdl(14),'str')));
  set(hdl(14:15),'enable','on')


elseif strcmp(task,'addvcode')

  if ~get(hdl(5),'userd'), % no modif in var. definition
    set(hdl(5:10),'vis','off'); set(hdl(11),'vis','on');
    set(hdl(3),'value',0); set(hdl(4),'value',1); return
  end

  lminame=dblnk(get(hdl(2),'str'));
  if isempty(dblnk(lminame)),
    parslerr(hdl,'Please name this LMI system');
    set(hdl(4),'value',0); return
  end

  addvcmd=parslvar(hdl,lminame);
  if isempty(dblnk(addvcmd(:))),
    parslerr(hdl,'The LMI variables are not fully specified');
    set(hdl(4),'value',0);
  else
    set(hdl(3),'value',0); set(hdl(4),'value',1);
    set(hdl(11),'str',cellstr(setstr([' '*ones(size(addvcmd,1),2) addvcmd])),'userd',0);
    set(hdl(5:10),'vis','off');
    set(hdl(11),'vis','on');
    set(hdl(5),'userd',0);
  end

elseif strcmp(task,'addtcode'),

  if ~get(hdl(14),'userd'), % no modif in LMI description
    set(hdl(14),'vis','off'); set(hdl(15),'vis','on');
    set(hdl(12),'value',0); set(hdl(13),'value',1); return
  end

  set(hdl(22),'str','Coding in progress...','hor','center');
  set(hdl(21:23),'vis','on');
  pause(1)

  lminame=dblnk(get(hdl(2),'str'));
  if isempty(dblnk(lminame)),
    parslerr(hdl,'Please name this LMI system');
    set(hdl(13),'value',0); return
  end

  [addvcmd,varlist]=parslvar(hdl,lminame);
  if isempty(dblnk(addvcmd(:))) & get(hdl(11),'userd'),
      stop=char(get(hdl(11),'str'));
      if isempty(dblnk(stop(:))),
        parslerr(hdl,'The LMI variables are not fully specified');
        set(hdl(13),'value',0); return
      end
      [sysname,varname,vartype,varstruct]=parslcod(hdl,stop,[]);
      if ~isempty(varname), set(hdl(11),'userd',0); end
      set(hdl(8),'str',cellstr(setstr(varname)));
      set(hdl(9),'str',cellstr(setstr(vartype)));
      set(hdl(10),'str',cellstr(setstr(varstruct)));
      [addvcmd,varlist]=parslvar(hdl,lminame);
  end

  addtcmd=' ';
  if ~isempty(dblnk(addvcmd)), addtcmd=parslsys(hdl,lminame,varlist); end

  set(hdl(15),'str',cellstr(setstr([' '*ones(size(addtcmd,1),2) addtcmd])),'userd',0);
  set(hdl(14),'vis','off','userd',0);
  set(hdl(15),'vis','on');
  set(hdl(12),'value',0); set(hdl(13),'value',1);



elseif strcmp(task,'makelmi'),

  lminame=dblnk(get(hdl(2),'str'));
  if isempty(dblnk(lminame)),
    parslerr(hdl,'Please name this LMI system'); return
  end

  addvcmd=char(get(hdl(11),'str'));
  if isempty(dblnk(addvcmd(:))),
    [addvcmd,varlist]=parslvar(hdl,lminame);
  end
  if isempty(dblnk(addvcmd(:))),
    parslerr(hdl,'Please describe the matrix variables'); return
  end

  addtcmd=char(get(hdl(15),'str'));
  if isempty(dblnk(addtcmd(:))),
    addtcmd=parslsys(hdl,lminame,varlist);
  end
  if isempty(dblnk(addtcmd(:))),
    parslerr(hdl,'Please describe the LMI constraints'); return
  end

  str=str2mat(addvcmd,'  ',addtcmd)';
  parslerr(hdl,['Internal description stored in "' lminame '"']);


elseif strcmp(task,'getfile'),

  set(hdl(17),'str','File to be used:');
  set(hdl(18),'str','  ');
  if aux, % write
    set(hdl(19),'callb',...
       ['ssztmp=get(ZZZ_ehdl(18),''str'');' ...
        'if ~isempty(dblnk(ssztmp)), '...
          'lmireq(ZZZ_ehdl,''writecode'');' ...
        'end, clear ssztmp;']);
  else    % read
    set(hdl(19),'callb',...
       ['ssztmp=get(ZZZ_ehdl(18),''str'');' ...
        'if ~isempty(dblnk(ssztmp)), '...
          'lmireq(ZZZ_ehdl,''readcode'');' ...
        'end, clear ssztmp;']);
  end
  set(hdl(16:20),'vis','on');
  set(hdl(14:15),'enable','off')


elseif strcmp(task,'writecode'),

  filename=strrep(dblnk(get(hdl(18),'str')),' ','');

  lminame=dblnk(get(hdl(2),'str'));
  if isempty(dblnk(lminame)),
    parslerr(hdl,'Please name this LMI system'); return
  end

  addvcmd=char(get(hdl(11),'str'));
  if isempty(dblnk(addvcmd(:))),
    [addvcmd,varlist]=parslvar(hdl,lminame);
  end
  if isempty(dblnk(addvcmd(:))),
    parslerr(hdl,'Please describe the matrix variables'); return
  end

  addtcmd=char(get(hdl(15),'str'));
  if isempty(dblnk(addtcmd(:))),
    addtcmd=parslsys(hdl,lminame,varlist);
  end
  if isempty(dblnk(addtcmd(:))),
    parslerr(hdl,'Please describe the LMI constraints'); return
  end

  code=str2mat(addvcmd,'  ',addtcmd);

  if fopen(filename,'r') >=0,
    s=input(sprintf(...
    ['This file already exists. \nAppend the code to it? ([y]/n):   ']),'s');
    if strcmp(s,'n') | strcmp(s,'N'),
      return,
    else s='a'; end
  else
    s='w';
  end

  fil_ptr=fopen(filename,s);
  fprintf(fil_ptr,'\n');
  for s=code',
    fprintf(fil_ptr,'%s\n',dblnk(s));
  end
  fprintf(fil_ptr,'\n');
  fclose(fil_ptr);
  set(hdl(16:20),'vis','off');
  set(hdl(14:15),'enable','on')


elseif strcmp(task,'readcode'),

  cr=sprintf('\n'); % carriage return

  % read file
  filename=strrep(dblnk(get(hdl(18),'str')),' ','');
  fid=fopen(filename,'r');
  if fid<0,
    parslerr(hdl,'This file does not exist or is read-protected'); return
  end

  % extract lines with LMI commands
  stop=[]; sbot=[]; buffer=[];
  while 1,
    line=fgetl(fid);    % get one line
    if ~isstr(line), break,
    elseif length(buffer), line=[buffer , dblnk(line)]; buffer=[];
    end
    ll=length(line);
    if ll<8, line=[];
    elseif strcmp(line(1),'%'), line=[];
    elseif ll>=11,
      ix=findstr(line,'...');
      if length(ix), buffer=line(1:ix-1); line=[]; end
    end

    if isempty(findstr(line,'lm')),
    elseif ~isempty(findstr(line,'lmivar')) | ...
       ~isempty(findstr(line,'setlmis')),
       stop=strstack(stop,[' ' dblnk(line)]);
    elseif ~isempty(findstr(line,'getlmis')) | ...
          ~isempty(findstr(line,'lmiterm')) | ...
          ~isempty(findstr(line,'newlmi')),
       sbot=strstack(sbot,[' ' dblnk(line)]);
    end
  end
  fclose(fid);

  if isempty(dblnk(stop(:))) & isempty(dblnk(sbot(:)))
    parslerr(hdl,'No LMI system described in this file'); return
  end

  set(hdl(11),'str',cellstr(setstr(stop)),'userd',1);
  set(hdl([8:10,14]),'str',' ');
  set(hdl(15),'str',cellstr(setstr(sbot)),'userd',1);
  set(hdl([5:10,14]),'vis','off');
  set(hdl([11,15]),'vis','on');
  set(hdl([4,13]),'value',1);
  set(hdl([3,12]),'value',0);
  set(hdl(16:20),'vis','off');
  set(hdl(14:15),'enable','on')


elseif strcmp(task,'readvar'),

  if ~get(hdl(11),'userd'),   % no modif in var commands
    set(hdl(11),'vis','off'); set(hdl(5:10),'vis','on');
    set(hdl(4),'value',0); set(hdl(3),'value',1); return
  end

  stop= char(get(hdl(11),'str'));
  if isempty(dblnk(stop(:))),
    parslerr(hdl,'LMIVAR commands are missing');
    set(hdl(3),'value',0); return
  end

  [sysname,varname,vartype,varstruct]=parslcod(hdl,stop,[]);

  if ~isempty(varname),
    set(hdl([11,5]),'userd',0);
    set(hdl(8),'str',cellstr(setstr(varname)));
    set(hdl(9),'str',cellstr(setstr(vartype)));
    set(hdl(10),'str',cellstr(setstr(varstruct)));
    set(hdl(4),'value',0); set(hdl(3),'value',1);
    set(hdl(11),'vis','off');
    set(hdl(5:10),'vis','on');
  else
    set(hdl(3),'value',0);
  end


elseif strcmp(task,'readterm'),

  if ~get(hdl(15),'userd'), % no modif in lmiterm commands
    set(hdl(15),'vis','off'); set(hdl(14),'vis','on');
    set(hdl(13),'value',0); set(hdl(12),'value',1); return
  end

  set(hdl(22),'str','Decoding in progress...','hor','center');
  set(hdl(21:23),'vis','on');
  pause(1)

  stop= char(get(hdl(11),'str'));
  if isempty(dblnk(stop(:))),
    parslerr(hdl,'LMIVAR commands are missing');
    set(hdl(12),'value',0);return
  end
  sbot= char(get(hdl(15),'str'));
  if isempty(dblnk(sbot(:))),
    parslerr(hdl,'LMITERM commands are missing');
    set(hdl(12),'value',0);return
  end

  [sysname,varname,vartype,varstruct,lmides]=parslcod(hdl,stop,sbot);

  if ~isempty(lmides),
    set(hdl(13),'value',0); set(hdl(12),'value',1);
    set(hdl(2),'str',sysname);
    set(hdl(14),'str',cellstr(setstr(lmides)));
    set(hdl(15),'vis','off','enable','on','userd',0);
    set(hdl(14),'vis','on','enable','on','userd',0);
  else
    set(hdl(12),'value',0);
  end


elseif strcmp(task,'help'),

  figure('units','norm','position',aux,'color','w');
  set(gca,'units','norm','position',[0.02 0 .96 .94],'vis','off');
  h=text(zeros(1,14),1:-1/14:1/14,setstr(' '*ones(14,1)));
  set(h,'color','black');
  comp = computer;
  if all(comp(1:2)=='PC'),  set(h,'fontsize',8); end

  if hdl==1,

   set(h(1),'str','For each matrix variable, you must:');
   set(h(2),'str',...
      '   * give it a name');
   set(h(3),'str','   * select its structure type among the following');
   set(h(4),'str','             S  ->  symmetric block diagonal');
   set(h(5),'str','             R  ->  rectangular unstructured');
   set(h(6),'str','             G  ->  other structures');
   set(h(7),'str','   * specify its particular structure (type "help lmivar" for details).');
   set(h(8),'str','Please use one line per variable.');
   set(h(10),'str','Example: ');
   set(h(11),'str','                  X         S        [1 0;1 0;1 0]');
   set(h(12),'str','                  Y         R        [3 2]');
   set(h(13),'str','specifies a 3x3 diagonal matrix X and a 3x2 rectangular');
   set(h(14),'str','matrix Y.');

  else

   set(h(1),'str',...
      'The LMIs are entered as regular  MATLAB  expressions.');
   set(h(2),'str','For instance,');
   set(h(4),'str','      [A''*X + X*A + C''*Y*C    X*B ; B''*X    -Y]  < 0');
   set(h(5),'str','       X > 0');
   set(h(6),'str','       Y > 1');
   set(h(8),'str',...
      'Please denote the matrix variables by their "names" (see');
   set(h(9),'str',...
      'the Help on the matrix variable specification for details).');
   set(h(11),'str','Expressions inside parentheses should not involve any');
   set(h(12),'str','matrix variable.');


  end
  uicontrol('sty','push','units','norm','pos',[.88 0 .12 .12],'str','close',...
            'callb','delete(gcf);');


elseif strcmp(task,'nolmi'),

  set(hdl(22),'str','Please name this LMI system','hor','center');
  set(hdl(21:24),'vis','on');
  set(hdl(14:15),'enable','off')

end
