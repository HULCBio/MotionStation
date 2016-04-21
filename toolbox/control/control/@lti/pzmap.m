function [pout,zout] = pzmap(varargin)
%PZMAP  Pole-zero map of LTI models.
%
%   PZMAP(SYS) computes the poles and (transmission) zeros of the
%   LTI model SYS and plots them in the complex plane.  The poles 
%   are plotted as x's and the zeros are plotted as o's.  
%
%   PZMAP(SYS1,SYS2,...) shows the poles and zeros of multiple LTI
%   models SYS1,SYS2,... on a single plot.  You can specify 
%   distinctive colors for each model, as in  
%      pzmap(sys1,'r',sys2,'y',sys3,'g')
%
%   [P,Z] = PZMAP(SYS) returns the poles and zeros of the system 
%   in two column vectors P and Z.  No plot is drawn on the screen.  
%
%   The functions SGRID or ZGRID can be used to plot lines of constant
%   damping ratio and natural frequency in the s or z plane.
%
%   For arrays SYS of LTI models, PZMAP plots the poles and zeros of
%   each model in the array on the same diagram.
%
%   See also IOPZMAP, POLE, ZERO, SGRID, ZGRID, RLOCUS, LTIMODELS.

%	Clay M. Thompson  7-12-90
%	Revised ACWG 6-21-92, AFP 12-1-95, PG 5-10-96, ADV 6-16-00
%          Kamesh Subbarao 10-29-2001
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.22 $  $Date: 2002/05/04 02:13:53 $

ni = nargin;
if ni==0,
   eval('exresp(''pzmap'')')
   return
end

% Parse input list
try
   for ct = ni:-1:1
      ArgNames(ct,1) = {inputname(ct)};
   end
   [sys,SystemName,InputName,OutputName,PlotStyle] = ...
      rfinputs('pzmap',ArgNames,varargin{:});
catch
   rethrow(lasterror)
end
nsys = length(sys);

% Handle various calling sequences
if nargout
   % Compute poles and zeros
   if nsys>1,
      error('PZMAP takes a single model when used with output arguments.')
   else
      pout = pole(sys{1});
      zout = zero(sys{1});
   end
else
   % Call with graphical output: plot using LTIPlot
   h = ltiplot(gca,'pzmap',InputName,OutputName,cstprefs.tbxprefs);
   
   % Create responses
   for ct=1:nsys
      src = resppack.ltisource(sys{ct},'Name',SystemName{ct});
      r = h.addresponse(src);
      r.DataFcn = {'pzmap' src r};
      % Styles and preferences
      initsysresp(r,'pzmap',h.Preferences,PlotStyle{ct})
   end
   
   % Draw now
   if strcmp(h.AxesGrid.NextPlot,'replace')
      h.Visible = 'on';  % new plot created with Visible='off'
   else
      draw(h)  % hold mode
   end
   
   % Right-click menus
   m = ltiplotmenu(h, 'pzmap');
   lticharmenu(h, m.Characteristics, 'pzmap');
end