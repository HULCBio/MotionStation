% XPCSPECTRUMDEMO xPC Target���g�p���ăX�y�N�g���A�i���C�U�̃f�����g�p������@
%
%   �X�y�N�g���A�i���C�U�̃f���́ASimulink ���f���t�@�C��xpcdspspectrum.mdl
%   �Ɋ܂܂�Ă��܂��B���̃f�����g�p���邽�߂ɂ́ADSP blockset���K�v�ł��B
%   ����ɁATargetScope�𓮍�\�Ƃ�����ԂŁAxPC Target PC�����삵�Ă���
%   �K�v������܂� �B
%
%   �f���́A512�T���v���̃o�b�t�@���g�p���āA���͐M���̍���Fourier�ϊ�
%   (FFT)��\�����邱�Ƃɂ��A�X�y�N�g���A�i���C�U��͕킵�܂��B 
%   ���͐M���́A2�̐����g�̏d�ˍ��킹�ŁA1�́A�U��0.6�Ŏ��g��250 Hz�ł���A
%   ��������́A�U��0.25�Ŏ��g��600 Hz�ł��B���̌��ʁAxPC Target PC ���j�^��
%   �ɁA�^�C�vTarget�̃X�R�[�v��\�����܂��B
%
%   MATLAB �R�}���h���C���ł��̂悤�ɓ��͂��āA�X�y�N�g���A�i���C�U�̃f�����A
%�@ �J�����Ƃ��ł��܂��B
%   >> xpcdspspectrum
%�@ Simulink Window����Tools|Real-Time Workshop|Build��I�����āA���̃��f�����A
%   �r���h���A�^�[�Q�b�gPC�Ƀ_�E�����[�h���邱�Ƃ��ł��܂��B����ɂ��A
%   ����ɁAMATLAB ���[�N�X�y�[�X�ŁA'tg' �ƌĂ΂��ϐ����쐬����܂��B
%   ����́A�^�[�Q�b�g�A�v���P�[�V�����ƒʐM���邽�߂Ɏg�p�����xpc�I�u�W�F�N�g
%   �ł��B
%
%   ���̌�A���̂悤�ɓ��͂ł��܂�
%   >> start(tg)
%   �R�}���h���C��MATLAB �ŁA�A�v���P�[�V�������N�����A���͐M���̎��g���X�y�N�g
%   ����\�����܂��B
%
%   ���̃R�}���h
%
%   >> s1amp = getparamid(tg, ...
%               'Sine Wave f=250Hz, amp= 0.6', 'Amplitude');
%   >> s1fre = getparamid(tg, ...
%               'Sine Wave f=250Hz, amp= 0.6', 'Frequency');
%   >> s2amp = getparamid(tg, ...
%               'Sine Wave f=600Hz, amp= 0.25', 'Amplitude');
%   >> s2fre = getparamid(tg, ...
%               'Sine Wave f=600Hz, amp= 0.25', 'Frequency');
%
%   �����s���A����ɁA���̃R�}���h
%   >> set(tg, s1amp, 0.3);
%   >> set(tg, s1fre, 300);
%   >> set(tg, s2amp, 0.55);
%   >> set(tg, s2fre, 500);
%   ���g�p���邱�Ƃɂ��A���͐M���p�����[�^���A�A�v���P�[�V�����̎��s����
%   �ς��邱�Ƃ��ł��܂��B�������āA�ω�����M�����A���A���^�C���ŁA���j�^
%�@ ���邱�Ƃ��\�ɂȂ�܂��B�R�}���hset�́A�U���Ǝ��g����ς��āA�V�~����
%   �[�V�������J��Ԃ����Ƃ��\�ɂ��܂��B
%
%   'xPC Target Spectrum Scope' �u���b�N�̏ڍׂ́A�u���b�N����E�N���b�N���A
%   'Look under mask'��I�����邱�Ƃɂ��A���ׂ��܂��B����ɂ��A�ǂ̂悤��
% �@�X�y�N�g���A�i���C�U�̋@�\���B������邩��������܂��B



%   Copyright (c) 1996-2000 The MathWorks, Inc. All Rights Reserved.
