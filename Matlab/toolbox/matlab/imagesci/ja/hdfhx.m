% HDFHX   HDF�O���f�[�^�C���^�t�F�[�X�ւ�MATLAB�Q�[�g�E�F�C
%
% HDFHX �́A�����N�����f�[�^�v�f��O���f�[�^�v�f����舵�����߂�HDF
% �C���^�t�F�[�X�ւ̃Q�[�g�E�F�C�ł��B���̊֐����g�����߂ɂ́AHDF version 
% 4.1r3��User'sGuide��Reference Manual�Ɋ܂܂�Ă���AHX�C���^�t�F�[�X��
% ���Ă̏���m���Ă��Ȃ���΂Ȃ�܂���B���̃h�L�������g�́ANational 
% Center for Supercomputing Applications(NCSA <http://hdf.ncsa.uiuc.edu>)
% ���瓾�邱�Ƃ��ł��܂��B 
% 
% HDFHX �ɑ΂����ʓI�ȃV���^�b�N�X�́AHDFHX(funcstr,param1,param2,...) 
% �ł��BHDF ���C�u��������HX�֐��� funcstr �ɑ΂���L���Ȓl�́A1��1��
% �Ή����܂��B���Ƃ��΁AHDFHX('setdir',pathname); �́AC���C�u�����R�[�� 
% HXsetdir(pathname) �ɑΉ����܂��B
%
% �V���^�b�N�X�̎g����
% --------------------
% �X�e�[�^�X�܂��͎��ʎq�̏o�͂�-1�̂Ƃ��A���삪���s�������Ƃ������܂��B
%
% HDF C���C�u�������������͂ɑ΂���NULL���󂯓����ꍇ�́A��s��([] 
% �܂��� '')���g���܂��B
%
% �V���^�b�N�X
% ------------
%  access_id = hdf('HX', 'create', file_id, tag, ref, extern_name,
% 		   offset, length)
% �V�����O���t�@�C���̓���̃f�[�^�v�f���쐬���܂��B
% 
%  status = hdf('HX','setcreatedir',pathname);
%  �������ݗp�O���t�@�C���̃f�B���N�g���̈ʒu��ݒ肵�܂��B
%
%  status = hdf('HX','setdir',pathname);
%  �O���t�@�C����z�u���邽�߂Ƀf�B���N�g����ݒ肵�܂��BPATHNAME �́A
%  | �ŕ������������̃f�B���N�g�����܂ނ��Ƃ��ł��܂��B
%
% �Q�l�FHDF, HDFSD, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%       HDFML, HDFV, HDFVF, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:54 $
