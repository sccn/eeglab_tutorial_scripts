% check folder
eeglab
if ~exist('task-P300_events.json', 'file')
    error('Download the data from https://openneuro.org/datasets/ds003061/ and go to the downloaded folder');
else
    filepath = fileparts(which('task-P300_events.json'));
end

% import data
[STUDY, ALLEEG] = pop_importbids(filepath, 'studyName','Oddball');
EEG = ALLEEG; CURRENTSET = 1:length(EEG); CURRENTSTUDY = 1; eeglab redraw; % redraw EEGLAB interface (optional)

% remove non-EEG channels (it is also possible to process EEG data with non-EEG data
EEG = pop_select( EEG,'nochannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG8','Resp'});

% compute average reference
EEG = pop_reref( EEG,[]);

% clean data using the clean_rawdata plugin
EEG = clean_artifacts( EEG,'FlatlineCriterion',5,'ChannelCriterion',0.8, ...
    'LineNoiseCriterion',4,'Highpass',[0.25 0.75] ,'BurstCriterion',20, ...
    'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian', ...
    'WindowCriterionTolerances',[-Inf 7] ,'fusechanrej',1);

% recompute average reference interpolating missing channels (and removing
% them again after average reference - STUDY functions handle them automatically)
EEG = pop_reref( EEG,[],'interpchan',[]);

% run ICA reducing the dimention by 1 to account for average reference 
EEG = pop_runica(EEG, 'icatype','runica','concatcond','on','options',{'pca',-1});

% run ICLabel and flag artifactual components
EEG = pop_iclabel(EEG, 'default');
EEG = pop_icflag( EEG,[NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);

% extract data epochs
EEG = pop_epoch( EEG,{'oddball_with_reponse','standard'},[-1 2] ,'epochinfo','yes');
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG,[-1000 0] ,[]);

% create STUDY design
ALLEEG = EEG;
STUDY = std_makedesign(STUDY, ALLEEG, 1, 'name','STUDY.design 1','delfiles','off', ...
    'defaultdesign','off','variable1','type','values1',{'oddball_with_reponse','standard'},...
    'vartype1','categorical','subjselect',{'sub-001'});

% precompute ERPs at the STUDY level
[STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, {},'savetrials','on','rmicacomps','on','interp','on','recompute','on','erp','on');

% plot ERPS
STUDY = pop_erpparams(STUDY, 'topotime',350);
chanlocs = eeg_mergelocs(ALLEEG.chanlocs); % get all channels from all datasets
STUDY = std_erpplot(STUDY,ALLEEG,'channels', {chanlocs.labels}, 'design', 1);
