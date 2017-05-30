% Noise Level Testing Script
format compact; clear all; clear global; clc; close all
Fs = 120e4;
y_total1 = [];
y_total2 = [];
h = waitbar(0,'Please wait while your computer is heating up...');
for noiseLevel = 0:20
    total1 = 0;
    for i = 1:16
        [sig1, bits1, gain1] = txMosquito();
        sum = sig1;
        sumNoisy = awgn(sum, noiseLevel, 1);

        total1 = total1 + rxMosquito(sumNoisy, bits1, gain1);
        waitbar((noiseLevel * 15 + i) / (20 * 15));
    end
    y_total1 = [y_total1 total1];
    clear global;
end
close(h);
figure
hold on;
p1 = plot(0:20, y_total1, 'g', 'LineWidth', 2);
hold off;
legend(p1, 'Mosquito');
xlabel('SNR (db)');
ylabel('Total Bits Transferred');