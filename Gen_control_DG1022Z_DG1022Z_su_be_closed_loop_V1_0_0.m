% 0 skyrius. Aporašymas 
% Bandomas Rigol generatorius DG1022Z kuris išstato pastovų sukimosį dažnį duomanų surinkimui

%% 1 skyrius. Generatoriaus objekto atidarymas.
clc, clear all;
resourceList = visadevlist("Timeout",10)                    %randa VISA irenginius

visausb_dg1000z = visadev("USB0::0x1AB1::0x0642::DG1ZA213704125::INSTR")

%Sukurti VISA objektą
fopen(visausb_dg1000z);                                     %Atidaryti sukurtą VISA objektą
fprintf(visausb_dg1000z, ':SOURce1:APPLy?' );               %Išsiųsti užklausą

query_CH1 = fscanf(visausb_dg1000z);                        %Užklausos duomenys
display(query_CH1);                                         %Parodyti perskaitytą įrenginio informaciją

fprintf(visausb_dg1000z, ':DISP:TEXT "RIGOL",25,35' );      %Ištrina ekrana ir palieka teksta "rigol" koordinatese 25x25
fprintf(visausb_dg1000z, ':DISPlay:TEXT:CLEar' );           %Gražina default ekrana

%% 2 skyrius. Generatoriaus kanalų pradinių parametrų inicializavimas

%Generatoriaus 1 kanalo inizializavimas
fprintf(visausb_dg1000z, '*IDN?' );   %/*Query the ID string of the signal generator to check whether the remote communication is normal*/
fprintf(visausb_dg1000z, ':SOUR1:FREQ 100' );
fprintf(visausb_dg1000z, ':SOUR1:FUNC SQU' );
fprintf(visausb_dg1000z, ':SOUR1:VOLT 5' );
fprintf(visausb_dg1000z, ':SOUR1:VOLT:OFFS 0' );
fprintf(visausb_dg1000z, ':SOUR1:PHAS 0' );
fprintf(visausb_dg1000z, ':OUTPut1 OFF' );
fprintf(visausb_dg1000z, ':OUTPut1:LOAD 50' ); %50 R impedance

%Generatoriaus 2 kanalo inizializavimas
%fprintf(visausb_dg1000z, '*IDN?' );
fprintf(visausb_dg1000z, ':SOUR2:FREQ 1' );
fprintf(visausb_dg1000z, ':SOUR2:FUNC SQU' );
fprintf(visausb_dg1000z, ':SOUR2:VOLT 5' );
fprintf(visausb_dg1000z, ':SOUR2:VOLT:OFFS 0' );
fprintf(visausb_dg1000z, ':SOUR2:PHAS 0' );
fprintf(visausb_dg1000z, ':OUTPut2 OFF' );
fprintf(visausb_dg1000z, ':OUTPut2:LOAD 50' ); %50 R impedance


%% 3 skyrius. Įgreitėjimo algoritmas

% Žingsnio dalinimas nustatytas diziausias 3200, vaizdas nusistovi per 3-5s

i=1; %veikai kaip stabdis, tik generuoja elektrovara - nenaudoti kai padanga sukasi (generuojasi elektrovara)!!!

%steps_per_revuolution=8573;    %20 km/h 8573                    <--passirenkama rankiniu budu
%steps_per_revuolution=17149;   %40 km/h 17149                   <--passirenkama rankiniu budu
steps_per_revuolution=25724 ;   %60 km/h 25724                   <--passirenkama rankiniu budu

                                %3200 1k/s  - ok++;      7.46 km/h 195/65R16      ++0.001s ~12s  +0.005s ~60s su 0.01 ~120s
                                %4290                    10 km/h
                                %6400 2k/s  - ok++;      14.93 km/h
                                %8573                    20 km/h
                                %9600 3k/s  - ok++;      22.39 km/h
                                %12800 4k/s - ok++;      29.85 km/h
                                %12864                   30 km/h
                                %16000 5k/s - ok++;      37.32 km/h
                                %17149                   40 km/h
                                %19200 6k/s - ok++;      44.78 km/h
                                %21438                   50 km/h
                                %22400 7k/s - ok++;      52.24 km/h
                                %25600 8k/s - ok++;      59.71 km/h
                                %25724                   60 km/h
                                %28800 9k/s - ok+;       67.17 km/h    
                                %32000 10k/s- ok+;       74.63 km/h     ok -su pause(0.01) daugiau nebandyta
                                %35200 11k/s- ok+;       82.10 km/h
                                %38400 12k/s- ok+;       89.56 km/h
                                %41600 13k/s- ok+;       97.02 km/h. 195/65R16                        
                                %44800 14k/s- ok+;       104.49 km/h 195/65R16   2A phase 
                                %48000 15k/s- ok?;       111.95 km/h 195/65R16   ok -su pause(0.005) %2.5A phase 
                                                        
                                %51200 16k/s- ok?;       119.41 km/h 195/65R16 ​
                                %54400 17k/s- ok?;       126.88 km/h 195/65R16
                             
counter = uint64(0);
while i>=1

    for i=1:1:steps_per_revuolution  %0 negali būti nes generas nesupranta; 
        fprintf(visausb_dg1000z, ':SOUR1:FREQ %d', i);   %printf("The number is %d\n", num);
        fprintf(visausb_dg1000z, ':OUTPut1 ON' );
        fprintf('i value: %d\n', i);
        %pause(0.01); %kad nusistovetu veikia iki TBD
        %pause(0.005); %kad nusistovetu veikia iki 15k/s
        pause(0.005); %kad nusistovetu veikia iki 15k/s
        %fprintf(visausb_dg1000z, ':OUTP1 OFF' );

        if i==4290        
        disp(['Pasiektas greitis 10km/h']);
        pause(1);
        fprintf(visausb_dg1000z, ':OUTPut2 ON' ); %vienos neužtenka
        fprintf(visausb_dg1000z, ':OUTPut2 ON' );
