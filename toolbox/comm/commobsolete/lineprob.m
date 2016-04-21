function lines = lineprob(lines, line_cell, block_handle, src_block, src_port);
%LINEPROB Handles the line problem caused by Simulink v2 inconsistency.
%
%WARNING: This is an obsolete function and may be removed in the future.

%	LINES = LINEPROB(LINES, LINE_CELL, BLOCK_HANDLE, SRC_BLOCK,
%	SRC_PORT) converts the information in the LINE_CELL into a four
%	column matrix LINES in which, the first column is the source
%	block index following the order in BLOCK_HANDLE, the second column
%	is the port number from the source block, the third column is the
%	destination block index and the fourth column is the port number of
%	the destination block. The SRC_BLOCK and SRC_PORT provides the
%	information of the source blocks. When the information is not
%	provided, the block is considered to be empty.
%
%	See also SIM2GEN, SIM2GEN2, SIM2TRAN.

%   Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.16 $

%	Wes Wang 7/13/96

line_size = size(line_cell, 1);

for i = 1 : line_size
    if isempty(line_cell(i).DstPort)
        if isempty(line_cell(i).SrcPort)
	    lines = lineprob(lines, line_cell(i).Branch, ...
                    block_handle, src_block, src_port);
	else
            lines = lineprob(lines, line_cell(i).Branch, ...
                    block_handle, line_cell(i).SrcBlock, line_cell(i).SrcPort);
	end
    else
	lines_tmp = zeros(1, 4);
	if ~isempty(line_cell(i).SrcPort)
	    src_block = line_cell(i).SrcBlock;
	    src_port  = line_cell(i).SrcPort;
	end
	lines_tmp(2) = src_port;
	lines_tmp(4) = line_cell(i).DstPort;
        T1 = find(src_block == block_handle);
        T2 = find(line_cell(i).DstBlock == block_handle);
        if isempty(T1) | isempty(T2)
	    error('Mismatched handles, you may have deleted blocks during this computation.')
        else
            lines_tmp(1) = T1;
            lines_tmp(3) = T2;
        end
	
	lines = [lines; lines_tmp];
    end
end

