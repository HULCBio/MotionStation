% SPTOOL  �M�������c�[�� - �O���t�B�J�����[�U�C���^�t�F�[�X
%
% SPTOOL�ɂ��ASPTool�E�B���h�E���J���A�M���A�t�B���^�A�X�y�N�g����ǂ�
% ���񂾂�A��͂�����A��舵�����Ƃ��ł��܂��B
% 
% �R�}���h���C�����g���āASPTool����Ώە��̍\���̂�]��������@�B
% ---------------------------------------------------------------
% �ȉ��̃R�}���h�ɂ���āA���݊J����Ă��� SPTool ����\���̔z������[�N
% �X�y�[�X�ɏ������݂܂��B
%
% s = sptool('Signals')�́A���ׂĂ̐M���̍\���̔z����o�͂��܂��B
% f = sptool('Filters')�́A���ׂẴt�B���^�̍\���̔z����o�͂��܂��B
% s = sptool('Spectra')�́A���ׂẴX�y�N�g���̍\���̔z����o�͂��܂��B
%
% [s,ind] = sptool(...)�́ASPTool ���ŃJ�����g�ɑI�������\����(s)�̗v�f
% �������C���f�b�N�X�x�N�g��(ind)���o�͂��܂��B
%
% s = sptool(...,0)�́A���ݑI�����Ă���I�u�W�F�N�g�݂̂��o�͂��܂��B
%
% �R�}���h���C�����g���č\���̔z����쐬������A���[�h������@�B
% --------------------------------------------------------------
% struc = sptool('create',PARAMLIST)�́A���[�N�X�y�[�X����"PARAMLIST"��
% ��`�����A�\���̔z�� struc���쐬���܂��B
%
% sptool('load',struc)�́ASPTool���ɍ\���̔z�� struc �����[�h���܂��B��
% ���A�K�v�ȏꍇ�ASPTool���J���܂��B
%
% struc = sptool('load',PARAMLIST)�́ASPTool���� "PARAMLIST" �ɂ���Ē�
% �`���ꂽ�A�\���̔z�� struc �����[�h���܂��B�܂��A�I�v�V�����̏o�͈���
% ���w�肷��΁A�\���̔z�� struc�����[�N�X�y�[�X���ɒ�`����܂��B
% 
% %
% COMPONENT           PARAMLIST
% ~~~~~~~~~           ~~~~~~~~~
% SIGNALS:   COMPONENT_NAME,DATA,FS,LABEL
% FILTERS:   COMPONENT_NAME,NUM,DEN,FS,LABEL
% SPECTRA:   COMPONENT_NAME,DATA,F,LABEL
%
% �p�����[�^�̒�`
% ~~~~~~~~~~~~~~~~~
% COMPONENT_NAME - 'Signal', 'Filter', 'Spectrum'�̂����ꂩ�ACOMPONENT_
% NAME ���ȗ�����ƃf�t�H���g��'Signal'�ɂȂ�܂��B
%   DATA    - �M����X�y�N�g������{���x�ŕ\���x�N�g���ł��B
%   NUM,DEN - �`�B�֐��\���ŕ\���ꂽ�t�B���^�̕��q�A����̌W���ł��B
%   FS      - �T���v�����O���g���ł�(�I�v�V����)�B�f�t�H���g�́A"1"�ł��B
%   F       - ���g���x�N�g���@; �X�y�N�g�������݂̂ɓK�p�ł��܂��B.
%   LABEL   - SPTool���ŕ\�������v�f�̕ϐ������w�肷�镶����ł�
%             (�I�v�V����)�B�f�t�H���g�ŁA'sig'�A 'filt'�A 'spec'�̂���
%             �ꂩ���g���܂��B
%   Copyright 1988-2001 The MathWorks, Inc.