%        fprintf(visausb_dg1000z, ':OUTPut2 ON' );
        pause(5); 
        fprintf(visausb_dg1000z, ':OUTPut2 OFF' );
        pause(5);           
        end

        if i==8573
                    pause(5); 
                    disp(['Pasiektas greitis 20km/h']);
                    pause(1);
                    fprintf(visausb_dg1000z, ':OUTPut2 ON' ); %vienos neužtenka
                    fprintf(visausb_dg1000z, ':OUTPut2 ON' );
                    %fprintf(visausb_dg1000z, ':OUTPut2 ON' );
                    pause(5); 
                    fprintf(visausb_dg1000z, ':OUTPut2 OFF' );
                    pause(5); 
                    
                    %% Programos sustabdymas/tesimas su 't'
                    disp('Spauskite bet kokį klavišą, kad tęstumėte...');
                    pause; % Sustabdo programą
  
                    while k ~= 't'
                        k = input('Iveskite "t", jei norite tęsti: ', 's');
                        disp('Tęsiame...');
                    end
                    disp('Babaiga...');
                    %%
        end
        if i==12864
                    pause(5); 
                    disp(['Pasiektas greitis 30km/h']);
                    pause(1);
                    fprintf(visausb_dg1000z, ':OUTPut2 ON' ); %vienos neužtenka
                    fprintf(visausb_dg1000z, ':OUTPut2 ON' );
                    %fprintf(visausb_dg1000z, ':OUTPut2 ON' );
                    pause(5); 
                    fprintf(visausb_dg1000z, ':OUTPut2 OFF' );
                    pause(5);    
        end
        if i==17149
                    pause(5); 
                    disp(['Pasiektas greitis 40km/h']);
                    pause(1);
                    fprintf(visausb_dg1000z, ':OUTPut2 ON' ); %vienos neužtenka
                    fprintf(visausb_dg1000z, ':OUTPut2 ON' );
                    %fprintf(visausb_dg1000z, ':OUTPut2 ON' );
                    pause(5); 
                    fprintf(visausb_dg1000z, ':OUTPut2 OFF' );
                    pause(5); 
                    
                    %% Programos sustabdymas/tesimas su 't'
                    disp('Spauskite bet kokį klavišą, kad tęstumėte...');
                    pause; % Sustabdo programą
  
                    while k ~= 't'
                        k = input('Iveskite "t", jei norite tęsti: ', 's');
                        disp('Tęsiame...');
                    end
                    disp('Babaiga...');
                   %%
        end        
        if i==21438
                    pause(5); 
                    disp(['Pasiektas greitis 50km/h']);
                    pause(1);
                    fprintf(visausb_dg1000z, ':OUTPut2 ON' ); %vienos neužtenka
                    fprintf(visausb_dg1000z, ':OUTPut2 ON' );
                    %fprintf(visausb_dg1000z, ':OUTPut2 ON' );
                    pause(5); 
                    fprintf(visausb_dg1000z, ':OUTPut2 OFF' );
                    pause(5);    
        end        
        if i==25724
                    pause(5); 
                    disp(['Pasiektas greitis 60km/h']);
                    pause(1);
                    fprintf(visausb_dg1000z, ':OUTPut2 ON' ); %vienos neužtenka
                    fprintf(visausb_dg1000z, ':OUTPut2 ON' );
                    %fprintf(visausb_dg1000z, ':OUTPut2 ON' );
                    pause(5); 
                    fprintf(visausb_dg1000z, ':OUTPut2 OFF' );
                    pause(5);    

                    %% Programos sustabdymas/tesimas su 't'
                    disp('Spauskite bet kokį klavišą, kad tęstumėte...');
                    pause; % Sustabdo programą
  
                    while k ~= 't'
                        k = input('Iveskite "t", jei norite tęsti: ', 's');
                        disp('Tęsiame...');
                    end
                    disp('Babaiga...');
                   %%
        end        
    end;
    
%% 4 skyriu. Stabdymas     
    disp(['Perėjimas į sustojimą nuo 60 km/h']);

    pause(20); %nusistovėjimui su PID

% perejimas i 0 step s - letejima iki 0k/s be closed loop.
    for i=steps_per_revuolution:-1:1     %0 negali būti nes generas nesupranta; 
        fprintf(visausb_dg1000z, ':SOUR1:FREQ %d', i);
        fprintf(visausb_dg1000z, ':OUTPut1 ON' );
        fprintf('i value: %d\n', i);
        %pause(0.01); %kad nusistovetu veikia iki TBD
        %pause(0.005); %kad nusistovetu veikia iki 15k/s
        pause(0.001); %kad nusistovetu veikia iki ??k/s
        %fprintf(visausb_dg1000z, ':OUTPut1 OFF' );
    end;
    disp(['Pasiektas greitis 0 kartas/s']);

counter =counter+1; %impulsų skaičiuotuvas
return;
end;

disp(['Greitis 0 kartai/s']);

%% 5 ksyrius. Įrenginio uždarymas
fprintf(visausb_dg1000z, ':OUTP1 OFF' );
fclose(visausb_dg1000z);                         %Uždaryti VISA objektą
disp(['Visa irenginys atjungtas']);
