function y = upsample(x,N,varargin)
%UPSAMPLE �M�����͂��A���v�T���v�����O���܂��B
%   UPSAMPLE(X,N) �́A���̓T���v���̊Ԃ�N-1�̃[���_��}�����邱�Ƃ�
%   ����āA���͐M��X ���A�b�v�T���v�����O���܂��B 
%   X �́A�x�N�g���A���邢�́A(1��ɂ�1�V�O�i��������)�M���s��
%   �̂����ꂩ�ł��B
%
%   UPSAMPLE(X,N,PHASE) �́A�I�v�V�����̃T���v���I�t�Z�b�g��
%   �w�肵�܂��BPHASE �́A[0, N-1]�͈̔͂̐����ł���K�v������܂��B
%
%   �Q�l: DOWNSAMPLE, UPFIRDN, INTERP, DECIMATE, RESAMPLE.

y = updownsample(x,N,'Up',varargin{:});

% [EOF] 


%   Copyright 1988-2002 The MathWorks, Inc.
