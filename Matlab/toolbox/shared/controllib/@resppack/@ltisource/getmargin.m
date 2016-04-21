function getmargin(this, MarginType, cd, ArrayIndex)
%  GETMARGIN  Update all data (@chardata) of the datavie (h = @dataview)
%  using the response source (this = @respsource).

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:20:50 $

if nargin<4
    ArrayIndex = 1;
end

% Get stability margin data
if isempty(this.FreqResponse(ArrayIndex).MarginInfo)
    % Recompute margins
    FreqResponse = this.FreqResponse;
    try
        FreqResponse(ArrayIndex).MarginInfo = allmargin(this.Model(:,:,ArrayIndex));
    catch
        sizes = size(this.Model(:,:,ArrayIndex));
        % If the system is complex then return no margin information 
        FreqResponse(ArrayIndex).MarginInfo = struct(...
            'GMFrequency',cell([sizes(3:end) 1 1]),...
            'GainMargin',[],...
            'PMFrequency',[],...
            'PhaseMargin',[],...
            'DMFrequency',[],...   
            'DelayMargin',[],...
            'Stable',[]);
    end
    this.FreqResponse = FreqResponse;
end
s = this.FreqResponse(ArrayIndex).MarginInfo;
    
% Update the data.
if strcmp(MarginType,'min')
   if isempty(s.GMFrequency)
      cd.GMFrequency = NaN;
      cd.GainMargin  = NaN;
   elseif ~any(s.GainMargin)
      cd.GMFrequency = NaN;
      cd.GainMargin  = Inf;
   else
      %% Remove zero margins from check
      ind = find(s.GainMargin==0);
      s.GainMargin(ind) = [];
      s.GMFrequency(ind) = [];
      [Gm_min,ind_m] = min(abs(log2(s.GainMargin)));
      cd.GMFrequency = s.GMFrequency(ind_m);
      cd.GainMargin  = s.GainMargin(ind_m);
   end
   if isempty(s.PMFrequency)
      cd.PMFrequency = NaN;
      cd.PhaseMargin = NaN;
      cd.DMFrequency = NaN;
      cd.DelayMargin = NaN;
   else
      [PM_min,ind] = min(abs(s.PhaseMargin)); 
      cd.PhaseMargin = s.PhaseMargin(ind);
      cd.PMFrequency = s.PMFrequency(ind);
      cd.DMFrequency = s.DMFrequency(ind);
      cd.DelayMargin = s.DelayMargin(ind);
   end
else
   cd.GMFrequency = s.GMFrequency;
   cd.GainMargin  = s.GainMargin;
   cd.PMFrequency = s.PMFrequency;
   cd.PhaseMargin = s.PhaseMargin;
   cd.DMFrequency = s.DMFrequency;
   cd.DelayMargin = s.DelayMargin;
end

cd.Stable = s.Stable;      
%% Store the sample rate in the characteristic data object so that the
%% proper units will be displayed in the tip function for the
%% phase margin characteristic points.
cd.Ts = get(this.Model(:,:,ArrayIndex),'Ts');