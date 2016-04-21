function [si,so] = dspblkstack(action, clri,eso,fso,nso)
% DSPBLKSTACK Signal Processing Blockset help function for
%   Stack and Queue blocks.


% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.6.4.2 $ $Date $

if nargin==0, action='dynamic'; end

switch action
case 'dynamic'
   % Dynamic dialog behavior
   
   % If "Clear input" not selected, disable "Reset data output port on clear" dialog
   clr_inport = strcmp(get_param(gcbh,'clr'),'on');
   ena=get_param(gcbh,'maskenables');
   if clr_inport, ena{9}='on'; else ena{9}='off'; end
   set_param(gcbh,'maskenables',ena);
   
case 'icon'
   % Input port labels:
   si(1).port = 1;
   si(1).txt = 'In';
   si(2).port = 2;
   si(2).txt = 'Push';
   si(3).port = 3;
   si(3).txt = 'Pop';
   if clri,
      si(4).port = 4;
      si(4).txt = 'Clr';
   else
      si(4) = si(3);
   end
   
   % Output port labels:
   i=1;
   so(i).port = 1;
   so(i).txt = 'Out';
   
   if eso,
      i=i+1;
      so(i).port = i;
      so(i).txt = 'Empty';
   end
   if fso,
      i=i+1;
      so(i).port = i;
      so(i).txt = 'Full';
   end
   if nso,
      i=i+1;
      so(i).port = i;
      so(i).txt = 'Num';
   end
   
   for j=i+1:4, so(j)=so(i); end
end

% [EOF] dspblkstack.m
