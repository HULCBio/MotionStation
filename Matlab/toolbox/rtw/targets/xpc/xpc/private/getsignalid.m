function index = getsignalid(block,modelname)
% GETSIGINDEX xPCTarget private function

%Group:        Scope
%
%Syntax:       index = getsigindex('blockpath')
%
%              getsigindex returns the index into the block list to get its
%              output signal, starting from the sought after path (block
%              path).  I.e. getsigindex is used to set a signal according to
%              the block name. Therefore it is guaranteed, that the
%              information stays correct, even after regenerating the xPC
%              Target-application.  The block path is made up of the model
%              name, possible sub model names and the block name. getsigindex
%              can only be called, if the current path corresponds to the xPC
%              Target-project directory, resp. if the file model.bio lies in
%              the current directory.
%
%              Example:

%              Inside the test model, the submodel sub1 is contained, that
%              itself contains the submodel sub2, that contains the block
%              testblock. Then the block path is:
%              test/sub1/sub2/test block
%              the syntax is:
%              getsigindex('test/sub1/sub2/testblock')
%
%              See also:     showsig

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $ $Date: 2004/04/08 21:04:31 $

eval(['bio=',modelname,'bio;']);
name=cellstr(strvcat(bio(:).blkName));
width=cat(1,bio(:).sigWidth)';
sigidx=filter([0 1],[1 -1],width);
%look for /s in string to get the signal offset
slashIdx=regexp(block,'/s[\d]');
offset=0;
if ~isempty(slashIdx)
    offset=str2num(block(slashIdx+2:end));
    if (offset)% Signal is /SNum we remove the /S from signal name
        block=block(1:slashIdx-1);    
    end
    index = strmatch(block,name,'exact');
    index=sigidx(index)+offset;
    if ~isempty(index), index = index - 1; end
    return;   
end
index = strmatch(block,name,'exact');
index=sigidx(index)+offset;

