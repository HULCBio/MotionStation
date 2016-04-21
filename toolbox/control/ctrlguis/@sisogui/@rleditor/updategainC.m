function updategainC(Editor)
%UPDATEGAINC  Lightweight plot update when modifying the loop gain.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.19 $  $Date: 2002/04/10 04:58:08 $

% RE: Assumes gain does not change sign

if strcmp(Editor.EditMode,'off') | strcmp(Editor.Visible,'off') | Editor.SingularLoop
   % Editor is inactive/disabled
   return
end

% Get normalized open-loop and absolute value of compensator gain
NormOpenLoop = getopenloop(Editor.LoopData);
CurrentGain = getzpkgain(Editor.EditedObject,'mag');
CLPoles = fastrloc(NormOpenLoop,CurrentGain);
[Wn,Zeta] = damp(CLPoles,Editor.EditedObject.Ts);

% If new closed-loop poles lie beyond data extent, extend asymptotes
% to include new gain value. Otherwise, include current gain value 
% to make sure red squares lie on the locus
% RE: Do not update Editor.LocusGains/Roots to avoid
%     * introducing persistent large gains in first case
%     * uncontrolled growth in second case
Gains = Editor.LocusGains;
Roots = Editor.LocusRoots;
[NewGain,RefRoot] = extendlocus(Gains,Roots,CurrentGain);
if ~isempty(NewGain)
   % Extend locus
   NewRoot = matchlsq(RefRoot,fastrloc(NormOpenLoop,NewGain));
   Roots = [NewRoot,Roots];
   [Gains,is] = sort([NewGain,Gains]);
   Roots = Roots(:,is);
elseif length(Gains) & ~any(Gains==CurrentGain)
   % Insert current gain in locus data 
   idx = find(Gains>CurrentGain);
   Roots = [Roots(:,1:idx(1)-1) , ...
           matchlsq(Roots(:,idx(1)-1),CLPoles) , Roots(:,idx(1):end)];
end

% Update locus plot
HG = Editor.HG;
for ct=1:size(Roots,1)
    set(HG.Locus(ct),'Xdata',real(Roots(ct,:)),...
        'Ydata',imag(Roots(ct,:)),'Zdata',Editor.zlevel('curve',[1 size(Roots,2)]))
end

% Update closed-loop pole location
Editor.ClosedPoles = CLPoles;   
for ct=1:length(CLPoles)
    set(HG.ClosedLoop(ct),'Xdata',real(CLPoles(ct)),'Ydata',imag(CLPoles(ct)));
end

%---Update axis limits
updateview(Editor)

   
