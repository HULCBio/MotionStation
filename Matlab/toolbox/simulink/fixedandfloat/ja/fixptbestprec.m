% FIXPTBESTEXP  �ō����x��^����w���̌���
%
% �l�ɑ΂���Œ菬���_�\��
% ���p�@:
% precision = FIXPTBESTPREC( RealWorldValue, TotalBits, IsSigned ) �}�^�n
% precision = FIXPTBESTPREC( RealWorldValue, FixPtDataType )
%
% �ō����x(2�ׂ̂���)�Œ菬���_�\���́ARealWorldValue = StoredInteger *
% precision�Ɋ�Â��܂��B�����ŁAStoredInteger�́A�w�肵���T�C�Y�ƕ����t��/��
% ���Ȃ��X�e�[�^�X���������ŁAprecision��2�ׂ̂���ɐ�������܂��B
%
% ���Ƃ��΁Afixptbestprec(4/3,8,1) �܂��� fixptbestprec(4/3,sfix(8)) �́A0.
% 015625 = 2^-6���o�͂��܂��B����́A�����t��8�r�b�g�����p����ꂽ�ꍇ�́A�ő�
% ���x�\��1.33333333333333 (base 10) �� 85 * 0.015625 = 85 * 2^6 = 01.
% 010101 (base 2) =  1.328125 (base 10)�ł��邱�Ƃ������܂��B���x�́AFixed
% Point�u���b�N�ŃX�P�[�����O�p�����[�^�Ƃ��ėp�����܂��B
%
% �Q�l : SFIX, UFIX, FIXPTBESTEXP


% Copyright 1994-2002 The MathWorks, Inc.
