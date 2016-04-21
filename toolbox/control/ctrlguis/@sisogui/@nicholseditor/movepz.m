function [X,Y] = movepz(Editor, MovedGroup, PZID, G0, X, Y, hline)
%  MOVEPZ   Updates pole/zero group to track mouse location (X,Y) in editor
%           axes.  X is in rad, and Y is in abs.

%  Author(s): Bora Eryilmaz
%  Revised:
%  Copyright 1986-2002 The MathWorks, Inc. 
%  $Revision: 1.26 $ $Date: 2002/04/10 05:05:28 $

% REMARK: G0 contains initial pole/zero values for moved group

% Initial data
LoopData = Editor.LoopData;
Ts = LoopData.Ts;

% Pole/zero format: time constant or zero/pole/gain
Format = Editor.EditedObject.Format;
Format = lower(Format(1));

% Some Parameters
Group.Zero = MovedGroup.Zero.';  % Compensator roots in row (1xNz)
Group.Pole = MovedGroup.Pole.';  % (1xNp)
iszpk  = strcmp(Format, 'z');          % pole/zero or time-constant format
sgnpz  = 1 - 2 * strcmp(PZID, 'Pole'); % 1 if zero, -1 otherwise

% Get initial mag/phase data and remove contribution of moved roots 
% REMARK: Do not project to end points to avoid 0 frequency.
Xo = Editor.Phase(2:end-1) * pi / 180;   % rad
Yo = Editor.Magnitude(2:end-1) * getzpkgain(Editor.EditedObject,'mag');  % abs
Wo = Editor.Frequency(2:end-1);  % rad/sec
[Xo,Yo] = LocalRespCurve(Wo, Xo, Yo, Group, Ts, Format, -1);

% Update pole/zero group data
switch MovedGroup.Type
case 'Real'
   % Real root in current domain.  Can't be s = 0 or z = 1.
   r0 = G0.(PZID);  % Initial (moved) real root
   
   % Locus of pole/zero marker positions.
   R0 = LocalSetRoot(Wo, Ts, r0);   % column vector of s = sgn(r0)*w, etc.
   Group.(PZID) = R0;
   [LocPha, LocMag] = LocalRespCurve(Wo, Xo, Yo, Group, Ts, Format, 1);
   
   % Plot marker locus
   LocalLocusLine(Editor, hline, LocPha, LocMag);
   
   % Project mouse position onto the marker locus and get frequency.
   W = LocalProject(Editor, X, Y, LocPha, LocMag, Wo);
   
   % New root value
   R = LocalSetRoot(W, Ts, r0);
   set(MovedGroup, PZID, R);
   
   % Recalculate the pole/zero marker position
   [X,Y] = LocalMarkerPosition(Editor, W, Wo, LocPha, LocMag);
   
   
case 'LeadLag'
   % Real root in current domain. Can't be s = 0 or z = 1.
   ZPID = setxor(PZID, {'Pole', 'Zero'}); ZPID = ZPID{:};
   r0 = G0.(PZID);  % Initial (moved) real root
   r1 = G0.(ZPID);  % Initial (fixed) real root
   
   % Locus of pole/zero marker positions.
   R0 = LocalSetRoot(Wo, Ts, r0);   % column vector
   R1 = r1 * ones(length(Wo),1);
   Group.(PZID) = R0;
   Group.(ZPID) = R1;
   [LocPha, LocMag] = LocalRespCurve(Wo, Xo, Yo, Group, Ts, Format, 1);
   
   % Plot marker locus
   LocalLocusLine(Editor, hline, LocPha, LocMag);
   
   % Project mouse position on the marker locus and get frequency.
   W = LocalProject(Editor, X, Y, LocPha, LocMag, Wo);
   
   % New root value
   R = LocalSetRoot(W, Ts, r0);
   set(MovedGroup, PZID, R);
   
   % Recalculate the pole/zero marker position
   [X,Y] = LocalMarkerPosition(Editor, W, Wo, LocPha, LocMag);
   
   
