function [err,msg] = errargn(ndfct,nbArgin,setOfargin,nbArgout,setOfargout)
%ERRARGN Check function arguments number.
%   ERR = ERRARGN('function',NBARGIN,SETofARGIN,NBARGOUT,SETofARGOUT) or 
%   [ERR,MSG] = ERRARGN('function',NBARGIN,SETofARGIN,NBARGOUT,SETofARGOUT) 
%   returns ERR = 1 if either the number of input NBARGIN or 
%   output (NBARGOUT) arguments of the specified function do not
%   belong to the vector of allowed values (SETofARGIN and
%   SETofARGOUT, respectively). In this case MSG contains an
%   appropriate error message.
%   Otherwise ERRARGN returns ERR = 0 and MSG = [].
%
%   See also ERRARGT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 16-Apr-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.11.4.2 $

% Special case:
% -------------
%  If SETofARGIN is not a numeric array, the number of input arguments
%  is not controlled. The same holds for SETofARGOUT.
%  example:
%    err = errargn('function',3,'var',2,[1:4]);
%    returns err = 0.
%    [err,msg] = errargn('function',2,[1:4],3,'var');
%    returns err = 0 and msg = [].

err = 0; msg = [];
if isnumeric(setOfargin)
    msg = nargchk(min(setOfargin),max(setOfargin),nbArgin);
    err = ~isempty(msg);
    if ~err
        err = isempty(find(nbArgin==setOfargin));
        if err , msg = 'Invalid number of input arguments.'; end
    end    
end
if ~err & isnumeric(setOfargout)
    msg = nargoutchk(min(setOfargout),max(setOfargout),nbArgout);
    err = ~isempty(msg);
    if ~err
        err = isempty(find(nbArgout==setOfargout));
        if err , msg = 'Invalid number of output arguments.'; end
    end    
end
if err & (nargout<2) , errargt(ndfct,msg,'msg'); end