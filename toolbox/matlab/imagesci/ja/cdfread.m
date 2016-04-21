% CDFREAD   CDF�t�@�C������̃f�[�^�̓ǂݍ���
% 
% DATA = CDFREAD(FILE) �́AFILE�̊e���R�[�h���炷�ׂĂ̕ϐ���ǂ�
% ���݂܂��BDATA �̓Z���z��ŁA�e�s�����R�[�h�Ŋe�񂪕ϐ��ł��BCDF
% �t�@�C���̃f�[�^�̊e�������ǂݍ��܂�A�o�͂���܂��B
% 
% DATA = CDFREAD(FILE, 'RECORDS', RECNUMS, ...) �́ACDF�t�@�C������
% ����̃��R�[�h��ǂݍ��݂܂��BRECNUMS �́A�P���܂��͕����́A�ǂݍ�
% �܂��[���x�[�X�̃��R�[�h�ԍ�����Ȃ�x�N�g���ł��BDATA �́A�s���� 
% length(RECNUM) �̃Z���z��ł��B��̐��͕ϐ��̐��𓯂��ł��B
% 
% DATA = CDFREAD(FILE, 'VARIABLES', VARNAMES, ...) �́ACDF�t�@�C��
% ����Z���z��VARNAMES���̕ϐ���ǂݍ��݂܂��BDATA �́A�񐔂� 
% length(VARNAMES) �̃Z���z��ł��B�v��������ɑ΂���1�s�����݂�
% �܂��B
% 
% DATA = CDFREAD(FILE, 'SLICES', DIMENSIONVALUES, ...) �́ACDF�t�@
% �C������1�ϐ�����w�肵���l��ǂݍ��݂܂��B�s�� DIMENSIONVALUES 
% �́A"start", "interval", "count" �̒l����Ȃ�m�s3��̔z��ł��B
% "start" �̒l�̓[���x�[�X�ł��B
%
% DIMENSIONVALUES ���̍s���́A�ϐ��̎������ȉ��łȂ���΂Ȃ�܂���B
% ���w��̍s�́A�l [0 1 N] �������邱�Ƃɂ���Ă����̎������炷�ׂ�
% �̒l��ǂݍ��݂܂��B
% 
% 'Slices' �p�����[�^�̗��p���ɂ́A��x��1�̕ϐ������ǂݍ��ނ��Ƃ��ł�
% �Ȃ��̂ŁA'Variables' �p�����[�^��p����K�v������܂��B
% 
% [DATA, INF0] = CDFREAD(FILE, ...) �́AINFO�\���̓���CDF�t�@�C���Ɋւ�
% ��ڍׂ��o�͂��܂��B
%
% ����:
%
% CDFREAD �́ACDF �t�@�C���ɃA�N�Z�X����ꍇ�A�e���|�����t�@�C����
% �쐬���܂��B�J�����g�̍�ƃf�B���N�g���́A�������݉\�ł���K�v������܂��B
%
% ���:
%
%     data = cdfread('example.cdf');
%
%       �t�@�C�����炷�ׂẴf�[�^��ǂݍ��݂܂��B
%
%     data = cdfread('example.cdf', ...
%                    'Variable', {'Time'});
%
%       �ϐ�"Time"����f�[�^��ǂݍ��݂܂��B
%
%     data = cdfread('example.cdf', ...
%                    'Variable', {'multidimensional'}, ...
%                    'Slices', [0 1 1; 1 1 1; 0 2 2]);
%
%       �ϐ�"Multidimensional"���̍ŏ��̎�����1�Ԗڂ̒l�A2�Ԗڂ̎�����
%		2�Ԗڂ̒l�A3�Ԗڂ̎�����1�Ԗڂ�3�Ԗڂ̒l��ǂݍ��݁A
%		�c��̎����̂��ׂĂ̒l��ǂݍ��݂܂��B����́A���ׂĂ�
%		�ϐ��� "data" �ɓǂݍ���ł���MATLAB�R�}���h�𗘗p����
%               ���ƂƓ����ł��B
%
%         data{1}(1, 2, [1 3], :)
%
% �Q�l �F CDFINFO, CDFWRITE.


%   Copyright 1984-2002 The MathWorks, Inc.
