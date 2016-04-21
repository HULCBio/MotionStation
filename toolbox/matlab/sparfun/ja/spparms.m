% SPPARMS   �X�p�[�X�s��̃��[�`���ɑ΂��ăp�����[�^��ݒ肵�܂��B
% 
% SPPARMS('key',value) �́A�X�p�[�X���[�`���A����ѓ��ɍŏ��x������
% ���בւ� COLMMD �� SYMMMD ����уX�p�[�X / �� \ �ŗp���钲���\
% �ȕ����̃p�����[�^��ݒ肵�܂��B
% 
% SPPARMS ���g�ł́A�J�����g�̐ݒ��\�����܂��B
%
% ���͈������Ȃ���΁Avalues = SPPARMS �́A�J�����g�̐ݒ�l�𐬕��Ƃ���
% �x�N�g�����o�͂��܂��B[keys,values] = SPPARMS �́A�J�����g�̐ݒ�l�𐬕�
% �Ƃ���x�N�g���ƁA�p�����[�^�̃L�[���[�h���s�̐����Ƃ��镶����s��Ƃ��o
% �͂��܂��B
%
% SPPARMS(values) �́A�o�͈����Ȃ��ŁA���ׂẴp�����[�^�������x�N�g���Ŏw�肳�ꂽ�l�ɐݒ肵�܂��B
%
% value = SPPARMS('key') �́A1�̃p�����[�^�̃J�����g�l���o�͂��܂��B
%
% SPPARMS('default') �́A���ׂẴp�����[�^���f�t�H���g�l�ɐݒ肵�܂��B
% SPPARMS('tight') �́A�ŏ��x�����̕��בւ��̃p�����[�^���A"tight"(����)�l
% �ɐݒ肵�܂��B����́A���Ȃ��[�U�ŕ��בւ����s�����Ƃ��ł��܂����A����
% �ւ��Ɏ��Ԃ�������悤�ɂȂ�܂��B
%
% �p�����[�^�̃L�[���[�h�Ƃ��̃f�t�H���g�l�����tight�l�͂��̒ʂ�ł��B
% 
%                �L�[���[�h	  �f�t�H���g�l	 tight�l
%
%    values(1)     'spumoni'       0
%    values(2)     'thr_rel'       1.1             1.0
%    values(3)     'thr_abs'       1.0             0.0
%    values(4)     'exact_d'       0               1
%    values(5)     'supernd'       3               1
%    values(6)     'rreduce'       3               1
%    values(7)     'wh_frac'       0.5             0.5
%    values(8)     'autommd'       1            
%    values(9)     'autoamd'      1
%    values(10)    'piv_tol'      0.1
%    values(11)    'bandden'      0.5
%    values(12)    'umfpack'       1
%
% �p�����[�^�̈Ӗ��́A���̒ʂ�ł��B
%
%    spumoni:  �X�p�[�X���j�^�[�t���O�ŁA�f�f�o�͂𐧌䂵�܂��B0�͐f�f�o
%              �͂����܂���B1�͐f�f�o�͂��s���܂��B2�͏ڂ��������o�͂�
%              �܂��B
%    thr_rel,
%    thr_abs:  �ŏ��x�����̂������l�́Athr_rel*mindegree + thr_abs �ł��B
%    exact_d:  �[���łȂ���΁A�ŏ��x�����ɐ��m�ȓx�������g���܂��B�[����
%              ����΁A�ߎ��̓x�������g���܂��B
%    supernd:  ���ł���΁AMMD�� supernd �i�K���� supernodes ��g�ݍ���
%				 �܂��B
%    rreduce:  ���ł���΁AMMD�� rreduce �i�K���ɍs�̏k�����s���܂��B
%    wh_frac:  density > wh_frac �ł���s�́ACOLMMD �ł͖�������܂��B
%    autommd:  ��[���ł���΁AQR �Ɋ�Â� \ �� / �ɂ�� MMD
%              ���בւ����s���܂��B
%    autoamd:  ��[���ł���΁ALU �Ɋ�Â� \ �� / �ɂ�� COLAMD ����
%              �ւ����s���܂��B
%    piv_tol:  �s�{�b�g���e�덷�́ALU�Ɋ�Â�(UMFPACK) \ �� / ��p���܂��B
%    bandden:  �ш斧�x�� bandden ���傫���ꍇ�A�o�b�N�X���b�V���́A
%              �ш�\���o���g�p���܂��B
%              bandden = 1.0 �̏ꍇ�A�ш�\���o���g���܂���B
%              bandden = 0.0 �̏ꍇ�A��ɑш�\���o���g���܂��B
% 				  
% ����: 
% �Ώ̂̐���s���CHOL �Ɋ�Â� \ �� / �́ASYMMMD ���g�p���܂��B
% �����s��� UMMFPACK LU �Ɋ�Â� \ �� / (UMFPACK) �́A�C�����ꂽ
% COLAMD ���g�p���܂��B
% �����s��� v4 LU �Ɋ�Â� \ �� / (UMFPACK) �́ACOLAMD ���g�p���܂��B
% �����`�̍s��� QR �Ɋ�Â� \ �� / �́ACOLMND ���g�p���܂��B
%
% �Q�l�FCOLMMD, SYMMMD, COLAMD, SYMAND, UMFPACK.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 02:03:32 $
