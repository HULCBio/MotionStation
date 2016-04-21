function [bpxv,wfxv,bpyv,wfyv] = crule2dgen (nquadx,nquady)
%
%usage:  [bpxv,wfxv,bpyv,wfyv] = crule2dgen (nquadx,nquady);
%
	[bpxv,wfxv]=crule(nquadx);
	[bpyv,wfyv]=crule(nquady);
endfunction
