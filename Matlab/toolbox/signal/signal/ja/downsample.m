function y = downsample(x,N,varargin)
%DOWNSAMPLE �M�����͂��_�E���T���v�����O���܂��B
%   DOWNSAMPLE(X,N) �́A���ׂĂ�N-�Ԗڂ̃T���v�����ŏ��̂��̂Ƃ��āA
%   �o�����邱�Ƃɂ��A���͐M��X�̃_�E���T���v�����O���s���܂��BX ���s��
%   �ł���ꍇ�A�_�E���T���v�����O�́AX �̗�ɉ����čs���܂��B
%
%   DOWNSAMPLE(X,N,PHASE) �́A�I�v�V�����̃T���v���̃I�t�Z�b�g
%   ���w�肵�܂��BPHASE �́A[0, N-1]�͈̔͂̐����ł���K�v������܂��B
%
%   �Q�l UPSAMPLE, UPFIRDN, INTERP, DECIMATE, RESAMPLE.


y = updownsample(x,N,'Down',varargin{:});

% [EOF] 


%   Copyright 1988-2002 The MathWorks, Inc.
