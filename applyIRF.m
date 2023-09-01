function [y y_fft] = applyIRF(g_fft, fSim, time)
    numTG = length(time);

    N = 2048;
    tstep = median(diff(time));
    f = (1:N/2)  / N / tstep; % tstep = 0.1 ns
%     g_fft =fft(gt, N) ;
    y_nirfast_fft = fft(fSim,N);
    y_fft = y_nirfast_fft.*g_fft;
    y  = ifft(y_fft, N);
%     
    y = abs(y(1:numTG));


end