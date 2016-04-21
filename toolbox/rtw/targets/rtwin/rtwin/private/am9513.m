function val = am9513(varargin)
%AM9513 mode control for hardware driver GUI.
%   AM9513 is timer/counter mode control for hardware driver GUI.
%
%   Private function.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2003/12/31 19:45:42 $  $Author: batserve $

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

defp.N = 5;
defp.X = 20;
defp.Y = 60;
defp.LABEL = 'Timer/counter setup :';
defp.PARM = 2;
P = mrgstruc(gui(idx), defp);

% draw the label

uicontrol('Style','text', 'HorizontalAlignment','left', 'String',P.LABEL, 'Position',[P.X P.Y 110 17]);

% draw button labels

uicontrol('Style','text','Position',[P.X P.Y-40 120 17],...
          'HorizontalAlignment','left', 'String','Counter with reset:');
uicontrol('Style','text','Position',[P.X P.Y-58 120 17],...
          'HorizontalAlignment','left', 'String','Counter without reset:');
uicontrol('Style','text','Position',[P.X P.Y-76 120 17],...
          'HorizontalAlignment','left', 'String','Chained counter:');
uicontrol('Style','text','Position',[P.X P.Y-94 120 17],...
          'HorizontalAlignment','left', 'String','Frequency generator:');
uicontrol('Style','text','Position',[P.X P.Y-112 120 17],...
          'HorizontalAlignment','left', 'String','Delayed pulse:');

for i=P.N-1:-1:0
  uicontrol('Style','text','Position',[P.X+120+20*i P.Y-15 15 12],...
            'String',sprintf('T%1d',i+1));
  for j=5:-1:1
    H.am9513(idx).io(i+1,j) = uicontrol('Style','radio','Position',[P.X+120+20*i P.Y-20-18*j 20 15],...
                                         'CallBack','rbutton','Tag',sprintf('AM9513_%d_%d',i,idx));
  end;
end;
setappdata(H.am9513(idx).io(1,1), 'Parameters', P);

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

weights = [1 8 64 512 4096]'*[0 1 2 3 4];

for C = H.am9513        % process multiple controls if present
  P = getappdata(C.io(1,1), 'Parameters');
  pvals = get(C.io(:,:),'Value');
  weights=weights(1:P.N,:);
  X(P.PARM) = [pvals{:}] * weights(:);
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  SETVALUE
%  set the control value(s)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SetValue(H, X)

for C = H.am9513        % process multiple controls if present
  P = getappdata(C.io(1,1), 'Parameters');
  for i=1:P.N
    rbutton(C.io(i,bitand(bitshift(X(P.PARM),3-3*i),7)+1));
  end;
end;
