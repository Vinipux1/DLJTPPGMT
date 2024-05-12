close all, clc, clear all;

%% 0 skyrius Bandoma patobulinti su kalibravimo duomemimis kad suplotintų ant tų pačių duomenų, 
% o ne plotintu laiptuotai - atsisakyta duomenų apvertimo 
% pagal max o tik apverstos ašys, gaunasi tada kad viskas atliekama vienoje dimensijoje


%% 1 skyrius. Apsirašomos pradinės konstantos/faktoriai
% Kalibravimo faktoriai
pixelToMmX = 0.1408450704225352;      % Default:0.1428571 išskaičiutas iš 10mm plocio ir 8mm gylio griovelio
pixelToMmZ = 0.0035971223021583;      % Default: 0.0035714285714286 išskaičiutoas iš 10mm plocio ir 8mm plocio griovelio

                                        % Kameros default kalibrafijos param
                                        % Example: 0.2 mm per pixel for the Z-axis  
                                        % Name: C6-1280CS30-248-GigE-660-3B
                                        % Date: 10-Nov-2023
                                        % SensorSN: 22011231
                                        % Creator: cx_3d
                                        % Description: Factory Calibration
                                        % Model: Homography|C_Poly|N_Poly
                                        % RangeScale: 0.015625 <--???

%% 2 skyrius.  Pasirinkti failą
start_path = 'C:\\Users\\valdasm\\OneDrive - Light Conversion, UAB\\Studijos 2022-2024\\Temos pasirinkimas ir vadovas\\MTD3\\Data\\Fixed\\M3 C6-1280CS\\'; %nurodyti kataloga
[filename, pathname] = uigetfile({'*.tif';'*.*'}, 'Select a TIFF file', start_path);

if isequal(filename,0) || isequal(pathname,0)
   disp('User pressed cancel');
else
   disp(['User selected ', fullfile(pathname, filename)]);
   % Dabar galite naudoti failą pagal poreikį
end

%% 3 skyrius. Realaus profilio atvaizdavimas (apversto). Profilio sk. įvedimas. 
% Bandymas iteruoti kad išliktų Nx1280 plotis su ištrintomis nulinėmis reikšmėmis
data = imread(fullfile(pathname, filename));
n_max = input('Ivesk iteruojamų profiliu skaiciu n: '); % Paprašykite naudotojo įvesti n reikšmę
figure(1);  %pagrindinis grafikas
set(gca,'ydir','reverse')
hold on;

%% 3 a kryrius. Duomenų konvertavimas į duoble
profileData = double(data);

