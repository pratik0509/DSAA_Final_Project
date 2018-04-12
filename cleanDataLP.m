function [cData] = cleanDataLP(data, s, e, k)
    I = data(s:e);
    FI = fft(I);
    FIL = ones(e - s + 1, 1);
    FIL((s+k):(e-k)) = 0;
    CI = FI .* FIL;
    cData = ifft(CI);
end