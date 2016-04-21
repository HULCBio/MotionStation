function postdeserialize(this)
%POSTDESERIALIZE Post deserialize stem plot
  
%   Copyright 1984-2003 The MathWorks, Inc.

ch = get(this,'Children');

% delete extra children from serialization
delete(ch(3:4))

% delete extra baseline if present
parent = get(this,'Parent');
baseline = find(handle(parent),'-isa','specgraph.baseline','-depth',1);
if length(baseline) > 1
  delete(baseline(2:end));
end

setLegendInfo(this);

update(handle(this));
