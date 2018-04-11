data = sig;

ECG = data(1, :);
INPUT = data(2:end, :);

Fs = 125;
s = 1;
e = 30 * Fs;
X = s:e;
R1 = ECG(s:e)';
FR1 = fft(R1);
size(R1);
figure, plot(X, R1);
figure, plot(X, FR1);
k = 1500;
CFR1 = ones(e - s + 1, 1);
CFR1(s + k: e - k) = 0;
CFR1 = CFR1.*FR1;
figure, plot(X, CFR1);
CR1 = ifft(CFR1);
figure, plot(X, CR1);


s = e + 1;
e = e + 60 * Fs;
R2 = ECG(s:e);

figure, plot(R2);


s = e + 1;
e = e + 60 * Fs;
R3 = ECG(s:e);

figure, plot(R3);

s = e + 1;
e = e + 60 * Fs;
R4 = ECG(s:e);

figure, plot(R4);

s = e + 1;
e = e + 60 * Fs;
R5 = ECG(s:e);

figure, plot(R5);

s = e + 1;
e = e + 30 * Fs;
R6 = ECG(s:e);

figure, plot(R6);
