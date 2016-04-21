function lines = connectBlocks(sys,outblocks,outports,inblocks,inports)
%CONNECTBLOCKS  Shorcut function to add lines
%
% Parameters
%   sys         -       The subsystem
%   ports       -       Port connectivity
%
% Example
%
%   connectBlocks('mysys',  ...
%       {   'inport1' 'inport2'  'inport3'  'inport4'  } , ...
%       ones(1,4) , ...
%       {  'muxin'  'muxin'  'muxin' 'gain' }, ...
%       [1:4] );
%   

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
%   $Date: 2004/04/19 01:22:25 $

for i=1:length(outblocks)
    outport = [  outblocks{i} '/' int2str(outports(i)) ];
    inport  = [  inblocks{i} '/' int2str(inports(i)) ];
    add_line(sys,outport,inport,'autorouting','on')
end



