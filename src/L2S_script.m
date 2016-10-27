clc
clear all
close all

global c_sim;

tic

%% Initialize variables

L2S = true; % Flag for L2S simulation

% Maximum number of channel realizations
L2SStruct.maxChannRea = 40;
% Channel models
L2SStruct.chan_multipath = {'B'};
% Standards to simulate
L2SStruct.version = {'802.11n'};
% Channel bandwidths
L2SStruct.w_channel = [20];
% Cyclic prefixes
L2SStruct.cyclic_prefix = {'long'};
% Data length of PSDUs in bytes
L2SStruct.data_len = [1000];
% Beta range and resolution
L2SStruct.betas = 0.1:0.05:50;
% Random generator seeds (must be of length L2SStruct.maxChannRea)
L2SStruct.seeds = 1:L2SStruct.maxChannRea;

% Display simulation status
L2SStruct.display = true;

L2SStruct.folderName = 'L2SResults4';

hsr_script; % Initialize c_sim

%% Simulate to calculate SNRps and PERs

% L2S_simulate(L2SStruct,parameters);

t1 = toc;
fprintf('\n\nSimulation time: %.3f hours \n\n', t1/(60*60));

%% Optimize beta

tic

configNum = length(L2SStruct.chan_multipath)*length(L2SStruct.version)*...
    length(L2SStruct.w_channel)*length(L2SStruct.cyclic_prefix)*...
    length(L2SStruct.data_len);
totalSimNum = configNum*L2SStruct.maxChannRea;

for numSim = 1:L2SStruct.maxChannRea:(totalSimNum - L2SStruct.maxChannRea + 1)
    
    [SNRp_mtx,per_mtx,snrAWGN_mtx,perAWGN_mtx] = L2S_load(numSim,L2SStruct);
    [beta,rmse,rmse_vec] = L2S_beta(SNRp_mtx,per_mtx,snrAWGN_mtx,perAWGN_mtx,L2SStruct);
    
    betaNum = (numSim + L2SStruct.maxChannRea - 1)/L2SStruct.maxChannRea;
    
    filename = [L2SStruct.folderName '\L2S_beta_results_' num2str(betaNum)];
    save([filename '.mat'],'L2SStruct','beta','rmse','rmse_vec','SNRp_mtx',...
        'per_mtx','snrAWGN_mtx','perAWGN_mtx','t1');
    
    fid = fopen([filename '.txt'],'wt');
    fprintf(fid,'%s\nGI: %s\nBand: %d MHz',L2SStruct.version{betaNum},...
        L2SStruct.cyclic_prefix{betaNum},L2SStruct.w_channel(betaNum));
    fprintf(fid,'\nChannel model: %s',L2SStruct.chan_multipath{betaNum});
    
    fprintf(fid,'\n\nbetas = {');
    for mcs = c_sim.drates + 1
        fprintf(fid,' %.4f',beta(mcs));
        if mcs~= length(c_sim.drates)
            fprintf(fid,',');
        end
    end
    fprintf(fid,'}');
    fclose(fid);
    
end

t2 = toc;
fprintf('\n\nBeta calculation time: %.3f seconds \n\n', t2);

%% Plot
for k = 1:configNum
    filename = [L2SStruct.folderName '\L2S_beta_results_' num2str(k) '.mat'];
    load(filename);
    figure(k);
    plot(L2SStruct.betas,rmse_vec,'LineWidth',2);
    legend('MCS0','MCS1','MCS2','MCS3','MCS4','MCS5','MCS6','MCS7');
    xlabel('\beta');
    ylabel('rmse');
    grid on
    title(['Scenario ' num2str(k)]);
    
    for mcs = c_sim.drates + 1
        
        figure(configNum + mcs);
        semilogy(db(snrAWGN_mtx(mcs,:),'power'),perAWGN_mtx(mcs,:),...
            'linewidth',2.5);
        xlabel('SNR [dB]');
        ylabel('PER');
        grid on;
        hold on;
        
        subBeta = 1;
        
        drP = hsr_drate_param(mcs - 1,false);
        SNReff = L2S_SNReff(SNRp_mtx.*(drP.data_rate/c_sim.w_channel),subBeta);
        subRmse = L2S_rmse(SNReff,per_mtx(:,:,mcs),snrAWGN_mtx(mcs,:),...
            perAWGN_mtx(mcs,:));
        
        semilogy(db(SNReff,'power'),per_mtx(:,:,mcs),'r.');
        
        title(['MCS' num2str(mcs - 1) ', suboptimal \beta = ' ...
            num2str(subBeta) ', rmse = ' num2str(subRmse)]);
        
        hold off;
    end
    
    for mcs = c_sim.drates + 1
        
        figure(configNum + mcs + c_sim.drates(end) + 1);
        semilogy(db(snrAWGN_mtx(mcs,:),'power'),perAWGN_mtx(mcs,:),...
            'linewidth',2.5);
        xlabel('SNR [dB]');
        ylabel('PER');
        grid on;
        hold on;
        
        drP = hsr_drate_param(mcs - 1,false);
        SNReff = L2S_SNReff(SNRp_mtx.*(drP.data_rate/c_sim.w_channel),beta(mcs));
        
        semilogy(db(SNReff,'power'),per_mtx(:,:,mcs),'r.');
        
        title(['MCS' num2str(mcs - 1) ', optimal \beta = ' ...
            num2str(beta(mcs)) ', rmse = ' num2str(rmse(mcs))]);
        
        hold off;
    end
    
end
