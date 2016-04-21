% fixdt  - �Œ菬���_�܂��͕��������_�f�[�^�^�C�v���L�q����I�u�W�F�N�g�̍�
%          ��
%
%
% ���̃f�[�^�^�C�v�I�u�W�F�N�g�́A�Œ菬���_�f�[�^�^�C�v���߰Ă���Simulink�u
% ���b�N�ɓn����܂��B
%
% ���p�@1: Fixed-Point Data Type With Unspecified scaling ?X?P?[???"?O?I'
% 1/4?I?u???b?N?p?��???[?^?E?a?A?A??'e?3?e?U?�E?B
%
% FIXDT( Signed, WordLength )
%
% ���p�@2: Fixed-Point Data Type With Binary point scaling
%
% FIXDT( Signed, WordLength, FractionLength )
%
% ���p�@3: Slope and Bias scaling
%
% FIXDT( Signed, WordLength, TotalSlope, Bias ) ?U?1/2?I FIXDT( Signed,
% WordLength, SlopeAdjustmentFactor, FixedExponent, Bias )
%
% ���p�@4: Data Type Name String
%
% FIXDT( DataTypeNameString ) ?U?1/2?I [DataType,IsScaledDouble] = FIXDT
% ( DataTypeNameString )
%
% �f�[�^�^�C�v��������́ASimulink���f���̐M�����C���ɕ\���������̂Ɠ�����
% ����ł��B�[�q�f�[�^�^�C�v��\�����邽�߂̃I�v�V�����ݒ�́ASimulink�̏�����
% �j���[�̉��ɂ���܂��B
%
% �W���f�[�^�^�C�v��p������́A�ȉ��̒ʂ�ł��B
%
% FIXDT('double')
% FIXDT('single')
% FIXDT('uint8')
% FIXDT('uint16')
% FIXDT('uint32')
% FIXDT('int8')
% FIXDT('int16')
% FIXDT('int32')
% FIXDT('boolean')
%
% �Œ菬���_�f�[�^�^�C�v���̃L�[�F
%
% Simulink�f�[�^�^�C�v���́A32�����������Ȃ��L����MATLAB���ʎq
% �ł��邱�Ƃ��K�{�ł��B
% �Œ菬���_�f�[�^�^�C�v�́A���̋K����p���ĕ���������܂��B
%
% Container
%
% 'ufix#'  unsigned with # bits  Ex.
% ufix3   is unsigned   3 bits 'sfix#'  signed   with # bits  Ex.
% sfix128 is signed   128 bits
% 'flts#'  scaled double data type override of sfix#
% 'fltu#'  scaled double data type override of ufix#
%
% Number encoding
%
% 'n'      minus sign,           Ex.
% 'n31' equals -31 'p'      decimal point         Ex.
% '1p5' equals 1.5 'e'      power of 10 exponent  Ex.
% '125e18' equals 125*(10^(18))
%
% Scaling Terms from the fixed-point scaling equation
%
% RealWorldValue = S * StoredInteger + B
% �܂���
% RealWorldValue = F * 2^E * StoredInteger + B
%
% 'E'      FixedExponent           if S not given, default is 0
% 'F'      SlopeAdjustmentFactor   if S not given, default is 1
% 'S'      TotalSlope              if E not given, default is 1
% 'B'      Bias                    default 0
%
% Examples using integers with non-standard number of bits
%
% FIXDT('ufix1')       Unsigned  1 bit
% FIXDT('sfix77')      Signed   77 bits
%
% �����_�X�P�[�����O��p������
%
% FIXDT('sfix32_En31')    Fraction length 31
%
% ���z�ƃo�C�A�X�X�P�[�����O��p������
%
% FIXDT('ufix16_S5')          TotalSlope 5
% FIXDT('sfix16_B7')          Bias 7
% FIXDT('ufix16_F1p5_En50')   SlopeAdjustmentFactor 1.
% 5  FixedExponent -50FIXDT('ufix16_S5_B7')       TotalSlope 5, Bias 7
% FIXDT('sfix8_Bn125e18')     Bias -125*10^18
%
% Scaled Doubles
%
% Scaled doubles?f?[?^?^?C?v?I?A?e?X?g?A?f?o?b?O?@"\?I?1/2?s?I?a?I?A?�E?B
% Scaled doubles?I?A2?A?I?d???a-??1/2?3?e?e?A?"?E"-?��?��?U?�E?B
% �ŏ��ɁA�����܂��͌Œ菬���_�f�[�^�^�C�v���ASimulink�u���b�N�̃}�X�N�ɓ����
% ���B���ɁA
% ?a-v?E?e?I?T?u?V?X?e???I?f?[?^?^?C?v?a?A?X?P?[???"?O?3?e?1/2double?E?I?
% X����܂��B
% ���̂��Ƃ���������Ƃ��A'sfix16_En7'?I?a???E?f?[?^?^?C?v?I?A?X?P?[???"?
% O?3?e?1/2doubles?f?[?^?^?C?v'flts16_En7'?E?I?X?3?e?U?�E?BFIXDT?I?A?��?I?
% o-I?I?A?I???W?i???I�f�[�^�^�C�v'sfix16_En7'?a"n?3?e?A?a?A? ?e?��?I?X?P?[?
% ??"?O?3?e?1/2double?A? ?e'flts16_En7'?a"n?3?e?e?A?a"�P?��?A?�E?B
% �I�v�V������2�Ԗڂ̏o�͈����́A���͂��X�P�[�����O���ꂽdouble�f�[�^�^�C�v��
% ����ꍇ�ɂ̂ݐ^�ł��B
%
% �Q�l : SFIX, UFIX, SINT, UINT, SFRAC, UFRAC, FLOAT.


% Copyright 1994-2003 The MathWorks, Inc.
