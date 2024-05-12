close all, clc, clear all;

%% 0 skyrius. Pagrindinis programos tikslas automatiškai aptikti visus griovelius
% Pagrindinis uždavinys. Bandoma parašyti programos kodą vienam profiliui, kad su fitintu pagal turimus taskus ir atvaizduotu tinkamai.

warning('off', 'all');
%profile on;


%% 1 skyrius. Pradinės konstantos
% Kalibravimo faktoriai gaunami iš nakstenio kodo kalibruojant C6 kamera ant plokštelės. 
pixelToMmX = 0.1408450704225352;      % Pagal nutylėjima --> 0.1428571, parametras išskaičiuojamas iš 10 mm plošio griovelio
pixelToMmZ = 0.0035971223021583;      % Pagal nutylėjima --> 0.0035714285714286, parametras išskaičiuojamas iš 8 mm gylio griovelio

% %Grfikų paruošimas
% figure(1);                  %Sukuraimas pagrindinis grafikas
% set(gca,'ydir','reverse')   %duomenys išlieka tie patys (apversti) čia apverčiamas tik atvaizdavimas
% hold on;                    %įjungiamas režimas piešti ant viršaus
% grid on;                    %piešiamas stambus tinklelis
% grid minor;                 %piešiamas smulkus tinklelis
% xlabel('Plotis, mm');
% ylabel('Gylis, mm');

%% 2 skyrius. Nagrinėjamo failo pasirinkimas.
%start_path = 'C:\\Users\\valdasm\\OneDrive - Light Conversion, UAB\\Studijos 2022-2024\\Temos pasirinkimas ir vadovas\\MTD3\\Data\\Fixed\\M3 C6-1280CS\\S (20565R15)\\000\\1\\'; %nurodyti katalogą iš kuriop pasiimti failą
start_path = 'C:\\Users\\valdasm\\OneDrive - Light Conversion, UAB\\Studijos 2022-2024\\Temos pasirinkimas ir vadovas\\MTD3\\Data\\Dynamic\\M3 C6-1280CS\\S (20565R15)\\20KM\\'; %nurodyti katalogą iš kuriop pasiimti failą

[filename, pathname] = uigetfile({'*.tif';'*.*'}, 'Pasirinkite tik TIFF failą', start_path);

if isequal(filename,0) || isequal(pathname,0)
   disp('Vartotojas paspaudė atšaukti');
else
   disp(['Pasirinktas naudotojas ', fullfile(pathname, filename)]);
   % Dabar galite naudoti failą pagal poreikį
end

%% 3 skyrius. Užsikrauname ir verčiame visus duomenis į double tipą masyve
data = imread(fullfile(pathname, filename));
profile_data_all = double(data);                                    %konvertuojame į double tipą visus duomenis

%% 3.1 skyrius. Pradinių duomanų atvaizdavimas procentinėje skalėje

% Plot the first row of profile_data_all
plot(profile_data_all(1, :));
hold on;
% Get current axes handle
ax = gca;

% Calculate percentage values for the x-axis at 5% intervals
numTicks = 20; % 100/5 = 20 ticks for 5% intervals
tickLocations = linspace(1, length(profile_data_all(1, :)), numTicks);
tickLabels = arrayfun(@(x) sprintf('%.0f%%', x), linspace(0, 100, numTicks), 'UniformOutput', false);

% Set the x-axis ticks and labels
ax.XTick = tickLocations;
ax.XTickLabel = tickLabels;

% Add labels and a title for clarity
xlabel('Percentage (%)');
ylabel('Data Value');
title('Plot of the First Row of Data with 5% Scale');

% Flip the figure vertically
set(gca, 'ydir', 'reverse');



%% 3.2 skyrius. Pasirinkti keik profilio nukirpti (procentais)

    [numRows, numCols] = size(profile_data_all);
    Nukripti_is_kaires_str = input('Nukripti_is_kaires (%): ', 's');    % Tekstinė įvestis
    Nukripti_is_kaires = str2double(Nukripti_is_kaires_str);            % Konvertuojama į skaičių
    
    Nukripti_is_desines_str = input('Nukripti_is_desines (%): ', 's');  % 's' nurodo, kad įvestis yra tekstas (string)
    Nukripti_is_desines = str2double(Nukripti_is_desines_str);  
    
    if (Nukripti_is_kaires > 0 && Nukripti_is_kaires < 100) && (Nukripti_is_desines > 0 && Nukripti_is_desines < 100)
    % Kodas čia bus vykdomas, jei abi sąlygos tenkinamos
    
    % Nustatome pradžios ir pabaigos indeksus
    Nukripti_is_kaires = round(Nukripti_is_kaires * numCols / 100); % Pavyzdys: pradžios indeksas
    Nukripti_is_desines = round(Nukripti_is_desines * numCols / 100); % Pavyzdys: pabaigos indeksas
    
    % Apskaičiuojame apkarpytą stulpelį
    profile_data_all = double(data(:, Nukripti_is_kaires:end-Nukripti_is_desines));  %apkarpyti
    
    [numRows, numCols] = size(profile_data_all);
    else
        disp('Skaicius neatitinka šių salygų arba lygus 0 t.y. procentinę reikšmę (nuo 0 iki 100).');
    
    end

close all;


%% 3.3 skyrius Atliekame kalibravimą visiems duomenims (failui)
    
% randame naujo masyvo eilučių ir stulpelių ilgį

[numRows, numCols] = size(profile_data_all);

X_indeksai = 1:numCols;                                 % Sukurti X asies indeksų masyvą 1...plotis
Z_reiksmes_all = profile_data_all;                      % Pervadinimas interpoliuotų masyvo reikšmių į paprastesni pavadinimą
    
    
%% 3.3A Su kalibravimu

X_index_mm=X_indeksai*pixelToMmX;                       %realios X reikšmės (n-ajam profiliui) kaip masyvas
Z_reiksmes_mm_all=Z_reiksmes_all*pixelToMmZ;            %realios Z reikšmės (n-ajam profiliui) kaip masyvas

%% 3.3B. Be kalibravimo

%X_index_mm=X_indeksai;                                 %realios X reikšmės (n-ajam profiliui)
%Z_reiksmes_mm_all=Z_reiksmes_all;                          %realios Z reikšmės (n-ajam profiliui)

%n_max = input('Ivesk visų profiliu skaiciu n: '); % Paprašykite naudotojo įvesti n reikšmę
%n_max = 1; %kai viena eilutė
%n_max = numRows; %kai visas profilis

%% 3.4 Skyrius. Įveskite skaičių eilutę, atskirtą tarpais
pasirenkami_profiliai = input('Pasirenkame kuriuos profilius norime atvaizduoti ir išsaugoti: ', 's'); % Paprašykite naudotojo įvesti n reikšmę
numbers = str2num(pasirenkami_profiliai );  % Jei reikia didesnio tikslumo, naudokite str2double
linear_sequence = numbers; %pasirenkame kuriuos profilius norime pasirinkti

% Patikriname ar visi elementai yra sveiki skaičiai
if all(mod(linear_sequence, 1) == 0)
    disp('Visi linear_sequence elementai yra sveiki skaičiai.');
