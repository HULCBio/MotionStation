% IM2COL   �C���[�W�u���b�N���ɍĔz��
%
% B = IM2COL(A,[M N],'distinct') �́A�C���[�W A �� M �s N ��̑傫��
% �̃u���b�N�ɕ������ꂽ�e�X�̃u���b�N�� B �̊e��ɍĔz�񂵂܂��B
% IM2COL �́AM �s N �� �̐����{�ɂȂ�悤�ɁA�K�v�ɉ����� A �Ƀ[����
% �t�����܂��BA = [A11 A12;A21 A22]�ŁAAij �� M �s N ��̏ꍇ�A
% B = [A11(:) A12(:);A21(:) A22(:)]�ɂȂ�܂��B
%
% B = IM2COL(A,[M N],'sliding') �́AA �̌X�� M �s N ��̑傫���̃X
% ���B�f�B���O�u���b�N�Ƀ[����t�����Ȃ��� B �̊e��ɕϊ����܂��BB 
% �� M*N �̍s�������AA �� M �s N ��̋ߖT�Ɠ����񐔂������Ă��܂��BA
% �̑傫����[MM NN]�̏ꍇ�AB �̃T�C�Y�́A(M*N)�s(MM-M+1)*(NN-N+1)��
% �ł��BB �̊e��́ANHOOD(:) �Ƃ��Đ��`���ꂽ A �̋ߖT���܂݂܂��B��
% ���ŁANHOOD �́AA �� M �s N ��̋ߖT���܂ލs��ł��BIM2COL �́AB 
% �̊e��������t���A�ʏ�̕��@�ōs����쐬����悤�ɕό`���邱�Ƃ���
% ���܂��B���Ƃ��΁ASUM(B) �̂悤�Ȋe��ɃX�J�����o�͂���֐����g��
% �Ƃ��܂��B���̃X�e�[�g�����g�Q���g���āA���ʂ��A���ځA(MM-M+1) 
% �s (NN-N+1) ��̍s��Ɋi�[���܂��B
%
%      B = im2col(A,[M N],'sliding');
%      C = reshape(sum(B),MM-M+1,NN-N+1);
%
% B = IM2COL(A,[M N]) �́A�u���b�N�^�C�v�̃f�t�H���g 'sliding' ���g
% �p���܂��B
%
% B = IM2COL(A,'indexed',...) �́AA ���C���f�b�N�X�t���C���[�W�Ƃ���
% �������AA �̃N���X�� uint8 �܂��� uint16 �̏ꍇ�̓[�����AA �̃N���X
% �� double �̃N���X�̏ꍇ�́A1��t�����܂��B
%
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W A �́A���l�܂��� logical �ł��B�o�͍s�� B �́A����
% �C���[�W�Ɠ����N���X�ł��B
%
% �Q�l : BLKPROC, COL2IM, COLFILT, NLFILTER


%   Copyright 1993-2002 The MathWorks, Inc.  
