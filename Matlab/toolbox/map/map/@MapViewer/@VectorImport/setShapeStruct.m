function setShapeStruct(this)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:15:15 $

set(this.Topology,'Enable','off');
set([this.Lat{:},this.Lon{:}],'Enable','off');
set([this.X{:},this.Y{:}],'Enable','off');
set(this.VectorTopologyText,'Enable','off');
set([this.X{2},this.Y{2}],...
    'BackgroundColor',[0.7 0.7 0.7]);
set([this.Lat{2},this.Lon{2}],...
    'BackgroundColor',[0.7 0.7 0.7]);

set([this.ShapeStruct{:}],'Enable','on');
set([this.ShapeStruct{2}],'BackgroundColor','w');