%% 4 skyrius. Iteravimas per visus profilius
for n=1:n_max  %profiliu skaicius

    %% 4.1 poskyris. Nuliniu reikšmių profilyje radimas ir duomenų teisingas interpoliavimas.
    profileData = data(n, :);    

    profileData = double(data(n, :));           %konvertuojame į double tipą n-aja eilute
    nonZeroIndices = find(profileData ~= 0);    % Rasti indeksus, kurių vertė nėra lygi nuliui
    
    % Interpoliuoti siekiant įvertinti nulinių taškų vertes
    % "interp1" naudojama 1D interpoliacijai
    % čia pasirinktas "tiesinis" metodas, tačiau galite naudoti ir kitus metodus, pavyzdžiui, "spline", "pchip" ir t. t.
    %interpolatedData = interp1(nonZeroIndices, profileData(nonZeroIndices), 1:length(profileData), 'linear', 'extrap'); %su extrapolaicija
            %Nurodykite "extrap", jei norite, kad interp1 įvertintų taškus UZ SRITIES RIBU naudodamas tą patį interpoliavimo metodą.
    
    %interpolatedData = interp1(nonZeroIndices, profileData(nonZeroIndices), 1:length(profileData), 'linear'); %be extrapolaicijos (puikiai veikia nebepraplecia vaizdo) <--antras pagal greituma
    %interpolatedData = interp1(nonZeroIndices, profileData(nonZeroIndices), 1:length(profileData), 'makima'); %be extrapolaicijos (sudas)
    
    interpolatedData = interp1(nonZeroIndices, profileData(nonZeroIndices), 1:length(profileData), 'nearest'); %be extrapolaicijos (puikiai veikia nebepraplecia vaizdo) <-FASTEST
    %interpolatedData = interp1(nonZeroIndices, profileData(nonZeroIndices), 1:length(profileData), 'next'); %be extrapolaicijos (puikiai veikia nebepraplecia vaizdo)
    %interpolatedData = interp1(nonZeroIndices, profileData(nonZeroIndices), 1:length(profileData), 'cubic'); %be extrapolaicijos (puikiai veikia nebepraplecia vaizdo)
    %interpolatedData = interp1(nonZeroIndices, profileData(nonZeroIndices), 1:length(profileData), 'v5cubic'); %be extrapolaicijos (puikiai veikia nebepraplecia vaizdo)
    %interpolatedData = interp1(nonZeroIndices, profileData(nonZeroIndices), 1:length(profileData), ''); %be extrapolaicijos 
    %interpolatedData = interp1(nonZeroIndices, profileData(nonZeroIndices), 1:length(profileData), 'spline'); %be extrapolaicijos (sudas)          

    %% 4.2 poskyris Kalibravimas arba mastelio keitimas
    
    numElements = length(interpolatedData); %Gaukite invertedYData elementų skaičių
    X_indeksai = 1:numElements;             % Sukurti indeksų masyvą
    Z_reiksmes = interpolatedData;          %pervadinti 
    
    X_index_mm{n}=X_indeksai*pixelToMmX;       %realios X reikšmės - sukurti lastelių masyvą (nors nebūtina)
    Z_reiksmes_mm{n}=Z_reiksmes*pixelToMmZ;    %realios Z reikšmės - sukurti lastelių masyvą (nors nebūtina)
     
    %% 4.3 poskyris. Atvaizduojame tame pačiame grafike taškus
     
    plot(X_index_mm{n}, Z_reiksmes_mm{n}, '-ko', 'MarkerSize', 2); % Linija su žymekliais
    hold on;
    xlabel('Plotis, mm')
    ylabel('Gylis, mm')
    grid on;

    %% Jei reikai naudojame limitus kad išrryškinti vaizdą
    %ylim([max(Z_reiksmes_mm)-7,max(Z_reiksmes_mm)+0.5]);       %S tyre - vaizdas formuojamas i viršų kad liktu 0,5mm, ir 7mm gylio profilis max
    %ylim([max(Z_reiksmes_mm)-8.5,max(Z_reiksmes_mm)+0.5]);     %M+S tyre - vaizdas formuojamas i viršų kad liktu 0,5mm, ir 8.5mm gylio profilis max
    %ylim([40,50]);                                             %M tyre
    
    %% 4.4 poskyris. Kai iteruojamas pirmas profilis įvedame lygini skaičių markerių. Braižome pagrindiniame grafike.
    if n==1    
       [x, ~] = ginput; % Taip galėsite spustelėti grafika. Baigę paspauskite Enter.
        
    end

    % Patikrinama, ar pasirinktas lyginis žymeklių skaičius
        if mod(length(x), 2) == 0
                %disp(['Pasirinktas lyginis markeriu skaicius - viskas OK']);
        else
                disp(['Turi buti pasirinktas lyginis markeriu skaicius!']);
                pause(inf);
        end    
    % Braizomi markeriai grafike.
    % Užveskite pelę per kiekvieną x koordinatę ir nubrėžkite vertikalią liniją
    for i = 1:length(x) %ciklas kiek markerių
         if n==1    
           line([x(i), x(i)], ylim, 'Color', 'r'); % Nubrėžia raudoną vertikalią liniją ties kiekviena x koordinate
         end
    end

    disp(['Profilis: ', num2str(n)]); %terminalr ismedame kelintas iteruojamas markeris.
end
    