case 'Complex'
   % Complex root (natural freq = W)
   r0 = G0.(PZID);
   r0 = r0(1);     % initial moved complex root
   [w0, Zeta] = damp(r0, Ts);  % initial damping
   
   % Locus of pole/zero marker positions.
   R0 = LocalSetRoot(Wo, Ts, r0, Zeta);   % column vector
   Group.(PZID) = [R0, conj(R0)];
   [LocPha, LocMag] = LocalRespCurve(Wo, Xo, Yo, Group, Ts, Format, 1);
   
   % Project mouse position on the marker locus and get frequency.
   W = LocalProject(Editor, X, Y, LocPha, LocMag, Wo);
   
   % Update dmping. Zeta here is actually abs(Zeta).
   Zeta = (Y/Editor.interpmag(Wo,Yo,W))^sgnpz / 2 / W^(2*iszpk);
   Zeta = max(min(Zeta,1), sqrt(2*eps));  % 0 < Zeta <= 1
   
   % Locus of pole/zero marker positions for new Zeta.
   r = LocalSetRoot(Wo, Ts, r0, Zeta);   % column vector
   Group.(PZID) = [r, conj(r)];
   [LocPha, LocMag] = LocalRespCurve(Wo, Xo, Yo, Group, Ts, Format, 1);
   
   % Marker locus
   LocalLocusLine(Editor, hline, LocPha, LocMag);
   
   % New root value
   R = LocalSetRoot(W, Ts, r0, Zeta);  % new value
   set(MovedGroup, PZID, [R ; conj(R)]);
   
   % Recalculate the pole/zero marker position
   [X,Y] = LocalMarkerPosition(Editor, W, Wo, LocPha, LocMag);
   
   
case 'Notch'
   % Mouse motion controls w0 and ZetaZ (ZetaP is fixed)
   % Notch filter (s^2+2*ZetaZ*w0*s+w0^2) / (s^2+2*ZetaP*w0*s+w0^2)
   [w0, ZetaZ] = damp(G0.Zero(1), Ts);   % initial zero damping (moved)
   [w0, ZetaP] = damp(G0.Pole(1), Ts);   % initial pole damping (fixed)  
   sgnZP = (sign(ZetaZ) - sign(ZetaP)) / 2;
   
   % Locus of pole/zero marker positions for ZetaZ.
   LocPha = Xo + pi * sgnZP;
   LocMag = Yo * abs(ZetaZ/ZetaP);
   
   % Project mouse position on the marker locus and get frequency.
   W = LocalProject(Editor, X, Y, LocPha, LocMag, Wo);
   
   % Update zero damping. ZetaZ here is actually abs(ZetaZ).
   ZetaZ = Y/Editor.interpmag(Wo,Yo,W) * abs(ZetaP); 
   ZetaZ = max(min(ZetaZ,abs(ZetaP)), sqrt(2*eps));  % 0 < ZetaZ <= ZetaP
   
   % Locus of pole/zero marker positions for new ZetaZ.
   LocPha = Xo + pi * sgnZP;
   LocMag = Yo * abs(ZetaZ/ZetaP);
   
   % Marker locus
   LocalLocusLine(Editor, hline, LocPha, LocMag);
   
   % Update notch data
   z = LocalSetRoot(W, Ts, G0.Zero(1), ZetaZ);  % new values
   p = LocalSetRoot(W, Ts, G0.Pole(1), ZetaP);
   set(MovedGroup, 'Zero', [z ; conj(z)], 'Pole', [p ; conj(p)]);
   
   % Recalculate the pole/zero marker position
   [X,Y] = LocalMarkerPosition(Editor, W, Wo, LocPha, LocMag);