else
    disp('linear_sequence kintamasis turi ne sveikus skaičius - kodas stabdomas');
    pause(inf);
end

greitis = input('Pasirenkame duomenų greitį x km/h: ', 's'); % Paprašykite s

padangos_tipas = input('Pasirenkame padangos tipa (S, M+S, M): ', 's'); % Paprašykite s

skenavimo_daznis = input('Skenavimo dažnį (kHz): ', 's'); % Paprašykite s


%% 3.5 skyrius.  Pasirinkite duomenų išsaugijimo vietą
%pasirenkame saugojimo veitą
% Iš anksto nustatytas katalogas
predefinedDirectory = 'C:\\Users\\valdasm\\OneDrive - Light Conversion, UAB\\Studijos 2022-2024\\Temos pasirinkimas ir vadovas\\MTD3\\Data\\Fixed\M3 C6-1280CS\\'; %nurodyti kataloga

% Let the user choose the directory, starting from the predefined directory
chosenDirectory = uigetdir(predefinedDirectory, 'Select a directory to save files');

% Check if the user pressed 'Cancel'
if isequal(chosenDirectory, 0)
    disp('User cancelled the operation. No files were saved.');
    return;
else
    saveDirectory = chosenDirectory;
end

% Ensure the directory exists, create it if it doesn't
if ~exist(saveDirectory, 'dir')
    mkdir(saveDirectory);
end

%% 3.6 skyrius. Sukuriame lentele duomenų išsaugojimui
%sukurit max lentelę
T4 = table([],[],[],[],[],[],[],[],[],[], 'VariableNames', {'topPeaksIndices', 'topPks', 'topLocs', 'IsoriniuGrioveliuVidurkis', 'CentriniuGrioveliuVidurkis', 'VidiniuGrioveliuVidurkis', 'VisuGrioveliuVidurkis', 'max_isorinis','max_centrinis', 'max_vidinis' });

%% 3.6.1 skyrius.  Parametru skaiciavimas. Visu profilių vidurkių skaičiavimas.
% 3.6.1 skyrius Apskaičiuojame vidurkį kiekvienam stulpeliui, nekreipiant dėmesio į nulines reikšmes kad surasti esminius griovelių
means = zeros(1, numCols); % Sukuriamas vektorius vidurkių saugojimui
for i = 1:numCols
    %column = profile_data_all(:, i);   % Gaunamas i-tasis stulpelis
    column = Z_reiksmes_mm_all(:, i);   % Gaunamas i-tasis stulpelis
    column(column == 0) = NaN;          % Pakeičiamos nulinės reikšmės į NaN
    means(i) = nanmean(column);         % Apskaičiuojamas vidurkis neįtraukiant NaN
end

%% 3.6.2 skyrius. Atvaizduojame grafiška išilginius vidurkius.
%% Braižomas 1 grafikas visu pasirinkt išilginių vidurkių
subplot(3,1,1)
plot(X_index_mm,means);
xlabel('mm ');
ylabel('mm');

% Grafiko pavadinimas su pridėtu papildomu tekstu
title(['Vidurkių grafikas:' num2str(greitis),' km/h, ', num2str(padangos_tipas)]);
% Flip the figure vertically
set(gca, 'ydir', 'reverse');
grid on;
grid minor;

new_ylim = [(min(means)-1), (max(means)+1)]; %su 1 mm atitraukimais
%new_ylim = [(min(means)-0.5), (max(means)+0.5)]; %su 1 mm atitraukimais
%new_ylim = [(min(means)), (max(means))]; %be atitraukimO

%% Paklausti ar norite pasirinkti rankiniu būdu įvesti koordinates
% Paprašyti vartotojo įvesti 'taip' arba 'ne'
atsakymas = input('Ar norite įvesti koordinates taip/ne - parinkti automati (t/n) ? ', 's');
% Patikrinti vartotojo įvestį ir atlikti veiksmus pagal atsakymą
if strcmpi(atsakymas, 't')
    disp('Pazymėkite dvi koordinates grafike:');
    % Laukite naudotojo įvesties pele markeriams
    if atsakymas=='t'    
       [x_marker, ~] = ginput(2); % Taip galėsite spustelėti grafika. Baigę paspauskite Enter.
          
    end
    % Ieškome indeksų:
    % Randa artimiausius indeksus x_marker taškams
    x_marker_indices = dsearchn(X_index_mm(:), x_marker(:));
    

    % Braizomi markeriai
    % Užveskite kilpą per kiekvieną x koordinatę ir nubrėžkite vertikalią liniją
    for i = 1:length(x_marker) %ciklas kiek markerių
         if atsakymas=='t'   
           line([x_marker(i), x_marker(i)], ylim, 'Color', 'r'); % Nubrėžia raudoną vertikalią liniją ties kiekviena x koordinate
           %line([x(i), x(i)], 'Color', 'r'); % Nubrėžia raudoną vertikalią liniją ties kiekviena x koordinate
         end
    end
elseif strcmpi(atsakymas, 'n')
    disp('Vartotojas pasirinko "ne".');
    % Čia galite įdėti logiką, kai vartotojas nepasirinko įvesti koordinačių
else
    disp('Neteisinga įvestis. Įveskite "taip" arba "ne".');
    % Čia galite pridėti klaidos pranešimą arba pakartoti užklausą
end

%% 3.6.2A vidurkiu santykinis gylio grafikas
subplot(3,1,2)
%set(gca, 'ydir', 'reverse');

[fitresult, gofit, X_RESIDUALS_vid, Z_RESIDUALS_vid, Z_fitinta]=createFit_function(X_index_mm, means);              % su realiais x duomenimis nefiltruotais
plot(X_RESIDUALS_vid,Z_RESIDUALS_vid);
grid on;
grid minor;
ylim([-1 8]); % Set y-axis limits
xlabel('mm ');
ylabel('mm');
title('Gylio santykinė kreivė');

% sutrumpiname residuals grafiką iki aktaulaus. 
x = X_RESIDUALS_vid; % x duomenų masyvas
y = Z_RESIDUALS_vid; % y duomenų masyvas

% Rasti pradžios ir pabaigos indeksus
if atsakymas ~= 't'
start_index = (find(y >= 1, 1, 'first'))-10;
end_index = (find(y >= 1, 1, 'last'))+10;
else
    start_index=x_marker_indices(1);
    end_index =x_marker_indices(2);
end

% Patikrinti, ar tokie indeksai egzistuoja
if ~isempty(start_index) && ~isempty(end_index)
    % Atrinkti duomenų intervalą
    x_selected = x(start_index:end_index);
    y_selected = y(start_index:end_index);

    % Atvaizduoti naują grafiką
    %figure(2);
    %plot(x_selected, y_selected);
    %xlim([0 160]);

    % Apskaičiuojame x ašies išplėtimą
    x_range = max(x_selected) - min(x_selected);  % Esamas x ašies diapazonas
    extension = x_range * 0.01;                  % 5% išplėtimo vertė
    %extension = x_range;                  % 5% išplėtimo vertė

else
    disp('Nėra taškų, kuriuose y = 1.');
