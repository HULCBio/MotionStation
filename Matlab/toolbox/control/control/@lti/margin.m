function [Gmout,Pm,Wcg,Wcp,isStable] = margin(sys)
%MARGIN  Gain and phase margins and crossover frequencies.
%
%   [Gm,Pm,Wcg,Wcp] = MARGIN(SYS) computes the gain margin Gm, the
%   phase margin Pm, and the associated frequencies Wcg and Wcp, 
%   for the SISO open-loop model SYS (continuous or discrete). 
%   The gain margin Gm is defined as 1/G where G is the gain at 
%   the -180 phase crossing.  The phase margin Pm is in degrees.  
%
%   The gain margin in dB is derived by 
%      Gm_dB = 20*log10(Gm)
%   The loop gain at Wcg can increase or decrease by this many dBs
%   before losing stability, and Gm_dB<0 (Gm<1) means that stability 
%   is most sensitive to loop gain reduction.  If there are several 
%   crossover points, MARGIN returns the smallest margins (gain 
%   margin nearest to 0 dB and phase margin nearest to 0 degrees).
%
%   For a S1-by...-by-Sp array SYS of LTI models, MARGIN returns 
%   arrays of size [S1 ... Sp] such that
%      [Gm(j1,...,jp),Pm(j1,...,jp)] = MARGIN(SYS(:,:,j1,...,jp)) .  
%
%   [Gm,Pm,Wcg,Wcp] = MARGIN(MAG,PHASE,W) derives the gain and phase
%   margins from the Bode magnitude, phase, and frequency vectors 
%   MAG, PHASE, and W produced by BODE.  Interpolation is performed 
%   between the frequency points to estimate the values. 
%
%   MARGIN(SYS), by itself, plot the open-loop Bode plot with 
%   the gain and phase margins marked with a vertical line. 
%
%   See also ALLMARGIN, BODE, LTIVIEW, LTIMODELS.

%   Note: if there is more than one crossover point, margin will
%   return the worst case gain and phase margins. 

%   Andrew Grace 12-5-91
%   Revised ACWG 6-21-92
%   Revised P.Gahinet 96-98
%   Revised A.DiVergilio 7-00
%   Revised J.Glass 1-02
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.44 $  $Date: 2002/04/10 05:53:07 $

error(nargchk(1,1,nargin));

% Compute margins
try
    s = allmargin(sys);
catch
    error(lasterr)
end

% Initialize output arrays
asizes = size(s);
nsys = prod(asizes);  % number of models
Gm = zeros(asizes);  Wcg = zeros(asizes);
Pm = zeros(asizes);  Wcp = zeros(asizes);
isStable = zeros(asizes);
for m=1:nsys
    % Compute min (worst-case) gain margins
    GmData = s(m).GainMargin;
    if ~any(GmData)   % empty or zero
        Gm(m) = Inf;   Wcg(m) = NaN;
    else
        % RE: watch for log of zero
        ipos = find(GmData>0);
        [junk,imin] = min(abs(log2(GmData(ipos))));
        Gm(m) = GmData(ipos(imin));
        Wcg(m) = s(m).GMFrequency(ipos(imin));
    end
    
    % Compute min phase margins
    if isempty(s(m).PhaseMargin)
        Pm(m) = Inf;   Wcp(m) = NaN;
    else
        [junk,idx] = min(abs(s(m).PhaseMargin));
        Pm(m) = s(m).PhaseMargin(idx);
        Wcp(m) = s(m).PMFrequency(idx);
    end
    
    % Stability flag
    isStable(m) = s(m).Stable;
end


% Handle case when called w/o output argument
if nargout
    Gmout = Gm;
    if nsys==1 & s.Stable==0
        warning('The closed-loop system is unstable.')
    end
else        
    if nsys>1
        error('Can only plot margins for a single system.')
    end
    
    % Parse input list
    try
       [sys,SystemName,InputName,OutputName,PlotStyle] = ...
          rfinputs('bode',{inputname(1)},sys);
    catch
       error(lasterr)
    end
    
    % Bode response plot
    % Create plot (visibility ='off')
    h = ltiplot(gca,'bode',InputName,OutputName,cstprefs.tbxprefs);
    
    % Create responses
    src = resppack.ltisource(sys{1},'Name',SystemName{1});
    r = h.addresponse(src);
    r.DataFcn = {'magphaseresp' src 'bode' r []};
    % Styles and preferences
    initsysresp(r,'bode',h.Preferences,PlotStyle{1})
    
    % Add margin display
    c = r.addchar('Stability Margins','resppack.MinStabilityMarginData', ...
        'resppack.MarginPlotCharView');
    
    % Draw now
    if strcmp(h.AxesGrid.NextPlot,'replace')
        h.Visible = 'on';  % new plot crated with Visible='off'
    else
        draw(h);  % hold mode
    end
    
    % Right-click menus
    m = ltiplotmenu(h,'margin');
end