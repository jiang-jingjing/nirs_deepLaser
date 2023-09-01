function [gt g_fft] = getIRF(fMeas, fSim, time)
    numTG = length(time);

    N = 2048;
    tstep = median(diff(time));
    f = (1:N/2)  / N / tstep; % tstep = 0.1 ns

    y_fft_ref =fft(fMeas, N) ;
    y_nirfast_fft = fft(fSim,N);
    g_fft = y_fft_ref./y_nirfast_fft;
     
%     g_fft = g_fft([1:61 (N-60):N]);
   freqT = 0.25e9;
   if freqT>0 % low pass
        id_th = find(f<freqT);
        iis = id_th(end);
        g_fft([iis+1:N/2 (N/2+1):(N-iis)]) = 0;
    end
    gt = ifft(g_fft, N);
    
    gt = gt(1:numTG);
end