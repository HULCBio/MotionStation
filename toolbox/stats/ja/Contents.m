% Statistics Toolbox
% Version 5.0 (R14) 05-May-2004 
%
% ���z
% �p�����[�^����
%   betafit     - �x�[�^���z�p�����[�^����
%   binofit     - �񍀕��z�p�����[�^����
%   evfit       - �ɒl���z�p�����[�^����
%   expfit      - �w�����z�p�����[�^����
%   gamfit      - �K���}���z�p�����[�^����
%   lognfit     - �ΐ����K���z�p�����[�^����
%   mle         - �Ŗސ���(MLE)�@
%   nbinfit     - ���̓񍀕��z�p�����[�^����
%   normfit     - ���K���z�p�����[�^����
%   poissfit    - Poisson���z�p�����[�^����
%   raylfit     - Rayleigh�p�����[�^����
%   unifit      - ��l���z�p�����[�^����
%   wblfit      - Weibull���z�p�����[�^����
%
% �m�����x�֐�(pdf)
%   betapdf     - �x�[�^���x
%   binopdf     - �񍀖��x
%   chi2pdf     - �J�C��斧�x
%   evpdf       - �ɒl���x
%   exppdf      - �w�����x
%   fpdf        - F ���x
%   gampdf      - �K���}���x
%   geopdf      - �􉽖��x
%   hygepdf     - ���􉽖��x
%   lognpdf     - �ΐ����K���x
%   mvnpdf      - ���ϗʐ��K���z���x�֐�
%   nbinpdf     - ���񍀖��x
%   ncfpdf      - ��SF���x
%   nctpdf      - ��St���x
%   ncx2pdf     - ��S�J�C��斧�x
%   normpdf     - ���K(�K�E�X)���x
%   pdf         - �w�肵�����z�ɑ΂���m�����x�֐�
%   poisspdf    - Poisson���x
%   raylpdf     - Rayleigh���x
%   tpdf        - T���x
%   unidpdf     - ���U��l���x
%   unifpdf     - ��l���x
%   wblpdf      - Weibull���x
% 
% �ݐϕ��z�֐�(cdf)
%   betacdf     - �x�[�^���z�̗ݐϕ��z�֐�
%   binocdf     - �񍀕��z�̗ݐϕ��z�֐�
%   cdf         - �w�肵�����z�̗ݐϕ��z�֐�
%   chi2cdf     - �J�C��敪�z�̗ݐϕ��z�֐�
%   ecdf        - �o���ݐϕ��z�֐� (Kaplan-Meier����)
%   evcdf       - �ɒl���z�̗ݐϕ��z�֐�
%   expcdf      - �w�����z�̗ݐϕ��z�֐�
%   fcdf        - F���z�̗ݐϕ��z�֐�
%   gamcdf      - �K���}���z�̗ݐϕ��z�֐�
%   geocdf      - �􉽕��z�̗ݐϕ��z�֐�
%   hygecdf     - ���􉽕��z�̗ݐϕ��z�֐�
%   logncdf     - �ΐ����K���z�̗ݐϕ��z�֐�
%   nbincdf     - ���񍀕��z�̗ݐϕ��z�֐�
%   ncfcdf      - ��SF���z�̗ݐϕ��z�֐�
%   nctcdf      - ��St���z�̗ݐϕ��z�֐�
%   ncx2cdf     - ��S�J�C��敪�z�̗ݐϕ��z�֐�
%   normcdf     - ���K(�K�E�X)���z�̗ݐϕ��z�֐�
%   poisscdf    - Poisson���z�̗ݐϕ��z�֐�
%   raylcdf     - Rayleigh���z�̗ݐϕ��z�֐�
%   tcdf        - T���z�̗ݐϕ��z�֐�
%   unidcdf     - ���U��l���z�̗ݐϕ��z�֐�
%   unifcdf     - ��l���z�̗ݐϕ��z�֐�
%   wblcdf      - Weibull���z�̗ݐϕ��z�֐�
% 
% ���z�֐��̗ՊE�l
%   betainv     - �x�[�^���z�̋t�ݐϕ��z�֐�
%   binoinv     - �񍀕��z�̋t�ݐϕ��z�֐�
%   chi2inv     - �J�C��敪�z�̋t�ݐϕ��z�֐�
%   evinv       - �ɒl���z�̋t�ݐϕ��z�֐�
%   expinv      - �w�����z�̋t�ݐϕ��z�֐�
%   finv        - F���z�̋t�ݐϕ��z�֐�
%   gaminv      - �K���}���z�̋t�ݐϕ��z�֐�
%   geoinv      - �􉽕��z�̋t�ݐϕ��z�֐�
%   hygeinv     - ���􉽕��z�̋t�ݐϕ��z�֐�
%   icdf        - �w�肵�����z�̋t�ݐϕ��z�֐�
%   logninv     - �ΐ����K���z�̋t�ݐϕ��z�֐�
%   nbininv     - ���񍀕��z�̋t�ݐϕ��z�֐�
%   ncfinv      - ��SF���z�̋t�ݐϕ��z�֐�
%   nctinv      - ��St���z�̋t�ݐϕ��z�֐�
%   ncx2inv     - ��S�J�C��敪�z�̋t�ݐϕ��z�֐�
%   norminv     - ���K(�K�E�X)���z�̋t�ݐϕ��z�֐�
%   poissinv    - Poisson���z�̋t�ݐϕ��z�֐�
%   raylinv     - Rayleigh���z�̋t�ݐϕ��z�֐�
%   tinv        - T���z�̋t�ݐϕ��z�֐�
%   unidinv     - ���U��l���z�̋t�ݐϕ��z�֐�
%   unifinv     - ��l���z�̋t�ݐϕ��z�֐�
%   wblinv      - Weibull���z�̋t�ݐϕ��z�֐�
%
% �����̔���
%   betarnd     - �x�[�^���z���闐��
%   binornd     - �񍀕��z���闐��
%   chi2rnd     - �J�C��敪�z���闐��
%   evrnd       - �ɒl���z���闐��
%   exprnd      - �w�����z���闐��
%   frnd        - F���z���闐��
%   gamrnd      - �K���}���z���闐��
%   geornd      - �􉽕��z���闐��
%   hygernd     - ���􉽕��z���闐��
%   iwishrnd    - Wishart�����t�s��
%   lognrnd     - �ΐ����K���z���闐��
%   mvnrnd      - ���ϗʂɂ�鐳�K���z���闐��
%   mvtrnd      - ���ϗ�t���z���闐��
%   nbinrnd     - ���񍀕��z���闐��
%   ncfrnd      - ��SF���z���闐��
%   nctrnd      - ��St���z���闐��
%   ncx2rnd     - ��S�J�C��敪�z���闐��
%   normrnd     - ���K(�K�E�X)���z���闐��
%   poissrnd    - Poisson���z���闐��
%   random      - �w�肵�����z�����闐��
%   raylrnd     - Rayleigh���z���闐��
%   trnd        - T���z���闐��
%   unidrnd     - ���U��l���z���闐��
%   unifrnd     - ��l���z���闐��
%   wblrnd      - Weibull���z���闐��
%   wishrnd     - Wishart�����s��
% 
% ���v��
%   betastat    - �x�[�^���z�̕��ϒl�ƕ��U
%   binostat    - �񍀕��z�̕��ϒl�ƕ��U
%   chi2stat    - �J�C��敪�z�̕��ϒl�ƕ��U
%   evstat      - �ɒl���z�̕��ϒl�ƕ��U
%   expstat     - �w�����z�̕��ϒl�ƕ��U
%   fstat       - F���z�̕��ϒl�ƕ��U
%   gamstat     - �K���}���z�̕��ϒl�ƕ��U
%   geostat     - �􉽕��z�̕��ϒl�ƕ��U
%   hygestat    - ���􉽕��z�̕��ϒl�ƕ��U
%   lognstat    - �ΐ����K���z�̕��ϒl�ƕ��U
%   nbinstat    - ���̓񍀕��z�̕��ϒl�ƕ��U
%   ncfstat     - ��SF���z�̕��ϒl�ƕ��U
%   nctstat     - ��St���z�̕��ϒl�ƕ��U
%   ncx2stat    - ��S�J�C��敪�z�̕��ϒl�ƕ��U
%   normstat    - ���K(�K�E�X)���z�̕��ϒl�ƕ��U
%   poisstat    - Poisson���z�̕��ϒl�ƕ��U
%   raylstat    - Rayleigh���z�̕��ϒl�ƕ��U
%   tstat       - T���z�̕��ϒl�ƕ��U
%   unidstat    - ���U��l���z�̕��ϒl�ƕ��U
%   unifstat    - ��l���z�̕��ϒl�ƕ��U
%   wblstat     - Weibull���z�̕��ϒl�ƕ��U
%
%  �ޓx�֐�
%   betalike    - �x�[�^�ΐ��ޓx�֐��̕��̒l
%   evlike      - �ɒl�ΐ��ޓx�֐��̕��̒l
%   explike     - �w���ΐ��ޓx�֐��̕��̒l
%   gamlike     - �K���}�ΐ��ޓx�֐��̕��̒l
%   lognlike    - �ΐ����K�ΐ��ޓx�֐��̕��̒l
%   nbinlike    - ���̓񍀑ΐ��ޓx�֐��̕��̒l
%   normlike    - ���K�ΐ��ޓx�֐��̕��̒l
%   wbllike     - Weibull�ΐ��ޓx�֐��̕��̒l
%
% �L�q�I���v��
%   bootstrp    - �C�ӊ֐��ɑ΂���u�[�g�X�g���b�v���v��
%   corrcoef    - ���֌W��
%   cov         - �����U
%   crosstab    - 2�̃x�N�g���̃N���X�\
%   geomean     - �􉽕���
%   grpstats    - �O���[�v���̓��v��
%   harmmean    - ���a����
%   iqr         - �W�{�̎l���ʃ����W
%   kurtosis    - �W�{��x
%   mad         - �f�[�^�W�{�̕��ϐ�Ε΍�
%   mean        - �T���v������(matlab toolbox�Ŏg�p)
%   median      - �x�N�g����s��̒����l
%   moment      - ����T���v���̃��[�����g
%   nanmax      - NaNs �𖳎������ő�l
%   nanmean     - NaNs �𖳎��������ϒl
%   nanmedian   - NaNs �𖳎����������l
%   nanmin      - NaNs �𖳎������ŏ��l
%   nanstd      - NaNs �𖳎������W���΍�
%   nansum      - NaNs �𖳎������a
%   prctile     - �W�{�̕S���ʐ�
%   range       - �����W
%   skewness    - �W�{�c�x
%   std         - �W���΍�(matlab toolbox)
%   tabulate    - �p�x�\
%   trimmean    - �ُ�l�����������f�[�^�W�{�̕���
%   var         - ���U(matlab toolbox)
% 
% ���`���f��
%   addedvarplot - �X�e�b�v���C�Y��A�̂��߂̒ǉ����ꂽ�ϐ��v���b�g�̍쐬
%   anova1      - ����q���U����
%   anova2      - ����q���U����
%   anovan      - n-���q���U����
%   aoctool     - �����U�̉�͂̂��߂̑Θb�`���̃c�[��
%   dummyvar    - 0��1�̃_�~�[�ϐ��s��
%   friedman    - Friedman����(�m���p�����g���b�N����q���U����anova)
%   glmfit      - ��ʉ����`���f���̃t�B�b�e�B���O
%   glmval      - ��ʉ����`���f���̗\���l�̌v�Z
%   kruskalwallis - Kruskal-Wallis����(�m���p�����g���b�N����q���U����anova)
%   leverage    - ��A�f�f
%   lscov       - ���m�̕��U�s����g�����ŏ���搄��
%   manova1     - ����q���U���ϗʉ��
%   manovacluster - manova1�ɑ΂���O���[�v���ς̃N���X�^�̐}��
%   multcompare - ���ϒl�A���̐���l�̑��d��r����
%   polyconf    - �������v�Z�ƐM����Ԃ̎Z�o
%   polyfit     - �ŏ����@���g�����������ߎ�
%   polyval     - �������֐����g�����\���l
%   rcoplot     - �P�[�X���̎c���\��
%   regress     - ���ϗʐ��`��A
%   regstats    - ��A�f�f�������O���t�B�J�����[�U�C���^�t�F�[�X
%   ridge       - ���b�W��A�̃p�����[�^����
%   robustfit   - ���o�X�g��A���f���t�B�b�e���O
%   rstool      - �����������Ȗʂ̉����̉����c�[��(RSM)
%   stepwise    - �X�e�b�v���C�Y��A�̑Θb�^�c�[��
%   stepwisefit - �Θb�^�ł͂Ȃ��X�e�b�v���C�Y��A
%   x2fx        - �ݒ肳�ꂽ�s����v��s��̗v���ɕϊ�
%
% ����`���f��
%   lsqnonneg   - �񕉂̍ŏ����
%   nlinfit     - Newton�@���g��������`�ŏ����@�ɂ��f�[�^�t�B�b�e�B���O
%   nlintool    - ����`���f���̗\���ɑ΂����b�^�O���t�B�b�N�X�c�[��
%   nlpredci    - �\���ɑ΂���M�����
%   nlparci     - �p�����[�^�ɑ΂���M�����
%
% �����v��@(DOE)
%   bbdesign    - Box-Behnken�v��
%   candexch    - D-�œK�v��(���W���ɑ΂���s�����A���S���Y��)�B
%   candgen     - D-�œK���v��쐬�̂��߂̌��W��
%   ccdesign    - ���S�����v��
%   cordexch    - D-�œK�v��@(���W�����A���S���C�Y��)
%   daugment    - �g�� D-�œK�v��@
%   dcovary     - �����U���Œ肵�� D-�œK�v��@
%   ff2n        - 2���x���̊��S���{�v��
%   fracfact    - 2���x���ꕔ���{�v��
%   fullfact    - �������x���̊��S���{�v��
%   hadamard    - Hadmard�s��(����z��)
%   lhsdesign   - ���e�������i(latin hypercube)�̕W�{���쐬
%   lhsnorm     - ���ϗʐ��K���z�������e�������i(latin hypercube)�W�{
%   rowexch     - D-�œK�v��@(�s�����A���S���Y��)
%
% ���v�I�H���Ǘ�(SPC)
%   capable     - �H���\�͎w��
%   capaplot    - �H���\�̓v���b�g
%   ewmaplot    - �w���I�d�ݕt���������ړ����σv���b�g
%   histfit     - �q�X�g�O�����Ɛ��K���x�Ȑ�
%   normspec    - �ݒ肵���͈͊Ԃł̐��K���z���x�̃v���b�g
%   schart      - ���v�I�H���Ǘ��̂��߂̕W���΍��̊Ǘ��}
%   xbarplot    - ���ϒl�����j�^����Xbar�}
%
% ���ϗʓ��v��
% �N���X�^����
%   cophenet    - Cophenetic���֌W�����Z�o
%   cluster     - LINKAGE�o�͂���̃N���X�^�̍쐬
%   clusterdata - �f�[�^����N���X�^�̍쐬
%   dendrogram  - ����}�̍쐬
%   inconsistent- �N���X�^�c���[�̐������̂Ȃ��l
%   kmeans      - K���σN���X�^�����O
%   linkage     - �K�w�I�ȃN���X�^�̏��̎擾
%   pdist       - �ϑ��Ԃ̋����̎Z�o
%   silhouette  - �N���X�^�f�[�^�̗֊s���v���b�g
%   squareform  - �����s�񏑎��ŋ�����\��
%
% �����팸��@
%   factoran    - ���q����
%   pcacov      - �����U�s��ɂ��听������
%   pcares      - �听�����͂���̎c��
%   princomp    - ���f�[�^�s��ɂ��听������
%
% ���̑��ϗʎ�@
%   barttest    - �����Ɋւ���Bartlett����
%   canoncorr   - �������֕���
%   cmdscale    - �ÓT�I�������ړx�\���@
%   classify    - ���`���ʕ���
%   mahal       - Mahalanobis�̋���
%   manova1     - ����q���U���ϗʉ��
%   procrustes  - Procrustes���
%
% ����؎�@
%   treedisp    - ����؂̕\��
%   treefit     - ���ނ܂��͉�A�c���[��p�����f�[�^�̋ߎ�
%   treeprune   - ����؂̎}���肨��эœK�Ȏ}���肳�ꂽ��̍쐬
%   treetest    - ����؂ɑ΂��鐄��덷
%   treeval     - ����؂�p�����ߎ��l�̌v�Z
%
% ��������
%   ranksum     - �E�B���R�N�\��(Wilcoxon)�̏��ʘa����(�Ɨ��ȕW�{)
%   signrank    - �E�B���R�N�\��(Wilcoxon)���������ʘa����(�ΕW�{)
%   signtest    - ����������(�ΕW�{)
%   ztest       - Z����
%   ttest       - 1�W�{t����
%   ttest2      - 2�W�{t����
%
% ���z�e�X�g
%   jbtest      - ���K����Jarque-Bera����
%   kstest      - 1�W�{�ɑ΂���Kolmogorov-Smirnov����
%   kstest2     - 2�W�{�ɑ΂���Kolmogorov-Smirnov����
%   lillietest  - ���K����Lilliefors����
%
% �m���p�����g���b�N�֐�
%   friedman    - Friedman����(�m���p�����g���b�N�j���q���U����)
%   kruskalwallis - Kruskal-Wallis����(�m���p�����g���b�N����q���U����)
%   ksdensity   - Kernel ���������x�̐���
%   ranksum     - �E�B���R�N�\��(Wilcoxon)�̏��ʘa����(�Ɨ��ȕW�{)
%   signrank    - �E�B���R�N�\��(Wilcoxon)���������ʘa����(�ΕW�{)
%   signtest    - ����������(�ΕW�{)
%
% �B��}���R�t���f��(Hidden Markov Model)
%   hmmdecode   - HMM�̌���̏�Ԋm�����v�Z
%   hmmestimate - ��ԏ���^����ꂽHMM�p�����[�^����
%   hmmgenerate - HMM�ɑ΂��郉���_���Ȍn��̐���
%   hmmtrain    - HMM�p�����[�^�ɑ΂���Ŗސ���l�̌v�Z
%   hmmviterbi  - HMM�̌n��ɑ΂��čł��N���肤���ԃp�X���v�Z
%
% ���v���L�̃v���b�g�֐�
%   boxplot     - �f�[�^�s��̃{�b�N�X�v���b�g(��P��)
%   cdfplot     - �o���I�ȗݐϕ��z�֐��̃v���b�g
%   ecdfhist    - �o���I�ݐϕ��z�֐�����v�Z���ꂽ�q�X�g�O����
%   fsurfht     - ����֐��̉�b�^�ɂ��R���^�[�v���b�g
%   gline       - �}�̒��ɑΘb�`���Œ�����`��
%   gname       - ��b�^�œ_�̃��x���\��
%   gplotmatrix - ���ʕϐ����g���ăO���[�v�����ꂽ�U�z�}�v���b�g�̍s��
%   gscatter    - �O���[�v�����ꂽ�ϐ��̎U�z�}���쐬
%   lsline      - �U�z�}�ɍŏ����ߎ��������d�˕\��
%   normplot    - ���K�m�����z�̃v���b�g
%   qqplot      - �l���ʃv���b�g
%   refcurve    - ��������̃v���b�g
%   refline     - ����C��
%   surfht      - �f�[�^�O���b�h�̉�b�^�R���^�[�v���b�g
%   wblplot     - Weibull�m���̃v���b�g
% 
% �񋟂���Ă���f�����X�g���[�V�����t�@�C��
%   aoctool     - �����U�̉�͂ɑ΂���Θb�`���̃c�[��
%   disttool    - �m�����z�֐��𒲂ׂ�GUI�c�[��
%   glmdemo     - ��ʉ����`���f���̃X���C�h�V���[
%   polytool    - �ߎ��������̗\���Ɋւ����b�^�̃O���t�B�b�N�X�c�[��
%   randtool    - ���������p��GUI�c�[��
%   rsmdemo     - �����v��ƋȐ��ߎ��̃f�����X�g���[�V����
%   robustdemo  - ���o�X�g��A�ƍŏ����t�B�b�e�B���O���r����Θb�`����
%                 �c�[��
%
% �t�@�C���� I/O �֘A
%   tblread     - �t�@�C���V�X�e������\�ɂ����f�[�^����荞��
%   tblwrite    - �t�@�C���V�X�e���ɕ\�ɂ����f�[�^����������
%   tdfread     - �^�u�ŋ�؂�ꂽ�t�@�C�����琔�l����уe�L�X�g�̓ǂݍ���
%   caseread    - �t�@�C������P�[�X����ǂݍ���
%   casewrite   - �t�@�C���ɃP�[�X������������
%
% ���[�e�B���e�B�֐�
%   combnk      - n �I�u�W�F�N�g�� k �𓯎��Ɏ��o�����ׂĂ̑g�ݍ��킹
%   grp2idx     - �O���[�v���ϐ����C���f�b�N�X�Ɩ��O�̔z��ɕϊ�
%   hougen      - Hougen���f��(����`�̗��)�ɑ΂���\���֐�
%   tiedrank    - �����ʂɑ΂��Ē������ꂽ�W�{�̃����N���v�Z
%   zscore      - �e�񂪕��ϒl0�A���U1�̗�ƂȂ�W�����s��


% Copyright 1993-2004 The MathWorks, Inc. 
% Generated from Contents.m_template revision 1.7  $Date: 2003/02/12 17:07:05 $
