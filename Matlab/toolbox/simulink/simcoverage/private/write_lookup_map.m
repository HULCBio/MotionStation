function write_lookup_map(outFile,tableId,execCnt,brkVal,brkEqCnts,imageDir)
%WRITE_LOOKUP_MAP - Convert a 2D table of execution counts into a html table map
%
%   WRITE_LOOKUP_MAP(OUTFILE,TABLEID,EXECCNT,BRKVAL) Create an HTML table in the
%   writable file handle OUTFILE where each entry is a scaled image to represent 
%   the execution count captured in EXECCNT.  Between the cell entries are smaller
%   scaled images that indicate if the break value was exactly matched.

%   Bill Aldrich
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.2 $  $Date: 2004/04/15 00:37:51 $

    
[numRows,numCols] = size(execCnt);

if ((numRows==1 & numCols>1) || (numRows>1 & numCols==1))
    numDims = 1;
    tableDims = numRows*numCols - 1;
else
    numDims = ndims(execCnt);
    tableDims = [numRows numCols] - 1;
end

if nargin<6
    imageDir = '';
end
    

switch (numDims)
case 1,
    numCols = length(execCnt);
    
    minRowBrk = brkVal(1);
    maxRowBrk = brkVal(end);
    fprintf(outFile,'<table border=0 cellpadding=0 cellspacing=0>\n');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print the first row
    fprintf(outFile,'<tr> <td> ');

    create_cell(outFile,tableId, execCnt(1),1,NaN,minRowBrk,tableDims);
    fprintf(outFile,' &nbsp </td>\n    <td> ');
            
    create_vert_divider(outFile,tableId,brkEqCnts(1), 1, brkVal(1),0,imageDir);
    fprintf(outFile,'</td>\n    <td> ');

    for i=2:(numCols-1)        
        create_cell(outFile,tableId, execCnt(i), i, brkVal(i-1),brkVal(i),tableDims);
        fprintf(outFile,'</td>\n    <td> ');
           
        create_vert_divider(outFile,tableId,brkEqCnts(i), i, brkVal(i),0,imageDir);
        fprintf(outFile,'</td>\n    <td> ');
    end

    fprintf(outFile,' &nbsp ');
    create_cell(outFile,tableId, execCnt(end),numCols, maxRowBrk, NaN,tableDims);
    fprintf(outFile,'</td>\n</tr></table>\n    ');

