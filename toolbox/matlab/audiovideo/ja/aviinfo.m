% AVIINFO �@AVI �t�@�C���Ɋւ�����
% FILEINFO = AVIINFO(FILENAME) �́AAVI�t�@�C���Ɋւ�������܂�
% �\���̂̃t�B�[���h���o�͂��܂��BFILENAME �́AAVI�t�@�C������ݒ�
% ���镶����ł��BFILENAME �Ɋg���q���܂܂�Ă��Ȃ��ꍇ�́A'.avi' ��
% �g���܂��B�t�@�C���́A�J�����g�̃��[�L���O�f�B���N�g�������A�܂���
% MATLAB�p�X��ɑ��݂��Ȃ���΂Ȃ�܂���B
%
% FILEINFO �Ɋւ���t�B�[���h
%   
%   Filename           - �t�@�C�������܂ޕ�����
%   		      
%   FileSize           - �o�C�g�P�ʂŕ\�킷�t�@�C���̑傫������������
%   		      
%   FileModDate        - �t�@�C����ύX�������t���܂ޕ�����
%   		      
%   NumFrames          - ���[�r�[���̑��t���[��������������
%   		      
%   FramesPerSecond    - 1�b�Ԃ�����̍Đ����̃t���[��������������
%   		      
%   Width              - �s�N�Z���P�ʂŁAAVI���[�r�[�̕�����������
%   		      
%   Height             - �s�N�Z���P�ʂŁAAVI���[�r�[�̍�������������
%   		      
%   ImageType          - �C���[�W�̃^�C�v������������F
%                     	 �g�D���[�J���[(RGB)�ɂ́A'truecolor'
%                     	 �C���f�b�N�X�t���C���[�W�ɂ́A'indexed' �ł��B
%   		      
%   VideoCompression   - AVI�t�@�C�������k���邽�߂Ɏg�p����R���v
%                        ���b�T�[���܂ޕ�����BMicrosoft Video 1, Run-
%                        Length Encoding, Cinepak, Intel Indeo�łȂ���
%                        ���́A4�̃L�����N�^�R�[�h���o�͂��܂��B
%		      
%   Quality            - AVI�t�@�C���̃r�f�I�i��������0����100�܂ł̐��B
%                        �傫�������́A��荂���r�f�I�i���������܂��B
%                        ����A�����������́A�Ⴂ�r�f�I�i���������܂��B
%                        ���̒l�́AAVI �t�@�C���̒��ɏ�ɐݒ肳��Ă���
%                        ���̂ł��̂ŁA�������Ȃ��ꍇ������܂��B
%                        
%   NumColormapEntries - �J���[�}�b�v���̃J���[�̐��B�g�D���[�J���[�C���[
%                        �W�̏ꍇ�́A�l�̓[���ł��B
%   
% AVI�t�@�C�����I�[�f�B�I�X�g���[�����܂�ł���ꍇ�A���̃t�B�[���h
% �� FILEINFO �ɐݒ肳��܂��B
%   
%   AudioFormat      - �I�[�f�B�I�f�[�^���i�[���邽�߂Ɏg�p�����t�H�[
%                      �}�b�g�����܂ޕ�����
%   
%   AudioRate        - �I�[�f�B�I�X�g���[���̃T���v�����[�g��Hertz�P��
%                      �Ŏ�������
%   
%   NumAudioChannels - �I�[�f�B�I�X�g���[�����I�[�f�B�I�`�����l����
%                      ����������
%   
% �Q�l�FAVIFILE, AVIREAD.

% Copyright 1984-2004 The MathWorks, Inc.

