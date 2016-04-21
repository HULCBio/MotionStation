function setLatLon(this)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/24 20:41:07 $

set([this.Lat{:},this.Lon{:},this.Topology],'Enable','on');
set([this.Lat{2},this.Lon{2}],'BackgroundColor','w');
set(this.VectorTopologyText,'Enable','on');

set([this.X{:},this.Y{:},this.ShapeStruct{:}],'Enable','off');
set([this.X{2},this.Y{2},this.ShapeStruct{2}],...
    'BackgroundColor',[0.7 0.7 0.7]);