end    

X_RESIDUALS_apkarpyti=x_selected;
Z_RESIDUALS_apkarpyti=y_selected;    

%% 3.6.2B vidurkiu santykinis gylio grafikas (efektyvus) - su siaurintas
subplot(3,1,3)
plot(X_RESIDUALS_apkarpyti, Z_RESIDUALS_apkarpyti,'-k');
ylim([-1 8]); % Set y-axis limits
%set(gca,'ydir','reverse')                                %duomenų grafiko apvertimas
hold on;
grid on;
grid minor;
xlabel('mm ');
ylabel('mm');
title('Susiaurinta efektyvi gylio santykinė kreivė');

% Nustatome naujas x ašies ribas
new_xlim1 = [min(x_selected) - extension, max(x_selected) + extension];
xlim(new_xlim1);
%axis tight;

%% 3.7 Braižome vertikalias punktyrines linijas ir pasiimame zonų korrdinačių indeksus. Gauname iš vidurkių grafiko. 

%gauname iš vidurkių grafiko  tris zonas

xMarkers = [X_RESIDUALS_apkarpyti(round(length(X_RESIDUALS_apkarpyti)/3)) , X_RESIDUALS_apkarpyti(round(length(X_RESIDUALS_apkarpyti)/3*2))];

%  Nubraižomes zonas: isorinė, centrinė,  vidine (laikinai)

% Method 1: Using 'line'
for i = 1:length(xMarkers)
    line([xMarkers(i) xMarkers(i)], ylim, 'Color', 'black','LineStyle','--', 'LineWidth', 1, 'HandleVisibility', 'off');
end

%% išorinis markeris (nulinis)
subplot(3,1,1);

    for i = 1:length(xMarkers)
        line([xMarkers(i) xMarkers(i)], ylim, 'Color', 'black','LineStyle','--', 'LineWidth', 1, 'HandleVisibility', 'off');
    end

    START=[(xMarkers(1)-(xMarkers(2)-xMarkers(1))) (xMarkers(1)-(xMarkers(2)-xMarkers(1)))];
    END=[(xMarkers(2)+(xMarkers(2)-xMarkers(1))) (xMarkers(2)+(xMarkers(2)-xMarkers(1)))];
        line([(xMarkers(1)-(xMarkers(2)-xMarkers(1))) (xMarkers(1)-(xMarkers(2)-xMarkers(1)))], ylim, 'Color', 'black','LineStyle','--', 'LineWidth', 1, 'HandleVisibility', 'off');
        line([(xMarkers(2)+(xMarkers(2)-xMarkers(1))) (xMarkers(2)+(xMarkers(2)-xMarkers(1)))], ylim, 'Color', 'black','LineStyle','--', 'LineWidth', 1, 'HandleVisibility', 'off');


%% išorinis markeris (galinis)
subplot(3,1,2);

    for i = 1:length(xMarkers)
        line([xMarkers(i) xMarkers(i)], ylim, 'Color', 'black','LineStyle','--', 'LineWidth', 1, 'HandleVisibility', 'off');
    end
        line([(xMarkers(1)-(xMarkers(2)-xMarkers(1))) (xMarkers(1)-(xMarkers(2)-xMarkers(1)))], ylim, 'Color', 'black','LineStyle','--', 'LineWidth', 1, 'HandleVisibility', 'off');
        line([(xMarkers(2)+(xMarkers(2)-xMarkers(1))) (xMarkers(2)+(xMarkers(2)-xMarkers(1)))], ylim, 'Color', 'black','LineStyle','--', 'LineWidth', 1, 'HandleVisibility', 'off');

%%
close all; %uždarome visus vidurkių grafikus

