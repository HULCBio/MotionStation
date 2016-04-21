function sflibrary
% SFLIBRARY

%	Jay R. Torgerson
%	Copyright 1995-2002 The MathWorks, Inc.
%  $Revision: 1.12.2.1 $  $Date: 2004/04/15 01:00:08 $

if ~sf('License', 'basic'),
    open_system('sf_examples');
    return;
end;

if length(sf('get','all','machine.id'))<=1
   sfnew
end
sflib;



