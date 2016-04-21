function [bpx,bpy,wfxy] = grule2d (nquadx,nquady)
%
%usage:  [bpx,bpy,wfxy] = grule2d (nquadx,nquady);
%
	[bpxv,wfxv]=grule(nquadx);
	[bpyv,wfyv]=grule(nquady);
	[bpx,bpy]=meshgrid(bpxv,bpyv);
	[wfx,wfy]=meshgrid(wfxv,wfyv);
%	[bpx,bpy]=meshdom(bpxv,bpyv);
%	[wfx,wfy]=meshdom(wfxv,wfyv);
	wfxy=wfx.*wfy;
endfunction
