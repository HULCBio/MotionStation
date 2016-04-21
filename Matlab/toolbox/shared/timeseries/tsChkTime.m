function time = tsChkTime(time)

% Copyright 2004 The MathWorks, Inc.

stime = hdsGetSize(time);
if length(stime)>2 
    error('tsChkTime:manytimedim',...
        'Time vectors cannot have more than 2 dimensions')
end
if max(stime)<1
    error('tsChkTime:shorttime',...
        'Timeseries objects must have at least 1 sample')
end
if stime(2)>1
    stime = stime(2:-1:1);
    time = hdsReshapeArray(time,stime);
end
if stime(2)~=1
    error('tsChkTime:matrixtime',...
        'The time vector must be a 1xn or nx1 vector')
end
if ~all(isfinite(time))
    error('tsChkTime:inftime',...
        'The time vector must contain only finite values')
end
if ~isreal(time)
    error('tsChkTime:inftime',...
        'The time vector must contain only real values')
end
