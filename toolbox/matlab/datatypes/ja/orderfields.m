% ORDERFIELDS   �\���̔z��̃t�B�[���h�̏��Ԃ̕��בւ�
% 
% SNEW = ORDERFIELDS(S1) �́A�V�����\���̔z�� SNEW ���AASCII�Őݒ�
% ���ꂽ���Ԃ̃t�B�[���h���ƂȂ�悤��S1 �̃t�B�[���h����בւ��܂��B
% 
% SNEW = ORDERFIELDS(S1, S2) �́A�V�����\���̔z�� SNEW ���AS2 ��
% �t�B�[���h�Ɠ������̃t�B�[���h���ƂȂ�悤�� S1 �̃t�B�[���h��
% ���בւ��܂��BS1 �� S2 �́A�����t�B�[���h�������Ȃ���΂Ȃ�܂���B
% 
% SNEW = ORDERFIELDS(S1, C) �́A�V�����\���̔z�� SNEW ���AC �̃t�B�[���h��
% ������̃Z���z��Ɠ������ԂɂȂ�悤�� S1 �̃t�B�[���h����בւ��܂��B
% S1 �� C �́A�����t�B�[���h���������Ȃ���΂Ȃ�܂���B
% 
% SNEW = ORDERFIELDS(S1, PERM) �́APERM �̃C���f�b�N�X�ɂ���Ďw�肳�ꂽ
% ���ԂɂȂ�悤�� S1 �̃t�B�[���h����בւ��܂��BS1 �� N �̃t�B�[���h
% �������ꍇ�APERM �̗v�f��1���� N �̐��̕��ёւ��łȂ���΂Ȃ�܂���B
% �ēx���ёւ����s�������\���̂�1�ȏ゠��ꍇ�ɁA���ׂē���̕��@��
% �s���邽�߁A����͓��ɕ֗��ł��B
% 
% [SNEW, PERM] = ORDERFIELDS(...) �́A���ёւ������s�������ʂł��� SNEW
% �ɏo�͂��ꂽ�\���̔z��̃t�B�[���h�̕ύX���������Ԃ̃x�N�g�����o�͂��܂��B
%
% ORDERFIELDS �́A�g�b�v���x���̃t�B�[���h�݂̂���בւ��܂��B(�J��Ԃ�
% ���Ƃ͂ł��܂���).
% 
% ���:
%          s = struct('b',2,'c',3,'a',1);
%          snew = orderfields(s);
%          [snew, perm] = orderfields(s,{'b','a','c'});
%          s2 = struct('b',3,'c',7,'a',4);
%          snew = orderfields(s2,perm);


%   Copyright 1984-2003 The MathWorks, Inc. 