for n=1:n_max  %profiliu skaicius
    
    %% 4.5 poskyris.Ieškome lokaliu minimumu pasirinktuose grioveliuose. Pažymime.
    hold on;
    tic; % Start timing
    counter=0;
        for i = 1:2:length(x) - 1  %pvz. 6 markeriai, ciklas bus 1 3 5 arba 2-1 4-1 6-1
            counter=counter+1;
            segment = X_index_mm{n} >= x(i) & X_index_mm{n} <= x(i+1); % Apsibrėžiame sutrumpintą segmentą (masyva) tarp dvieju x koordinaciu 
            segment_x = X_index_mm{n}(segment);    %atskiriame x segmento reiksmes
            segment_y = Z_reiksmes_mm{n}(segment); %atskiriame y arba Z segmento reiksmes
            
            % Randame lokalų MAXIMUMA segmente
            [min_value, min_idx] =max(segment_y); %grazina  min reiksme ir min indeksa lokaliame minimume
            min_x{n} = segment_x(min_idx); %grazina  min realia reiksme ir min indeksa lokaliame minimume
            min_y{n} = min_value;          %grazina  min reiksme lokaliame minimume
            
            %% Pažymime lokalų minimumą grafike
            plot(min_x{n}, min_y{n}, 'ro'); % 'mo' sukurs magentos spalvos apskritimą
            %arba
            %set(hScatter, 'XData', min_x, 'YData', min_y);
    
            %% 4.6 poskyris. Ieškome lokaliu maximu pasirinktuose grioveliuose nuo lokalaus minimumo į kairę ir į dešinę. Tikrinama ar masyves nėra tuščias.

            % DVIEJU LOKALIU MAKSIMUMU IESKOJIMAS REZYJE
            % Ieškome lokalų maksimumo kairėje nuo minimumo
            left_segment_y = segment_y(1:min_idx);                  %dar sumazinamas segmentas su y reiksmemis
            left_segment_x = segment_x(1:min_idx);                  %dar sumazinamas segmentas su x reiksmemis
            
            %tikriname ar masyvas nera tuscias?
            if ~isempty(left_segment_y)  
                [left_peak, left_loc_idx] = min(left_segment_y);    %grazina maksimalia reiksme ir ideksa
                left_loc = left_segment_x(left_loc_idx);            %grazina realia x reiksme mm
                plot(left_loc, left_peak, 'go');                    % 'go' sukurs žalią apskritimą
                %arba
                % Update the scatter plot object with left_loc and left_peak
                %set(hScatterLeft, 'XData', left_loc, 'YData', left_peak);
            end
        
            % Ieškome lokalų maksimumo dešinėje nuo minimumo
            right_segment_y = segment_y(min_idx:end);               %dar sumazinamas segmentas su y reiksmemis
            right_segment_x = segment_x(min_idx:end);               %dar sumazinamas segmentas su x reiksmemis
            
            %tikrinama ar masyvas nera tuscias?
            if ~isempty(right_segment_y)                            %tikrinama ar masyvas nera tuscias?
                [right_peak, right_loc_idx] = min(right_segment_y); %grazina maksimalia reiksme ir ideksa
                right_loc = right_segment_x(right_loc_idx);         %grazina realia x reiksme mm
                plot(right_loc, right_peak, 'bo');                  % 'bo' sukurs mėlyną apskritimą
                %arba
                % Update the scatter plot object with right_loc and right_peak
                %set(hScatterRight, 'XData', right_loc, 'YData', right_peak);

            end
    
            %% 4.6 poskyris. Fiksuojamos koordinatės ir braižomi lokalių minimumų ir maximumų taškai. Ir brėžiama linijos tarp lokalių maksimumų. 
            taskasL = [left_loc, left_peak];
            taskasR = [right_loc, right_peak];
            taskasB = [min_x{n}, min_y{n}];
        
            % Nubrėžti pasirinktų taškų liniją
            % Piešiame liniją tarp taškų
            
            % x ir y koordinačių išskyrimas iš vektoriaus
            x_linijos = [left_loc, right_loc];   %yra vektorius, kuriame yra x koordinatės 
            y_linijos = [left_peak, right_peak]; %yra vektorius, kuriame yra y koordinatės 
            
            % Linijos braižymas
            plot(x_linijos, y_linijos, '-o');  % '-o' sukuria punktyrinę liniją su apskritimo žymekliais taškuose
    
            %% 4.7 poskyris. Apskaičiuojamas minimalus atstumas nuo taskasB iki linijos, sujungiančios taskasL ir taskasR
            % Apskaičiuojamas atstumas (skaiciuoja gerai tarp LRx ir LRy korrdinaciu dekarto sistemoje)
            atstumas_tieses = sqrt((right_loc - left_loc)^2 + (right_peak - left_peak)^2);
    
            % Tarp linijos
            % Apskaičiuojamas minimalus atstumas nuo taskasB iki linijos, sujungiančios taskasL ir taskasR
            a = right_peak - left_peak;
            b = left_loc - right_loc;
            c = right_loc*left_peak - left_loc*right_peak;
            
            atstumasB = abs(a*min_x{n} + b*min_y{n} + c) / sqrt(a^2 + b^2);
           
            %% 4.8 poskyris. Išsaugome kiekvieno pasirinkto griovelio atstumus.
            %isaugome reiksmes kiekveino profilio iteracimo metu
            atstumasB_values_real(n, counter) = atstumasB; %i6saugome dveijų ciklų duomenis n - profilių, counter - grioveliu
    
            %% 4.9 poskyris. Piešiame trumpiausias griovelių linijas grafikuose. 
            
            %Piešiame
            dx = right_loc - left_loc;
            dy = right_peak - left_peak;
            t = ((min_x{n} - left_loc) * dx + (min_y{n} - left_peak) * dy) / (dx^2 + dy^2);  %Kai t yra apskaičiuojamas, jis turėtų būti ribojamas tarp 0 ir 1, kad užtikrintų, jog artimiausias taškas yra ant tiesės segmento, o ne už jo ribų. Jei t yra mažesnis nei 0 arba didesnis nei 1, tai reiškia, kad artimiausias taškas nėra ant tiesės segmento tarp taskasL ir taskasR.
            
            % Ribojame t reikšmę tarp 0 ir 1
            t = max(0, min(1, t));
            
            artimiausiasTaskasX = left_loc + t * dx;
            artimiausiasTaskasY = left_peak + t * dy;
            
            % Linijos nuo taško B iki artimiausio LR linijos taško braižymas
            plot([min_x{n}, artimiausiasTaskasX], [min_y{n}, artimiausiasTaskasY], '--'); % Dashed line

        end
    
        %Laiko skaiciavimo pabaiga

