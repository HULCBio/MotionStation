% HILBIIR   Hilbert �ϊ� IIR �t�B���^��݌v
% 
% HILBIIR �́A���z�� Hilbert �ϊ��t�B���^�Ɛ݌v���ꂽ4���̃f�B�W�^�� 
% Hilbert �ϊ� IIR �t�B���^�̃C���p���X�����������v���b�g���쐬���܂��B
% �t�B���^�̕W�{�����Ԃ�2/7�b�ł��B�܂��A�t�B���^�̎��Ԓx����1�b�ł��B
% �V�X�e���ɂ����闝�z�� Hilbert �ϊ��t�B���^�̃C���p���X������1/(t-1)/pi
% �ł��B�⏞��́A�K�p���܂���B
% 
% HILBIIR(TS) �́A���z�̗��_��� Hilbert �ϊ��t�B���^�Ɛ݌v���ꂽ4����
% �f�B�W�^�� Hilbert �ϊ� IIR �t�B���^�̃C���p���X�����������v���b�g��
% �쐬���܂��B�t�B���^�̕W�{�����Ԃ� TS (�b)�ł��B�܂��A�t�B���^�̌Q�x����
% 3.5*TS (�����l)�ł��BTOL = 0.05 ���g�p���āA���̃t�B���^�̎���������
% ���܂��B�⏞��̕t���͍s���܂���B���̃t�B���^�́A�ш敝 1/TS/2 �ł�
% �g�p��z�肵�����̂ł��B
% 
% HILBIIR(TS, DLY) �́A�W�{���� TS �ƌQ�x�� DLY(�b)�ɂ��݌v���ꂽ 
% Hilbert �ϊ��t�B���^�̃C���p���X�����̃v���b�g���쐬���܂��B�⏞���
% �g�p���܂���B���m�Ȍv�Z���s�����߂ɂ́ADLY �� TS �������Ȃ��Ƃ����{
% �傫���A����ɁArem(DLY, TS) = TS/2 �ƂȂ�悤�Ƀp�����[�^��I������
% �K�v������܂��B
% 
% HILBIIR(TS, DLY, BANDWIDTH) �́A�W�{������ TS �ƒx�� DLY �ɂ��݌v
% ���ꂽ Hilbert �ϊ��t�B���^�̃C���p���X�����̃v���b�g���쐬���܂��B
% ���̃t�B���^�̐݌v�ł́A���͐M���ɑ΂���⏞����g�p���܂��B���͐M����
% �ш敝�� BANDWIDTH �ł��BBANDWIDTH = 0�A�܂��́ABANDWIDTH > 1/TS/2��
% �Ƃ��ɂ́A�⏞��̕t�����s���܂���B
% 
% HILBIIR(TS, DLY, BANDWIDTH, TOL) �́A�W�{������ TS�A�x�� DLY�A����сA
% �ш敝 BANDWIDTH �ɂ��݌v���ꂽ Hilbert �ϊ��t�B���^�̃C���p���X����
% �̃v���b�g���쐬���܂��BTOL �́A�t�B���^�̐݌v�ɂ����鋖�e���������܂��B
% ���̃t�B���^�̎����̌���ɂ́A���̎����g���܂��B
% 
% �ł��؂������ْl/�ő���ْl < TOL 
% 
% TOL ��1�ȏ�̂Ƃ��A�t�B���^�̎����� TOL �ł��BBANDWIDTH = 0�A�܂��́A
% BANDWIDTH > 1/TS/2 �̏ꍇ�A�⏞���t�����Ă��Ȃ����߁A���̃t�B���^��
% �����͂��傤�� TOL �ł��B����ȊO�̏ꍇ�A�⏞���t�������t�B���^��
% �����́ATOL + max(3,ceil(TOL)/2)�ł��B
% 
% [NUM, DEN] = HILBIIR(...) �́A�`�B�֐� NUM(s)/DEN(s) ���o�͂��܂��B
% 
% [NUM, DEN, SV] = HILBIIR(...) �́A���̌v�Z�ł̓��ْl�ł���ǉ��p�����[
% �^ SV ���o�͂��܂��B
% 
% [A, B, C, D] = HILBIIR(...) �́A��ԋ�Ԃ̉����o�͂��܂��B
% 
% [A, B, C, D, SV] = HILBIIR(...) �́A��ԋ�Ԃ̉��Ɠ��ْl���o�͂��܂��B
% 


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $