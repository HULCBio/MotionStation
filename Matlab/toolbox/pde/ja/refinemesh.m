% REFINEMESH   �O�p�`���b�V�����ו������܂��B
% [P1,E1,T1] = REFINEMESH(G,P,E,T) �́A�`�� G�APoint �s�� P�AEdge �s�� E�A
% Triangle �s��T�ɂ���Đݒ肳�ꂽ�O�p�`���b�V�����ו������܂��B
%
% G �́APDE ���̌`���\�킵�܂��BG �́ADecomposed Geometry �s��܂��� 
% Geometry M-�t�@�C���̃t�@�C�����̂ǂ���ł��\�ł��B�ڍׂ́ADECSG ��
% ���� PDEGEOM ���Q�Ƃ��Ă��������B
%
% �O�p�`���b�V���́A���b�V���f�[�^ P, E, T �ɂ���ė^�����܂��B�ڍׂ́A
% INITMESH ���Q�Ƃ��Ă��������B
%
% [P1,E1,T1,U1] = REFINEMESH(G,P,E,T,U) �́A���b�V�����ו������A�֐� u 
% ����`��Ԃɂ���ĐV�������b�V���Ɋg�����܂��BU �̍s���́AP �̗񐔂ɑ�
% �����܂��BU1 �́AP1 �ɂ�����ߓ_�Ɠ����s���������܂��BU �̊e��́A�ʁX
% �ɕ�Ԃ���܂��B
%
% �t���I�ȓ��͈����́A�s�x�N�g���̏ꍇ�A�ו����̃T�u�h���C���̃��X�g�A��
% �x�N�g���Ȃ�΍ו����̎O�p�`�̃��X�g�Ƃ��ĉ��߂���܂��B
%
% �f�t�H���g�̍ו������@�́A�ݒ肳�ꂽ�O�p�`�S�Ăɂ����ē����`��4�̎O
% �p�`�ɕ��������ו������@(regular refinement)�ł��B�ݒ肳�ꂽ�e�O�p�`
% �ɂ����čł������e�Ђ�2���������ו������@(Longest edge refinement)�́A
% �p�����[�^�̍Ō�� 'longest' ��^���邱�Ƃɂ���Đݒ�ł��܂��B�p����
% �[�^�̍Ō�� 'regular' ���g���ƁA�K���I�ȍו������s���܂��B�O�p�`�̐�
% ����ۂ��߂ɁA�ݒ肳�ꂽ�W���̊O���̎O�p�`���ו�������邩������܂�
% ��B
%
% �Q�l   INITMESH, PDEGEOM



%       Copyright 1994-2001 The MathWorks, Inc.
