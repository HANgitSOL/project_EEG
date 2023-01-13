%% clear workspace

clc;
clear;
close all;

%% load data

sub_id = 'sub-01';

proj_path = fullfile('_'); % enter your own data path
data_path = fullfile(proj_path, 'data');

addpath(genpath(data_path));

eeg_file = fullfile(data_path, sub_id, [sub_id '_decoder-nback.eeg']);
event_file = fullfile(data_path, sub_id, [sub_id '_events-bst.mat']);
proj_file = fullfile(data_path, sub_id, [sub_id '_projection-ssp.mat']);

%% preprocessing

% load data under 40Hz
cfg = [];
cfg.dataset = fullfile(eeg_file);
cfg.lpfilter = 'yes';
cfg.lpfreq = 40;

data_eeg = ft_preprocessing(cfg);

% ssp(signal-space projection)
projector = load(proj_file);

docorrect = 1;

% projection rule
% W: signal space
% I: ssp or independent component
% S: eeg signal

% W*I = S
% I = pinv(W)*S;
% W_ * I = S_ : corrected signal

%%%%%%%%%%%%%% SET %%%%%%%%%%%%%%%%%
W = projector.Projector(1).Components;
iW = pinv(W);
M = projector.Projector(1).CompMask;
W_ = W;
W_(:,find(M)) = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data_clean = data_eeg;

if docorrect
    temp = data_clean.trial{1};
    I = iW*temp;
    temp = W_*I;
    data_clean.trial = {temp};
end

% re-reference - mastoid
cfg = [];
cfg.reref = 'yes';
cfg.channel = 'all';
cfg.implicitref = 'LM';
cfg.refchannel = {'LM', 'RM'};

data_ref = ft_preprocessing(cfg, data_eeg);

%% define trials

start_t = -0.2;
end_t = 1.5;

% frequent event
cfg = [];
cfg.dataset = fullfile(eeg_file);
cfg.trialfun = 'trialfunc';
cfg.trialdef.prestim = start_t;
cfg.trialdef.poststim = end_t;
cfg.trialdef.eventvalue = {'S100'; 'S101'; 'S102'; 'S200'}';

trig = ft_definetrial(cfg);

segment = ft_redefinetrial(trig, data_ref);

%% select trials for artifact rejection

% choose trials meaning the presentation of target
cfg = [];
cfg.trials = segment.trialinfo == 2 | segment.trialinfo == 3;
data_f_clean = ft_selectdata(cfg, segment);

%% reject trials
% 0: without artifact / 1: with artifact

% load artifact file from brainstorm
trials = [];
arti_mat = load(fullfile(event_file)).events;

% fast noise signal rejection
% find trials overlapping with fast noise
high_freq_p = arti_mat(7).times;
high_freq_temp = high_freq_p';

high_freq = [];
for d=1:length(data_f_clean.sampleinfo)
    searching = 0;
    check = 0;
    while(~searching)
        for b=1:length(high_freq_temp)

            % make interval vector per intervals
            high_freq_n = [];
            high_freq_n = high_freq_temp(b,1):0.1:high_freq_temp(b,2);
            if b ~= length(high_freq_temp)
                high_freq_post = [];
                high_freq_post = high_freq_temp(b+1,1):0.1:high_freq_temp(b+1,2);
            end

            for in=1:length(high_freq_n) % the number of elements in one row
                if data_f_clean.sampleinfo(d,1)/500 <= high_freq_n(in) && high_freq_n(in) <= data_f_clean.sampleinfo(d,2)
                    high_freq = [high_freq; 1];
                    check = 1;
                    break;
                end
            end
            if check == 1
                break;
            elseif data_f_clean.sampleinfo(d,2)/500 < high_freq_post(1)
                high_freq = [high_freq; 0];
                break;
            elseif b == length(high_freq_temp)
                high_freq = [high_freq; 0];
                break;
            end
        end
        searching = 1;
    end
end

% select clean trials

clean_t = [];
for i=1:length(high_freq)

    check = sum(high_freq(i,:));
    if check == 0
        clean_t = [clean_t; 0];
    else
        clean_t = [clean_t; 1];
    end

end

data_f_clean.clean_trial = clean_t;

% clean data
cfg = [];
cfg.trials = data_f_clean.clean_trial == 0;

clean_data = ft_selectdata(cfg, data_f_clean);

trials = [trials; length(clean_data.trial)];

%% calculate against mean signal between -0.2 and 0

% frequent event
trig.demean = 'yes';
trig.baselinewindow = [-0.2 0];

cut_data = ft_preprocessing(trig, clean_data);

%% segment data

% frequent event
cfg = [];
cfg.trials = cut_data.trialinfo == 2;
data_obj = ft_selectdata(cfg, cut_data);

% oddball event
cfg = [];
cfg.trials = cut_data.trialinfo == 3;
data_sce = ft_selectdata(cfg, cut_data);

%% run time-lock analysis

cfg = [];
obj_an = ft_timelockanalysis(cfg, data_obj);
sce_an = ft_timelockanalysis(cfg, data_sce);

%% run grand-mean ERP calculation

cfg = [];
cfg.method = 'within';

grand_obj = ft_timelockgrandaverage(cfg, obj_an);
grand_sce = ft_timelockgrandaverage(cfg, sce_an);

%% print topoplot

cfg = [];
cfg.layout = 'kanglab32-2021.lay';

topo_obj = ft_topoplotER(cfg, grand_obj);
topo_sce = ft_topoplotER(cfg, grand_sce);

%% plot results

cfg=[];
cfg.channel = 'Oz'; % change channels or do not define channel name 
                    % : 'Fz', 'Cz', 'Pz', 'Oz'

figure;
ERP = ft_singleplotER(cfg,grand_obj, grand_sce);

%% save data
% this step may not be needed in this project

% make folder for data per subject
if ~isdir(fullfile(data_path, sub_id, 'prep'))
    mkdir(fullfile(data_path, sub_id, 'prep'));
end

% set save folder path
save_path = fullfile(data_path, sub_id, 'prep', [sub_id '_green-preprocessing_SSP.mat']);
ERP_path = fullfile(data_path, sub_id, 'prep', [sub_id '_green-ERP_SSP.jpg']);

% save data
save(save_path, 'grand_obj', 'grand_sce');
saveas(gcf, ERP_path);
