function refreshplot(Editor,eventData,LocusGains,UpdatePlantPZ)
%REFRESHPLOT  Dynamically updates root locus plot when C or F are modified
%
%   Note: Changes in F affect open loop only for cascaded loops.

%   Author(s): N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/06/11 17:29:59 $

NormOpenLoop = getopenloop(Editor.LoopData);
if ~isfinite(NormOpenLoop)
   return
end
GainMag = getzpkgain(Editor.EditedObject,'mag');

% Add gain values where branches cross (for more smoothness)
LocusGains = unique([LocusGains,LocalCrossGains(NormOpenLoop)]);

% Update locus data and closed-loop locations
Roots = fastrloc(NormOpenLoop,[LocusGains,GainMag]);
Editor.LocusRoots  = Roots(:,1:end-1);
Editor.ClosedPoles = Roots(:,end);
Editor.LocusGains  = LocusGains;

% Update plot
HG = Editor.HG;
if ~isempty(Roots)
    Nroot = size(Editor.LocusRoots,2);
    for ct=1:length(Editor.HG.Locus)
        set(HG.Locus(ct),...
            'Xdata',real(Editor.LocusRoots(ct,:)),...
            'Ydata',imag(Editor.LocusRoots(ct,:)),...
            'Zdata',Editor.zlevel('curve',[1 Nroot]))
    end
    for ct=1:length(Editor.ClosedPoles)
        set(HG.ClosedLoop(ct),...
            'Xdata',real(Editor.ClosedPoles(ct)),...
            'Ydata',imag(Editor.ClosedPoles(ct)))
    end
end

% If the filter forms a minor-loop the open-loop (fixed) poles will move
if UpdatePlantPZ
    % Plot the fixed poles and zeros (Z level = 2)
    [FixedZeros, FixedPoles] = fixedpz(Editor.LoopData);
    nz = length(FixedZeros);
    for ct=1:nz
        set(HG.System(ct),'XData',real(FixedZeros(ct)),'YData',imag(FixedZeros(ct)))
    end % for ct
    for ct=1:length(FixedPoles)
        set(HG.System(nz+ct),'XData',real(FixedPoles(ct)),'YData',imag(FixedPoles(ct)))
    end % for ct
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalCrossGains %%%
%%%%%%%%%%%%%%%%%%%%%%%
function gmult = LocalCrossGains(NormOpenLoop)
% Computes gain crossings
% REVISIT: merge with version in REFRESHPZC when private functions available

[z,p,k] = zpkdata(NormOpenLoop,'v');
gmult = rlocmult(z,p,k);