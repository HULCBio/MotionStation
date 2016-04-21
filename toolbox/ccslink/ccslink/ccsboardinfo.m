function bdstruct = ccsboardinfo(varargin)
%CCSBOARDINFO Queries Code Composer Studio(R)(CCS) setup utility for board info.
%   CCSBOARDINFO displays a formatted list that describes the DSP boards and
%   processors available for use by the Code Composer IDE.  A MATLAB CCSDSP object
%   communicates with a specific DSP processor.  However, processor names do not
%   uniquely identify a particular DSP processor.  Consequently, the CCSDSP object
%   requires both the processor name (or number) and the board name (or number).
%   Each row in the output list represents a single processor.  In multiprocessor
%   systems, a board name and number will be repeated for each processor on that
%   board.  The supplied board and processor number can be used with the CCSDSP
%   to create a link to that processor.
%
%   Note - If the board and/or processor names are very long, the display list will
%   be truncated with '...'.  In this case, use the returned structure to retrieve
%   complete names.
%
%   BD = CCSBOARDINFO same as above except the board and processor information 
%   is returned as a structure. The BD structure fields are as follows:
%
%   bd                     = Board(s) information structure array
%   bd(bi).name            = String with board name
%   bd(bi).number          = Index used by CCS to refer to this board (zero-based)
%   bd(bi).proc            = Structure array describing processor(s) on board
%   bd(bi).proc(pi).name   = String with processor name
%   bd(bi).proc(pi).type   = String describing the processor type
%   bd(bi).proc(pi).number = Index used by CCS to refer to this processor (zero-based)
%   
%   The follow fields are returned in the BD structure, but not displayed
%   bd(bi).proc(pi).internal = Internal processor name
%   bd(bi).devdrvfile      = Board Device Driver file and path
%   bd(bi).datfile         = Board Date file and path
%
%   See also CCSDSP

%   Copyright 2000-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.4 $  $Date: 2004/04/08 20:47:21 $

error(nargchk(0,0,nargin));
error(nargoutchk(0,1,nargout));

try 
    bds = ccsmexsetup;
catch
    if strfind(lasterr,'CCSDSP:Class not registered'),
        error(generateccsmsgid('CCSNotInstalled'),'Proper installation of Code Composer Studio(R) is required');
    else
        rethrow(lasterror);
    end
end
if ischar(bds),
    error(bds);
end

% reverse the order to conform with Code Composer Setup listing
nb = length(bds);
bds = bds(nb:-1:1);  
for bi=1:nb,
    np = length(bds(bi).proc);
    bds(bi).proc = bds(bi).proc(np:-1:1);
    % push BYPASS Proc types to the end of the list of bds
    bds(bi) = pushbypass(bds(bi));
end


if nargout == 0,
    if ~isempty(bds)
        disp('Board Board                               Proc Processor                           Processor');
        disp(' Num  Name                                Num  Name                                Type');
        disp(' ---  ----------------------------------  ---  ----------------------------------  --------------');
    else
        warning(generateccsmsgid('NoProcsFound'),'!!! No processors found - load Code Composer Setup to configure.');
    end
    % Display each board-proc information
    procfound = 0;
    for ibd = 1:length(bds),
        bdname = strunc(bds(ibd).name,34);
        for iprc = 1:length(bds(ibd).proc),
            procfound = 1;
            pcname = strunc(bds(ibd).proc(iprc).name,34);
            ptype = strunc(bds(ibd).proc(iprc).type,14);
            fprintf(' %-3d  %-34s  %-3s  %-34s  %-20s\n',bds(ibd).number,bdname,num2str(bds(ibd).proc(iprc).number),pcname,ptype);
        end 
    end   
   
else
    bdstruct = bds;
end

%-----------------------------------------------------------------------
% Local function to push BYPASS Proc types to the end of the list.
function bd = pushbypass(bd)
for k = 1:length(bd.proc)
    while(strcmpi(bd.proc(k).type,'BYPASS') && ~strcmpi(bd.proc(k).number,'-'))
        temp = bd.proc(k);
        for m = k:length(bd.proc)-1
            bd.proc(m) = bd.proc(m+1);
            if ~strcmpi(bd.proc(m).number,'-')
                bd.proc(m).number = bd.proc(m).number - 1;
            end
        end
        bd.proc(end) = temp;
        bd.proc(end).number = '-';
    end
end

%-----------------------------------------------------------------------
% Local function to truncate long strings with ...
function sout=strunc(sin,nmax)
if length(sin) > nmax,
    sout = [sin(1:nmax-4) ' ...'];
else
    sout = sin;
end

% [EOF] ccsboardinfo.m