% DDEADV �A�h�o�C�T�������N�̐ݒ�
% 
% DDEADV�́AMATLAB�ƃT�[�o�A�v���P�[�V�����Ƃ̊Ԃ̃A�h�o�C�U�������N��
% �ݒ肵�܂�(�ڍׂ́A"DDE Advisory Links"�̏�)�B����item�ɂ���ė^��
% ��ꂽ�f�[�^���ύX�����ƁA����callback�ŗ^����ꂽ������eval�֐���
% �^�����A���s����܂��B�A�h�o�C�U�������N���z�b�g�����N�̏ꍇ�ADDE��
% item�̃f�[�^�𔽉f���邽�߂ɃA�b�v�f�[�g�s��upmtx���C�����܂��Bitem��
% �f�[�^�l�͈̔͂ƈ�v����ꍇ�́A�͈͓��ł̒l�̕ύX�ɂ���āA�R�[��
% �o�b�N�����s����܂��B
%
% rc = DDEADV(channel,item,callback,upmtx,format,timeout)
%
% rc       �Ԃ�l: 0�͎��s�A 1�͐������Ӗ����܂��B
% channel  DDEINIT����̒ʐM�`�����l��
% item     �A�h�o�C�U�������N�ɑ΂���DDE�A�C�e���̖��O���w�肷�镶����
%          �T�[�o���A�h�o�C�U�������N�Ɠ��������Ƃ��A�A�C�e���ɂ����
%          �w�肳�ꂽ�f�[�^���ύX����܂��B
% 
% callback �A�b�v�f�[�g�ʒm�Ŏ��s�����callback���w�肵��������B�T�[�o
%          �ŃA�C�e�����ύX������callback��eval�֐��ɗ^�����A���s
%          ����܂��B
% 
% upmtx    (�I�v�V�����I��)�A�b�v�f�[�g�ʒm�ő���ꂽ�f�[�^��ێ�����
%          ����s��̖��O�Bupmtx���܂܂�Ă���ƁA�T�[�o�ł̃A�C�e����
%          �ύX�ɂ��C���f�[�^��upmtx���A�b�v�f�[�g����܂��B�A�b�v
%          �f�[�g�s����w�肷�邱�Ƃɂ���ăz�b�g�����N���쐬���܂��B
%          uptmx��^���Ȃ�������A��s��Ƃ��ė^����ƃE�H�[�������N��
%          �쐬���܂��Bupmtx�����[�N�X�y�[�X�ɑ��݂���ꍇ�́A���̓��e��
%          �㏑������܂��Bupmtx�����݂��Ȃ���΁A�쐬����܂��B
% 
% format   (�I�v�V����)�X�V�œ]�������f�[�^�t�H�[�}�b�g��ݒ肷��2�v�f
%          �z��B�ŏ��̗v�f�́A�f�[�^�ɑ΂��Ďg�p����Windows�N���b�v�{�[�h
%          �t�H�[�}�b�g���w�肵�A�J�����g�T�|�[�g����Ă���t�H�[�}�b�g�́A
%          CF_TEXT�݂̂ŁA����͒l1�ɑΉ����܂��B2�Ԗڂ̗v�f�́A���������
%          �s��̃^�C�v��ݒ肷����̂ł��B�������l�́ANUMERIC(�f�t�H���g
%          �ŁA0�̒l�ɑΉ�)��STRING(1�ɑΉ�)�̂ǂ��炩�ł��B
%          �f�t�H���g�t�H�[�}�b�g�z��́A[1�@0]�ł��B
% 
% timeout  (�I�v�V����)���̉��Z�ɑ΂��鎞�Ԑ�����ݒ肷��X�J���ł��B
%          ���Ԑ����́A�~���b�P�ʂŐݒ肵�܂��B�A�h�o�C�U�������N���A
%          ���Ԑ����͈̔͊O�łȂ��ꂽ�ꍇ�A�֐��̓G���[�ɂȂ�܂��B
%          ���Ԑ����̃f�t�H���g�l��3�b�ł��B
% 
% ���Ƃ��΁AExcel�̃Z���͈̔͂ƍs��'x'�̊Ԃ̃z�b�g�����N��ݒ肵�܂��B
% ��������ƁA�s��͂��̂悤�ɕ\������܂��B
% 
%      rc = ddeadv(channel, 'r1c1:r5c5', 'disp(x)', 'x');
%
% �Q�l�FDDEINIT, DDETERM, DDEEXEC, DDEREQ, DDEPOKE, DDEUNADV.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2004/04/28 02:09:41 $
%   Built-in function.
