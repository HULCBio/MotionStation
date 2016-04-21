function varargout = centerfig(F1,F2)
%CENTERFIG  Position figure F1 centered with respect to figure F2.
%
%   CENTERFIG is used to center a window (F1) with respect to another
%   window (F2) or the root window.  F1 must be a valid MATLAB figure
%   window or Java frame.  F2 must be a valid MATLAB figure window or the
%   root window.
%
%   CENTERFIG(F1,F2) centers figure F1 with respect to figure F2
%
%   CENTERFIG(F1,0)  centers figure F1 with respect to the screen
%
%   CENTERFIG(F1)    centers figure F1 with respect to the screen
%
%   CENTERFIG        centers the current figure with respect to the screen

%   Author(s): A. DiVergilio
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/14 22:17:57 $

%---Defaults
if nargin<2, F2 = 0; end
if nargin<1, F1 = gcf; end

if isjava(F1)
   xy = localPlaceJavaFig(F1,F2);
else
   xy = localPlaceHGFig(F1,F2);
end

%---Return xy position if requested
if nargout, varargout{1}=xy; end


%%%%%%%%%%%%%%%%%%%%%
% localPlaceJavaFig %
%%%%%%%%%%%%%%%%%%%%%
function xy = localPlaceJavaFig(J,HG)
% Place Java frame J within bounds of Handle Graphics object HG

 %---Get screen size in pixels
  su = get(0,'Units');
  if ~strcmpi(su,'pixels')
     set(0,'Units','pixels');
     ss = get(0,'ScreenSize');
     set(0,'Units',su);
  else
     ss = get(0,'ScreenSize');
  end

 %---Get HG position in pixels
  if HG==0
     hgp = ss;
  else
     hgu = get(HG,'Units');
     if ~strcmpi(hgu,'pixels')
        set(HG,'Units','pixels');
        hgp = get(HG,'Position');
        set(HG,'Units',hgu);
     else
        hgp = get(HG,'Position');
     end
  end

 %---Set position of J
  x = hgp(1)+hgp(3)/2 - J.getSize.width/2;
  y = ss(4) - (hgp(2)+hgp(4)/2+J.getSize.height/2);
  J.setLocation(java.awt.Point(x,y));
  xy = [x y];


%%%%%%%%%%%%%%%%%%%
% localPlaceHGFig %
%%%%%%%%%%%%%%%%%%%
function xy = localPlaceHGFig(F1,F2)
% Place HG figure F1 within bounds of HG figure F2 (F2 may be root)

 %---Fieldname of F2 which contains its position
  if F2==0
     Property = 'ScreenSize';
  else
     Property = 'Position';
  end

 %---Get F2 position in pixels
  f2u = get(F2,'Units');
  if ~strcmpi(f2u,'pixels')
     set(F2,'Units','pixels');
     f2p = get(F2,Property);
     set(F2,'Units',f2u);
  else
     f2p = get(F2,Property);
  end

 %---Set F1 position
  f1u = get(F1,'Units');
  if ~strcmpi(f1u,'pixels')
     set(F1,'Units','pixels');
     f1p = get(F1,'Position');
     xy = [f2p(1)+(f2p(3)-f1p(3))/2 f2p(2)+(f2p(4)-f1p(4))/2];
     set(F1,'Position',[xy f1p(3:4)]);
     set(F1,'Units',f1u);
  else
     f1p = get(F1,'Position');
     xy = [f2p(1)+(f2p(3)-f1p(3))/2 f2p(2)+(f2p(4)-f1p(4))/2];
     set(F1,'Position',[xy f1p(3:4)]);
  end
