% PDEBOUND Boundary M-�t�@�C��
% Boundary M-�t�@�C���́APDE ���̋��E������ݒ肵�܂��B
%
% [Q,G,H,R] = PDEBOUND(P,E,U,TIME) �́A���E�����̒l���o�͂��܂��B
%
% �s�� P �� E �́A���b�V���f�[�^�ł��BE �́A���b�V����ŃG�b�W�̕����W��
% �ł��邱�Ƃ�����K�v�Ƃ��܂��B�ڍׂ́AINITMESH ���Q�Ƃ��Ă��������B
%
% ���͈��� U �� TIME �́A���ꂼ��A����^�\���o�Ǝ��ԃX�e�b�v�̃A���S��
% �Y���Ŏg���܂��B
%
% �� U �́AMATLAB ��x�N�g�� U �Ƃ��ĕ\������܂��B�ڍׂ́AASSEMPDE ���Q
% �Ƃ��Ă��������B
%
% Q �� G �́A�e���E�̒��_��̍s��̒l q �� g ���܂܂Ȃ���΂Ȃ�܂���B
% ���̂悤�ɂ��āAN ���V�X�e���̎����ŁAE �ɂ�����G�b�W���� NE�ASIZE(G)
% = [N NE] �ł���Ƃ���ŁASIZE(Q) = [N^2 NE] �ɂȂ�܂��B�f�B���N���̏�
% ���A�Ή�����l�̓[���ɂȂ�Ȃ���΂Ȃ�܂���B
%
% H �� R �́A�e�G�b�W���1�Ԗڂ̓_�ɂ�����s�� h �� r �̒l�A���Ɋe�G�b
% �W���2�Ԗڂ̓_�ɂ����� h �� r �̒l���܂܂Ȃ���΂Ȃ�܂���B���̂悤
% �ɂ��āAN ���V�X�e���̎����ŁAE �ɂ�����G�b�W���� NE�ASIZE(R) = [N 
% 2*NE] �ł���Ƃ���ŁASIZE(H) = [N^2 2*NE] �ɂȂ�܂��BM<N �̂Ƃ��Ah 
% �� r �̓[���s��� N-M �s�łȂ���΂Ȃ�܂���B
%
% �s�� q �� h �̗v�f�́AMATLAB �s�� Q �� H �ɗ񖈂ɔz�񂵂Ă����ԂŃX
% �g�A����܂��B



%       Copyright 1994-2001 The MathWorks, Inc.
