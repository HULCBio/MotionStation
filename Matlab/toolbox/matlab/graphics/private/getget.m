function propValue = getget( h, propName )
%GETGET Do a GET on Handle Graphics object or a GET_PARAM on Simulink object.
%   GETGET(H, PN) GET property PN for Handle Graphics object H.
%   GETGET(H, PN) GET_PARAM property PN for Simulink object H.
%   GETGET(N, PN) GET_PARAM property PN for Simulink object named N.
%   If H is a vector, result is concatenated value from vectorized GET and GET_PARAM.

%    See also GET, GET_PARAM.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 17:08:59 $

if isempty(h)
    propValue = [];
    return
end

if isstr(h)
    h = get_param(h,'handle');
end

hi = find(ishghandle(h));
si = find(isslhandle(h));

%Put values into same order as handles
propValue = cell(size(h));

if ~isempty(hi)
    hValue = get(h(hi), propName );
    if ~iscell( hValue )
        hValue = { hValue };
    end
    propValue(hi) = hValue;
end

if ~isempty(si)
    sValue = get_param(h(si), propName );
    if ~iscell( sValue )
        sValue = { sValue };
    end
    propValue(si) = sValue;
end

if length(h) == 1 & ~iscell(h)
    propValue = propValue{1};
end
