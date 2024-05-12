close all, clc, clear all;
%% 0 skyrius. Aprašymas. Kalibravimas rankiniu budu - X, Z kalibravimo factoriu gavimas

%% 1 skyrius. Atsidarome failą. 
filename_calibrated = 'C6-1280CS30-248-GigE-660-3B_calibration.tif';     %manualiniu budu pasiimame calibravimo faila su 6 grioveliais

%% 2 skyrius. Darant prielaidą, kad profilio duomenys yra pirmoji vaizdo eilutė, pasiimame profilio duomenis ir konvertuojame į  double tipą
data_calibrated = imread(filename_calibrated);          %gauname 16 bitu duomenis, tipiskai 1x1280
profileData_calibrated = double(data_calibrated(1, :)); %konvertuojame į double tipą
 figure;
 plot(profileData_calibrated);   %pasižiūrime pirmo profilio duomenis
 xlim([0 1280]);
 hold on;

%% 3 skyrius. Nenulinių indeksų ieškojimas
nonZeroIndices_calibrated = find(profileData_calibrated ~= 0); % Randame indeksus, kurių vertė nėra lygi nuliui

%% 4 1D Interpoliavimas siekiant įvertinti nulinių taškų vertes
% "interp1" funkcija naudojama 1D interpoliacijai
% čia pasirinktas "tiesinis" metodas, tačiau galite naudoti ir kitus metodus, pavyzdžiui, "spline", "pchip" ir t. t.
interpolatedData_calibrated = interp1(nonZeroIndices_calibrated, profileData_calibrated(nonZeroIndices_calibrated), 1:length(profileData_calibrated), 'linear', 'extrap');

%% 5 skyrius. Rasti maksimalią vertę (galima pabandyti praleisti jei norime vaizdus sutapatinti)
maxValue_calibrated = max(interpolatedData_calibrated);

%% 6 skyrius. Apversti duomenis pagal y ašį
invertedYData_calibrated = maxValue_calibrated - interpolatedData_calibrated;
maxZValue_inverted_calibrated = max(invertedYData_calibrated);
minZValue_inverted_calibrated = min(invertedYData_calibrated);

% atvaizdavimas pagal poreikį. 
figure();
plot(invertedYData_calibrated);  %Jei reikai atvaizduoti
title('Nekalibruotų duomenų vaizdassu C6 kamera');
xlabel('Profilio pikselio indeksas, vnt. (X ašis)');
ylabel('Pikselio intensyvumas (Z ašis)');
ylim([maxZValue_inverted_calibrated*0.85,maxZValue_inverted_calibrated]); %0.8 parenkamas vizualizacijai
grid on;
grid minor;
hold on;


%% 7 skyrius. X ašies kalibravimas pagal trečia griovelį
%trecias 8(gylis)x10(plotis)mmmm griovelis 660-589 arba 71=10mm, tai 1 pikselis = 10/71=0.1408450704225352

[x_selected, y_selected] = ginput(2);% Naudojant ginput dviem  griovelio pločio taškams pasirinkti

% Rodyti pasirinktus taškus
plot(x_selected, y_selected, 'ro'); % Pažymėkite pasirinktus taškus raudonais apskritimais

% Nupiešti raudoną punktyrinę liniją tarp pasirinktų taškų
plot(x_selected, y_selected, 'r:');

% Pasirinktinai galite išvesti koordinates
disp('Pasirinkti taškai:');
disp([x_selected, y_selected]);

%skaičiuojamas X koordinatės faktorius
format long;
X_calib_factor=10/(x_selected(2,1)-x_selected(1,1));
disp('X kalibravimo faktorius:');
disp(X_calib_factor);
format short;

% Išsaugoti X_calib_factor į calib_factor.mat failą
save('calib_factor.mat', 'X_calib_factor');

%% 8 skyrius. Z ašies kalibravimas pagal trečia griovelį
%trecias 8x10mmmm griovelis 23926-21702=8mm, arba 2224 verte=8mm, tai verte 1 = 8/2224=0.0035971223021583
[x_selected, y_selected] = ginput(2);% Naudojant ginput dviem  griovelio pločio taškams pasirinkti

% Rodyti pasirinktus taškus
plot(x_selected, y_selected, 'bo'); % Pažymėkite pasirinktus taškus raudonais apskritimais

% Nupiešti raudoną punktyrinę liniją tarp pasirinktų taškų
plot(x_selected, y_selected, 'b:');

% Pasirinktinai galite išvesti koordinates
disp('Pasirinkti taškai:');
disp([x_selected, y_selected]);

%skaičiuojamas X koordinatės faktorius
format long;
Z_calib_factor=8/(y_selected(1,1)-y_selected(2,1));

disp('Z kalibravimo faktorius:');
disp(Z_calib_factor);
%format short;

% Išsaugoti X_calib_factor į calib_factor.mat failą
save('calib_factor.mat', 'Z_calib_factor', '-append');

%Gauti faktoriai.
%pixelToMmX = 0.1408450704225352;      % Default: 0.1408450704225352 išskaičiutas iš 10mm plocio griovelio
%pixelToMmZ = 0.0035971223021583;      % Default: 0.0035971223021583 išskaičiutoas iš 8mm gylio griovelio

