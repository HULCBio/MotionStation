function nb = sizeof(S,inx)
% SIZEOF  Number bytes in partition or segement
%  N=SIZEOF(S) - Returns the number of bytes in the entire partition.  This
%    calculation includes all padding and adjustments for alignment.  This
%    corresponds to the total data block which is written by xPC at each
%    time step, but could be larger than the user's data.
%  N=SIZEOF(S,INX) - Returns the number of bytes in the segment.  This
%    value does not include any padding and is simply the raw size of 
%    the data.  
% 
% Note - The total partition size that is read by sizeof(S) may NOT equal the
% sum of the individual segements.   
% 

% Copyright 2004 The MathWorks, Inc.

if nargin == 1, % Sizeof entire partition
    nS = numel(S);
    for inxS = 1:nS,
        firstaddress = base(S(inxS));
        lastaddress = S(inxS).Address(end); 
        lastnbytes = S(inxS).NBytes(end);
        % add size of last 
        totalbytes = lastnbytes + lastaddress - firstaddress;
        nb(inxS)= ceil(totalbytes/4)*4;  %Always increments of 4
    end
    reshape(nb,size(S));
elseif nargin == 2, % Sizeof specified segment
    if ~isnumeric(inx) || inx < 1,
        error('Parameter for sizeof() method must be an index (positive integer)');
    end
    nS = numel(S);
    for inxS = 1:nS,
        if inx > numseg(S(inxS)),
            if nS > 1,
                nb(inxS) = 0; %% NULL entry
            else
                error('Index exceeds number of segments');
            end
        else
            nb(inxS) = S(inxS).NBytes(inx);
        end
    end
    reshape(nb,size(S));
end

