function val = i8255(varargin)
%I8255 I/O Intel 8255 control for hardware driver GUI.
%   I8255 is the I/O Intel 8255 control for hardware driver GUI.
%
%   Private function.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2003/12/31 19:45:47 $  $Author: batserve $

if nargout==1                 % the switchyard
  val = feval(varargin{:});
else
  feval(varargin{:});
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  DRAW
%  draws the control
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function H = Draw(H, gui, opt)    %#ok called by name from a callback

for idx=1:length(gui)    % process multiple controls if present

% set defaults to non-specified parameters

defp.X = 20;
defp.Y = 60;
defp.LABEL = 'Digital I/O :';
defp.PARM = 2;
P = mrgstruc(gui(idx), defp);

% draw the label

uicontrol('Style','text', 'HorizontalAlignment','left', 'String',P.LABEL, 'Position',[P.X P.Y+85 150 17]);

% draw the I8255 Port controls

portlab = {'Port A:','Port B:','Port CL:','Port CH:'};
iolab = {'Input','Output'};
for i=4:-1:1
  uicontrol('Style','text', 'HorizontalAlignment','left', ...
            'String',portlab{i}, 'Position', [P.X P.Y+80-20*i 45 17]);
  for j=2:-1:1
    H.i8255(idx).io(i,j) = uicontrol('Style','radio', ...
                                     'Position', [P.X-10+55*j P.Y+80-20*i 53 20], ...
                                     'String', iolab{j}, ...
                                     'HorizontalAlignment','left', ...
                                     'Callback', 'rbutton', ...
                                     'UserData', idx, ...
                                     'Tag',sprintf('I8255_%d_%d',i,idx));
  end;
end;
setappdata(H.i8255(idx).io(1,1), 'Parameters', P);

end;  % of multiple controls loop

% set the defaults

SetValue(H, opt);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  GETVALUE
%  return the control value(s)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function X = GetValue(X, H)    %#ok called by name from a callback

for C = H.i8255        % process multiple controls if present
  P = getappdata(C.io(1,1), 'Parameters');
  pvals = get(C.io(:,2),'Value');
  X(P.PARM) = [pvals{:}] * [1;2;4;8];
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  SETVALUE
%  set the control value(s)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SetValue(H, X)

for C = H.i8255        % process multiple controls if present
  P = getappdata(C.io(1,1), 'Parameters');
  for i=1:4
    rbutton(C.io(i,bitget(X(P.PARM),i)+1));
  end;
end;

