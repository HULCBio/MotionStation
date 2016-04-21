function postdeserialize(this)
%POSTDESERIALIZE Post deserialize stairs plot
  
%   Copyright 1984-2003 The MathWorks, Inc.

ch = get(this,'Children');

% delete extra child from serialization
delete(ch(end))

setLegendInfo(this);

update(handle(this));