end; %ciklo su eiluciu skenavimu pabaiga

hold off;

%% 5 skyrius. Pamatuotų griovelių duomenų pagrindinių parametrų apskaičiavimas (min, max, avg, dif, std) ir išsaugojimas failuose.

%% Initialize an empty matrix to store the data
dataMatrix = [];

 for i = 1:counter   %grioveliu skaicius
        %% Profilių gautų reikšmių statistiniai skaičiavimai 
        % Apskaičiuokite minimumą, maksimumą ir vidurkį, STD, skirtumą
        min_value_ok(i) = min(atstumasB_values_real(:, i));         %nagrinėjamo riovelio
        max_value_ok(i) = max(atstumasB_values_real(:, i));         %nagrinėjamo riovelio
        average_value(i) = mean(atstumasB_values_real(:, i));       %nagrinėjamo riovelio
        difference_min_max(i) =  max_value_ok(i)-min_value_ok(i);   %nagrinėjamo riovelio
        deviation(i)=std(atstumasB_values_real(:, i));              %nagrinėjamo riovelio
       

        % Append the current row of data to the dataMatrix
        newRow = [min_value_ok(i), max_value_ok(i),  difference_min_max(i), average_value(i), deviation(i)];
        dataMatrix = [dataMatrix; newRow];

end;

% Transpose the dataMatrix to change columns to rows
transposedData = dataMatrix';


