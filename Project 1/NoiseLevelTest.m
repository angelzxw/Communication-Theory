% Noise Level Testing Script
format compact; clear all; clear global; clc; close all
Fs = 120e4;
y_total1 = [];
y_total2 = [];
h = waitbar(0,'Please wait while your computer is heating up...');
for noiseLevel = 0:20
    total1 = 0;
    total2 = 0;
    for i = 1:16
        [sig1, bits1, gain1] = txMosquito();
        [sig2, bits2, gain2] = tx1_flat();

        sum = sig1 + sig2;
        sumNoisy = awgn(sum, noiseLevel, 1);

        total1 = total1 + rxMosquito(sumNoisy, bits1, gain1);
        total2 = total2 + rx1_flat(sumNoisy, bits2, gain2);
        waitbar((noiseLevel * 15 + i) / (20 * 15));
    end
    y_total1 = [y_total1 total1];
    y_total2 = [y_total2 total2];
    clear global;
end
close(h);
figure
hold on;
p1 = plot(0:20, y_total1, 'g', 'LineWidth', 2);
p2 = plot(0:20, y_total2, 'r', 'LineWidth', 2);
hold off;
legend([p1 p2], 'Mosquito', 'ENEMY');
xlabel('SNR (db)');
ylabel('Total Bits Transferred');