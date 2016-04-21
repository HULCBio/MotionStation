function S = append(S,A)
% APPEND  Add segments to partition(s)
%   SA=APPEND(S,PSTR) - returns a new partition object SA that has the
%    segements described by PSTR is added to each partition.  
%   SA=APPEND(S,POBJ) Same as above, expect POBJ is a partition object.
%    
%  Note - to add a new partition that is NOT appended to the existing
%  partitions, use horzcat(A,B) or [A B].
%
% See also SMPARTITION

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/01/22 18:34:47 $

if isa(A,'smpartition') || isa(A,'smpartsbs25x0'),
    A = getstruct(A);
end
wittmp.WIT = S.WIT;
S = class(wittmp,'smpartsbs25x0',append(S.smpartition,A));
% OK need to append NEW WIT entries.
if isa(A,'struct'),
    nA = numel(A);  % Array of structures
    nS = numel(S);  % Array of partitions
    for inxS = 1:nS 
        for inxA = 1:nA,  %Accept arrays of structures
            % For an array, append this to each entry...
            sin = A(inxA);

            if isfield(sin,'WIT') && ~isempty(sin.WIT),
                inx = strmatch(sin.WIT,['first';'last ';'all  ';'off  ';'[]   ']);
                if isempty(inx)
                    error('WIT parameter limited to ''first'',''last'',''all'' and ''off''');
                elseif inx == 5,
                    inx = 4;
                    S(inxS).WIT = horzcat(S(inxS).WIT,{'off'});
                else
                    S(inxS).WIT = horzcat(S(inxS).WIT,{sin.WIT});
                end
            else
                S(inxS).WIT = horzcat(S(inxS).WIT,{'off'});   % Default
            end
        end
    end
else
    error('Append requires a partition definition structure or partition object');
end
% S = adjustWIT(S);
 