% Paraginimas įrašyti duomenis atstumasB_values_real į lentelę

% Iš anksto nustatytas katalogas
predefinedDirectory = 'C:\Users\valdasm\OneDrive - Light Conversion, UAB\Studijos 2022-2024\Temos pasirinkimas ir vadovas\MTD3\Data\Fixed\M3 C6-1280CS\'; %nurodyti kataloga

% Tegul naudotojas pasirenka katalogą, pradedant nuo iš anksto nustatyto katalogo
chosenDirectory = uigetdir(predefinedDirectory, 'Pasirinkite katalogą failams išsaugoti');

% Patikrinkite, ar naudotojas paspaudė 'Atšaukti'
if isequal(chosenDirectory, 0)
    disp('Vartotojas atšaukė operaciją. Nebuvo išsaugota jokių failų.');
    return;
else
    saveDirectory = chosenDirectory;
end

% Įsitikinkite, kad katalogas egzistuoja, jei ne, sukurkite jį
if ~exist(saveDirectory, 'dir')
    mkdir(saveDirectory);
end

% Sukonstruokite visus failų kelius
matFileName = fullfile(saveDirectory, 'all_usefull_data.mat');
csvFileName1 = fullfile(saveDirectory, 'all_data.csv');
csvFileName2 = fullfile(saveDirectory, 'all_data_calculations.csv');
figureA = fullfile(saveDirectory, 'myFigure.fig');

% Išsaugoti MAT failą
% Pastaba: išsaugojimo funkcijoje iš "all_usefull_data.mat" pašalinkite ".mat".
save(matFileName, 'atstumasB_values_real', 'min_value_ok', 'max_value_ok', 'difference_min_max','average_value',  'deviation');

%% 6 skyrius. Sukuriame lentelel T1 (griovelių atstumai), T2(kiekveino griovelio apskaičiuotos reikšmės matricoje), T3 (kiekveino griovelio apskaičiuotos reikšmės eilutėje)
T1 = table(atstumasB_values_real); %sukuriame lentelę su visų griovelių atstumais

% Nustatykite eilučių pavadinimus ir kintamųjų pavadinimus
rowNames = {'min_value_ok', 'max_value_ok',  'difference_min_max', 'average_value', 'deviation'}; % Replace with your desired row names

% Sukurti lentelę iš transposedData su eilučių pavadinimais ir kintamųjų pavadinimais
columnNames = cell(1, counter); % Initialize an empty cell array for column names
for i = 1:counter
    columnNames{i} = ['Griovelis ' num2str(i)]; % Generate column names like 'Column1', 'Column2', etc.
end

T2 = array2table(transposedData, 'RowNames', rowNames, 'VariableNames', columnNames);
T3 = table(min_value_ok, max_value_ok,  difference_min_max, average_value, deviation); %duomenu pasiemimui į exel


%T2 = table(min_value_ok, max_value_ok,  difference_min_max, average_value, deviation); %pavadinimai stulepeliu

%% 7 skyrius. Išsaugojimas. 
% Save the tables as CSV files
writetable(T1, csvFileName1);
writetable(T2, csvFileName2);
writetable(T3, 'T3.csv');
%%
savefig(figureA);

disp('Data saved successfully.');

%% 8 skyrius. Tikrinama ar nėra reikšmių mažesnių nei 3mm. T.y. padanga tinkama žiemai.
%tikrinimaos visu grioveliu minimalios reiksmes 
        threshold = 3;
        if average_value >= threshold
            disp('Padanga tinkama naudoti ziema t.y. >= 3 mm');
        else
            disp('Padanga ne tinkama naudoti ziema t.y. < 3 mm');
        end


        %tikrinimaos visu grioveliu minimalios reiksmes 
        threshold = 1.6;
        if average_value >= threshold
            disp('Padanga tinkama naudoti vasara t.y. >= 1,6 mm');
        else
            disp('Padanga ne tinkama naudoti vasara  t.y. < 1,6 mm');
        end