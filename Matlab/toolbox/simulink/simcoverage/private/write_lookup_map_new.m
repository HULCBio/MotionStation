function str = write_lookup_map_new(tableId,execCnt,brkVal,brkEqCnts,imageDir)
%WRITE_LOOKUP_MAP - Convert a 2D table of execution counts into a html table map
%
%   WRITE_LOOKUP_MAP(TABLEID,EXECCNT,BRKVAL) Create an HTML table in the
%   writable file handle OUTFILE where each entry is a scaled image to represent 
%   the execution count captured in EXECCNT.  Between the cell entries are smaller
%   scaled images that indicate if the break value was exactly matched.

%   Bill Aldrich
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:37:52 $

str = '';
    
[numRows,numCols] = size(execCnt);

if ((numRows==1 & numCols>1) | (numRows>1 & numCols==1))
    numDims = 1;
else
    numDims = ndims(execCnt);
end

if nargin<5
    imageDir = '';
end
    

switch (numDims)
case 1,
    numCols = length(execCnt);
    str = [str,sprintf('<table border=0 cellpadding=0 cellspacing=0>\n')];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print the first row
    str = [str,sprintf('<tr> <td> ')];

    str = [str,create_cell(tableId, execCnt(1),1,NaN,brkVal(1))];
    str = [str,sprintf(' &nbsp </td>\n    <td> ')];
            
    str = [str,create_vert_divider(tableId,brkEqCnts(1), 1, brkVal(1),0,imageDir)];
    str = [str,sprintf('</td>\n    <td> ')];

    for i=2:(numCols-1)        
        str = [str,create_cell(tableId, execCnt(i), i, brkVal(i-1),brkVal(i))];
        str = [str,sprintf('</td>\n    <td> ')];
           
        str = [str,create_vert_divider(tableId,brkEqCnts(i), i, brkVal(i),0,imageDir)];
        str = [str,sprintf('</td>\n    <td> ')];
    end

    str = [str,sprintf(' &nbsp ')];
    str = [str,create_cell(tableId, execCnt(end),numCols, brkVal(end), NaN)];
    str = [str,sprintf('</td>\n</tr></table>\n    ')];

case 2,
    str = [str,sprintf('<table border=0 cellpadding=0 cellspacing=0>\n')];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print the first row
    str = [str,sprintf('<tr> <td> ')];

    str = [str,create_cell(tableId, execCnt(1,1),[1 1],[NaN NaN] ,[brkVal(1) brkVal(numRows)])];
    str = [str,sprintf('</td>\n    <td> ')];
            
    str = [str,create_vert_divider(tableId,brkEqCnts(numRows), 1, brkVal(numRows),1,imageDir)];
    str = [str,sprintf('</td>\n    <td> ')];

    for i=2:(numCols-1)        
        str = [str,create_cell(tableId, execCnt(1,i), [1 i], [NaN brkVal(numRows+i-2)],[brkVal(1) brkVal(numRows+i-1)])];
        str = [str,sprintf('</td>\n    <td> ')];
           
        str = [str,create_vert_divider(tableId,brkEqCnts(numRows+i-1), i, brkVal(numRows+i-1),1,imageDir)];
        str = [str,sprintf('</td>\n    <td> ')];
    end

    str = [str,create_cell(tableId, execCnt(1,numCols), [1 numCols], [NaN brkVal(numRows+numCols-2)], [brkVal(1) NaN])];
    str = [str,sprintf('</td>\n</tr><tr>\n    ')];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print the dividing row 
    str = [str,create_horz_divider( tableId, brkEqCnts(1), 1, brkVal(1),numCols,imageDir)];
    str = [str,sprintf('</td>\n</tr><tr>\n    <td> ')];

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print middle rows of the table
    for j=2:(numRows-1)
        str = [str,create_cell( tableId, execCnt(j,1), [j 1], [brkVal(j-1) NaN],[brkVal(j) brkVal(numRows)])];
        str = [str,sprintf('</td>\n    <td> ')];
           
        str = [str,create_vert_divider( tableId, brkEqCnts(numRows), 1,  brkVal(numRows),0,imageDir)];
        str = [str,sprintf('</td>\n    <td> ')];
    
        for i=2:(numCols-1)        
            str = [str,create_cell(tableId, execCnt(j,i), [j i], [brkVal(j-1) brkVal(numRows+i-2)], [brkVal(j) brkVal(numRows+i-1)])];
            str = [str,sprintf('</td>\n    <td> ')];
               
            str = [str,create_vert_divider(tableId,brkEqCnts(numRows+i-1),i,brkVal(numRows+i-1),0,imageDir)];
            str = [str,sprintf('</td>\n    <td> ')];
        end
    
        str = [str,create_cell(tableId,execCnt(j,numCols),[j numCols],[brkVal(j-1) brkVal(numRows+numCols-2)],[brkVal(j) NaN])];
        str = [str,sprintf('</td>\n</tr><tr>\n    ')];

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Print the dividing row 
        str = [str,create_horz_divider( tableId, brkEqCnts(j),j,brkVal(j),numCols,imageDir)];
        str = [str,sprintf('</td>\n</tr><tr>\n    <td> ')];
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print the bottom row
    str = [str,create_cell( tableId, execCnt(end,1), [numRows 1], [brkVal(1) NaN], [NaN brkVal(numRows-1)])];
    str = [str,sprintf('</td>\n    <td> ')];

    str = [str,create_vert_divider( tableId, brkEqCnts(numRows), 1, brkVal(numRows),1,imageDir)];
    str = [str,sprintf('</td>\n    <td> ')];

    for i=2:(numCols-1)        
        str = [str,create_cell( tableId, execCnt(end,i), [numRows i], [brkVal(numRows-1) brkVal(numRows+i-2)], [NaN brkVal(numRows+i-1)])];
        str = [str,sprintf('</td>\n    <td> ')];
           
        str = [str,create_vert_divider( tableId, brkEqCnts(numRows+i-1), i, brkVal(numRows+i-1),1,imageDir)];
        str = [str,sprintf('</td>\n    <td> ')];

    end

    str = [str,create_cell( tableId, execCnt(end,end), [numRows, numCols], [brkVal(numRows-1),brkVal(end)],[NaN NaN])];

    str = [str,sprintf('</td>\n</table>')];

