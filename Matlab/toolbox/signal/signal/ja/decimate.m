% DECIMATE �f�[�^��Ƀ��[�p�X�t�B���^��K�p���A���̌�A�T���v�����O���[
% �g�̒ጸ(�Ԉ���)���s���܂��B
%
% Y = DECIMATE(X,R)�́A�x�N�g��X�̒�����1/R(LENGTH(Y) = LENGTH(X)/R)�ɒZ
% �k����悤�ɁA�I���W�i���̃T���v�����O���[�g��ύX���܂��B
%
% DECIMATE�́A���T���v���̑O�ɁA�J�b�g�I�t���g�� .8*(Fs/2)/R ��8�����[�p
% �XChebyshev I�^�t�B���^��K�p���܂��B
%
% Y = DECIMATE(X,R,N)�́AN����Chebyshev�t�B���^���g�p���܂��B 
%
% Y = DECIMATE(X,R,'FIR')�́AChebyshev �t�B���^�̑���ɁA30�_��FIR�t�B
% ���^(FIR1(30,1/R))���g�p���܂��B
%
% Y = DECIMATE(X,R,N,'FIR')�́A����N��FIR�t�B���^���g�p���܂��B 
%
% ����: 
% R���傫���Ȃ�ƁA���l���x�̌��E�ɂ��AChebyshev�t�B���^���݌v�ł��Ȃ�
% �Ȃ�\��������܂��B���̂悤�ȏꍇ�ADECIMATE �̓t�B���^������Ⴍ��
% �肵�܂��B���ǂ��A���`�G�C���A�V���O�̕��@�́AR���e�v�f�ɕ������āA
% DECIMATE�����񂩎��s������@�ł��B
%
% �Q�l�F   INTERP, RESAMPLE.



%   Copyright 1988-2002 The MathWorks, Inc.
