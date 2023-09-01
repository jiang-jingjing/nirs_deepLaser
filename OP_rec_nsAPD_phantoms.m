%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OP_rec_nsAPD_phantoms.m
% created:  2023.08.31 by jingjing jiang jing.jing.jiang@outlook.com
% modified:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts = optimoptions(@lsqcurvefit,'MaxFunEvals',20,'Display',...
        'iter-detailed','TolX',1e-12,'TolFun',1e-12,'DiffMinChange', 0.05,...
        'Algorithm','trust-region-reflective' ,'PlotFcns',...
        {@optimplotx,@optimplotfunccount ,@optimplotfval,...
        @optimplotresnorm,@optimplotstepsize,@optimplotfirstorderopt}); 
    
% paras.scaler = [10 1]; % scale to the same order of magnitude  

% valSpih9.mua = 0.0042; % absorption [mm-1]
% valSpih9.mus = 0.82; % reduced scattering [mm-1]

%% reconstruction for Phantoms measurement
ii = 5;
meas(ii).phantom
paras.scaler = [100 1];
paras.cfg = cfg;
tShift = 0
refOP = meas(ii).OPs
% init = refOP  .*paras.scaler; % initial guess
init = [0.005 0.6 ]  .*paras.scaler; % initial guess
upper = [0.02 1.3] .*paras.scaler; % upper bound from educated guess
lower = [ 0.002 0.5] .*paras.scaler; % lower bound
 % paras.w = 5; % all data
paras.mesh = meshAll(ii).mesh;
paras.gCFT = gCFT;
% paras.tInterval = 20 : 150;
% paras.tInterval = 70 : 300;
ydata = @(x,xdata)y_nirfast_global(x,xdata,paras)


DataRef = meas(ii).data./max(meas(ii).data);
% DataRef = log(abs(DataRef)); % take log scale
% DataRef = DataRef(paras.tInterval); % select a time range
if tShift
    DataRef = circshift(DataRef,tShift,2);
end

[x,resnorm] = lsqcurvefit(ydata,init,0,DataRef,...
    lower,upper,opts);

recOP = x./paras.scaler;
initOP = init ./paras.scaler;

fwd_init = y_nirfast_global(init,0, paras) ;
fwd_rec = y_nirfast_global(x,0, paras) ;

%% plot results
figure, 
plot(DataRef)
hold on
plot(fwd_init)
plot(fwd_rec)
legend('ref', 'init','optimized')
title(['Forward results ' meas(ii).phantom])

figure
X = categorical({'ref', 'init','optimized'});
X = reordercats(X,{'ref', 'init','optimized'});
subplot(121)
bar(X, [refOP(1) initOP(1) recOP(1)]')
title('mua')
subplot(122)
bar(X, [refOP(2) initOP(2) recOP(2)]')
title('musp')
 
 