function x = view(w, option)
%VIEW View a virtual world.
%   VIEW(W) views the virtual worlds referred to by VRWORLD handles
%   contained in vector W. The default viewer (specified by the
%   'DefaultViewer' preference) is used to view the world.
%
%   VIEW(W, '-internal') always uses the internal viewer for viewing.
%   VIEW(W, '-web') always uses the Web browser for viewing.
%
%   X = VIEW(W) also returns the VRFIGURE handle of the internal viewer
%   window if internal viewer is used. For the Web browser, an empty array
%   of VRFIGURE handles is returned.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.17.4.6 $ $Date: 2004/03/15 22:35:31 $ $Author: batserve $


% use overloaded method only if the first argument is VRWORLD
if ~isa(w, 'vrworld')
  error('VR:invalidinarg', 'The first argument must be of type VRWORLD.');
end

% check for invalid worlds
if ~all(isvalid(w(:)))
  error('VR:invalidworld', 'Invalid world.');
end

% decide whether to use internal or Web browser
if nargin>1
  switch(lower(option))
    case '-web'
      webswitch = true;
    case '-internal'
      webswitch = false;
    otherwise
      error('VR:invalidinarg', 'Invalid input arguments.');
  end;
else
  webswitch = strcmpi(vrgetpref('DefaultViewer'), 'web');
end

% view the worlds by the internal viewer ...
if ~webswitch
   x = vrfigure(w);
   return;
end


% ... or by the external viewer
p = vrgetpref('HttpPort');
for i = 1:numel(w)
  wid = w(i).id;
  if ~isopen(w)
    error('VR:worldnotopen', 'World "%s" is not open.', get(w(i), 'Description'));
  end
  if strcmp(get(w, 'view'), 'on')
    oldc = vrsfunc('GetRemoteCount', wid);
    s = web(sprintf('http://127.0.0.1:%d/worlds/%d/index.html', p, wid), '-browser');
    if s==1
      error('VR:browsererror', 'Web browser not found.');
    elseif s==2
      error('VR:browsererror', 'Error invoking Web browser.');
    end

    % wait before the external client connects, but at maximum for TransportTimeout
    timeout = vrgetpref('TransportTimeout');
    t0 = clock;

    while 1
      % adjust for possible old client disconnection
      nc = vrsfunc('GetRemoteCount', wid);
      if nc>oldc
        break;
      end
      oldc = min(nc, oldc);

      % let the HTTP server work
      vrdrawnow;

      % exit on timeout
      if etime(clock, t0) > timeout
        warning('VR:protocoltimeout', 'Timeout has occured opening the remote viewer. Try increasing the "TransportTimeout" property.');
        break;
      end
    end

  end
end

% end
x = vrfigure([]);
