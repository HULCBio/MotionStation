%UINT64 �����Ȃ���64�r�b�g�����ւ̕ϊ�
% I = UINT64(X) �́A�z�� X �̗v�f�𕄍��Ȃ���64�r�b�g�����ɕϊ����܂��B
% X �́A(DOUBLE �̂悤��) �C�ӂ̐��l�I�u�W�F�N�g�ɂȂ邱�Ƃ��ł��܂��B
% UINT64 �̒l�́A0 ���� 18,446,744,073,709,551,615 �܂ŁA�܂��́A
% INTMIN('uint64') ���� INTMAX('uint64') �܂ł͈̔͂��Ƃ�܂��B
% ���͈̔͊O�̒l�́AINTMIN('uint64') �܂��� INTMAX('uint64')�Ɋ��蓖�Ă��܂��B

% X �����łɕ����Ȃ�64�r�b�g�����z��ł���ꍇ�́AUINT64 �͉e����^���܂���B
% DOUBLE ����� SINGLE �̒l�͕ϊ��̍ہA�ł��߂� UINT64 �̒l�ւ̊ۂ߂��s���܂�
%
% UINT64 �̃N���X�́A��Ƃ��Đ����l���i�[���邽�߂Ɏg�p���邱�Ƃ��Ӑ}
% ���Ă��܂��B�]���āA�����̗v�f��ύX�����ɔz�����舵���قƂ�ǂ�
% ���삪��`����Ă��܂��B(��Ƃ��ẮARESHAPE�ASIZE�A��r���Z�q�A�_��
% ���Z�q�A�T�u�X�N���v�g�t���̊��蓖�Ă�Q�Ƃł�)�B 
% �Z�p���Z�́AUINT64 �ɑ΂��Ă͒�`����Ă��܂���B
%
% ���[�U�̃p�X��̃f�B���N�g������@uint64�f�B���N�g���ɓK�؂Ȗ��̂̃��\�b�h
% ��p�ӂ��邱�ƂŁA(�C�ӂ̃I�u�W�F�N�g�ɑ΂��ĂƓ��l��) UINT64 �ɑ΂���
% ���[�U���g�̎�@���`���邱�Ƃ��ł��܂��B
% �I�[�o���[�h�ł��郁�\�b�h���ɂ��ẮAHELP DATATYPES ���^�C�v����
% ���������B
%
% ���̕��@�́A�傫�� UINT64 �z�������������̂ɓ��Ɍ����I�ł��B
%
%      I = zeros(100,100,'uint64')
%
% ����́A1000x1000 �v�f�� UINT64 �z����쐬���A���̗v�f�͂��ׂă[���ł��B
% ���l�̕��@�ŁAONES �� EYE ���g�p���邱�Ƃ��ł��܂��B
%
% �Q�l DOUBLE, SINGLE, DATATYPES, ISINTEGER, UINT8, UINT16, UINT32,
%   �@ INT8, INT16, INT32, INT64, INTMIN, INTMAX, EYE, ONES, ZEROS.

%   Copyright 1984-2002 The MathWorks, Inc. 
