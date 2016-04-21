function src = findbussrc(busStruct, signal)
% FINDBUSSRC
%    This function will return the number of input signals in the block, and
%    the input signals name in a string format delimitated by ",".
%
%    Jun Wu, Apr. 2001
%
%    Copyright 1990-2002 The MathWorks, Inc.
%    $Revision: 1.3 $  $Date: 2002/04/10 18:29:03 $

src = [];

[signal, signalStruct] = strtok(signal, '.');

% clean up the signal's name first, i.e., remove blanks and '+' or '-', etc.
minusPlusSignIdx = [findstr(signal, '-') findstr(signal, '+')];
if ~isempty(minusPlusSignIdx)
  signal = signal(minusPlusSignIdx+1:end);
end
signal = deblankall(signal);

if ~isempty(busStruct)
  for i=1:length(busStruct)
    %
    % Note: this deblankall can be avoided if we always set signal name
    % without leading or trailing blanks.
    %
    if strcmp(deblankall(busStruct(i).name), signal) 
      if isempty(signalStruct)
	src = busStruct(i).src;
	return;
      else
	subBusStruct = busStruct(i).signals;
	src = findbussrc(subBusStruct, signalStruct);
	if ~isempty(src)
	  return;
	end
      end
    end
  end
end

% end findbussrc

