% RARX �́AARX ���f���̒���������s���܂��B
% 
%   [THM,YHAT] = RARX(Z,NN,adm,adg)
%
%   z : IDDATA �I�u�W�F�N�g�A�܂��́A�o�� - ���̓f�[�^�s�� z = [y u]
%       ���̃��[�`���́A�P�o�͑����̓f�[�^�ɑΉ����Ă��܂��B
%   NN : NN = [na nb nk]�AARX ���f���̎����ƒx��(ARX ���Q��)
%
%   adm: �K�����J�j�Y���A adg: �K���Q�C��
%      adm='ff', adg=lam : �Y�p�t�@�N�^ lam ���g�����Y�p�t�@�N�^�A���S��
%                          �Y��
%      adm='kf', adg=R1  : ���ԃX�e�b�v���ɕω�����p�����[�^�̋����U�s
%                          �� R1 ���g���� Kalman �t�B���^�A���S���Y��
%      adm='ng', adg=gam : �Q�C�� gam ���g�������K�����ꂽ���z�A���S���Y
%                          ��
%      adm='ug', adg=gam : �Q�C�� gam ���g�������K�����Ă��Ȃ����z�A���S
%                          ���Y��
%   THM  : ���茋�ʁB�s k �́A���� k �܂ł̃f�[�^�ɑΉ�����"�A���t�@�x�b
%          �g����"����p�����[�^�ł��B
%   YHAT : �o�̗͂\���l�B�s k �́A���� k �ɑΉ����Ă��܂��B�p�����[�^
%          (TH0) �� "P-�s��"(P0) �̏����l�����̂悤�Ɏg���܂��B
%
%    [THM,YHAT,P] = RARX(Z,NN,adm,adg,TH0,P0)
% 
% �⏕�f�[�^�׃N�g�� phi �� psi �̏����l�ƍŏI�l�́A���̃X�e�[�g�����g
% �ŁA�����܂��B
% 
%    [THM,YHAT,P,phi]=RARX(Z,NN,adm,adg,TH0,P0,phi0).
%
% �Q�l�F RARMAX, ROE, RBJ, RPEM and RPLR.



%   Copyright 1986-2001 The MathWorks, Inc.
