function [blkpairs,skipCount] = slcheckprelookups(sys, varargin)
%SLCHECKPRELOOKUPS ensure breakpoints are correctly sized in SYS
%
% Synopsis:
%
% >> open_system('f14')
% >> bpcheck_rpt = slcheckprelookups('f14');
%
% Given a model name or the name of a system in a model, first find 
% all Interpolation n-D Using PreLookup blocks and trace them back    
% to PreLookup Index Search blocks and check parameter sizes to ensure
% that the table sizes match the corresponding breakpoint sizes.
%
% NOTE: you must perform an update diagram on the model sometime 
%       before running this function.
%
% For each input port of an interpolation block, the following information
% is returned in a structure array with the following fields, one
% array element per input port:
%
%    interpBlkName:    interpolation block name
%    interpBlkPort:    interpolation block port number
%    interpBlkParam:   text of interpolation block's table parameter
%    interpBlkDimSize: table dimension size corresponding to interpBlkPort
%    prelookupName:    prelookup block name
%    prelookupParam:   text of prelookup blocks's breakpoint parameter
%    prelookupSize     size of the breakpoint set in block prelookupName
%    mismatch :        true/false or empty - true for a size mismatch
%    errorMsg:         if an error occurred, message is put here
%
% The optional skipcount return variable can be used to check to see
% if an error condition occurred during the search causing a block to be
% skipped:
%
% >> [blks,skips] = slcheckprelookups('f14');
%
% The return value of skipcount is normally zero.  If it is nonzero,
% some of the fields in the returned structure array could be empty
% [], such as if an interpolation block has an unconnected input
% port causing the prelookup information to be empty.  To find the entries
% with skipped analysis, you can find the nonzero indices of this array:
%
%  skipitem = zeros(length(blks)); 
%  for k=1:length(blks), 
%     skipitem(k) = isempty(blks(k).mismatch); 
%  end
%  skipidx = find(skipitem ~= 0);
%
% To use this function as part of a model checking process, you can 
% call it from a model checking script, or if you want, you can put
% a call to this function in your model's StartFcn callback.
%
% The return structure information can be browsed using the hilite_sytem()
% command from Simulink to highlight the blocks as they are browsed.
% Here is an example:
%
% >> hilite_system( blks(n).interpBlkName, 'find' )
% >> hilite_system( blks(n).prelookupName, 'find' )
%
% Use the 'none' highlighting option to turn off highlighting for a block
% or use the View/RemoveHighlighting menu option for a model to remove all
% highlighting.
%

% Copyright 1990-2004 The MathWorks, Inc.
% $Revision: 1.1.4.2 $

% --- Initializations

if nargin > 1,
    doVerbose = varargin{1};
else
    doVerbose = false;
end
blkpairs  = struct([]);
skipCount = 0;

% --- get a list of all the interpolation blocks in sys

interpBlks = find_system( ...
    sys, ...
    'FollowLinks','on', 'LookUnderMasks', 'on', ...
    'MaskType', 'LookupNDInterpIdx');

XinterpBlks = find_system( ...
    sys, ...
    'FollowLinks','on', 'LookUnderMasks', 'on', ...
    'MaskType', 'LookupNDSelectInterp');

interpBlks = [interpBlks; XinterpBlks];

% --- Go through each port of sys and match it to a prelookup

for k=1:length(interpBlks)
    try
        m       = [];
        thispre = [];
        
        tabVar      = slResolve('table',interpBlks{k});
        tableDims   = size(tabVar);
        interpPorts = get_param(interpBlks{k}, 'PortHandles');
        numPorts    = length(interpPorts.Inport);
        
        % --- Fix-up for 1-D table sizes
        if (numPorts == 1) && (tableDims(1) == 1 || tableDims(2) == 1)
            tableDims = length(tabVar);
        end

        if length(tableDims) ~= numPorts
            error('Table number of dimensions %d incompatible with block port count %d', tableDims, numPorts);
        end
        
        for m=1:numPorts
            
            % --- Look for a prelookup
            thispre = slprivate('tblpresrc', interpBlks{k}, m);

            % --- Check its breakpoint data length (1-D assumed)
            if isempty(thispre)
                error('a prelookup block is not attached to this port');
            else
                dlgEntry = get_param(thispre, 'bpData');
                
                try
                    bpVar = slResolve(dlgEntry, thispre);
                catch
                    if doVerbose
                        warning( ...
                           ['Resolve failure for prelookup parameter; ',...
                            ' backup plan is to try the base workspace ...']);
                    end
                    bpVar = evalin('base', dlgEntry);
                end
                
                if isa(bpVar,'Simulink.Parameter')
                    preSize = length(bpVar.Value);
                elseif isnumeric(bpVar)
                    preSize = length(bpVar);
                else
                    error('Unrecognized parameter data type');
                end

                % --- Match breakpoint data size with corresponding
                %     table dimension size and add to the results
                n = length(blkpairs);
                n = n+1;
                blkpairs(n).interpBlkName    = interpBlks{k};
                blkpairs(n).interpBlkPort    = m;
                blkpairs(n).interpBlkParam   = get_param(interpBlks{k},'table');
                blkpairs(n).interpBlkDimSize = tableDims(m);
                blkpairs(n).prelookupName    = thispre;
                blkpairs(n).prelookupParam   = dlgEntry;
                blkpairs(n).prelookupSize    = preSize;
                blkpairs(n).mismatch         = (tableDims(m) ~= preSize);
                blkpairs(n).errorMsg         = '';
            end
        end
    catch
        skipCount = skipCount + 1;
        n = length(blkpairs);
        n = n+1;
        blkpairs(n).interpBlkName    = interpBlks{k};
        blkpairs(n).interpBlkPort    = m;
        blkpairs(n).interpBlkParam   = [];
        blkpairs(n).interpBlkDimSize = tableDims(m);
        blkpairs(n).prelookupName    = thispre;
        blkpairs(n).prelookupParam   = [];
        blkpairs(n).prelookupSize    = [];
        blkpairs(n).mismatch         = [];
        blkpairs(n).errorMsg         = lasterror;
    end
end

% --- Display summary of findings

mismatchedItems = find([blkpairs.mismatch] == true);

display(sprintf( ...
    '\nChecked %d interpolation blocks, found %d issues to review.',...
    k, length(mismatchedItems) ));

if length(mismatchedItems) > 0
    listTxt = 'Index list: ';
    for k=1:length(mismatchedItems)
        listTxt = sprintf('%s %d,', listTxt, mismatchedItems(k));
    end
    listTxt = listTxt(1:(end-1));
    display(sprintf('%s\n', listTxt));
end

%[EOF] slcheckprelookups.m
