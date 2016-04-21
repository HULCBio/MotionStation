% Communications Toolbox
% Version 3.0 (R14) 05-May-2004
%
% ?��
%   randerr      - �r�b�g���p�^?[����?�?�
%   randint      - ��l���z����??�?�?���?s���?�?�
%   randsrc      - �O������?ݒ肵���A���t�@�x�b�g���g����?A�����_��?s��
%                  ��?�?�
%   wgn          - ��?F�K�E�X�m�C�Y��?�?�
%
% ?M?���?͊�?�
%   biterr       - �r�b�g�G��?[?��ƃr�b�g�G��?[��?[�g�̌v�Z
%   eyediagram   - �A�C�p�^?[����?�?�
%   scatterplot  - �X�L���^?[�v�?�b�g��?�?�
%   symerr       - �V���{���G��?[?��ƃV���{���G��?[��?[�g�̌v�Z
%
% ?��̕�?���
%   compand      - �ʖ@��?A�܂���?AA�@����?k/?L���ɂ��?�񌹕�?���
%   dpcmdeco     - ?����p���X��?��ϒ��������g�p���ĕ�?�
%   dpcmenco     - ?����p���X��?��ϒ��������g�p���ĕ�?���
%   dpcmopt      - DPCM�p���??[�^��?œK��
%   lloyds       - Lloyd�A���S���Y�����g���ėʎq���p���??[�^��?œK��
%   quantiz      - �ʎq���C���f�b�N�X�Ɨʎq������?o�͒l��?�?�
%
% ���?��䕄?���
%   bchpoly      - �o�C�i��BCH��?��̃p���??[�^�܂���?�?���?�����?�?�
%   convenc      - ?��?��ݕ�?���
%   cyclgen      - ?���?��̃p���e�B�`�F�b�N?s��?A?�?�?s���?�?�
%   cyclpoly     - ?���?���?�?���?�����?�?�
%   decode       - �u�?�b�N��?�
%   encode       - �u�?�b�N��?���
%   gen2par      - ?�?�?s����p���e�B�`�F�b�N?s��֕ϊ�
%   gfweight     - ?��`�u�?�b�N��?���?�?��������v�Z
%   hammgen      - Hamming��?���?�?�?s��ƃp���e�B�`�F�b�N?s���?�?�
%   rsdec        - ��?[�h�\�?������?�
%   rsenc        - ��?[�h�\�?������?���
%   rsdecof      - ��?[�h�\�?������?������ꂽASCII�t�@�C����?�
%   rsencof      - ��?[�h�\�?������?������g����ASCII�t�@�C����?���
%   rsgenpoly    - ��?[�h�\�?������?���?�?���?�����?�?�
%   syndtable    - �V���h�??[����?��e?[�u����?�?�
%   vitdec       - ?��?��ݕ�?������ꂽ�o�C�i���f?[�^��Viterbi�A���S���Y�����g���ĕ�?�
%
% ���?��䕄?����p�̒�?�?���?�
%   bchdeco      - BCH ��?�
%   bchenco      - BCH ��?���
%
% �ϒ�/����
%   ademod       - �A�i�?�O�p�X�o���h����
%   ademodce     - �A�i�?�O�x?[�X�o���h����
%   amod         - �A�i�?�O�p�X�o���h�ϒ�
%   amodce       - �A�i�?�O�x?[�X�o���h�ϒ�
%   apkconst     - �~�`ASK/PSK ?M?��_�z�u?}�̃v�?�b�g
%   ddemod       - �f�B�W�^���p�X�o���h����
%   ddemodce     - �f�B�W�^���x?[�X�o���h����
%   demodmap     - ����?M?�����f�B�W�^���?�b�Z?[�W�փf�}�b�s���O
%   dmod         - �f�B�W�^���p�X�o���h�ϒ�
%   dmodce       - �f�B�W�^���x?[�X�o���h�ϒ�
%   modmap       - �f�B�W�^��?M?����A�i�?�O?M?��փ}�b�s���O
%   qaskdeco     - QASK?���?M?��_�z�u����?�b�Z?[�W���f�}�b�s���O
%   qaskenco     - �?�b�Z?[�W��QASK?���?M?��_�z�u�Ƀ}�b�s���O
%
% ����t�B���^
%   hank2sys     - �n���P��?s���?��`�V�X�e���ɕϊ�
%   hilbiir      - �q���x���g�ϊ� IIR �t�B���^
%   rcosflt      - �R�T�C���??[���I�t�t�B���^���g����?A����?M?����t�B��
%                  �^�����O
%   rcosine      - �R�T�C���??[���I�t�t�B���^��?݌v
%
% ����t�B���^�p�̒�?�?���?�
%   rcosfir      - �R�T�C���??[���I�tFIR �t�B���^��?݌v
%   rcosiir      - �R�T�C���??[���I�tIIR �t�B���^��?݌v
%
% �`���l����?�
%   awgn         - ��?F�K�E�X�m�C�Y��?M?��ɕt�� 
%   
% �K�?�A�̂̌v�Z
%   gfadd        - �K�?�A��?�̑�?����̘a
%   gfconv       - �K�?�A��?�̑�?�����?�
%   gfcosets     - �K�?�A�̂̉~������?�]�ނ�?�?�
%   gfdeconv     - �K�?�A��?�̑�?�����?��Z
%   gfdiv        - �K�?�A�̂̌���?��Z
%   gffilter     - �f�K�?�A��?�̑�?������g�����f?[�^�̃t�B���^�����O
%   gflineq      - �f�K�?�A��?��?��`������Ax = b������
%   gfminpol     - �K�?�A�̂̌���?�?���?�������?o
%   gfmul        - �K�?�A�̂̌���?�Z
%   gfplus       - 2�̃K�?�A�̂̌������Z
%   gfpretty     - ��?�����?��`���ĕ\��
%   gfprimck     - �K�?�A��?�̑�?��������n��?����ł��邩�`�F�b�N
%   gfprimdf     - �K�?�A�̂̃f�t�H���g���n��?�����?�?�
%   gfprimfd     - �K�?�A�̂̌��n��?�������?�
%   gfrank       - �K�?�A��?��?s��̃����N���v�Z
%   gfrepcov     - GF(2)?�̑�?����\���𑼂̕\���ɕϊ�
%   gfroots      - �f�K�?�A��?�̑�?�����?��̌�?o
%   gfsub        - �K�?�A��?�̑�?����̌��Z
%   gftrunc      - �K�?�A��?�̑�?����\�����R���p�N�g�ɕ\��
%   gftuple      - �K�?�A�̂̌��̃t�H?[�}�b�g���ȒP���܂��͕ϊ�
%
% ��?[�e�B���e�B
%   bi2de        - 2?i�x�N�g����10?i?��ɕϊ�
%   de2bi        - 10?i?���2?i?��ɕϊ�
%   erf          - ��?���?�
%   erfc         - �����?���?�
%   istrellis    - ���͂��Ó��ȃg�����X?\���̂��ǂ����`�F�b�N
%   oct2dec      - 8?i?���10?i?��ɕϊ�
%   poly2trellis - ?�?��ݕ�?���?������g�����X�\���ɕϊ�
%   vec2mat      - �x�N�g����?s��ɕϊ�
% 
% �Q?l?F COMMDEMOS, SIGNAL.



% Generated from Contents.m_template revision 1.1.6.1
% Copyright 1996-2004 The MathWorks, Inc.