end


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Purpose: Get equivalent root value in continuous-time domain
% ----------------------------------------------------------------------------%
function p = dom2ct(p, Ts)
if Ts
   p = log(p) / Ts;
end

% ----------------------------------------------------------------------------%
% Purpose: Get equivalent root value in current time domain.
% ----------------------------------------------------------------------------%
function p = ct2dom(p, Ts)
if Ts
   p = exp(Ts*p);
end

% ----------------------------------------------------------------------------%
% Purpose:  Add contribution of selected root or group of roots
%           to Nichols data and get the new marker position.
% ----------------------------------------------------------------------------%
function [X,Y] = LocalMarkerPosition(Editor, W, Wo, LocPha, LocMag)
X = interp1(Wo, LocPha, W);
Y = Editor.interpmag(Wo, LocMag, W);

% ----------------------------------------------------------------------------%
% Purpose:  Project mouse position onto the marker locus and get frequency.
% ----------------------------------------------------------------------------%
function W = LocalProject(Editor, Pha, Mag, LocPha, LocMag, Wo)
W = Editor.project(unitconv(Pha, 'rad', Editor.Axes.XUnits), ...
   mag2dB(Mag), ...
   unitconv(LocPha, 'rad', Editor.Axes.XUnits), ...
   mag2dB(LocMag), Wo);

% ----------------------------------------------------------------------------%
% Purpose:  Draw the locus of marker positions.
% ----------------------------------------------------------------------------%
function LocalLocusLine(Editor, hline, LocPha, LocMag)
Zlevel = Editor.zlevel('curve');
set(hline, 'XData', unitconv(LocPha, 'rad', Editor.Axes.XUnits), ...
	   'YData', mag2dB(LocMag), ...
	   'ZData', Zlevel(ones(1,length(LocPha)),:));

% ----------------------------------------------------------------------------%
% Purpose:  Sets up a root (continuous or discrete) with stability properties
%           as that of the initial root r, using continuous time frequency (w)
%           and damping (zeta) data.
% ----------------------------------------------------------------------------%
function p = LocalSetRoot(w, Ts, r, zeta)
% Stability of the root
if Ts
  isStable = (abs(r) > 1) - (abs(r) <= 1);   % discrete, abs(z) < 1
else
  isStable = (real(r) > 0) - (real(r) <= 0); % continuous, Re(s) < 0
end
% Root in appropriate domain
switch nargin
 case 3,  % real root
  p = ct2dom(isStable*w, Ts);
 case 4,  % complex root
  p = ct2dom(isStable*w*abs(zeta) + j*w*sqrt(1-zeta^2), Ts);
end

% ----------------------------------------------------------------------------%
% Purpose:  Add/remove contribution of selected root or group of roots
%           to/from Nichols data.  Generates locus in degrees and abs values.
% ----------------------------------------------------------------------------%
function [X,Y] = LocalRespCurve(Wo, Xo, Yo, Group, Ts, Format, op)
% REM: op = +1 for add and -1 for remove action.

% Get zero and pole values (in continuous domain)
rz = dom2ct(Group.Zero, Ts);  % zeros
rp = dom2ct(Group.Pole, Ts);  % poles

% Continuous domain variable, s
s = 1j * Wo;

% Evaluate root contribution
resp = 1;
switch Format
 case 'z'   % zero/pole/gain
  for ct = 1:size(rz,2)
    resp = resp .* (s - rz(:,ct));
  end
  for ct = 1:size(rp,2)
    resp = resp ./ (s - rp(:,ct));
  end
 case 't'   % time constant
  for ct = 1:size(rz,2)
    resp = resp .* (1 - s./rz(:,ct));
  end
  for ct = 1:size(rp,2)
    resp = resp ./ (1 - s./rp(:,ct));
  end
end

% Add/remove contribution of moved root(s) to/from X and Y data.
X = Xo  + op * unwrap(atan2(imag(resp), real(resp)));
Y = Yo .* (abs(resp)).^op;
