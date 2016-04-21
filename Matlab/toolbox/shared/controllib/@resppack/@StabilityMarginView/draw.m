function draw(cv,cd,NormalRefresh)
%DRAW  Draws stability margin characteristic.

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:36 $

% RE: DRAW in charge of adjusting the number of characteristic points.
%     Actual drawing delegated to ADJUSTVIEW because it is limit dependent.
if isempty(cv.MagPoints)
   % Not a SISO response
   return
end
ndata = max([1,length(cd.GainMargin),length(cd.PhaseMargin)]);
nviews = length(cv.MagPoints);

% If a dataSrc has been replaced by one with fewer crossings we need to
% destroy additional characteristic lines so that characteristics from the 
% former system are not visible
if ndata<nviews
   idx = ndata+1:nviews;
   Tips = [cv.MagTips(idx);cv.PhaseTips(idx)];  
   delete(Tips(ishandle(Tips)))
   Lines = [cv.MagPoints(idx);cv.Maglines(idx);cv.MagCrossLines(idx);...
         cv.PhasePoints(idx);cv.PhaseLines(idx);cv.PhaseCrossLines(idx)];
   delete(Lines(ishandle(Lines)))
   cv.MagPoints = cv.MagPoints(1:ndata);
   cv.MagLines = cv.MagLines(1:ndata);
   cv.MagCrossLines = cv.MagCrossLines(1:ndata);
   cv.MagTips = cv.MagTips(1:ndata);
   cv.PhasePoints = cv.PhasePoints(1:ndata);
   cv.PhaseLines = cv.PhaseLines(1:ndata);
   cv.PhaseCrossLines = cv.PhaseCrossLines(1:ndata);
   cv.PhaseTips = cv.PhaseTips(1:ndata);
end

% If more stability characteristic markers are needed, 
% add them to the end of the list.
% RE: GHANDLE requires MAGPOINTS and PHASEPOINTS to be of same length
if ndata>nviews
   % UDDREVISIT  cv.MagLines(ct,1) = rhs does not work
   MagPoints = cv.MagPoints;
   MagLines = cv.MagLines;
   MagCrossLines = cv.MagCrossLines;
   MagTips = cv.MagTips;
   PhasePoints = cv.PhasePoints;
   PhaseLines = cv.PhaseLines;
   PhaseCrossLines = cv.PhaseCrossLines;
   PhaseTips = cv.PhaseTips;

   % Magnitude Characteristics
   Parent = get(cv.MagPoints(1),'Parent');
   for ct=ndata:-1:nviews+1
      MagPoints(ct,1) = handle(copyobj(cv.MagPoints(1),Parent));
      MagLines(ct,1) = handle(copyobj(cv.MagLines(1),Parent));
      MagCrossLines(ct,1) = handle(copyobj(cv.MagCrossLines(1),Parent));
      MagTips(ct,1) = handle(NaN);
   end
   
   % Phase Characteristics
   Parent = get(cv.PhasePoints(1),'Parent');
   for ct=ndata:-1:nviews+1
      PhasePoints(ct,1) = handle(copyobj(cv.PhasePoints(1),Parent));
      PhaseLines(ct,1) = handle(copyobj(cv.PhaseLines(1),Parent));
      PhaseCrossLines(ct,1) = handle(copyobj(cv.PhaseCrossLines(1),Parent));
      PhaseTips(ct,1) = handle(NaN);
   end
   
   cv.MagPoints = MagPoints;
   cv.MagLines = MagLines;
   cv.MagCrossLines = MagCrossLines;
   cv.MagTips = MagTips;
   cv.PhasePoints = PhasePoints;
   cv.PhaseLines = PhaseLines;
   cv.PhaseTips = PhaseTips;
   cv.PhaseCrossLines = PhaseCrossLines;
end
