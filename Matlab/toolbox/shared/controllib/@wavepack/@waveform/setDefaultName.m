function setDefaultName(this,WaveList)
%SETDEFAULTNAME  Assigns default name to unnamed waveforms.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:21 $

% Resolve wave name
if isempty(this.Name)
   % Assign untitled## name when name is unspecified
   Names = get(WaveList,{'Name'});
   Names = [Names{:}];
   n = 1;
   while ~isempty(strfind(Names,sprintf('untitled%d',n)))
      n = n+1;
   end
   this.Name = sprintf('untitled%d',n);
end
