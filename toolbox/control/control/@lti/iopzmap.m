function iopzmap(varargin)
%IOPZMAP  Plots poles and zeros for each I/O pair of an LTI model.
%
%   IOPZMAP(SYS) computes and plots the poles and zeros of each input/output  
%   pair of the LTI model SYS.  The poles are plotted as x's and the zeros are 
%   plotted as o's.  
%
%   IOPZMAP(SYS1,SYS2,...) shows the poles and zeros of multiple LTI models 
%   SYS1,SYS2,... on a single plot.  You can specify distinctive colors for 
%   each model, as in  iopzmap(sys1,'r',sys2,'y',sys3,'g')
%
%   The functions SGRID or ZGRID can be used to plot lines of constant
%   damping ratio and natural frequency in the s or z plane.
%
%   For arrays SYS of LTI models, IOPZMAP plots the poles and zeros of
%   each model in the array on the same diagram.
%
%   See also PZMAP, POLE, ZERO, SGRID, ZGRID, RLOCUS, LTIMODELS.
 
%  Kamesh Subbarao 10-29-2001
%	Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/05/04 02:13:50 $

% Parse input list
ni = nargin;
try
   for ct = ni:-1:1
      ArgNames(ct,1) = {inputname(ct)};
   end
   [sys,SystemName,InputName,OutputName,PlotStyle] = ...
      rfinputs('iopzmap',ArgNames,varargin{:});
catch
   rethrow(lasterror)
end
nsys = length(sys);

% Call with graphical output: plot using LTIPlot
h = ltiplot(gca,'iopzmap',InputName,OutputName,cstprefs.tbxprefs);

% Create responses
for ct=1:nsys
   src = resppack.ltisource(sys{ct},'Name',SystemName{ct});
   r = h.addresponse(src);
   r.DataFcn = {'pzmap' src r 'io'};
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