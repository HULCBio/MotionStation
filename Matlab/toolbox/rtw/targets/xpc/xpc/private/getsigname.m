function signalname=getsigname(index,modelname)
% GETSIGNAME xPCTarget private function
%
%    Retruns the name from the index into the
%    signal BIO.

%    Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/09/13 21:05:28 $

eval(['bio=',modelname,'bio;']);
name=cellstr(strvcat(bio.blkName));
width=cat(1,bio(:).sigWidth);
sigidx=filter([0 1],[1 -1],width);
Idx=find(index >= sigidx & sigidx <= index);
bioIdx=Idx(end);
if (sigidx(bioIdx)+width(bioIdx)-1 < index)
    signalname=[];
    return;
end
signalname=name{bioIdx};
if (width(bioIdx)>1)
    offset=index-sigidx(bioIdx);
    signalname=[name{bioIdx},'/s',num2str(offset+1)];
end

    
    







