function [sys, x0] = animrule(t, x, u, flag, fismatrix)
%ANIMRULE call fuzzy rule viewer during simulation.
%   Animation of fuzzy rules during simulation. This function calls ruleview 
%   during simulation to show how rules are fired. 
%
%   Animation S-function: animrule.m
%   SIMULINK file: fuzblkrule.mdl 
%
%   Type sltankrule in MATLAB command line to see a demo.

%   Kelly Liu 10-6-97
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.8.2.3 $  $Date: 2004/04/10 23:15:15 $
if nargin<5 || isempty(fismatrix)
   return
else
   % Find handle of RuleViewer figure associated with FIS
   fig = findall(0,'Type','figure','Name',sprintf('Rule Viewer: %s',fismatrix.name));
   switch flag
      case 0
         % Initialization
         if isempty(fig)
            ruleview(fismatrix);
            fig = findall(0,'Type','figure','Name',sprintf('Rule Viewer: %s',fismatrix.name));
            position=get(fig, 'Position');
            set(fig, 'Position', position+[.2 -.2 0 0]);
         else
            figure(fig);
         end
         sys = [0 0 0 -1 0 0];
         x0=[];

      case 2
         % Run time
         if ~isempty(fig)
            set(fig, 'HandleVisibi', 'on');
            ruleview('#simulink', u, fig);
            set(fig, 'HandleVisibi', 'callback');
         end
         sys = [];
         x0=[];
         drawnow;    % for invoking with rk45, etc.
   end
end
