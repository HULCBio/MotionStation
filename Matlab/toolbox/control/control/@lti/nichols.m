function [magout,phase,w] = nichols(varargin)
%NICHOLS  Nichols frequency response of LTI models.
%
%   NICHOLS(SYS) draws the Nichols plot of the LTI model SYS
%   (created with either TF, ZPK, SS, or FRD).  The frequency range  
%   and number of points are chosen automatically.  See BODE for  
%   details on the notion of frequency in discrete-time.
%
%   NICHOLS(SYS,{WMIN,WMAX}) draws the Nichols plot for frequencies
%   between WMIN and WMAX (in radian/second).
%
%   NICHOLS(SYS,W) uses the user-supplied vector W of frequencies, in
%   radians/second, at which the Nichols response is to be evaluated.  
%   See LOGSPACE to generate logarithmically spaced frequency vectors.
%
%   NICHOLS(SYS1,SYS2,...,W) plots the Nichols plot of multiple LTI
%   models SYS1,SYS2,... on a single plot.  The frequency vector W
%   is optional.  You can also specify a color, line style, and marker 
%   for each system, as in  
%      nichols(sys1,'r',sys2,'y--',sys3,'gx').
%
%   [MAG,PHASE] = NICHOLS(SYS,W) and [MAG,PHASE,W] = NICHOLS(SYS) return
%   the response magnitudes and phases in degrees (along with the 
%   frequency vector W if unspecified).  No plot is drawn on the screen.  
%   If SYS has NY outputs and NU inputs, MAG and PHASE are arrays of 
%   size [NY NU LENGTH(W)] where MAG(:,:,k) and PHASE(:,:,k) determine 
%   the response at the frequency W(k).
%
%   See also BODE, NYQUIST, SIGMA, FREQRESP, LTIVIEW, LTIMODELS.

%   Authors: P. Gahinet, B. Eryilmaz
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.38.4.2 $  $Date: 2004/04/10 23:13:20 $

ni = nargin;
no = nargout;
if ni == 0,
   eval('exresp(''nichols'')')
   return
end

% Parse input list
try
   for ct = ni:-1:1
      ArgNames(ct,1) = {inputname(ct)};
   end
   [sys,SystemName,InputName,OutputName,PlotStyle,ExtraArgs] = ...
      rfinputs('nichols',ArgNames,varargin{:});
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
      error('NICHOLS takes a single model when used with output arguments.')
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
      [m,p,w,FocusInfo] = genfresp(sys,2,w);  % Grade=2
      m = permute(m,[2 3 1]);
      p = permute(p,[2 3 1]);
      % Clip to FOCUS and make W(1) and W(end) entire decades
      [w,m,p] = roundfocus('freq',FocusInfo.Range(2,:),w,m,p);
   end
   % Set units
   magout = m;
   phase = (180/pi)*p;
   
else
   % Nichols plot
   % Create plot (visibility ='off')
   try
       h = ltiplot(gca, 'nichols', InputName, OutputName, cstprefs.tbxprefs);
   catch
       rethrow(lasterror)
   end
   
   if isnumeric(w)
       % Unique frequencies, to avoid interpolation incompatibility 
       % for other calculations. Resolution for G154921 
       w = unique(w); 
   end

   % Create responses
   for ct = 1:nsys
       src = resppack.ltisource(sys{ct}, 'Name', SystemName{ct});
      r = h.addresponse(src);
      r.DataFcn = {'magphaseresp' src 'nichols' r w};
      % Styles and preferences
      initsysresp(r,'nichols',h.Preferences,PlotStyle{ct})
   end
   
   % Draw now
   if strcmp(h.AxesGrid.NextPlot, 'replace')
      h.Visible = 'on';  % new plot created with Visible='off'
   else
      draw(h)  % hold mode
   end
   
   % Right-click menus
   m = ltiplotmenu(h, 'nichols');
   lticharmenu(h, m.Characteristics, 'nichols');
end
