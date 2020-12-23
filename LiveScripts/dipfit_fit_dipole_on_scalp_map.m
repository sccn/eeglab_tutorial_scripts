%% Using DIPFIT to fit one dipole to EEG or ERP scalp maps
% 
% 
% This Live Script shows how to use EEGLAB command-line function to use the 
% DIPFIT plugin to fit dipoles to raw ERP or EEG scalp maps. Note that it can't 
% be done through a time-window, you need to specify a time point.
%% 
%% Load data


eeglab; close; % add path
eeglabp = fileparts(which('eeglab.m'));
EEG = pop_loadset(fullfile(eeglabp, 'sample_data', 'eeglab_data_epochs_ica.set'));
%% Find the 100-ms latency data frame. 
%  Fitting may only be  performed at selected time points, not throughout a 
% time window. 
%% 

latency = 0.100;
pt100 = round((latency-EEG.xmin)*EEG.srate);
%% Find the best-fitting dipole for the ERP scalp map at this timepoint

erp = mean(EEG.data(:,:,:), 3);
dipfitdefs;
%% Specify DIPFIT settings using MNI BEM model

EEG = pop_dipfit_settings( EEG, 'hdmfile',template_models(2).hdmfile,'coordformat',template_models(2).coordformat,...
    'mrifile',template_models(2).mrifile,'chanfile',template_models(2).chanfile,...
   'coord_transform',[0.83215 -15.6287 2.4114 0.081214 0.00093739 -1.5732 1.1742 1.0601 1.1485] ,'chansel',[1:32] ); 
[ dipole, model, TMPEEG] = dipfit_erpeeg(erp(:,pt100), EEG.chanlocs, 'settings', EEG.dipfit, 'threshold', 100);
%% Plot the dipole on 3-D map

pop_dipplot(TMPEEG, 1, 'normlen', 'on');
%% Plot the dipole and the scalp map

figure; pop_topoplot(TMPEEG,0,1, [ 'ERP 100ms, fit with a single dipole (RV ' num2str(dipole(1).rv*100,2) '%)'], 0, 1);
%% 
%