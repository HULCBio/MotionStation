%UINT8 �����Ȃ���8�r�b�g�����ւ̕ϊ�
% I = UINT8(X)  �́A�z�� X �̗v�f�𕄍��Ȃ���8�r�b�g�����ɕϊ����܂��B
% X �́ADOUBLE �̂悤�ȔC�ӂ̐��l�I�u�W�F�N�g�ɂȂ邱�Ƃ��ł��܂��B
% UINT8 �̒l�́A0 ���� 255 �܂ŁA�܂��́AINTMIN('uint8') ���� INTMAX('uint8')
% �܂ł͈̔͂��Ƃ�܂��B ���͈̔͊O�̒l�́A�I�[�o�[�t���[�ɖO�a�A���Ȃ킿�A
% ���͈̔͊O�̏ꍇ�A0 �܂��� 255 �Ɋ��蓖�Ă��܂��B X ���A���łɕ����Ȃ���
% 8�r�b�g�����z��ł���ꍇ�AUINT8  �͉e����^���܂���BDOUBLE ����� SINGLE 
% �̒l�͕ϊ��̍ہA�ł��߂� UINT8 �̒l�ւ̊ۂ߂��s���܂��B
%
%
% UINT8 �ɑ΂��A���� UINT8 �z��Ƃ̉��Z�ɒ�`�����Z�p���Z������܂��B 
% ���Ƃ��΁A+, -, .*, ./, .\ ����� .^ �ł��B
% ���Ȃ��Ƃ�1�̃I�y�����h���X�J���[�̏ꍇ�A*, /, \ ����� ^ ����`����܂��B
% UINT8 �z��́A�܂��A�萔���܂ށA�X�J���[�� DOUBLE �ϐ��Ƃ̉��Z���s���܂��B
% ���Z�̌��ʂ́AUINT8 �ł��BUINT8 �z��́A���Z�ŃI�[�o�[�t���[�ɖO�a���܂��B
%
% ���[�U�̃p�X��̃f�B���N�g������@uint8�f�B���N�g���ɓK�؂Ȗ��̂̃��\�b�h
% ��p�ӂ��邱�ƂŁA(�C�ӂ̃I�u�W�F�N�g�ɑ΂��ĂƓ��l��) UINT8 �ɑ΂���
% ���[�U���g�̎�@���`������A�I�[�o�[���[�h���邱�Ƃ��ł��܂��B
% �I�[�o���[�h�ł��郁�\�b�h���ɂ��ẮAHELP DATATYPES ���^�C�v����
% ���������B
%
% ���̕��@�́A�傫�� UINT8 �z�������������̂ɓ��Ɍ����I�ł��B
%
%      I = zeros(1000,1000,'uint8')
%
% ����́A1000x1000 �v�f�� UINT8 �z����쐬���A���̗v�f�͂��ׂă[���ł��B
% ���l�̕��@�ŁAONES �� EYE ���g�p���邱�Ƃ��ł��܂��B
%
% ���:
%    X = 17 * ones(5,6,'uint8')
%
% �Q�l DOUBLE, SINGLE, DATATYPES, ISINTEGER, UINT16, UINT32, UINT64,
%      INT8, INT16, INT32, INT64, INTMIN, INTMAX, EYE, ONES, ZEROS.


%   Copyright 1984-2002 The MathWorks, Inc. 
