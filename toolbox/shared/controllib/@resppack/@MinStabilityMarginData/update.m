function update(cd,r)
%UPDATE  Data update method @MinStabilityMarginData class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:18:56 $

rdata = cd.Parent;
if length(r.RowIndex)==1 && length(r.ColumnIndex)==1
   freq = unitconv(rdata.Frequency,rdata.FreqUnits,'rad/s');
   Focus = unitconv(rdata.Focus,rdata.FreqUnits,'rad/s');
   if ~isempty(r.DataSrc)
      r.DataSrc.getmargin('min',cd,find(r.Data==rdata));
   else
      % If the response data type is resppack.freqdata, (i.e. Nyquist),
      % then convert to magnitude and phase.  Otherwise use the magnitude
      % and phase from the response data.
      if isa(rdata,'resppack.freqdata')
         mag = abs(rdata.Response);
         phase = unitconv(unwrap(angle(rdata.Response)),'rad','deg');
      else
         mag = unitconv(rdata.Magnitude,rdata.MagUnits,'abs');
         phase = unitconv(rdata.Phase,rdata.PhaseUnits,'deg');
      end
      
      % Compute gain and phase margins for k=th model
      [Gm,Pm,Wcg,Wcp] = imargin(mag,phase,freq,'all');
      
      % Eliminate NaN crossings
      idxf = isfinite(Wcg);
      Wcg = Wcg(:,idxf);     Gm = Gm(:,idxf);
      idxf = isfinite(Wcp);
      Wcp = Wcp(:,idxf);     Pm = Pm(:,idxf);
      
      % Delay margins
      Dm = zeros(size(Pm));
      Dm(Pm>=0 & Wcp>0) = (pi/180) * Pm(Pm>=0 & Wcp>0) ./ Wcp(Pm>=0 & Wcp>0);
      Dm(Pm<0 & Wcp>0) = (pi/180) * (360 + Pm(Pm<0 & Wcp>0)) ./ Wcp(Pm<0 & Wcp>0);
      Dm(Wcp==0) = Inf;
      
      if isempty(Gm)
         cd.GainMargin = NaN;
         cd.GMFrequency = NaN;
      elseif ~any(Gm)
         cd.GMFrequency = NaN;
         cd.GainMargin  = Inf;
      else
         ind = find(Gm==0);
         Gm(ind) = [];
         Wcg(ind) = [];
         [Gm_min,ind_m] = min(log2(abs(Gm)));
         cd.GMFrequency = Wcg(ind_m);
         cd.GainMargin  = Gm(ind_m);
      end
      
      if isempty(Pm)
         cd.PhaseMargin = NaN; 
         cd.PMFrequency = NaN;
         cd.DMFrequency = NaN;
         cd.DelayMargin = NaN;
         %% If the system is pure data, then don't assume a sample rate
         %% and return the delay margin in seconds.
         cd.Ts = 0;
      else
         [Pm_min,ind] = min(abs(Pm)); 
         cd.PhaseMargin = Pm(ind); 
         cd.PMFrequency = Wcp(ind);
         cd.DMFrequency = Wcp(ind);
         cd.DelayMargin = Dm(ind);
         %% If the system is pure data, then don't assume a sample rate
         %% and return the delay margin in seconds.
         cd.Ts = 0;
      end
   end
   
   % Extend frequency focus by up to two decades to include margin markers
   MarginFreqs = [cd.GMFrequency cd.PMFrequency cd.DMFrequency];
   if isempty(Focus)
      MarginFreqs = MarginFreqs(:,isfinite(MarginFreqs) & MarginFreqs>0);
      Focus = [min(MarginFreqs)/2,2*max(MarginFreqs)];
   else
      MarginFreqs = MarginFreqs(:,MarginFreqs >= max(rdata.Frequency(1),Focus(1)/100) & ...
         MarginFreqs <= min(rdata.Frequency(end),Focus(2)*100));
      Focus = [min([Focus(1),MarginFreqs]),max([Focus(2),MarginFreqs])];
   end
   rdata.Focus = unitconv(Focus,'rad/s',rdata.FreqUnits);
   
else
   cd.GMFrequency = zeros(1,0);
   cd.GainMargin = zeros(1,0);
   cd.PMFrequency = zeros(1,0);
   cd.PhaseMargin = zeros(1,0); 
   cd.DMFrequency = zeros(1,0);
   cd.DelayMargin = zeros(1,0);   
end
