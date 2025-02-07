% check folder
cd ..

path2eeglab = 'eeglab';
addpath(fullfile(path2eeglab, '/functions/guifunc'))
addpath(fullfile(path2eeglab, '/functions/popfunc'))
addpath(fullfile(path2eeglab, '/functions/adminfunc'))
addpath(fullfile(path2eeglab, '/plugins/firfilt'))
addpath(fullfile(path2eeglab, '/functions/sigprocfunc'))
addpath(fullfile(path2eeglab, '/functions/miscfunc'))
addpath(fullfile(path2eeglab, '/plugins/dipfit'))
addpath(fullfile(path2eeglab, '/plugins/clean_rawdata'))

%EEG = pop_loadset('/System/Volumes/Data/data/matlab/eeglab/sample_data/eeglab_data.set');
%EEG = pop_loadset('/Users/arno/python/eegprep/data/eeglab_data_with_ica_tmp.set');
EEG = pop_loadset('data/eeglab_data_with_ica_tmp.set');

EEG = pop_eegfiltnew(EEG, 'locutoff',5,'hicutoff',25,'revfilt',1,'plotfreqz',0);

pop_saveset(EEG, './tmp.set');

% clean data using the clean_rawdata plugin
EEG = pop_clean_rawdata( EEG,'FlatlineCriterion',5,'ChannelCriterion',0.87, ...
    'LineNoiseCriterion',4,'Highpass',[0.25 0.75] ,'BurstCriterion',20, ...
    'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian', ...
    'WindowCriterionTolerances',[-Inf 7] ,'fusechanrej',1);

% recompute average reference interpolating missing channels (and removing
% them again after average reference - STUDY functions handle them automatically)
EEG = pop_reref( EEG,[],'interpchan',[]);

% run ICA reducing the dimention by 1 to account for average reference 
EEG = pop_runica(EEG, 'icatype','picard','concatcond','on','options',{'pca',-1});

% % run ICLabel and flag artifactual components
% EEG = pop_iclabel(EEG, 'default');
% EEG = pop_icflag( EEG,[NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
