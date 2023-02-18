%% clear workspace

clc;
clear;
close all;

%% load data

sub_id = 'sub-02';

proj_path = fullfile('_'); % enter your own data path
data_path = fullfile(proj_path, 'data');

addpath(genpath(data_path));

eeg_file = fullfile(data_path, sub_id, [sub_id '_decoder-distractor.eeg']);
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
end_t = 4.0;

% frequent event
cfg = [];
cfg.dataset = fullfile(eeg_file);
cfg.trialfun = 'trialfunc';
cfg.trialdef.prestim = start_t;
cfg.trialdef.poststim = end_t;
cfg.trialdef.eventvalue = {'S111'; 'S112'}'; % 1 = object first / 2 = scene first

trig = ft_definetrial(cfg);

segment = ft_redefinetrial(trig, data_ref);

%% select trials for artifact rejection

% load distracted working memory task response
Ddsgn = dir(fullfile(data_path, sub_id, 'behavior', '*with-dist_dsgn.mat'));
Ddsgn = {Ddsgn(:).name};
Ddsgn = load(Ddsgn{1});
Ddsgn = Ddsgn.dsgn;

% define distracted-trial
ND_trial = find(Ddsgn(:,4) == 1);
D_trial = find(Ddsgn(:,4) == 2);

% defind trialinfo
NE_block = zeros(200,1);
E_block = ones(400,1);
E_block(D_trial) = 2;
info = [NE_block; E_block];

segment.trialinfo = [segment.trialinfo info];

%% reject trials
% 0: without artifact / 1: with artifact

% load artifact file from brainstorm
trials = [];
arti_mat = load(fullfile(event_file)).events;

% fast noise signal rejection
% find trials overlapping with fast noise
arti_label = {arti_mat.label};
high_label = strfind(arti_label, '40-240Hz');
high_label = find(not(cellfun('isempty',high_label)));

high_freq_p = arti_mat(high_label).times;
high_freq_temp = high_freq_p';

high_freq = [];
for d=1:length(segment.sampleinfo)
    searching = 0;
    check = 0;
    while(~searching)
        for b=1:length(high_freq_temp)

            % make interval vector per intervals
            % it is because that the length of noisy interval is different from each other
            high_freq_n = [];
            high_freq_n = high_freq_temp(b,1):0.1:high_freq_temp(b,2);
            if b ~= length(high_freq_temp)
                high_freq_post = [];
                high_freq_post = high_freq_temp(b+1,1):0.1:high_freq_temp(b+1,2);
            end

            for in=1:length(high_freq_n) % the number of elements in one row
                if segment.sampleinfo(d,1)/500 <= high_freq_n(in) && high_freq_n(in) <= segment.sampleinfo(d,2)
                    high_freq = [high_freq; 1];
                    check = 1;
                    break;
                end
            end
            if check == 1
                break;
            elseif segment.sampleinfo(d,2)/500 < high_freq_post(1)
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

segment.clean_trial = clean_t;

% clean data
cfg = [];
cfg.trials = segment.clean_trial == 0;

clean_data = ft_selectdata(cfg, segment);

trials = [trials; length(clean_data.trial)];

%% calculate against mean signal between -0.2 and 0

% frequent event
trig.demean = 'yes';
trig.baselinewindow = [-0.2 0];

cut_data = ft_preprocessing(trig, clean_data);

%% segment data

% non-expectation block
cfg = [];
cfg.trials = cut_data.trialinfo(:,2) == 0;
data_NE = ft_selectdata(cfg, cut_data);

cfg.trials = data_NE.trialinfo(:,1) == 1;
data_NE_ob = ft_selectdata(cfg, data_NE);

cfg.trials = data_NE.trialinfo(:,1) == 2;
data_NE_sc = ft_selectdata(cfg, data_NE);

% expectation block not-distracted trial
cfg = [];
cfg.trials = cut_data.trialinfo(:,2) == 1;
data_E_ND = ft_selectdata(cfg, cut_data);

cfg.trials = data_E_ND.trialinfo(:,1) == 1;
data_E_ND_ob = ft_selectdata(cfg, data_E_ND);

cfg.trials = data_E_ND.trialinfo(:,1) == 2;
data_E_ND_sc = ft_selectdata(cfg, data_E_ND);

% expectation block distracted trial
cfg = [];
cfg.trials = cut_data.trialinfo(:,2) == 2;
data_E_D = ft_selectdata(cfg, cut_data);

cfg.trials = data_E_D.trialinfo(:,1) == 1;
data_E_D_ob = ft_selectdata(cfg, data_E_D);

cfg.trials = data_E_D.trialinfo(:,1) == 2;
data_E_D_sc = ft_selectdata(cfg, data_E_D);

%% run time-lock analysis

cfg = [];
an_NE_ob = ft_timelockanalysis(cfg, data_NE_ob);
an_NE_sc = ft_timelockanalysis(cfg, data_NE_sc);
an_E_ND_ob = ft_timelockanalysis(cfg, data_E_ND_ob);
an_E_ND_sc = ft_timelockanalysis(cfg, data_E_ND_sc);
an_E_D_ob = ft_timelockanalysis(cfg, data_E_D_ob);
an_E_D_sc = ft_timelockanalysis(cfg, data_E_D_sc);

%% run grand-mean ERP calculation

cfg = [];
cfg.method = 'within';

grand_NE_ob = ft_timelockgrandaverage(cfg, an_NE_ob);
grand_NE_sc = ft_timelockgrandaverage(cfg, an_NE_sc);
grand_E_ND_ob = ft_timelockgrandaverage(cfg, an_E_ND_ob);
grand_E_ND_sc = ft_timelockgrandaverage(cfg, an_E_ND_sc);
grand_E_D_ob = ft_timelockgrandaverage(cfg, an_E_D_ob);
grand_E_D_sc = ft_timelockgrandaverage(cfg, an_E_D_sc);

%% print topoplot

cfg = [];
cfg.layout = 'kanglab32-2021.lay';

topo_NE_ob = ft_topoplotER(cfg, grand_NE_ob);
topo_NE_sc = ft_topoplotER(cfg, grand_NE_sc);
topo_E_ND_ob = ft_topoplotER(cfg, grand_E_ND_ob);
topo_E_ND_sc = ft_topoplotER(cfg, grand_E_ND_sc);
topo_E_D_ob = ft_topoplotER(cfg, grand_E_D_ob);
topo_E_D_sc = ft_topoplotER(cfg, grand_E_D_sc);

%% plot results

cfg=[];
cfg.channel = 'Fz'; % change channels or do not define channel name 
                    % : 'Fz', 'Cz', 'Pz', 'Oz'

figure;
ERP = ft_singleplotER(cfg,grand_NE_ob, grand_NE_sc, grand_E_ND_ob, grand_E_ND_sc, grand_E_D_ob, grand_E_D_sc);