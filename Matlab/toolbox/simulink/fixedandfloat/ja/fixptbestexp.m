% FIXPTBESTEXP  �ō����x��^����w���̌���
%
% �l�ɑ΂���Œ菬���_�\��
% ���p�@:
% fixedExponent = FIXPTBESTEXP( RealWorldValue, TotalBits, IsSigned ) �܂�
% �� fixedExponent = FIXPTBESTEXP( RealWorldValue, FixPtDataType )
%
% �ō����x(2�ׂ̂���)�̌Œ菬���_�\���́A��RealWorldValue = StoredInteger
% * 2^fixedExponent �Ɋ�Â��܁B�����ŁAStoredInteger�͎w�肵���T�C�Y�ƕ����t
% ��/�����Ȃ��X�e�[�^�X���������ł��B
%
% ���̌Œ菬���_�\���́A�����_�̉E���̃r�b�g�����w�肵�܂��B
%
% ���Ƃ��΁Afixptbestexp(4/3,16,1) �܂��� fixptbestexp(4/3,sfix(16)) �́A
% -14 ���o�͂��܂��B����́A�����t��16�r�b�g�����p����ꂽ�ꍇ�́A�ő吸�x�\��
% 1.33333333333333 (base 10)�́A�����_��14�r�b�g�E�ɒu�����Ƃɂ���ē�����
% ���Ƃ��Ӗ����܂��B�\���́A01.01010101010101 (base 2)  =  21845 * 2^-14 =
% 1.33331298828125 (base 10)�ɂȂ�܂��B���̕\���̐��x�́A�X�P�[�����O��
% 2^-14 �܂��� 2^fixptbestexp(4/3,16,1)�ɐݒ肷�邱�Ƃɂ���ČŒ菬���_�u���b
% �N�Ŏw�肳��܂��B
%
% �Q�l : SFIX, UFIX, FIXPTBESTPREC


% Copyright 1994-2002 The MathWorks, Inc.
