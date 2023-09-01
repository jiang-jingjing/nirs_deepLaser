%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% analysis_nsAPD_phantoms.m
% created:  2023.08.31 by jingjing jiang jing.jing.jiang@outlook.com
% modified:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  info from Letizia
% %with mesh and Nirfast
% sim_1SiPh = simulation_mesh(0,'1SiPh', 54, mua, mus_p, time(end)+tstep, tstep); %time so as to match femdata_stnd_TR
% sim_2SiPh = simulation_mesh(0,'2SiPh', 108, mua, mus_p, time(end)+tstep, tstep);
% sim_3SiPh = simulation_mesh(0,'3SiPh', 162, mua, mus_p, time(end)+tstep, tstep);
% sim_HG4B = simulation_mesh(1,'HG4B', 54, 0.013, 1.13, time(end)+tstep, tstep);
% sim_1LQ7 = simulation_mesh(0,'1LQ7', 68, 0.008, 0.89, time(end)+tstep, tstep);
%% - add PATHS (temporary)
addpath(genpath('/media/jiang/WD10T/Data/Projects/PioneerImageReconstruction/'))
% define nirfast paths
% Nirfaster: GPU-fascilitated model
% Nirfast8: old CPU version
pathNirfaster = '/media/jiang/WD10T/Data//SoftwarePackages/NIRFASTer';
pathNirfast8 = '/media/jiang/WD10T/Data/SoftwarePackages/nirfast8';
%% load data tpsf
fldr_data = '/media/jiang/WD10T/Data/Projects/DeepLaser2023/PhantomData202308/mean_data/';
flmat = dir([fldr_data '*.mat']); 
for ii = 1:7
    load([fldr_data flmat(ii).name])
end 
%% Data preparation 
tInterval = [480:879];
% - SPih9 1, 2, 3 phantoms
meas(1).data = tpsf_Meas_1SiPh_mean(tInterval);
meas(1).thickness = 54;
meas(1).phantom = '1 SPih9';
 meas(2).data = tpsf_Meas_2SiPh_mean(tInterval);
meas(2).thickness = 108;
meas(2).phantom = '2 SPih9';
meas(3).data = tpsf_Meas_3SiPh_mean(tInterval+6);
meas(3).thickness = 162;
meas(3).phantom = '3 SPih9';
for ii = 1:3 % SPih9
    meas(ii).OPs = [0.0042 0.82]; % mua musp in mm-1
end
% - HG4B
meas(4).data = tpsf_Meas_HG4B_mean(tInterval-6);
meas(4).thickness = 54;
meas(4).phantom = 'HG4B';
meas(4).OPs =  [0.013 1.13];

% - LQ7  
meas(5).data = tpsf_Meas_LQ7_mean(tInterval);
meas(5).thickness = 68;
meas(5).phantom = 'LQ7';
meas(5).OPs =  [0.008, 0.89];

mIRF = tpsf_Meas_1IRF_mean(tInterval-8);

figure,
for ii = 1:5
    plot(meas(ii).data./max(meas(ii).data))
    hold on
    legend_str{ii} = meas(ii).phantom;
end
 
% plot(mIRF./max(mIRF))
legend(legend_str )
title('measured TPSFs')

save meas meas
%% mesh generation NIRFAST  
addpath(genpath(pathNirfast8))

for ii = 1:5
    val.mua = meas(ii).OPs(1); % absorption [mm-1]
    val.mus = meas(ii).OPs(2); % reduced scattering [mm-1]
    val.ri = 1.43;
    mesh = generate_mesh_2D(meas(ii).thickness); 
    mesh = set_mesh(mesh, 0, val);
    mesh.nodes = mesh.nodes(:,1:2);
    meshAll(ii).mesh = mesh;
end

save meshAll meshAll
%% simulation NIRFAST  
addpath(genpath(pathNirfaster)) 
cfg.tstart=0;
cfg.tstep= 0.1e-9;
len_bin = 400;
cfg.tend=cfg.tstep*len_bin;%5e-09;
cfg.timeGates = cfg.tstart+cfg.tstep:cfg.tstep:cfg.tend;

for ii = 1:5
    sim(ii).data = femdata_stnd_TR(meshAll(ii).mesh, ...
        cfg.tend,cfg.tstep,'field', 'BiCGStab_GPU');
    figure(111)
    plot(cfg.timeGates, sim(ii).data.tpsf./max(sim(ii).data.tpsf))
    hold on
end
% len_bin2 = 451;
% time2 = cfg.tstart+cfg.tstep:cfg.tstep:(cfg.tstep*len_bin2);
% plot(time2,[sim_1SiPh'./max(sim_1SiPh'), sim_2SiPh'./max(sim_2SiPh'), sim_3SiPh'./max(sim_3SiPh')])

title('simulation results')
legend(legend_str)

%% calculated IRFs  
for ii = 1:5
    [g_cal gft_cal] = getIRF(meas(ii).data, sim(ii).data.tpsf, cfg.timeGates);
    gCal(ii).data = g_cal;
    gCal(ii).dataFT = gft_cal;
    figure(121)
    semilogy(cfg.timeGates, gCal(ii).data./max(gCal(ii).data))
    hold on
end
 
plot(cfg.timeGates,mIRF./max(mIRF))
title('calculated IRFs')
legend(legend_str)


%% take the calculated IRF from a single SPih9r measurement
gCFT = gCal(1).dataFT;

for ii = 2:5
aIRF(ii).data = applyIRF(gCFT, sim(ii).data.tpsf, cfg.timeGates);
figure(122), 

plot(aIRF(ii).data./max(aIRF(ii).data),'-.')
hold on
plot(meas(ii).data ./max(meas(ii).data ))
legend_str2{(ii-1)*2-1} = [meas(ii).phantom 'sim conv.IRF'];
legend_str2{(ii-1)*2} = [meas(ii).phantom 'meas'];
end
title('apply IRF from 1 spih9 measurement')
legend(legend_str2)

save gCFT gCFT
 
 