%% 4.	Pagrindinis profilių apdorojimo ciklas
%for n=1:n_max  %random profiliu skaicius
for n = linear_sequence            %vykdomas ciklas pagal pasirinktus profilius (pagal nutylėjimą 1)
    %disp(['Current value of n: ', num2str(n)]);     % Darykite ką nors su kiekviena n reikšme

    %% 4.1.1 skyrius. Vieno profilio duomenų išskyrimas
    profileData = Z_reiksmes_mm_all(n, :);           %išsaugome duomenis į profile data masyvą z asis

    %% 4.1.2 skyrius. Ieškome nulinių indeksų masyve
    ZeroIndices = find(profileData == 0);        % Rasti visus indeksus, kurių vertė lygi nuliui
    
    %% 4.1.3 skyrius. Priskiriame NaN arba tuščias reikšmes visoms nulinėms reikšmems

    profileData(ZeroIndices) = NaN; %priskirti NaN reikšmes - neištrina masyvo
    %profileData(ZeroIndices) = []; %priskirti tuščias reikšmes - ištrina masyvą

    %tarpiniu_profilio_duomenu_atvaizdavimas(1:length(profileData),profileData); %atvaizdavimo funkcija

    %% 4.1.4. Užpildome tuščius elementus
    %profileDataFilled = fillmissing(profileData, 'linear');
    %profileDataFilled = fillmissing(profileData, "previous"); pagal paskutini
    %profileDataFilled = fillmissing(profileData, "next"); pagal pirmutini
    %profileDataFilled = fillmissing(profileData, "nearest"); %pagal pirmutini ir paskutinį
    %profileDataFilled = fillmissing(profileData, "spline"); %nesamone

    % Tarkime, kad `data` yra jūsų duomenų masyvas
    profileDataFilled = fillmissing(profileData, 'linear'); % Užpildome NaN reikšmes

    %% 4.2.1A. slenkancio vidurkio filtras

    % windowSize = 5;                         % Filtravimo langas
    % b = (1/windowSize)*ones(1,windowSize);  % Slenkančio vidurkio filtro koeficientai
    % a = 1;
    % 
    % profileData = filter(b, a, profileData); % Taikome filtrą

    % tarpiniu_profilio_duomenu_atvaizdavimas(1:length(filteredData),filteredData) %atvaizdavimo funkcija


    %% 4.2.1B. Mediano filtravimas
    
    %windowSize = 5;                         % Filtravimo langas
    %windowSize = 10;                         % Filtravimo langas
    windowSize = 15;                         % Filtravimo langas


    profileData = medfilt1(profileDataFilled, windowSize); % Mediano filtravimas
    % 
    % % tarpiniu_profilio_duomenu_atvaizdavimas(1:length(filteredData),filteredData) %atvaizdavimo funkcija

    %% 4.2.2 skyrius. Atliekame duomenų aproksimaciją naudojant tinkamumo (arba aproksimacijos) funkciją
    % Atliekame fitinima su fitinimo funkcija APP'so ir tam tikrai pasirinktais parametrais bei atvaizduojame 


    %[X_fitintos_reiksmes,Z_fitintos_reiksmes,X_RESIDUALS, Z_RESIDUALS]=createFit_function(1:length(filteredData), profileData); % su indeksais - filtruotais
    [fitresult, gofit, X_RESIDUALS, Z_RESIDUALS, Z_fitinta]=createFit_function(X_index_mm, profileData);              % su realiais x duomenimis nefiltruotais
    %[fitresult, gofit, X_RESIDUALS, Z_RESIDUALS, Z_fitinta]=createFit_function(X_index_mm, filteredData);              % su realiais x duomenimis filtruotais
    
    %% 4.2.3 Atvaizduojame rezultataus grafiškai (pradinius, aproksimacijos ir iekamųjų (paklaidų) kreivę)
    
    %% 4.2.3A Atvaizduojame pradinius ir aproksimacijos duomenis
    figure;
    %figure('Visible', 'off'); %kad neatvaizduotų

    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]); % Set the figure to full screen
    subplot(2, 1, 1);
    hold on;  % Išlaikyti esamą grafiką, kai pridedami nauji objektai
    [xData, yData] = prepareCurveData( X_index_mm(start_index:end_index), profileData(start_index:end_index));  %orriginalus duomenys
    %[xData, yData] = prepareCurveData( X_index_mm, filteredData); %filtruoti duomenys 

    plot(xData, yData);  % Nubrėžkite brūkšninę liniją juoda spalva 
    %plot(X_index_mm, profileData, 'ko-', 'LineWidth', 1); % Vientisa juoda linija su apskritimo žymekliais ir linijos pločiu 2
    plot(X_index_mm, profileData, 'k.', MarkerSize=3); % Juoda spalva nubraižykite grafiką
    
    % Įvertinti atitikimą X_index_mm taškuose
    Z_fitinta_evaluated = feval(Z_fitinta, X_index_mm);
    % Nubraižykite įvertintą tinkamumą
    plot(X_index_mm, Z_fitinta_evaluated, 'b'); % Mėlyna spalva nubraižykite grafiką
    set(gca, 'ydir', 'reverse');  % Pakeiskite y ašies kryptį

    title('Fitted Data vs Original Data');
    xlabel('X Axis Label');
    ylabel('Z Axis Label');
    legend('Fitted Data', 'Original Data');
    grid on; 
    grid minor;

    ylim(new_ylim);


    %% nubraižome markerius pagrindiniame grafike
    % Method 1: Using 'line'
    for i = 1:length(xMarkers)
        line([xMarkers(i) xMarkers(i)], ylim, 'Color', 'black','LineStyle','--', 'LineWidth', 1, 'HandleVisibility', 'off');
    end
        line([(xMarkers(1)-(xMarkers(2)-xMarkers(1))) (xMarkers(1)-(xMarkers(2)-xMarkers(1)))], ylim, 'Color', 'black','LineStyle','--', 'LineWidth', 1, 'HandleVisibility', 'off');
        line([(xMarkers(2)+(xMarkers(2)-xMarkers(1))) (xMarkers(2)+(xMarkers(2)-xMarkers(1)))], ylim, 'Color', 'black','LineStyle','--', 'LineWidth', 1, 'HandleVisibility', 'off');

        %xlim(new_xlim1);
        %xlim([xMarkers(2) (xMarkers(2) + (xMarkers(2) - xMarkers(1)))]);


    xlim([min(X_RESIDUALS_vid) max(X_RESIDUALS_vid)]);  % Set x-axis limits

    %% 4.2.3B Atvaizduojame profilio santykinio gylio duomanis ir efektyvus centravimas
    subplot(2, 1, 2);
   
    % Tarkime, turite šiuos duomenis
    x1 = X_RESIDUALS; % x duomenų masyvas
    y1 = Z_RESIDUALS; % y duomenų masyvas

    % Rasti pradžios ir pabaigos indeksus
    % start_index = (find(y1 >= 1, 1, 'first'))-10;
    % end_index = (find(y1 >= 1, 1, 'last'))+10;

    % start_index = (find(y1 >= 1, 1, 'first'));    <--deklaruota pagal vidurkius
    % end_index = (find(y1 >= 1, 1, 'last'));       <--deklaruota pagal vidurkius


    %% Patikrinti, ar tokie indeksai egzistuoja
    if ~isempty(start_index) && ~isempty(end_index)
        % Atrinkti duomenų intervalą
        x_selected = x1(start_index:end_index);
        y_selected = y1(start_index:end_index);

        % Atvaizduoti naują grafiką
        %figure(2);
        %plot(x_selected, y_selected);
        xlabel('x');
        ylabel('y');
        title('Grafikas su atrinktais duomenimis');
        %xlim([0 160]);

        % Apskaičiuojame x ašies išplėtimą
        x_range = max(x_selected) - min(x_selected);  % Esamas x ašies diapazonas
        extension = x_range * 0.01;                  % 5% išplėtimo vertė
        %extension = x_range;                  % 5% išplėtimo vertė
    else
        disp('Nėra taškų, kuriuose y = 1.');
    end

    X_RESIDUALS=x_selected;
    Z_RESIDUALS=y_selected;    

    % X_RESIDUALS=X_RESIDUALS(start_index:end_index);
    % Z_RESIDUALS=Z_RESIDUALS(start_index:end_index);    

    %% Braižome santykine gylio kreivę pagal gilaiusius rezultatus

    plot(X_RESIDUALS, Z_RESIDUALS ,'-k');
    ylim([-1 8]); % Set y-axis limits
    %set(gca,'ydir','reverse')                                %duomenų grafiko apvertimas
    hold on;
    grid on;
    grid minor;
    
    % Nustatome naujas x ašies ribas
    % new_xlim = [min(x_selected) - extension, max(x_selected) + extension];
    % xlim(new_xlim);
    xlim(new_xlim1);

    %axis tight;

    %% nubraižome markerius pagrindiniame grafike
    % Method 1: Using 'line'
    for i = 1:length(xMarkers)
        line([xMarkers(i) xMarkers(i)], ylim, 'Color', 'black','LineStyle','--', 'LineWidth', 1, 'HandleVisibility', 'off');
    end

    %% 4.2.4. Ieškome peaksų, nemažesnių nei nustatytas slenkstis


    % For Z_RESIDUALS
    %[peaks_Z, locs_Z] = findpeaks(Z_RESIDUALS, 'MinPeakProminence', 0.1); % Adjust parameters as needed
    
    %findpeaks(Z_RESIDUALS, 'MinPeakProminence', 0.1); % This also plots the peaks
    %set(gca,'xdir','reverse') 
    %set(gca,'ydir','reverse')
    %findpeaks(Z_RESIDUALS, X_RESIDUALS,'MinPeakProminence', 0.5); % Su MinPeakProminence - nustatomas slenkstis <--plotina iš karto
   
    slenkstis=1.5;
    %[pks,locs,widths,prominences] = findpeaks(Z_RESIDUALS, X_RESIDUALS,'MinPeakProminence', slenkstis); % Su MinPeakProminence - nustatomas slenkstis <--negazina į grafiką!!!
    %[pks,locs,widths,prominences] = findpeaks(Z_RESIDUALS, X_RESIDUALS,'MinPeakProminence', slenkstis); % Su MinPeakProminence - nustatomas slenkstis <--negazina į grafiką!!!
    %[pks,locs,widths,prominences] = findpeaks(Z_RESIDUALS, X_RESIDUALS,'MinPeakProminence', slenkstis); % Su MinPeakProminence - nustatomas slenkstis <--negazina į grafiką!!!
    [pks,locs,widths,prominences] = findpeaks(Z_RESIDUALS, X_RESIDUALS,'MinPeakProminence', slenkstis); % Su MinPeakProminence - nustatomas slenkstis <--negazina į grafiką!!!

    %% 4.2.4A Rūšiuojame virsunes
      
    [sortedHeights, sortIndices] = sort(pks, 'descend'); % Rūšiuokite viršūnes pagal jų aukštį mažėjančia tvarka
    %[sortedHeights, sortIndices] = sort(locs, 'descend'); % Rūšiuokite x kordinate  pagal jų aukštį mažėjančia tvarka

    numPeaksToPlot = min(10, length(sortedHeights));  % Nustatykite brėžiamų viršūnių skaičių X
    topPeaksIndices = sortIndices(1:numPeaksToPlot); % Pasirinkite viršutinių X viršūnių indeksus pagal aukštį
    
    % Ištraukite šių aukščiausių viršūnių savybes, kad galėtumėte braižyti diagramas
    topPks = pks(topPeaksIndices);
    topLocs = locs(topPeaksIndices);

    %% 4.2.4B Nerūšiuojame virsunes

    % topPks = pks;
    % topLocs = locs;

    %% 4.2.5 Žiūrim pagal lentelės dydi ir pridedame papildomas reikšmes jei yra tuščios
    % Patikrinkite, ar topPeaksIndices, topPks ir topLocs yra vienodo ilgio

    %maxLength = max([length(topPeaksIndices), length(topPks), length(topLocs)]);
    maxLength = max(10);  %fiksuotai

    % Užpildykite masyvus su NaN (arba kita pakaitine žyma), kad atitiktų ilgį
    %topPeaksIndicesPadded = padarray(topPeaksIndices, [0, maxLength - length(topPks)], NaN, 'post');
    
    %Bandymas su NaN reikšmėm
    topPeaksIndicesPadded = [topPeaksIndices; NaN(maxLength - length(topPeaksIndices), 1)];
    topPksPadded = [topPks; NaN(maxLength - length(topPks), 1)];
    topLocsPadded = [topLocs; NaN(maxLength - length(topLocs), 1)];

    % %Bandymas su 0 reikšmėm
    % topPeaksIndicesPadded = [topPeaksIndices; zeros(maxLength - length(topPeaksIndices), 1)];
    % topPksPadded = [topPks; zeros(maxLength - length(topPks), 1)];
    % topLocsPadded = [topLocs; zeros(maxLength - length(topLocs), 1)];

    %% 4.2.6 Nubraižykite iki 10 didžiausias (maksimalias) viršūnes

    %plot(X_RESIDUALS(topLocs), topPks, 'p', 'MarkerSize', 12, 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'yellow');
    %plot(topLocs, topPks, 'p', 'MarkerSize', 12, 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'yellow');   
    plot(topLocs, topPks, 'p', 'MarkerSize', 6, 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'yellow');   

    %additionalText = input('Įveskite papildomą tekstą pavadinimui: ', 's');  % 's' nurodo, kad įvestis yra tekstas (string)

    % Enhancing the plot
    %title(['Griovelių atvaizdavimas (iki 10 giliausių), kai slenkstis: ' num2str(slenkstis) ' mm, greitis: ' num2str(greitis) ' km/h, tipas: ' num2str(padangos_tipas) ', 'Skenavimo dažnis: ', num2str(skenavimo_daznis), ', kHz, profilis: ' num2str(n)]);
    title(['Griovelių atvaizdavimas (iki 10 giliausių), kai slenkstis: ' num2str(slenkstis) ...
       ' mm, greitis: ' num2str(greitis) ' km/h, tipas: ' num2str(padangos_tipas) ...
       ', Skenavimo dažnis: ' num2str(skenavimo_daznis) ' kHz, profilis: ' num2str(n)]);

    xlabel('X reikšmės, mm');
    ylabel('Z (ištiesintos) reikšmės, mm');
    legend('Ištiesintas profilio grafikas', 'iki 10 giliausių griovelių', 'Location', 'best');

    % Kiekvieną viršūnę pažymėkite jos verte10
    
    for i = 1:numPeaksToPlot
        text(topLocs(i), topPks(i), sprintf('%.2f', topPks(i)), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');
    end

    %% 4.2.7. skyrius. Vertikalių linijų braižymas.

    yline(0, 'y--', 'LineWidth', 2); % Adds a red horizontal line at y=5 with a line width of x
    text(X_RESIDUALS(end)+10, 0, '0 mm', 'VerticalAlignment', 'middle', HorizontalAlignment='left');

    yline(1.6, 'r--', 'LineWidth', 2); % Adds a red horizontal line at y=5 with a line width of x
    text(X_RESIDUALS(end)+10, 1.6, '1,6 mm', 'VerticalAlignment', 'middle', HorizontalAlignment='left');

    yline(2, 'g--', 'LineWidth', 2); % Adds a red horizontal line at y=5 with a line width of x
    text(X_RESIDUALS(end)+10, 2, '2 mm', 'VerticalAlignment', 'middle', HorizontalAlignment='left');

    yline(3, 'b--', 'LineWidth', 2); % Adds a red horizontal line at y=5 with a line width of x
    text(X_RESIDUALS(end)+10, 3, '3 mm', 'VerticalAlignment', 'middle', HorizontalAlignment='left');

    %% 4.2.8 Vidurkio linijos skaičiavimas. Bendras vidurkio skaiciavimas
    vidurkis=mean(topPks);
    yline(vidurkis, 'k-', 'LineWidth', 2); % Prideda raudoną horizontalią liniją ties y=2, linijos plotis x    
    %text(X_RESIDUALS(end)-5, vidurkis, 'Vidurkis', 'VerticalAlignment', 'baseline')
    %legend('Ištiesinta kreive','Maks taškai','0 mm','1.6 mm slenkstis', '2 mm slenkstis', '3 mm  slenkstis', 'vidurkis');

    % Pavyzdžio vidutinė vertė
    averageValue = vidurkis; % Replace with your actual average value

    % Konvertuoti skaitinę vertę į eilutę
    averageValueStr = num2str(averageValue, '%.2f'); % Format to 2 decimal places

    % Sukurti legendą su įtraukta verte
    legend('Ištiesinta kreive', 'Maks taškai', '0 mm', '1.6 mm slenkstis', '2 mm slenkstis', '3 mm slenkstis', [averageValueStr 'mm vidurkis'], 'išorės top', 'centro top', 'vidaus top');
    
    %% 4.2.9 skyrius. Ruožų vidurkių skaičiavimas

    % Gaukite x ašies diapazoną
    %xRange = xlim;
    xRange = new_xlim1; %pagal vidurkius
    
    % Apskaičiuoti pozicijas
    leftX = xRange(1);  % Toli į kairę nuo x ašies
    centerX = mean(xRange);  % X ašies centras
    rightX = xRange(2);  % Toli į dešinę nuo x ašies
    
    % Bendra Y padėtis, skirta viršutiniam lygiavimui
    textLocationY = max(ylim);

    %% 4.2.9A išorinio
    indexRange = find(topLocs < xMarkers(1) & topLocs >=0);     %ieško centrinių griovelių indeksų iš top 10
    selectedPks = topPksPadded(indexRange);                     %išrinkti atitinkamus topPksPadded elementus
    
    % Surasti maksimalią reikšmę ir jos indeksą
    [maxValue, maxIndex] = max(selectedPks);
    maxIndexGlobal = indexRange(maxIndex);  % Paverčiame lokalią indekso reikšmę į globalią

    % Pavaizduoja pasirinktus taškus skirtinga spalva arba ženklu
    plot(topLocs(maxIndexGlobal), maxValue, 'ro', MarkerSize=50); % 'ro' reiškia raudonas apskritimus

    % Apskaičiuokime vidurkį
    if isempty(selectedPks)
        disp('Nerasta viršūnių nurodytame diapazone.');

       isoriniu_grioveliu_vidurkis  = NaN;
    else
        isoriniu_grioveliu_vidurkis = mean(selectedPks);
        %disp(['Viršūnių, esančių isoriniame intervale, vidurkis: ', num2str(isoriniu_grioveliu_vidurkis)]);
    end

    %% Tikriname ar nera nulis

    max_isorinis=max(selectedPks);
    if isempty(max_isorinis)
        max_isorinis = NaN;
    end

    %Atvaizduojame grafike paryškintai
    isoriniu_grioveliu_vidurkis_str = num2str(isoriniu_grioveliu_vidurkis);

    %text(textLocationX, textLocationY, ['   Vidurikis išorės: ' isoriniu_grioveliu_vidurkis_str], 'VerticalAlignment', 'top', 'FontSize', 12, 'FontWeight', 'bold');
    text(leftX, textLocationY, ['   Vidurikis išorės: ' isoriniu_grioveliu_vidurkis_str], ...
     'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', ...
     'FontSize', 12, 'FontWeight', 'bold');

    %% 4.2.9A centrinio
    indexRange = find(topLocs >= xMarkers(1) & topLocs <= xMarkers(2));%ieško centrinių griovelių indeksų iš top 10
    selectedPks = topPksPadded(indexRange);         % išrinkti atitinkamus topPksPadded elementus
    
    % Surasti maksimalią reikšmę ir jos indeksą
    [maxValue, maxIndex] = max(selectedPks);
    maxIndexGlobal = indexRange(maxIndex);  % Paverčiame lokalią indekso reikšmę į globalią

    % Pavaizduoja pasirinktus taškus skirtinga spalva arba ženklu
    plot(topLocs(maxIndexGlobal), maxValue, 'bo', MarkerSize=50); % 'ro' reiškia raudonas apskritimus

    % Apskaičiuokime vidurkį
    if isempty(selectedPks)
        disp('Nerasta viršūnių nurodytame diapazone.');
        centriniu_grioveliu_vidurkis = NaN;
    else
        centriniu_grioveliu_vidurkis = mean(selectedPks);
        %disp(['Viršūnių, esančių centriniame intervale, vidurkis: ', num2str(centriniu_grioveliu_vidurkis)]);
    end

    %Atvaizduojame grafike paryškintai
    centriniu_grioveliu_vidurkis_str = num2str(centriniu_grioveliu_vidurkis);

    % Center-aligned text
    text(centerX, textLocationY, ['   Vidurikis centro: ' centriniu_grioveliu_vidurkis_str], ...
     'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', ...
     'FontSize', 12, 'FontWeight', 'bold');

    %%
    max_centrinis=max(selectedPks);
    if isempty(max_centrinis)
        max_centrinis = NaN;
    end

    %% 4.2.9C vidinio
    indexRange = find(topLocs > xMarkers(2));     %ieško centrinių griovelių indeksų iš top 10
    selectedPks = topPksPadded(indexRange);                     %išrinkti atitinkamus topPksPadded elementus

    % Surasti maksimalią reikšmę ir jos indeksą
    [maxValue, maxIndex] = max(selectedPks);
    maxIndexGlobal = indexRange(maxIndex);  % Paverčiame lokalią indekso reikšmę į globalią

    % Pavaizduoja pasirinktus taškus skirtinga spalva arba ženklu
    plot(topLocs(maxIndexGlobal), maxValue, 'ko', MarkerSize=50); % 'ro' reiškia raudonas apskritimus
    
    % Apskaičiuokime vidurkį
    if isempty(selectedPks)
        disp('Nerasta viršūnių nurodytame diapazone.');
        vidiniu_grioveliu_vidurkis = NaN;
    else
        vidiniu_grioveliu_vidurkis = mean(selectedPks);
        %disp(['Viršūnių, esančių isoriniame intervale, vidurkis: ', num2str(vidiniu_grioveliu_vidurkis)]);
    end

    %Atvaizduojame grafike paryškintai
    vidiniu_grioveliu_vidurkis_str = num2str(vidiniu_grioveliu_vidurkis);

    % Right-aligned text
    text(rightX, textLocationY, ['   Vidurikis vidinės: ' vidiniu_grioveliu_vidurkis_str], ...
     'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', ...
     'FontSize', 12, 'FontWeight', 'bold');
    %%
    max_vidinis = max(selectedPks);
    if isempty(max_vidinis)
        max_vidinis = NaN;
    end

    %% 4.3 skyrius. Duomenų pridėjimas prie T4
    % Patikrinkite, ar topPeaksIndices, topPks ir topLocs yra vienodo ilgio

    % maxLength = max([length(topPeaksIndicesPadded), length(topPksPadded), length(topLocsPadded)]);
    % topPeaksIndicesPadded = padarray(topPeaksIndicesPadded, maxLength - length(topPeaksIndicesPadded), NaN, 'post');
    % topPksPadded = padarray(topPksPadded, maxLength - length(topPksPadded), NaN, 'post');
    % topLocsPadded = padarray(topLocsPadded, maxLength - length(topLocsPadded), NaN, 'post');

    if length(topPeaksIndicesPadded) == length(topPksPadded) && length(topPksPadded) == length(topLocsPadded)
        % Sukurti laikiną lentelę su masyvais
        % newRow = table(topPeaksIndicesPadded', topPksPadded', topLocsPadded', ...
        %                 'VariableNames', {'topPeaksIndices', 'topPks', 'topLocs'});
        
        % Patikrinkite, ar egzistuoja reikiami stulpeliai (visada pridėti dekalruotoje lentelėje celiu kuriant nauja kintamaji)
        requiredColumns = {'IsoriniuGrioveliuVidurkis', 'CentriniuGrioveliuVidurkis', 'VidiniuGrioveliuVidurkis','max_isorinis','max_centrinis','max_vidinis' };
        %requiredColumns = {'topPeaksIndices', 'topPks',        'topLocs',    'IsoriniuGrioveliuVidurkis', 'CentriniuGrioveliuVidurkis', 'VidiniuGrioveliuVidurkis', 'VisuGrioveliuVidurkis','max_isorinis','max_centrinis','max_vidinis' };
        for col = requiredColumns
            if ~ismember(col{1}, T4.Properties.VariableNames)
                T4.(col{1}) = NaN(height(T4), 1);  % Sukuriame stulpelį su NaN reikšmėmis
            end
        end

        %vidurkis_numeric = str2double(vidurkis); % Convert to numeric
        vidurkis_string = {vidurkis}; % Convert to cell array of strings

        % Sukurti naują eilutę su papildomu kintamuoju "vidurkis"

        newRow = table(topPeaksIndicesPadded', topPksPadded', topLocsPadded', isoriniu_grioveliu_vidurkis, centriniu_grioveliu_vidurkis, vidiniu_grioveliu_vidurkis, vidurkis_string,         max_isorinis, max_centrinis, max_vidinis, ...
          'VariableNames', {'topPeaksIndices', 'topPks',        'topLocs',    'IsoriniuGrioveliuVidurkis', 'CentriniuGrioveliuVidurkis', 'VidiniuGrioveliuVidurkis', 'VisuGrioveliuVidurkis','max_isorinis','max_centrinis','max_vidinis'});

        
        % Laikinosios lentelės pridėjimas prie T4
        T4 = [T4; newRow];

    else
        disp('Error: Arrays topPeaksIndices, topPks, and topLocs must be of the same length.');
    end

    % Update row names for the entire table
    rowNames = strcat('Row_', string(1:height(T4))); 
    T4.Properties.RowNames = rowNames; 
    
    %% 4.4 skyrius. Išsaugojame paveiksliukus

    subDirName = 'Paveiksliukai\\';         % Name of the subdirectory
    subDirPath = fullfile(saveDirectory, subDirName);  % Full path to the subdirectory

    % Check if subdirectory exists, if not, create it
    if ~exist(subDirPath, 'dir')
        mkdir(subDirPath);
    end

    %% Įrašoma į diską tik pirmūjų 100 profilių
    if n<=100

        figureName = fullfile(subDirPath, sprintf('Figure+%d.fig', n)); %veikia saugo kataloge
        saveas(gcf, figureName);
        
        %kaip 
        figureName1 = fullfile(subDirPath, sprintf('Figure-%d.jpg', n));
        saveas(gcf, figureName1);

    end
    
    disp(['Profilis: ' num2str(n)]);
    
    %% nubraižome markerius pagrindiniame grafike
    % Method 1: Using 'line'
    for i = 1:length(xMarkers)
        line([xMarkers(i) xMarkers(i)], ylim, 'Color', 'black','LineStyle','--', 'LineWidth', 1, 'HandleVisibility', 'off');
    end


    close all;
end
hold off;



%% 5 skyrius. Top 10 griovelių indeksų (reikšmių) ir gylio reikšmių išsaugojimas per visą profilį

% Sukonstruokite visus failų kelius

matFileName = fullfile(saveDirectory, 'all_data_auto.mat');
csvFileName1 = fullfile(saveDirectory, 'all_data_T4.csv');
%csvFileName2 = fullfile(saveDirectory, 'all_data_calculations_auto.csv');
%save(matFileName, 'topPeaksIndices', 'topPks',  'topLocs');
save(matFileName); %all data

writetable(T4, csvFileName1);
disp('Data saved successfully.');
cd(saveDirectory); % Change the current directory to the predefined directory

%% 6 skyrius. Grafikų atvaizdavimas
% Įkelkite lentelę, pvz pakeičiant katalogą
% cd 'C:\Users\valdasm\OneDrive - Light Conversion, UAB\Studijos 2022-2024\Temos pasirinkimas ir vadovas\MTD3\Data\Fixed\M3 C6-1280CS\Temp40 9600'

%% Gautų ir apskaičiuotų duomenų užkrovimas
T4 = readtable('all_data_T4.csv');

% figure(2);
% grid on;
% grid minor;
% % Check if 'T4' exists and is a table
% if ~exist('T4', 'var') || ~istable(T4)
%     T4 = readtable('all_data_T4.csv', 'ReadRowNames', true);
% end
% 
% %1 viename grafike - top surūšiuoti peaksai 
% hold on;
% plot(T4.topPks_1, 'b-'); 
% plot(T4.topPks_2, 'b-');
% plot(T4.topPks_3, 'g-');
% plot(T4.topPks_4, 'k-');
% plot(T4.topPks_5, 'm-');
% plot(T4.topPks_6, 'c-');
% plot(T4.topPks_7, 'y-');
% plot(T4.topPks_8, 'b--');
% plot(T4.topPks_9, 'r--');
% plot(T4.topPks_10, 'g--');
% grid on; grid minor; 
% legend('topPks_1','topPks_2','topPks_3','topPks_4','topPks_5','topPks_6','topPks_7','topPks_8','topPks_9','topPks_10' ); % Replace with your plot title % First plot with 'hold on' to keep adding to the same figure

%% 6.1 skyrius. Vidutiniu griovelių zonų vidurkių ir bendro vidirkio atvaizdavimas (neapdorotų)

figure(3);
grid on;
grid minor;
% Check if 'T4' exists and is a table
if ~exist('T4', 'var') || ~istable(T4)
    T4 = readtable('all_data_T4.csv', 'ReadRowNames', true);
end

%1 viename grafike
hold on;
plot(T4.IsoriniuGrioveliuVidurkis, 'b-'); 
plot(T4.CentriniuGrioveliuVidurkis, 'b-');
plot(T4.VidiniuGrioveliuVidurkis, 'g-');
plot(T4.VisuGrioveliuVidurkis, 'k-');
% plot(T4.topPks_5, 'm-');
% plot(T4.topPks_6, 'c-');
% plot(T4.topPks_7, 'y-');
% plot(T4.topPks_8, 'b--');
% plot(T4.topPks_9, 'r--');
% plot(T4.topPks_10, 'g--');
grid on; grid minor; 
legend('IsoriniuGrioveliuVidurkis','CentriniuGrioveliuVidurkis','VidiniuGrioveliuVidurkis', 'VisuGrioveliuVidurkis');
saveas(gcf, 'vid_vidurkiai.fig');

%% 6.2A Skyrius. A dalis - nefiltruoti Plotiname minimumus kiekvienos srities minimumus. 

figure(5);
subplot(2,1,1)
grid on;
grid minor;
hold on;
plot(T4.max_isorinis, 'b-'); 
plot(T4.max_centrinis, 'b-');
plot(T4.max_vidinis, 'g-');
ylim([-1 8]); % Set y-axis limits
% Pridedame legendą, jei reikia
legend('Isorinis', 'Centrinis', 'Vidinis');
title('Ne filtruotų išilgai Duomenų Grafikas');
xlabel('Profiliu sk., vnt.');
ylabel('Z, mm');


% Medianinis filtravimas

%windowSize = 0 ;  % Langų dydis medianiniam filtrui
%windowSize = 10 ;  % Langų dydis medianiniam filtrui
%windowSize = 25 ;  % Langų dydis medianiniam filtrui
windowSize = 50 ;  % Langų dydis medianiniam filtrui - indikatoriams

% Taikome medianinį filtrą kiekvienam duomenų rinkiniui
filtered_max_isorinis = medfilt1(T4.max_isorinis, windowSize);
filtered_max_centrinis = medfilt1(T4.max_centrinis, windowSize);
filtered_max_vidinis = medfilt1(T4.max_vidinis, windowSize);

%
% Let's assume you're using a simple moving average for filtering
% windowSize = 10;  % The size of the moving window for the average filter 
% %windowSize = 50; 
% %windowSize = 100; 
% %windowSize = 200; 
% 
% % You would replace 'movmean' with your specific filter function as required
% 
% % Apply the filter to your data
% filtered_max_isorinis = movmean(T4.max_isorinis, windowSize);
% filtered_max_centrinis = movmean(T4.max_centrinis, windowSize);
% filtered_max_vidinis = movmean(T4.max_vidinis, windowSize);
%

% Pridėti filtruotas reikšmes kaip naujus stulpelius lentelėje T4
T4.filtered_max_isorinis = filtered_max_isorinis;
T4.filtered_max_centrinis = filtered_max_centrinis;
T4.filtered_max_vidinis = filtered_max_vidinis;

%% 6.2B Skyrius. B dalis - filtruoti  Braižome filtruotus duomenis
subplot(2,1,2)
grid on;  % Įjungiame tinklelį
grid minor;  % Įjungiame smulkesnį tinklelį
hold on;  % Laikome esamus grafikus, kad galėtume piešti ant jų naujus

% Piešiame filtruotus duomenis nurodytomis spalvomis
plot(filtered_max_isorinis, 'b-'); 
plot(filtered_max_centrinis, 'b-');
plot(filtered_max_vidinis, 'g-');

ylim([-1 8]); % Set y-axis limits

% Pridedame ašių pavadinimus ir antraštę, jei reikia
xlabel('Profiliu sk., vnt.');
ylabel('Z, mm');

title('Filtruotų Duomenų Grafikas');

% Pridedame legendą, jei reikia
legend('Isorinis', 'Centrinis', 'Vidinis');
hold off;  % Paleidžiame grafiką naujiems braižymams

saveas(gcf, 'nefiltruoti_filtruoti.fig');

%% 7 skyrius. Toliau inicijuojame skaičiavimus.

min_isorinis = min(T4.max_isorinis, [], 'omitnan');
max_isorinis = max(T4.max_isorinis, [], 'omitnan');
dev_isorinis = max_isorinis - min_isorinis;
avg_isorinis = mean(T4.max_isorinis, 'omitnan');
std_dev_isorinis = std(T4.max_isorinis, 'omitnan');

min_centrinis = min(T4.max_centrinis, [], 'omitnan');
max_centrinis = max(T4.max_centrinis, [], 'omitnan');
dev_centrinis = max_centrinis - min_centrinis;
avg_centrinis = mean(T4.max_centrinis, 'omitnan');
std_dev_centrinis = std(T4.max_centrinis, 'omitnan');

min_vidinis = min(T4.max_vidinis, [], 'omitnan');
max_vidinis = max(T4.max_vidinis, [], 'omitnan');
dev_vidinis = max_vidinis - min_vidinis;
avg_vidinis = mean(T4.max_vidinis, 'omitnan');
std_dev_vidinis = std(T4.max_vidinis, 'omitnan');

avg_filtered_isorinis = mean(T4.filtered_max_isorinis, 'omitnan');
avg_filtered_centrinis = mean(T4.filtered_max_centrinis, 'omitnan');
avg_filtered_vidinis = mean(T4.filtered_max_vidinis, 'omitnan');

% Priskirti apskaičiuotas vertes tik pirmajai eilutei
T4.MinIsorinis(1) = min_isorinis;
T4.MaxIsorinis(1) = max_isorinis;
T4.DevIsorinis(1) = dev_isorinis;
T4.AvgIsorinis(1) = avg_isorinis;
T4.StdDevIsorinis(1) = std_dev_isorinis;

% Priskirti apskaičiuotas 'centrinis' vertes tik pirmajai eilutei
T4.MinCentrinis(1) = min_centrinis;
T4.MaxCentrinis(1) = max_centrinis;
T4.DevCentrinis(1) = dev_centrinis;
T4.AvgCentrinis(1) = avg_centrinis;
T4.StdDevCentrinis(1) = std_dev_centrinis;

% Priskirti apskaičiuotas 'vidinis' vertes tik pirmajai eilutei
T4.MinVidinis(1) = min_vidinis;
T4.MaxVidinis(1) = max_vidinis;
T4.DevVidinis(1) = dev_vidinis;
T4.AvgVidinis(1) = avg_vidinis;
T4.StdDevVidinis(1) = std_dev_vidinis;

if ~ismember('filtered_max_isorinis', T4.Properties.VariableNames)
    T4.filtered_max_isorinis = NaN(height(T4), 1); % Sukuria stulpelį su NaN reikšmėmis
end

% Pridėti filtruotas reikšmes kaip naujus stulpelius lentelėje T4
T4.FilteredMaxIsorinis(1) = avg_filtered_isorinis;
T4.FilteredMaxCentrinis(1) = avg_filtered_centrinis;
T4.FilteredMaxVidinis(1) = avg_filtered_vidinis;

writetable(T4, 'T4_su_skaiciavimais.csv'); % Save the updated table to a CSV file
%% išvedame apskaičiuose reikšmes i console
fprintf('avg_isorinis: %.2f\navg_centrinis: %.2f\navg_vidinis: %.2f\n', avg_isorinis, avg_centrinis, avg_vidinis);
% Assuming avg_filtered_isorinis, avg_filtered_centrinis, and avg_filtered_vidinis are already calculated and stored in variables

disp(['Average Filtered Isorinis: ', num2str(avg_filtered_isorinis, '%.2f')]);
disp(['Average Filtered Centrinis: ', num2str(avg_filtered_centrinis, '%.2f')]);
disp(['Average Filtered Vidinis: ', num2str(avg_filtered_vidinis, '%.2f')]);

%% 10 skyrius. Make video iš JPG

% pathWithDoubleBackslashes = strrep(saveDirectory, '\', '\\');
% 
% if isfolder(pathWithDoubleBackslashes)
%     disp('The folder exists.');
% else
%     disp('The folder does not exist.');
% end
% 
% outputVideo = VideoWriter(fullfile(pathWithDoubleBackslashes, 'myVideo_iki_25MB.avi')); % Define the name and path of the output video file
% outputVideo.FrameRate = 24; % Set the frame rate
% open(outputVideo);
% 
% % Set the directory where your images are stored
% subDirPath = fullfile(saveDirectory, subDirName);  % Full path to the subdirectory
% 
% % Assuming you know the number of images or calculate it
% numImages = 9; % Update this with the number of images you have
% 
% for i = 1:length(numImages)
%     % Construct the file name
%     fileName = fullfile(subDirPath, sprintf('Figure-%d.jpg', i));
% 
%     % Check if the file exists
%     if isfile(fileName)
%         img = imread(fileName); % Read the image
%         writeVideo(outputVideo, img); % Write the image to the video
%     else
%         warning('File %s does not exist.', fileName);
%     end
% end
% 
% %užbaigimas
% close(outputVideo);

% Vykdykite savo skriptą
%profile viewer; %kodo debuginimui