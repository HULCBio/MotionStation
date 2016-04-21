function deelin(u0val)
%DEELIN Derive a linear model for a DEE system.
%   DEELIN uses linmod to derive a linear model for a DEE system.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.9 $

%   Jay Torgerson
%   December, 1994

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preamble.
%%%%%%%%%%%%%%%%%%%%%%%%%%
Thisfig  = gcf;
set(Thisfig,'Visible','off');
figh     = get(Thisfig,'UserData');
figtitle = get(figh,'Name');

controlhands = get(figh,'UserData');
FooSys  = 'dee_lin_model';
blkname = 'temp';
FooBlk = [FooSys,'/',blkname];
se = controlhands(1);
so = controlhands(2);
ic = controlhands(3);
st = controlhands(5);
linb = controlhands(13);


% Affect status field.
prevstr = get(st,'String');
set(st,'String','Status: Linearizing model...');
drawnow;

seRestore = findobj(figh,'Tag','SE_Restore');
soRestore = findobj(figh,'Tag','SO_Restore');

xStr  = get(se, 'String');
yStr  = get(so, 'String');
x0Str = get(ic, 'String');

set(seRestore,'String',xStr);
set(soRestore,'String',yStr);

NumOfStates = size(xStr,1);

if NumOfStates < 1,
   set(st,'String',prevstr);
   drawnow;
   return;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Phantom system.
%%%%%%%%%%%%%%%%%%%%%%%%%%
if (exist(FooSys)==4), % if this guy already exists, blow him away.
   close_system(FooSys,0);
end
new_system(FooSys);
add_block(figtitle,FooBlk);

NumOfInputs = size(get_param(FooBlk,'inport'),1);
NumOfOutputs = size(get_param(FooBlk,'outport'),1);

if (NumOfInputs ~= size(u0val(:),1)),
   errordlg('Length of u0 must equal the number of system inputs.','DEE Linearization ERROR');
   set(st,'String',prevstr);
   drawnow;
   close_system(FooSys,0);
   return;
end

for i=1:NumOfInputs,
  index = num2str(i);
  portname = ['u',index];
  add_block('built-in/Inport',[FooSys,'/',portname]);
  add_line(FooSys,[portname,'/1'],[blkname,'/',index]);
end

for i=1:NumOfOutputs,
  index = num2str(i);
  portname = ['y',index];
  add_block('built-in/Outport',[FooSys,'/',portname]);
  add_line(FooSys,[blkname,'/',index],[portname,'/1']);
end

%%%%%%%%%%%%%%%%%%%%%%%%
% Get x0 numeric values.
%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:NumOfStates,
  x0val(i) = eval(x0Str(i,:));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Actually take the linmod()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% but first, insure that the system can be simulated.
CmdStr   = '[tt,xx,yy] = rk45(FooSys,0);';
CatchStr = 'errordlg(''DEE System has a syntax error or a variable does not exist.'',''DEE Linearization ERROR'');';
eval(CmdStr,CatchStr);

if ~exist('tt'),
  set(st,'String','Status: Syntax error or undefined variable referenced.');
  drawnow;
  close_system(FooSys,0);
  return
end

% Setup switch logic and button text for linear/restore button.
set(linb,'String','Restore');
set(linb,'UserData',0);

x0val  = x0val(:); % make sure this is a column vector.
u0val  = u0val(:);
[A,B,C,D] = linmod(FooSys, x0val, u0val);
close_system(FooSys,0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a set of linear state and output equations.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATE EQUATIONS
xStr = '';
suffix = '+';
for i=1:NumOfStates,
  eqnStr = [];
  for j=1:NumOfStates,
    if (A(i,j)~=0)
      if (A(i,j)==1),
        Mult = '';
      else
        Mult = [sprintf('%.7g',A(i,j)),'*'];
      end
      eqnStr = [eqnStr,[Mult, 'x(',num2str(j),')',suffix]];
    end
  end

  for k =1:NumOfInputs,
    if (B(i,k)~=0)
      if (B(i,k)==1),
        Mult = '';
      else
        Mult = [sprintf('%.7g',B(i,k)),'*'];
      end
      eqnStr = [eqnStr,[Mult, 'u(',num2str(k),')',suffix]];
    end
  end

  % Clip unwanted suffix and other cruft, and stuff into xStr.
  len         = size(eqnStr,2);
  eqnStr(len) = [];
  eqnStr      = strrep(eqnStr,'+-','-');
  eqnStr      = strrep(eqnStr,'+1*','+');
  eqnStr      = strrep(eqnStr,'-1*','-');
  if (strcmp(eqnStr(1:2),'1*')),
    eqnStr(1:2) = [];
  end
  if (strcmp(eqnStr(1:3),'-1*')),
    eqnStr(1:3) = [];
  end
  xStr        = str2mat(xStr, eqnStr);
end
xStr(1,:) = [];

% OUTPUT EQUATIONS
yStr = '';
for i=1:NumOfOutputs,
  eqnStr = [];
  for j=1:NumOfStates,
    if (C(i,j)~=0)
      if (C(i,j)==1),
        Mult = '';
      else
        Mult = [sprintf('%.7g',C(i,j)),'*'];
      end
      eqnStr = [eqnStr,[Mult, 'x(',num2str(j),')',suffix]];
    end
  end

  for k =1:NumOfInputs,
    if (D(i,k)~=0)
      if (D(i,k)==1),
        Mult = '';
      else
        Mult = [sprintf('%.7g',D(i,k)),'*'];
      end
      eqnStr = [eqnStr,[Mult, 'u(',num2str(k),')',suffix]];
    end
  end

  % Clip unwanted suffix and other cruft, and stuff into yStr.
  len         = size(eqnStr,2);
  eqnStr(len) = [];
  eqnStr      = strrep(eqnStr,'+-','-');
  eqnStr      = strrep(eqnStr,'+1*','+');
  eqnStr      = strrep(eqnStr,'-1*','-');
  if (strcmp(eqnStr(1:2),'1*')),
    eqnStr(1:2) = [];
  end
  if (strcmp(eqnStr(1:3),'-1*')),
    eqnStr(1:3) = [];
  end
  yStr        = str2mat(yStr, eqnStr);
end
yStr(1,:) = [];

set(se,'String',xStr);
set(so,'String',yStr);
figure(figh); deeupdat;
