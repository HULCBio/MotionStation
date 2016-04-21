function dataevent(LoopData,Scope)
%DATAEVENT  Issues LoopDataChanged event

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $ $Date: 2002/04/10 04:53:09 $

% Clear derived data
LoopData.reset(Scope);

% Broadcast event
% REVISIT
LoopData.send('LoopDataChanged',...
    ctrluis.dataevent(LoopData,'LoopDataChanged',Scope));
