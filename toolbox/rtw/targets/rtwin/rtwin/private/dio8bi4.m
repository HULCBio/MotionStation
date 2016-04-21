function val = dio8bi4(varargin)
%DIO8BI4 8-bit bi-directional digital I/O control for hardware driver GUI.
%   DIO8BI4 is the 8-bit bi-directional digital I/O (settable by nibbles) control
%   for hardware driver GUI.
%
%   Private function.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.5.2.2 $  $Date: 2003/12/31 19:45:46 $  $Author: batserve $

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
defp.PORTLOW = 'Port L:';
defp.PORTHIGH = 'Port H:';
defp.PARM = 0;
P = mrgstruc(gui(idx), defp);

% draw the label

uicontrol('Style','text', 'HorizontalAlignment','left', 'String',P.LABEL, 'Position',[P.X P.Y+45 100 17]);

% draw the Digital I/O port controls

portlab = {P.PORTLOW, P.PORTHIGH};
iolab = {'Input', 'Output'};
for i=2:-1:1
  uicontrol('Style','text', 'HorizontalAlignment','left', ...
            'String',portlab{i}, 'Position', [P.X P.Y+40-20*i 45 17]);
  for j=2:-1:1
    H.dio8bi4(idx).io(i,j) = uicontrol('Style','radio', ...
                                      'Position', [P.X-10+60*j P.Y+40-20*i 55 20], ...
                                      'String', iolab{j}, ...
                                      'HorizontalAlignment','left', ...
                                      'Callback', 'rbutton', ...
                                      'UserData', idx, ...
                                      'Tag',sprintf('DIO8BI4_%d_%d',i,idx));
  end;
end;
setappdata(H.dio8bi4(idx).io(1,1), 'Parameters', P);

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

for C = H.dio8bi4        % process multiple controls if present
  P = getappdata(C.io(1,1), 'Parameters');
  pvals = get(C.io(:,2),'Value');
  X(P.PARM) = [pvals{:}] * [1;2];
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  SETVALUE
%  set the control value(s)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SetValue(H, X)

for C = H.dio8bi4        % process multiple controls if present
  P = getappdata(C.io(1,1), 'Parameters');
  for i=1:2
    rbutton(C.io(i,bitget(X(P.PARM),i)+1));
  end;
end;

