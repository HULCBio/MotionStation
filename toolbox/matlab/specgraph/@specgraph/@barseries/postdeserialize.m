function postdeserialize(this)
%POSTDESERIALIZE Post deserialize bar plot
  
%   Copyright 1984-2003 The MathWorks, Inc.

ch = get(this,'Children');

% delete extra children from serialization
delete(ch(2:end))

% find existing baseline, if any
parent = get(this,'Parent');
children = allchild(parent);
baseline = [];
for k=1:length(children)
  if isa(handle(children(k)),'specgraph.baseline')
    baseline = [baseline handle(children(k))];
  end
end

delete(baseline(2:end));

setLegendInfo(this);

update(handle(this));
