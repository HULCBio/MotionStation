% EVALFIS  �t�@�W�B���_�v�Z�̎��s
%
% �\��
%    output =  evalfis(input,fismat)
%    output =  evalfis(input,fismat,numPts)
%    [output,IRR,ORR,ARR] =  evalfis(input,fismat)
%    [output,IRR,ORR,ARR] =  evalfis(input,fismat,numPts)
% 
% �ڍ�
% evalfis �́A���̈����������܂��B
% 
% input   : ���͒l��ݒ肷�鐔�A�܂��́A�s��B���͂� M �s N ��(�����ł́A
%           N �͓��͕ϐ��̐�)�̍s��̏ꍇ�Aevalfis �́A���͂̊e�s�����
%           �x�N�g���Ƃ��Ď󂯎���āA�ϐ� output �� M �s L ��̍s����o
%           �͂��܂��B���̂Ƃ��A�e�s�͏o�̓x�N�g���ŁAL �͏o�͕ϐ��̐���
%           ���B
% 
% fismat  : �v�Z�̑ΏۂƂȂ� FIS �\����
% 
% numPts  :���̓��͔͈́A�܂��́A�o�͔͈͏�ŁA�����o�V�b�v�֐����v�Z��
%          ��T���v���_����\���I�v�V�����̈����B���̈������g�p���Ȃ���
%          ���A�f�t�H���g�l��101�_���g�p���܂��B
% 
% evalfis �͈̔̓��x���́A���̂Ƃ���ł��B
% 
% output  :�傫�����AM �s L ��̏o�͍s��B���̂Ƃ��AM �͏�Őݒ肵������
%          �l�̐��AL �� FIS �ɑ΂���o�͕ϐ��̐��ł��B
% 
% �@�@�@�@�@���͈������s�x�N�g��(���͂̏W����1�̂ݓK�p)�̏ꍇ�̂݁Aev-
%           alfis �ɑ΂���I�v�V�����͈͕̔ϐ����v�Z���܂��B�I�v�V������
%           �͈͂̕ϐ��́A���̂Ƃ���ł��B
% 
% IRR     :�����o�V�b�v�֐����g�������͒l�̌v�Z���ʁB�傫���́AnumRules 
%          �s N ��̍s��ɂȂ�܂��B���̂Ƃ��AnumRules �̓��[���̐��AN 
%          �͓��͕ϐ��̐��ł��B
% 
% ORR     :�����o�V�b�v�֐��ɂ��o�͒l�̌v�Z���ʁB�傫���́AnumPts �s 
%          numRules*L ��̍s��ɂȂ�܂��B�����ŁAnumRules �̓��[���̐�
%          L �͏o�͐��ł��B
%          ���̍s��̍ŏ��� numRules ��́A�ŏ��̏o�͂ɑΉ����A���� 
%          numRules ��́A2�Ԗڂ̏o�͂ɑΉ����܂��B�����āA�ȉ����l�ɑ�
%          �����܂��B
% 
% ARR     :�e�o�͂̏o�͔͈͂ɉ����� numPts �ŃT���v�����ꂽ�W�ϒl��v�f
%          �Ƃ��� numPts �s L ��̍s��ł��B
% 
% 1�͈̔͂̕ϐ��݂̂ŋN������ƁA���̊֐��́A���l�A�܂��́A�s�� input 
% �Őݒ肳�����͒l�ɑ΂��āA�s�� fismat �ɂ��ݒ肳��Ă���t�@�W�B��
% �_�V�X�e���̏o�̓x�N�g�� output ���v�Z���܂��B���̌v�Z�̓I�v�V�����̈�
% ���ł��B
% 
% ���
%    fismat = readfis('tipper');
%    out = evalfis([2 1; 4 9],fismat)
% 
% ���ʂ́A���̂悤�ɂȂ�܂��B
% 
%    out  = 
%        7.0169
%        19.6810
% 
% �Q�l    ruleview, gensurf



%   Copyright 1994-2002 The MathWorks, Inc. 
