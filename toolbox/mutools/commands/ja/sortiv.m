% function [out,err] = sortiv(in,sortflg,nored,epp)
%
% �Ɨ��ϐ����P�������łȂ���΁A�Ɨ��ϐ��͕��בւ����AOUT�ɏo�͂����
% ���BSORTFLG = 0 (�f�t�H���g)�́A�Ɨ��ϐ��𑝉����ɕ��ׁASORTFLG = 1��
% �������ɕ��ׂ܂��BNORED = 0 (�f�t�H���g)�́A�d�����Ă���Ɨ��ϐ�������
% �Ă��Ɨ��ϐ��̐��͌������܂���BNORED���[���̒l�ɐݒ肷��ƁA�d����
% ��Ɨ��ϐ��̑Ή�����s�񂪓����ꍇ�A�Ɨ��ϐ��͏d�Ȃ邱�Ƃɂ���苎��
% ��܂��B�����łȂ���΃G���[���b�Z�[�W���\������A�ŏ��̓Ɨ��ϐ��Ƃ���
% �Ή�����s��݂̂��ۑ�����܂��B�o�͈���ERR�͒ʏ�0�ŁA�G���[���b�Z�[�W
% ���\��������1�ɐݒ肳��܂��BEPP�́A2�̓Ɨ��ϐ��Ƃ����̑Ή�����
% �s��̗ގ��x���`�F�b�N���邽�߂Ɏg���܂��B�f�t�H���g�l�́A[1e-9; 
% 1e-9]�ł��BSORTIV�́A���g�������܂��͎��ԉ����̃��b�V������邽�߂�
% TACKON�Ƌ��Ɏg���܂��B
%
% �Q�l: GETIV, INDVCMP, SORT, TACKON, XTRACT, XTRACTI.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
