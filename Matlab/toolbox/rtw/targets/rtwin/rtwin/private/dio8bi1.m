function val = dio8bi1(varargin)
%DIO8BI1 8-bit bi-directional digital I/O control for hardware driver GUI.
%   DIO8BI1 is the 8-bit bi-directional digital I/O (settable by bits) control
%   for hardware driver GUI.
%
%   Private function.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2003/12/31 19:45:45 $  $Author: batserve $

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

uicontrol('Style','text', 'HorizontalAlignment','left', 'String',P.LABEL, 'Position',[P.X P.Y 100 17]);

% draw button labels

uicontrol('Style','text','Position',[P.X P.Y-41 40 17],...
          'HorizontalAlignment','left', 'String','Input:');
uicontrol('Style','text','Position',[P.X P.Y-57 40 17],...
          'HorizontalAlignment','left', 'String','Output:');

for i=7:-1:0
  uicontrol('Style','text','Position',[P.X+40+20*i P.Y-15 15 12],...
            'String',sprintf('D%1d',i));
  for j=2:-1:1
    H.dio8bi1(idx).io(i+1,j) = uicontrol('Style','radio','Position',[P.X+40+20*i P.Y-20-18*j 20 15],...
                                         'CallBack','rbutton','Tag',sprintf('DIO8BI1_%d_%d',i,idx));
  end;
end;
setappdata(H.dio8bi1(idx).io(1,1), 'Parameters', P);

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

for C = H.dio8bi1        % process multiple controls if present
  P = getappdata(C.io(1,1), 'Parameters');
  pvals = get(C.io(:,2),'Value');
  X(P.PARM) = [pvals{:}] * [1;2;4;8;16;32;64;128];
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  SETVALUE
%  set the control value(s)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SetValue(H, X)

for C = H.dio8bi1        % process multiple controls if present
  P = getappdata(C.io(1,1), 'Parameters');
  for i=1:8
    rbutton(C.io(i,bitget(X(P.PARM),i)+1));
  end;
end;
