function parse_formatter_strings(id)
%   Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/03/23 02:59:18 $

summary = cv('get',id,'formatter.summary.formatStr');
[newStr,pts,types,indices] = parse_string(summary);
cv('set',id ...
    ,'formatter.summary.formatStr',       newStr ...
    ,'formatter.summary.insertPts',       pts ...
    ,'formatter.summary.insertTypes',     types ...
    ,'formatter.summary.insertIndices',   indices ...
    );

detail = cv('get',id,'formatter.detail.formatStr');
[newStr,pts,types,indices] = parse_string(detail);
cv('set',id ...
    ,'formatter.detail.formatStr',       newStr ...
    ,'formatter.detail.insertPts',       pts ...
    ,'formatter.detail.insertTypes',     types ...
    ,'formatter.detail.insertIndices',   indices ...
    );

verbose = cv('get',id,'formatter.verbose.formatStr');
[newStr,pts,types,indices] = parse_string(verbose);
cv('set',id ...
    ,'formatter.verbose.formatStr',       newStr ...
    ,'formatter.verbose.insertPts',       pts ...
    ,'formatter.verbose.insertTypes',     types ...
    ,'formatter.verbose.insertIndices',   indices ...
    );


function [newStr,insertPts,insertTypes,insertIndices] = parse_string(formatStr)
	[S,E] = regexp(formatStr,'%[dsoDSO][0-9]*');

    newStr = '';
    insertPts = [];
    insertTypes = [];
    insertIndices = [];
    nextChar = 1;
    removedChars = 0;
    
    if isempty(S) | S(1)==0
        newStr = formatStr;
    else
        for rng = [S;E],
            newStr = [newStr formatStr(nextChar:(rng(1)-1))];
            nextChar = rng(2)+1;
    
            insertPts = [insertPts rng(1)-removedChars-1];
            removedChars = removedChars + 1 + rng(2) - rng(1);

            switch(formatStr(rng(1)+1))
                case {'o', 'O'}
                    insertTypes = [insertTypes 0];
                case {'d', 'D'}
                    insertTypes = [insertTypes 1];
                case {'s', 'S'}
                    insertTypes = [insertTypes 2];
            end
                
            if(rng(2)-rng(1) > 1)
                insertIndices = [insertIndices str2num(formatStr((rng(1)+2):rng(2)))-1];
            else
                insertIndices = [insertIndices 0];
            end
        end
        newStr = [newStr formatStr(nextChar:end)];
    end
    
        

    
    
    
