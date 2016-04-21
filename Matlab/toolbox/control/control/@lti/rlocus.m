function [rout,kout] = rlocus(varargin)
%RLOCUS  Evans root locus.
%
%   RLOCUS(SYS) computes and plots the root locus of the single-input,
%   single-output LTI model SYS.  The root locus plot is used to 
%   analyze the negative feedback loop
%
%                     +-----+
%         ---->O----->| SYS |----+---->
%             -|      +-----+    |
%              |                 |
%              |       +---+     |
%              +-------| K |<----+
%                      +---+
%
%   and shows the trajectories of the closed-loop poles when the feedback 
%   gain K varies from 0 to Inf.  RLOCUS automatically generates a set of 
%   positive gain values that produce a smooth plot.  
%
%   RLOCUS(SYS,K) uses a user-specified vector K of gain values.
%
%   RLOCUS(SYS1,SYS2,...) draws the root loci of multiple LTI models  
%   SYS1, SYS2,... on a single plot.  You can specify a color, line style, 
%   and marker for each model, as in  
%      rlocus(sys1,'r',sys2,'y:',sys3,'gx').
%
%   [R,K] = RLOCUS(SYS) or R = RLOCUS(SYS,K) returns the matrix R of
%   complex root locations for the gains K.  R has LENGTH(K) columns
%   and its j-th column lists the closed-loop roots for the gain K(j).  
%
%   See also SISOTOOL, POLE, ISSISO, LTIMODELS.

%   J.N. Little 10-11-85
%   Revised A.C.W.Grace 7-8-89, 6-21-92 
%   Revised P. Gahinet 7-96
%   Revised A. DiVergilio 6-00
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.37.4.3 $  $Date: 2004/04/20 23:15:53 $

ni = nargin;
no = nargout;
if ni==0,
   eval('exresp(''rlocus'');')
   return
end

% Parse input list
try
   for ct = ni:-1:1
      ArgNames(ct,1) = {inputname(ct)};
   end
   [sys,SystemName,InputName,OutputName,PlotStyle,ExtraArgs] = ...
      rfinputs('rlocus',ArgNames,varargin{:});
catch
   rethrow(lasterror)
end
GainVector = ExtraArgs{1};
nsys = length(sys);
         
% Handle various calling sequences
if no
   % Compute locus data
   sys = sys{1};
   if (nsys>1 | ndims(sys)>2)
      error('RLOCUS takes a single model when used with output arguments.')
   else
      [rout,kout] = genrlocus(sys,GainVector);
   end

else
   % Root locus plot
   % Create plot (visibility ='off')
   h = ltiplot(gca,'rlocus',[],[],cstprefs.tbxprefs);
   
   % Create responses
   GainVector = unique(GainVector);
   for ct=1:nsys
      src = resppack.ltisource(sys{ct},'Name',SystemName{ct});
      r = h.addresponse(src);
      r.DataFcn = {'rlocus' src r GainVector};
      % Styles and preferences
      initsysresp(r,'rlocus',h.Preferences,PlotStyle{ct})
   end
   
   % Trap case of single model with unspecified color 
   % (use different color for each branch in this case)
   if nsys==1 & ndims(sys{1})==2 & LocalNoColor(PlotStyle{1})
      r.View.BranchColorList = ...
         {[0 0 1],[0 .5 0],[1 0 0],[0 .75 .75],[.75 0 .75],[.75 .75 0],[.25 .25 .25]};
   end
   
   % Draw now
   if strcmp(h.AxesGrid.NextPlot,'replace')
      h.Visible = 'on';  % new plot created with Visible='off'
   else
      draw(h)  % hold mode
   end

   % Right-click menus
   m = ltiplotmenu(h,'rlocus');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function boo = LocalNoColor(PlotStyle)
if ~isempty(PlotStyle)
   [L,C,M] = colstyle(PlotStyle);
   boo = isempty(C);
else
   boo = true;
end