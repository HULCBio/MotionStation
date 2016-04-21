function postdeserialize(this)
%POSTDESERIALIZE Post deserialize area plot
  
%   Copyright 1984-2003 The MathWorks, Inc.

ch = get(this,'Children');

% delete extra children from serialization
delete(ch(2:end))

setLegendInfo(this);

update(handle(this));
