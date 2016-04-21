function [flag,fig] = deeflag(str,silent)
%DEEFLAG True if figure is currently displayed on screen.
%   [FLAG,FIG] = DEEFLAG(STR,SILENT) checks to see if any figure 
%   with Name STR is presently on the screen. If such a figure is 
%   presently on the screen, FLAG=1, else FLAG=0.  If SILENT=0, the
%   figures are brought to the front.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.9 $
%   Jay Torgerson

ni = nargin;
if ni==0,
   error('FIGFLAG must have at least one argument.');
elseif ni==1,
   silent = 0;
end

fig = [];
flag = 0;
rchi = get(0,'Children');
for i = 1:length(rchi),
   if strcmp(get(rchi(i),'type'),'figure'), % If the object is a figure
      figureName=get(rchi(i),'Name');
      if strcmp(figureName,str),
         fig = [fig rchi(i)];
         flag = 1; 
         if ~silent,
            figure(rchi(i));
         end
      end 
   end 
end

% end deeflag
