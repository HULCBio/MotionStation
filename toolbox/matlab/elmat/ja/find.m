%FIND   ��[���v�f�̃C���f�b�N�X�����߂܂�
% I = FIND(EXPR) �́A�_���� EXPR ��]�����A���ʂ̍s��̗v�f�̘_���l�� 
% TRUE �̏�Ԃɓ��������̂̃C���f�b�N�X���o�͂��܂��B���Ƃ��΁A
% I = FIND(A > 100) �́AA �� 100 ���傫���v�f�̃C���f�b�N�X���o�͂��܂��B
% EXPR ���s��̏ꍇ�AFIND �́A���`�̃C���f�b�N�X���o�͂��܂��B
% 
% [R,C] = FIND(EXPR) �́ATRUE �ƕ]�����ꂽ���̍s�Ɨ�̃C���f�b�N�X���o��
% ���܂��B���̃V���^�b�N�X�́A�X�p�[�X�s�����舵���ꍇ�ɁA���ɗL���ł��B
% EXPR �� N > 2 �Ƃ��āAN �����z��ɕ]������ꍇ�AC �́Atrailing 
% dimensions �̐��`�C���f�b�N�X�ł��B
% 
% [R,C,V] = FIND(EXPR) �́A�܂��AEXPR �� true �ƂȂ�A �ʒu R,C �ɑΉ�����
% �l���܂ރx�N�g�� V ���o�͂��܂��BMATLAB �́Afind �̑�����s���O�Ɏ���
% �]�����邽�߁AV �́AEXPR �̕]����ɕԂ����l���܂ނ��Ƃɒ��ӂ��Ă��������B
%
% [...] = FIND(EXPR,K) �́AEXPR �� TRUE �ƕ]�������ŏ��� K ��
% �C���f�b�N�X���o�͂��܂��BK �́A���̐����łȂ���΂Ȃ�܂��񂪁A�������
% ���l�^�C�v�ɂȂ邱�Ƃ��ł��܂��B
%
% [...] = FIND(EXPR,K,'first') �́AEXPR �� TRUE �ƕ]�������ŏ��� K ��
% �C���f�b�N�X���o�͂��܂��B
%
% [...] = FIND(EXPR,K,'last') �́ATRUE �ɕ]������� EXPR �̏I��肩�� K ��
% �C���f�b�N�X���o�͂��܂��B
%
% �Q�l SPARSE, IND2SUB.

%   Copyright 1984-2002 The MathWorks, Inc. 
