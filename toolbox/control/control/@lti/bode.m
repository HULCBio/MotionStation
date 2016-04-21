function [magout,phase,w] = bode(varargin)
%BODE  Bode frequency response of LTI models.
%
%   BODE(SYS) draws the Bode plot of the LTI model SYS (created with
%   either TF, ZPK, SS, or FRD).  The frequency range and number of  
%   points are chosen automatically.
%
%   BODE(SYS,{WMIN,WMAX}) draws the Bode plot for frequencies
%   between WMIN and WMAX (in radians/second).
%
%   BODE(SYS,W) uses the user-supplied vector W of frequencies, in
%   radian/second, at which the Bode response is to be evaluated.  
%   See LOGSPACE to generate logarithmically spaced frequency vectors.
%
%   BODE(SYS1,SYS2,...,W) graphs the Bode response of multiple LTI
%   models SYS1,SYS2,... on a single plot.  The frequency vector W
%   is optional.  You can specify a color, line style, and marker 
%   for each model, as in  
%      bode(sys1,'r',sys2,'y--',sys3,'gx').
%
%   [MAG,PHASE] = BODE(SYS,W) and [MAG,PHASE,W] = BODE(SYS) return the
%   response magnitudes and phases in degrees (along with the frequency 
%   vector W if unspecified).  No plot is drawn on the screen.  
%   If SYS has NY outputs and NU inputs, MAG and PHASE are arrays of 
%   size [NY NU LENGTH(W)] where MAG(:,:,k) and PHASE(:,:,k) determine 
%   the response at the frequency W(k).  To get the magnitudes in dB, 
%   type MAGDB = 20*log10(MAG).
%
%   For discrete-time models with sample time Ts, BODE uses the
%   transformation Z = exp(j*W*Ts) to map the unit circle to the 
%   real frequency axis.  The frequency response is only plotted 
%   for frequencies smaller than the Nyquist frequency pi/Ts, and 
%   the default value 1 (second) is assumed when Ts is unspecified.
%
%   See also BODEMAG, NICHOLS, NYQUIST, SIGMA, FREQRESP, LTIVIEW, LTIMODELS.

%   Authors: P. Gahinet  8-14-96
%   Revised: A. DiVergilio
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.49.4.3 $  $Date: 2004/04/10 23:13:14 $

ni = nargin;
no = nargout;
if ni==0,
   eval('exresp(''bode'')')
   return
end

% Parse input list
try
   for ct = ni:-1:1
      ArgNames(ct,1) = {inputname(ct)};
   end
   [sys,SystemName,InputName,OutputName,PlotStyle,ExtraArgs] = ...
      rfinputs('bode',ArgNames,varargin{:});
catch
   rethrow(lasterror)
end
w = ExtraArgs{1};
nsys = length(sys);

% Handle various calling sequences
if no,
   % Call with output arguments
   sys = sys{1};  % single model
   if (nsys>1 | ndims(sys)>2),
      error('BODE takes a single model when used with output arguments.')
   elseif isempty(w)
      w = 'decade';  % make sure to include decades for ROUNDFOCUS below
   end
   % Compute frequency response
   if isnumeric(w)
      % Supplied grid
      h = freqresp(sys,w);
      m = abs(h);   
      p = unwrap(angle(h));
   else
      [m,p,w,FocusInfo] = genfresp(sys,3,w);
      m = permute(m,[2 3 1]);
      p = permute(p,[2 3 1]);
      % Clip to FOCUS and make W(1) and W(end) entire decades
      [w,m,p] = roundfocus('freq',FocusInfo.Range(3,:),w,m,p);
   end
   % Set units
   magout = m;
   phase = (180/pi)*p;
   
else
   % Bode response plot
   % Create plot (visibility ='off')
   try
      h = ltiplot(gca,'bode',InputName,OutputName,cstprefs.tbxprefs);
   catch
      rethrow(lasterror)
   end
   
   % Set global frequency focus for user-defined range/vector (specifies preferred limits)
   if iscell(w)
       h.setfocus([w{:}],'rad/sec')
   elseif ~isempty(w)
       % Unique frequencies, to avoid interpolation incompatibility
       % for other calculations. Resolution for G154921
       w = unique(w); 
       h.setfocus([w(1) w(end)],'rad/sec')
   end
   
   % Create responses
   for ct=1:nsys
      src = resppack.ltisource(sys{ct},'Name',SystemName{ct});
      r = h.addresponse(src);
      r.DataFcn = {'magphaseresp' src 'bode' r w};
      % Styles and preferences
      initsysresp(r,'bode',h.Preferences,PlotStyle{ct})
   end
   
   % Draw now
   if strcmp(h.AxesGrid.NextPlot,'replace')
      h.Visible = 'on';  % new plot created with Visible='off'
   else
      draw(h)  % hold mode
   end
   
   % Right-click menus
   m = ltiplotmenu(h,'bode');
   lticharmenu(h,m.Characteristics,'bode');
end