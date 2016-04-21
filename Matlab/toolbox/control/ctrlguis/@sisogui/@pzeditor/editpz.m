function Editor = editpz(Editor,hedit,Group)
%EDITPZ  Updates internal group data according to user input.

%   Author(s): Karen Gondoly. 
%              P. Gahinet (OO implementation)
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 04:55:43 $

% Editor parameters
Ts = Editor.LoopData.Ts;
IsRealImag = strcmp(Editor.Format,'RealImag');

% Get edit box identifiers
PZID = get(hedit,'Tag');         % zero or pole
Column = get(hedit,'UserData');  % 1 (real/damping) or 2 (imag/freq)
RealPZ = any(strcmp(Group.Type,{'Real','LeadLag'}));

% Get current data
r = get(Group,PZID);  % zero or pole data
r = r(1);
if isnan(r)
    % Default = [0,0] for RealImag, [1 1] otherwise
    Data = ~IsRealImag * [1,1];
elseif IsRealImag,
    Data = [real(r) , abs(imag(r))];
else
    [Wn,Z] = damp(r,Ts);
    Data = [Z , Wn];
end
    
% Evaluate user input
NewValue = eval(get(hedit,'String'),'[]');

% Invalid input: revert to old value
if ~isequal(size(NewValue),[1 1]) | ~isreal(NewValue) | ~isfinite(NewValue),
    if isfinite(r)
        set(hedit,'String',sprintf('%0.3g',Data(Column)))
    else
        set(hedit,'String','')
    end
    return
end

% Get X,Y = real,imag or zeta,wn
Data(Column) = NewValue;
X = Data(1);
Y = Data(2);

% Enforce constraints on X,Y data
if ~IsRealImag
   if RealPZ
      % Damping of real poles is +1 or -1
      X = sign(X) + (~X);
   else
      % Damping of complex pairs remains in [-1,1]
      X = min(max(X,-1),1);
   end
end

% Keep imag part and natural frequency positive
Y = abs(Y);

% Assemble data to get new root value
if IsRealImag
   R = X + 1i * Y;
else
   R = Y * (-X + 1i * sqrt(1-X^2));
   if Ts
      R = exp(Ts*R);
   end
end

% Update group data (triggers edit box update)
if RealPZ
    set(Group,PZID,R);
else
    set(Group,PZID,[R;conj(R)]);
end

