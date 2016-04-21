function dest = addBlock(sys,src,name,props,iportcon,outportcon,location)
%ADDBLOCK  Shortcut function to add a block
%
% Parameters
%
%   sys         -       The subsystem in which you are operating
%   src         -       The src block ie from a library
%   props       -       A cell array of properties to set in 
%                   the new block
%   iportcon    - { 'srcBlockName' outPortNumber inPortNumber ;
%                 'srcBlockName' outPortNumber inPortNumber ;
%                 ...
%                 }
%   outportcon  - {  'destBlockName' inPortNumber outPortNumber ;
%                 'destBlockName' inPortNumber outPortNumber ;
%                 ...
%                 }
%   location    - [ x y ] 
%               - { block [ x y ] }
%

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
%   $Date: 2004/04/19 01:22:23 $

    dest = [ sys '/' name ];
    add_block(src,dest);
    simUtil_setPosition(dest,location);

    if ~isempty(props)
        set_param(dest,props{:});
    end
    
    for i=1:size(iportcon,1)
        srcPort = [ iportcon{i,1} '/' int2str(iportcon{i,2}) ];
        destPort = [ name '/' int2str(iportcon{i,3}) ];
        add_line(sys,srcPort,destPort,'autorouting','on');
    end

    for i=1:size(outportcon,1)
        srcPort = [ name '/' int2str(outportcon{i,3}) ];
        destPort = [ outportcon{i,1} '/' int2str(outportcon{i,2}) ];
        add_line(sys,srcPort,destPort,'autorouting','on');
    end
