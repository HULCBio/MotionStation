% UPFIRDN �́AFIR�t�B���^�̓K�p�ƊԈ������s���܂��B
%
% UPFIRDN(X,H,P,Q) �́A����3�̑������͐M�� X �ɃJ�X�P�[�h�I�Ɏ��s
% ���܂��B
% 
%     (1) P �ɂ��A�b�v�T���v�����O(�[���}��)
%     (2) H �ɗ^����ꂽ�C���p���X�����Őݒ肳�ꂽ�t�B���^���g���� FIR 
%         �t�B���^����
%     (3) Q �ɂ��_�E���T���v�����O(�T���v�����Ԉ���)
%
% UPFIRDN �́A�|���t�F�[�Y�\�����g�p���܂��B
%
% �ʏ�A���� X �ƃt�B���^ H �̓x�N�g���ŁA�o�͂�(�M��)�x�N�g���ł��BUP-
% FIRDN �ł́A�z������ɑ΂��āA�ȉ��̑g����������܂��B
%
% X ���s��ŁAH ���x�N�g���̏ꍇ�AX �̊e��́AH �Ńt�B���^�����O���܂��B
% X ���x�N�g���ŁAH ���s��̏ꍇ�AH �̊e�� X ���t�B���^�����O���邽��
% �Ɏg���܂��BX �� H �����ɍs��(������)�̏ꍇ�AH �� i �Ԗڂ̗񂪁AX 
% �� i �Ԗڂ̗���t�B���^�����O���邽�߂Ɏg���܂��B
%
% ���ɁA�����̑g�ݍ��킹�́A���̂悤�Ɏ��s����܂��B�܂��A�o�͂̒���
% Ly �́Aceil( ((Lx-1)*P + Lh)/Q )�ŁA����ɁALx �́Alength(X)�ALh �́A
% length(H) �ł��B
% 
%   ���͐M�� X          ���̓t�B���^ H      �o�͐M�� Y       �L�@
%  ---------------------------------------------------------------
% 1) ����Lx �̃x�N�g�� ����Lh �̃x�N�g�� ����Ly �̃x�N�g��  �ʏ�g�p
% 2) Lx�sNx��̍s��    ����Lh �̃x�N�g�� Ly�sNx��̍s��     X �̊e���H
%                                                           �Ńt�B���^��
%                                                           ���O
% 3) ����Lx�̃x�N�g��  Lh�sNh��̍s��     Ly�sNh��̍s��    H�̊e����g
%                                                           ���āAX ���t
%                                                           �B���^�����O
% 4) Lx�sN��̍s��     Lh�sN��̍s��      Ly�sN��̍s��     H��i �Ԗڂ�
%                                                           ����g���āA
%                                                           X��i�Ԗڂ̗�
%                                                           ���t�B���^��
%                                                           ���O
%
% UPFIRDN(X,H,P) �́A�f�t�H���g�ŁAQ=1 ���g���܂��BUPFIRDN(X,H) �́A�f�t
% �H���g�ŁAP=1 �� Q=1 ���g���܂��B
%
% UPFIRDN ���A�����ƊȒP�Ɏg���ɂ́A�t�B���^��ݒ肵����A�t�B���^����
% �O�ɂ�蓱�������M���̒x���⏞����K�v�̂Ȃ��ARESAMPLE ���g���Ă�
% �������B
%
% �Q�l�F   RESAMPLE, INTERP, DECIMATE, FIR1, INTFILT.



%   Copyright 1988-2002 The MathWorks, Inc.
