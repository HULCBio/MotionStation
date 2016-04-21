function Str = describe(LoopData,Component,CompactFlag)
%DESCRIBE  Info about the loop components and variables.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 04:53:51 $

if LoopData.Ts
    DomainVar = 'z';
else
    DomainVar = 's';
end

if ~any(LoopData.Configuration==[1 2 3 4])
   Compact = '';   Full = '';  % first initialize stops here
else
   switch Component
   case 'C'
      Compact = 'Compensator';
      Full = sprintf('compensator C(%s)',DomainVar);
   case 'F'
      switch LoopData.Configuration
      case {1 2}
         Compact = 'Prefilter';
         Full = sprintf('prefilter F(%s)',DomainVar);
      case 3
         Compact = 'Feedforward';
         Full = sprintf('feedforward F(%s)',DomainVar);
      case 4
         Compact = 'Filter';
         Full = sprintf('filter F(%s)',DomainVar);
      end
   end
end

% Return compact or full description
if nargin>2
	Str = Compact;
else
	Str = Full;
end
