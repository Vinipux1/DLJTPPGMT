close all, clc, clear all;

% Z ašies diapazonas
Z = 250:1090;

% Skaičiuojame Z ašies linijiškumo toleranciją mm (0,01% nuo atstumo)
tolerancija = 0.01/100 * Z;

% Piešiame grafiką
figure;
plot(Z, tolerancija, 'b-', 'LineWidth', 2);
hold on;
plot(Z, -tolerancija, 'b-', 'LineWidth', 2);
title('Kameros C6 tikslumo priklausomybė nuo atstumo, kai linijiškuams +/-0,01%');
xlabel('Z diapazonas, mm)');
ylabel('Tolerancija, mm');
grid on;

% Pažymime nominalų atstumą
nominalus_atstumas = 400;
line([nominalus_atstumas nominalus_atstumas], ylim, 'Color', 'red', 'LineStyle', '--');
text(nominalus_atstumas, 0, ' Nominalus atstumas', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'Color', 'red');
axis tight;
hold off;

%%
% Z ašies diapazonas
Z = 250:1090;

% Skaičiuojame Z ašies linijiškumo toleranciją mm (0,01% nuo atstumo)
tolerancija = 0.01/100 * Z;

% Apskaičiuojame X-FOV, interpoliuojant duomenis
X_FOV = linspace(248, 944, length(Z));

% Piešiame grafiką tolerancijai
figure;
yyaxis left;
plot(Z, tolerancija, 'b-', 'LineWidth', 2);
hold on;
plot(Z, -tolerancija, 'b-', 'LineWidth', 2);
ylabel('Tolerancija (mm)');

% Piešiame grafiką FOV priklausomybei
yyaxis right;
plot(Z, X_FOV, 'g-', 'LineWidth', 2);
ylabel('X-FOV (mm)');

title('Kameros tikslumo ir FOV priklausomybė nuo atstumo');
xlabel('Z diapazonas (mm)');
grid on;

% Pažymime nominalų atstumą
nominalus_atstumas