case 2,

    minRowBrk = brkVal(1);
    maxRowBrk = brkVal(numRows-1);

    minColBrk = brkVal(numRows);
    maxColBrk = brkVal(numRows + numCols - 2);

    fprintf(outFile,'<table border=0 cellpadding=0 cellspacing=0>\n');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print the first row
    fprintf(outFile,'<tr> <td> ');

    create_cell(outFile,tableId, execCnt(1,1),[1 1],[NaN NaN] ,[minRowBrk minColBrk],tableDims);
    fprintf(outFile,'</td>\n    <td> ');
            
    create_vert_divider(outFile,tableId,brkEqCnts(numRows), 1, minColBrk,1,imageDir);
    fprintf(outFile,'</td>\n    <td> ');

    for i=2:(numCols-1)        
        create_cell(outFile,tableId, execCnt(1,i), [1 i], [NaN brkVal(numRows+i-2)],[minRowBrk brkVal(numRows+i-1)],tableDims);
        fprintf(outFile,'</td>\n    <td> ');
           
        create_vert_divider(outFile,tableId,brkEqCnts(numRows+i-1), i, brkVal(numRows+i-1),1,imageDir);
        fprintf(outFile,'</td>\n    <td> ');
    end

    create_cell(outFile,tableId, execCnt(1,numCols), [1 numCols], [NaN maxColBrk], [minRowBrk NaN],tableDims);
    fprintf(outFile,'</td>\n</tr><tr>\n    ');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print the dividing row 
    create_horz_divider(outFile, tableId, brkEqCnts(1), 1, brkVal(1),numCols,imageDir);
    fprintf(outFile,'</td>\n</tr><tr>\n    <td> ');

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print middle rows of the table
    for j=2:(numRows-1)
        create_cell(outFile, tableId, execCnt(j,1), [j 1], [brkVal(j-1) NaN],[brkVal(j) minColBrk],tableDims);
        fprintf(outFile,'</td>\n    <td> ');
           
        create_vert_divider(outFile, tableId, brkEqCnts(numRows), 1,  brkVal(numRows),0,imageDir);
        fprintf(outFile,'</td>\n    <td> ');
    
        for i=2:(numCols-1)        
            create_cell(outFile,tableId, execCnt(j,i), [j i], [brkVal(j-1) brkVal(numRows+i-2)], [brkVal(j) brkVal(numRows+i-1)],tableDims);
            fprintf(outFile,'</td>\n    <td> ');
               
            create_vert_divider(outFile,tableId,brkEqCnts(numRows+i-1),i,brkVal(numRows+i-1),0,imageDir);
            fprintf(outFile,'</td>\n    <td> ');
        end
    
        create_cell(outFile,tableId,execCnt(j,numCols),[j numCols],[brkVal(j-1) maxColBrk],[brkVal(j) NaN],tableDims);
        fprintf(outFile,'</td>\n</tr><tr>\n    ');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Print the dividing row 
        create_horz_divider(outFile, tableId, brkEqCnts(j),j,brkVal(j),numCols,imageDir);
        fprintf(outFile,'</td>\n</tr><tr>\n    <td> ');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print the bottom row
    create_cell(outFile, tableId, execCnt(end,1), [numRows 1], [maxRowBrk NaN], [NaN minColBrk],tableDims);
    fprintf(outFile,'</td>\n    <td> ');

    create_vert_divider(outFile, tableId, brkEqCnts(numRows), 1, brkVal(numRows),1,imageDir);
    fprintf(outFile,'</td>\n    <td> ');

    for i=2:(numCols-1)        
        create_cell(outFile, tableId, execCnt(end,i), [numRows i], [maxRowBrk brkVal(numRows+i-2)], [NaN brkVal(numRows+i-1)],tableDims);
        fprintf(outFile,'</td>\n    <td> ');
           
        create_vert_divider(outFile, tableId, brkEqCnts(numRows+i-1), i, brkVal(numRows+i-1),1,imageDir);
        fprintf(outFile,'</td>\n    <td> ');

    end

    create_cell(outFile, tableId, execCnt(end,end), [numRows, numCols], [maxRowBrk,maxColBrk],[NaN NaN],tableDims)

    fprintf(outFile,'</td>\n</table>');

otherwise,
    error('Table map generation currently only supports 1D and 2D tables');

end



% =============================================================================
%                           Internal Functions
% =============================================================================

function create_cell(outFile,tableId,execCnt,index,dimMins,dimMax,tableDims)

    switch(length(index))
    
    case 1, 
        fprintf(outFile,'<A HREF="matlab:cvtablecell(%d,%d,%d,%g,%g,%g);"><IMG src="%s" width=12 height=12 border=0></A>', ...
                tableId, ...
                execCnt, ...
                index, ...
                dimMins, ...
                dimMax, ...
                tableDims, ...
                cnt_to_filename(execCnt));

    case 2,
        fprintf(outFile,'<A HREF="matlab:cvtablecell(%d,%d,[%d %d],[%g %g],[%g %g],[%g %g]);"><IMG src="%s" width=12 height=12 border=0></A>', ...
                tableId, ...
                execCnt, ...
                index(1), index(2), ...
                dimMins(1), dimMins(2), ...
                dimMax(1), dimMax(2), ...
                tableDims(1), tableDims(2), ...
                cnt_to_filename(execCnt));
    otherwise,
        error('Table map generation currently only supports 1D and 2D tables');
    end
    


function create_vert_divider(outFile,tableId,execCnt,index,value,offTable,imageDir)
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
    
    fprintf(outFile,'<A HREF="matlab:cvtablecell(%d,%d,%d,[],%f);"><IMG src="%s" width=3 height=12 border=0></A>', ...
            tableId, ...
            execCnt, ...
            index, ...
            value, ...
            fileName);
            




function create_horz_divider(outFile,tableId,execCnt,index,value,totCols,imageDir)   
    % Print the dividing row 
    fprintf(outFile,'<td colspan=%d align="center"> ', 2*totCols-1);

    if (execCnt > 0)
        fileName = 'black.gif';
    else
        fileName = 'horz_line.gif';
    end

    if ~isempty(imageDir)
        fileName = [imageDir '/' fileName];
    end

    fprintf(outFile,'<A HREF="matlab:cvtablecell(%d,%d,%d,%f,[]);"><IMG src="%s" width=%d height=3 border=0></A>', ...
            tableId, ...
            execCnt, ...
            index, ...
            value, ...
            fileName, ...
            15*(totCols-2)+3);





                               