otherwise,
    error('Table map generation currently only supports 1D and 2D tables');

end



% =============================================================================
%                           Internal Functions
% =============================================================================

function str = create_cell(tableId,execCnt,index,dimMins,dimMax)

    switch(length(index))
    
    case 1, 
        str = sprintf('<A HREF="matlab:cvtablecell(%d,%d,%d,%g,%g);"><IMG src="%s" width=12 height=12 border=0></A>', ...
                tableId, ...
                execCnt, ...
                index, ...
                dimMins, ...
                dimMax, ...
                cnt_to_filename(execCnt));

    case 2,
        str = sprintf('<A HREF="matlab:cvtablecell(%d,%d,[%d %d],[%g %g],[%g %g]);"><IMG src="%s" width=12 height=12 border=0></A>', ...
                tableId, ...
                execCnt, ...
                index(1), index(2), ...
                dimMins(1), dimMins(2), ...
                dimMax(1), dimMax(2), ...
                cnt_to_filename(execCnt));
    otherwise,
        error('Table map generation currently only supports 1D and 2D tables');
    end
    


function str = create_vert_divider(tableId,execCnt,index,value,offTable,imageDir)
    if (offTable)
        fileName = 'trans.gif';
    elseif (execCnt > 0)
        fileName = 'black.gif';
    else
        fileName = 'vert_line.gif';
    end
       
    if ~isempty(imageDir)
        fileName = [imageDir '/' fileName];
    end
    
    str = sprintf('<A HREF="matlab:cvtablecell(%d,%d,%d,[],%f);"><IMG src="%s" width=3 height=12 border=0></A>', ...
            tableId, ...
            execCnt, ...
            index, ...
            value, ...
            fileName);
            




function str = create_horz_divider(tableId,execCnt,index,value,totCols,imageDir)   
    % Print the dividing row 
    str = sprintf('<td colspan=%d align="center"> ', 2*totCols-1);

    if (execCnt > 0)
        fileName = 'black.gif';
    else
        fileName = 'horz_line.gif';
    end

    if ~isempty(imageDir)
        fileName = [imageDir '/' fileName];
    end

    str = [str,sprintf('<A HREF="matlab:cvtablecell(%d,%d,%d,%f,[]);"><IMG src="%s" width=%d height=3 border=0></A>', ...
            tableId, ...
            execCnt, ...
            index, ...
            value, ...
            fileName, ...
            15*(totCols-2)+3)];





                               