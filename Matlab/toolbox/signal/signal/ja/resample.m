% RESAMPLE �́A�C�ӂ̃t�@�N�^�ɂ��T���v�����O���[�g��ύX���܂��B
%
% Y = RESAMPLE(X,P,Q) �́A�|���t�F�[�Y�������g���āA�I���W�i���̃T���v��
% ���O���[�g�� P/Q �{�ŁA�x�N�g�� X �̃f�[�^������T���v�����O���܂��BY 
% �́AX �̒����� P/Q �{�ɂȂ�܂��BP �� Q �́A���̐����łȂ���΂Ȃ�܂�
% ��BP/Q �������łȂ��ꍇ�AP/Q �𐳂̖���������֊ۂ� (ceil(P/Q)) ���s
% ���܂��B
%
% RESAMPLE �́A���T���v�����O�ߒ��ŁAX �ɃA���`�G�C���A�X(���[�p�X)FIR 
% �t�B���^��K�p���A�t�B���^�̒x����⏞���܂��B�t�B���^�́AFIRLS ���g��
% �Đ݌v����܂��BRESAMPLE �́AUPFIRDN �����ȒP�Ɏg�����Ƃ��ł��A�t�B
% ���^�����O�ɂ��M���x���̕⏞��t�B���^��v�����܂���B
%
% Y = RESAMPLE(X,P,Q,N) �́AX �� 2*N*max(1,Q/P) �̃T���v���ɏd�ݕt���a
% ���g���āAY �����߂܂��B�֐� RESAMPLE ���g�p���� FIR �t�B���^�̒����� 
% N �ɔ�Ⴕ�AN �̒l��傫������Ɛ��x�͍����Ȃ�܂����A�v�Z���Ԃ��K�v��
% �Ȃ�܂��BN �̃f�t�H���g�l��10�ł��BN  = 0 �ɂ���ƁARESAMPLE �͍ŋߖT
% �ߎ����g�p���܂��B�����ŁAY(n) = X(round((n-1)*Q/P)+1) �ƂȂ�܂��B��
% ���AX �̃C���f�b�N�X�Around((n-1)*Q/P)+1 >length(X) �̏ꍇ�AY(n) = 0 
% �ł��B
%
% Y = RESAMPLE(X,P,Q,N,BETA) �́ARESAMPLE �����[�p�X�t�B���^��݌v�����
% �Ɏg�p���� Kaiser �E�B���h�E�̐݌v�p�����[�^�Ƃ��� BETA ���g�p���܂��B
% BETA �̃f�t�H���g�l��5�ł��B
%
% Y = RESAMPLE(X,P,Q,B) �́A�t�B���^�W���x�N�g�� B �� X ���t�B���^������
% �܂��BRESAMPLE �́A�t�B���^�̒x����⏞���鎞�ɁA���`�ʑ��Ŋ�̒���
% �����W���x�N�g�� B �����肵�܂��B�t�B���^�̒����������̏ꍇ�A1/2�T��
% �v���Œx�����ߏ�⏞���܂��B�܂��A����`�ʑ��̃t�B���^�́AUPFIRDN ���g
% ���܂��B
%
% [Y,B] = RESAMPLE(X,P,Q,...)�́A���T���v�����O�ߒ��� X �ɓK�p�����t�B
% ���^�̌W�����x�N�g��B�ɏo�͂��܂��B 
%
% X���s��̏ꍇ�ARESAMPLE�́AX �̊e��ɑ΂��ă��T���v�����O���s���܂��B
%
% �Q�l�F   UPFIRDN, INTERP, DECIMATE, FIRLS, KAISER, INTFILT.



%   Copyright 1988-2002 The MathWorks, Inc.
