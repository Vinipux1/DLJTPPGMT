%% 0 skyrius. Programos aprašymas 
% Bandomas Rigol generatorius DG1022Z 
% nepamiršti paleisti close comandos, kitaip neišeinama iš klausymo būnsenos
% prisijungus rodo Rigol zenkiuka jog užrakinta

%% Išvalomi visi duomanys
clc, clear all; clear cam;

webcamlist      %pasitikrinama ar yra ZED kamera

%% 1 skyrius. Atidarome ZED kamera

zed = webcam('ZED') 
%zed = webcam('Integrated Camera')

% Nustatome maksimalia rezoliucija (pastaba jei negalima nustatyti reikai paleisti diagnositine programa patikrinti ar yra USB 3.0 sasaja
zed.Resolution = zed.AvailableResolutions{4}; % <--4416x1242
% AvailableResolutions: {'2560x720'  '1344x376'  '3840x1080'  '4416x1242'}  <--visi rezoliucijų vairantai
 
%Pasižiūrime infomacija apie kamerą
zed  %info apie camera

% Patikriname ar kamera paleista
result = webcamlist;
if(strcmp(result,'ZED'));   % patikrinimas 
    disp('========= Kamera paleista ========='); 
else 
    disp('========= Kamera neveikia =========');    
end

%% 2 Skyrius. Pasiimama pirma momentinio vaizdo kadrą su aukščiu, pločius ir kanalų skaičiumi

%KOMANDOS GAUNANČIOS INFORMACIJĄ
cam = webcam;               %Webcam properties
preview(cam);               %vaizdo peržiūra

% Gauti vaizdą: dydis ir kanalai (gauti vieną vaizdo kadrą iš "GigE Vision" kameros)
[height width channels] = size(snapshot(zed))

hold on;
img = snapshot(zed);    %jei reikia daugiau vaizdų - galima įdėti į ciklą
closePreview(cam);      % uždaryti peržiūra

% Šalia esantį vaizdą padalykite į du vaizdus
image_left = img(:, 1 : width/2, :);
image_right = img(:, width/2 : width-1, :);

% Rodyti kairįjį ir dešinįjį vaizdus
figure(2);
subplot(2,2,[1 2]);
imshow(img);
title('Originalus vaizdas');
subplot(2,2,3);
imshow(image_left);
title('Kaire');
subplot(2,2,4);
imshow(image_right);
title('Desine');

%% 3 skyrius. Generatoriaus valdymas
resourceList = visadevlist                       %Randa VISA irenginius
visausb_dg1000z = visadev("USB0::0x1AB1::0x0642::DG1ZA213704125::INSTR");

%Sukurti VISA objektą
fopen(visausb_dg1000z);                          %Atidarykite VISA objekto sukūrimą
fprintf(visausb_dg1000z, ':SOURce1:APPLy?' );    %Išsiųsti užklausą

query_CH1 = fscanf(visausb_dg1000z);             %Užklausos duomenys 
display(query_CH1);                              %Parodyti perskaitytą įrenginio informaciją

%fprintf(visausb_dg1000z, ':DISP:TEXT "RIGOL",25,35' );    %Ištrina ekrana ir palieka teksta "rigol" koordinatese 25x25
%fprintf(visausb_dg1000z, ':DISPlay:TEXT:CLEar' );         %Gražina default ekrana

%% 3.1 skyrius. Generatoriaus inicializavimas

fprintf(visausb_dg1000z, '*IDN?' );
fprintf(visausb_dg1000z, ':SOUR1:FREQ 1' );
fprintf(visausb_dg1000z, ':SOUR1:FUNC SQU' );
fprintf(visausb_dg1000z, ':SOUR1:VOLT 5' );
fprintf(visausb_dg1000z, ':SOUR1:VOLT:OFFS 0' );
fprintf(visausb_dg1000z, ':SOUR1:PHAS 0' );
fprintf(visausb_dg1000z, ':OUTP1 OFF' );
fprintf(visausb_dg1000z, ':OUTP1:LOAD 50' ); %50 R impedance

%% 3.2 skyrius. Generatoriaus parametrų keitimas ir vaizdų išsaugojimas (prie žingnio dalinimo 25000, vaizdas nusistovi per 3-5s)
for i=1:1:100
    fprintf(visausb_dg1000z, ':SOUR1:FREQ %d', 1);
    fprintf(visausb_dg1000z, ':OUTP1 ON' );
    pause(1); %kad nusistovetu 3   
    fprintf(visausb_dg1000z, ':OUTP1 OFF' );

    % Vaizdu gavimas
    img = snapshot(zed);  % Capture the current image, jei reikia daugiau vaizdų - galima įdėti į ciklą
    % Split the side by side image image into two images
    image_left = img(:, 1 : width/2, :);
    image_right = img(:, width/2 -1: width, :);

  %  filename_left = sprintf('FolderisL/image_left_%d.png', i);  % Create a filename using the index
  %  filename_right = sprintf('FolderisR/image_right_%d.png', i);  % Create a filename using the index

    filename_left = sprintf('FolderisL_summer/image_left_%d.png', i);  % Create a filename using the index
    filename_right = sprintf('FolderisR_summer/image_right_%d.png', i);  % Create a filename using the index

    imwrite(image_left,filename_left);
    imwrite(image_right,filename_right);

    disp([i]); disp([' kadras']);
end;

%pause(10);  %pidui susibalansuoti

%% GENERATORIASU UZDARYMAS

fprintf(visausb_dg1000z, ':OUTP1 OFF' );
fclose(visausb_dg1000z);                         %Close the VISA object
disp(['Visa irenginys atjungtas']);

%% 7 KAMEROS SUSTABDYMAS
clear cam        % close the camera instance
disp('========= Kamera tvarkingai uždaryta =========');
