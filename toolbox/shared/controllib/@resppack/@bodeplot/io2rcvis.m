function rcvis = io2rcvis(this,rcflag,iovis)
%IO2RCVIS  Converts I/O visibility into row/column visibility for @axesgrid.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:23 $

switch rcflag
case 'r'
   rcvis = [iovis iovis];
   if strcmp(this.MagVisible,'off'),
      rcvis(:,1) = {'off'};
   end
   if strcmp(this.PhaseVisible,'off'),
      rcvis(:,2) = {'off'};
   end
   rcvis = reshape(rcvis',[2*length(iovis),1]);
case 'c'
   rcvis = iovis;
end
