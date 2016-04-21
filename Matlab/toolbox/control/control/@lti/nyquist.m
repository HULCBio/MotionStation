function [reout,im,w] = nyquist(varargin)
%NYQUIST  Nyquist frequency response of LTI models.
%
%   NYQUIST(SYS) draws the Nyquist plot of the LTI model SYS
%   (created with either TF, ZPK, SS, or FRD).  The frequency range 
%   and number of points are chosen automatically.  See BODE for  
%   details on the notion of frequency in discrete-time.
%
%   NYQUIST(SYS,{WMIN,WMAX}) draws the Nyquist plot for frequencies
%   between WMIN and WMAX (in radians/second).
%
%   NYQUIST(SYS,W) uses the user-supplied vector W of frequencies 
%   (in radian/second) at which the Nyquist response is to be evaluated.  
%   See LOGSPACE to generate logarithmically spaced frequency vectors.
%
%   NYQUIST(SYS1,SYS2,...,W) plots the Nyquist response of multiple
%   LTI models SYS1,SYS2,... on a single plot.  The frequency vector
%   W is optional.  You can also specify a color, line style, and marker 
%   for each system, as in  
%      nyquist(sys1,'r',sys2,'y--',sys3,'gx').
%
%   [RE,IM] = NYQUIST(SYS,W) and [RE,IM,W] = NYQUIST(SYS) return the
%   real parts RE and imaginary parts IM of the frequency response 
%   (along with the frequency vector W if unspecified).  No plot is 
%   drawn on the screen.  If SYS has NY outputs and NU inputs,
%   RE and IM are arrays of size [NY NU LENGTH(W)] and the response 
%   at the frequency W(k) is given by RE(:,:,k)+j*IM(:,:,k).
%
%   See also BODE, NICHOLS, SIGMA, FREQRESP, LTIVIEW, LTIMODELS.

%   Authors: P. Gahinet 6-21-96
%   Revised: A. DiVergilio, 6-16-00
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.34.4.2 $  $Date: 2004/04/10 23:13:21 $

ni = nargin;
no = nargout;
if ni==0,
   eval('exresp(''nyquist'')')
   return
end

% Parse input list
try
   for ct = ni:-1:1
      ArgNames(ct,1) = {inputname(ct)};
   end
   [sys,SystemName,InputName,OutputName,PlotStyle,ExtraArgs] = ...
      rfinputs('nyquist',ArgNames,varargin{:});
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
      error('NYQUIST takes a single model when used with output arguments.')
   elseif isempty(w)
      w = 'decade';  % make sure to include decades for ROUNDFOCUS below
   end
   % Compute frequency response
   if isnumeric(w)
      % Supplied grid
      h = freqresp(sys,w);
   else
      [m,p,w,FocusInfo] = genfresp(sys,1,w);  % Grade=1
      m = permute(m,[2 3 1]);
      p = permute(p,[2 3 1]);
      % Clip to FOCUS and make W(1) and W(end) entire decades
      % RE: Use Nichols focus to avoid grid extending to 0 or Inf with
      %     nonzero rel. degree
      [w,m,p] = roundfocus('freq',FocusInfo.Range(2,:),w,m,p);
      h = m .* exp(1i*p);
   end
   reout = real(h);
   im = imag(h);
   
else
   % Nyquist plot
   % Create plot
   try
      h = ltiplot(gca,'nyquist',InputName,OutputName,cstprefs.tbxprefs);
   catch
      rethrow(lasterror)
   end
   
   if isnumeric(w)
       % Unique frequencies, to avoid interpolation incompatibility 
       % for other calculations. Resolution for G154921 
       w = unique(w); 
   end
   
   % Create responses
   for ct=1:nsys
      src = resppack.ltisource(sys{ct},'Name',SystemName{ct});
      r = h.addresponse(src);
      r.DataFcn = {'nyquist' src r w};
      % Styles and preferences
      initsysresp(r,'nyquist',h.Preferences,PlotStyle{ct})
   end
   
   % Draw now
   if strcmp(h.AxesGrid.NextPlot,'replace')
      h.Visible = 'on';  % new plot created with Visible='off'
   else
      draw(h)  % hold mode
   end
   
   % Right-click menus
   m = ltiplotmenu(h,'nyquist');
   lticharmenu(h,m.Characteristics,'nyquist');
end