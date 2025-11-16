import processing.serial.*;

// ========== КОНФИГУРАЦИЯ ИГРЫ ==========
class GameConfig {
  // Настройки сложности
  final int EASY_LEVEL = 1;
  final int NORMAL_LEVEL = 2;
  final int HARD_LEVEL = 3;

  final int EASY_HINTS = 10;
  final int NORMAL_HINTS = 5;
  final int HARD_HINTS = 3;

  final int EASY_BONUS_WORDS = 3;
  final int NORMAL_BONUS_WORDS = 5;
  final int HARD_BONUS_WORDS = 7;

  // Настройки интерфейса
  final int BAUD_RATE = 115200;
  final int MAX_ATTEMPTS = 7;
  final int MAX_HINTS = 3;
  final int CURSOR_DELAY = 200;

  // Цвета
  final color BG_COLOR = color(66, 170, 255);
  final color RED_COLOR = color(188, 8, 11);
  final color WIN_COLOR = color(30, 116, 7);

  // Координаты
   final int CURSOR_START_X = 100;
  final int CURSOR_START_Y = 200;
  final int CURSOR_STEP = 100;
  final int HINT_ZONE_X = 1200;
  final int HINT_ZONE_Y = 280;
  final int ALPHABET_START_X = 100;
  final int ALPHABET_END_X = 800; // 8 столбцов: 100,200,...,900

  // Меню
  final int MENU_START_X = 650;
  final int MENU_START_Y = 450;
  final int MENU_STEP_Y = 100;
  final int MENU_ROWS = 3;

  // ДОБАВЛЕНО: Интервал перемещения курсора (в миллисекундах)
  final int MOVE_INTERVAL = 300;
  
  // ДОБАВЛЕНО: Задержка для клавиатуры
  final int KEY_COOLDOWN = 200;
  
  // ДОБАВЛЕНО: Интервал проверки подключения порта
  final int PORT_CHECK_INTERVAL = 2000; // Проверять каждые 2 секунды
}

// ========== КЛАСС КОНФИГУРАЦИИ СЛОЖНОСТИ ==========
class DifficultyConfig {
  final int level;
  final int bonusWords;
  final int startHints;
  final boolean hintsEnabled;

  DifficultyConfig(int level, int bonusWords, int startHints, boolean hintsEnabled) {
    this.level = level;
    this.bonusWords = bonusWords;
    this.startHints = startHints;
    this.hintsEnabled = hintsEnabled;
  }
}

// ========== КЛАССЫ ДАННЫХ ==========
class GameData {
  // Массив слов для угадывания
  char[][] dictionary = {
    // 3 буквы
    {'К', 'О', 'Т'}, {'Д', 'О', 'М'}, {'М', 'А', 'К'}, {'С', 'О', 'К'},
    // 4 буквы
    {'С', 'Т', 'О', 'Л'}, {'Ф', 'Л', 'А', 'Г'}, {'З', 'Н', 'А', 'К'}, {'Р', 'Ы', 'Б', 'А'},
    {'С', 'Т', 'У', 'Л'}, {'О', 'Ч', 'К', 'И'}, {'Я', 'Щ', 'И', 'К'}, {'Л', 'У', 'Н', 'А'},
    {'Р', 'Е', 'К', 'А'}, {'П', 'А', 'Р', 'К'},
    // 5 букв
    {'Р', 'О', 'Б', 'О', 'Т'}, {'С', 'П', 'О', 'Р', 'Т'}, {'Б', 'У', 'К', 'В', 'А'},
    {'Т', 'Р', 'А', 'В', 'А'}, {'Ч', 'А', 'Ш', 'К', 'А'},
    // 6 букв
    {'К', 'Н', 'О', 'П', 'К', 'А'}, {'П', 'Р', 'О', 'В', 'О', 'Д'}, {'О', 'Д', 'Е', 'Ж', 'Д', 'А'},
    {'С', 'О', 'Б', 'А', 'К', 'А'}, {'С', 'О', 'Л', 'Н', 'Ц', 'Е'}, {'П', 'А', 'Л', 'Ь', 'Т', 'О'},
    {'М', 'О', 'Л', 'О', 'К', 'О'},
    // 7 букв
    {'Т', 'Е', 'Л', 'Е', 'Ф', 'О', 'Н'}, {'И', 'Г', 'Р', 'У', 'Ш', 'К', 'А'}, {'К', 'А', 'Р', 'Т', 'И', 'Н', 'А'},
    // 8 букв
    {'П', 'У', 'Г', 'О', 'В', 'И', 'Ц', 'А'},
    // 9 букв
    {'В', 'Е', 'Л', 'О', 'С', 'И', 'П', 'Е', 'Д'}
  };

  // Длины слов (должны соответствовать dictionary)
  int[] wordLengths = {3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 8, 9};

  // Подсказки для каждого слова
  String[] wordHints = {
    "Животное", "Жилье", "Растение", "Напиток",
    "Мебель", "Символ", "Указатель", "Животное", "Мебель", "Аксессуар",
    "Контейнер", "Небесное тело", "Водоем", "Территория",
    "Техника", "Активность", "Письмо", "Растительность", "Посуда",
    "Элемент управления", "Кабель", "Ткани", "Животное", "Звезда",
    "Одежда", "Продукт", "Связь", "Развлечение", "Искусство",
    "Аксессуар", "Транспорт"
  };

  // Отображаемые символы (подчеркивания для скрытых букв)
  char[][] hiddenDisplay;

  // Русский алфавит для выбора букв
  char[] russianAlphabet = {
    'А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ё', 'Ж', 'З', 'И', 'Й', 'К', 'Л', 'М',
    'Н', 'О', 'П', 'Р', 'С', 'Т', 'У', 'Ф', 'Х', 'Ц', 'Ч', 'Ш', 'Щ', 'Ъ',
    'Ы', 'Ь', 'Э', 'Ю', 'Я'
  };

  GameData() {
    // Инициализация hiddenDisplay на основе dictionary
    hiddenDisplay = new char[dictionary.length][];
    for (int i = 0; i < dictionary.length; i++) {
      hiddenDisplay[i] = new char[dictionary[i].length];
      for (int j = 0; j < dictionary[i].length; j++) {
        hiddenDisplay[i][j] = '_';
      }
    }
  }
}

// ========== ОСНОВНЫЕ ПЕРЕМЕННЫЕ ИГРЫ ==========
GameConfig config = new GameConfig();
GameData gameData = new GameData();
Serial port;
String comPort = "";
int c = 1;
// ДОБАВЛЕНО: Переменная для отслеживания состояния порта (0 - отключен, 1 - активен)
int p = 0; // По умолчанию порт отключен

// Состояние игры
boolean inMainMenu = true;
boolean gameEnded = false;
boolean showGameOver = false;
boolean showWinMessage = false;

// Игровые переменные
int attempts = config.MAX_ATTEMPTS;
int currentWordIndex;
IntList usedWordIndexes = new IntList();
int selectedLetterIndex = 0;
int hintsCount = config.MAX_HINTS;
int score = 0;

// Переменные для бонусной системы
int wordsWithoutHints = 0;
int wordsForBonus = config.NORMAL_BONUS_WORDS;
boolean usedHintThisWord = false;

// Переменные для управления
int cursorX = config.CURSOR_START_X;
int cursorY = config.CURSOR_START_Y;
boolean cursorInHintZone = false;

// Меню сложности
String[] difficultyItems = new String[config.MENU_ROWS];
int menuCursorY = config.MENU_START_Y;
int selectedRow = 0;

// Конфигурация сложности
DifficultyConfig currentDifficulty;
HashMap<String, DifficultyConfig> difficultyConfigs = new HashMap<String, DifficultyConfig>();

// Переменные для меню после победы
int winMenuOption = 0; // 0 - продолжить, 1 - в меню

// Переменные для меню после поражения
int gameOverMenuOption = 0; // 0 - новая игра, 1 - в меню

// НОВАЯ СИСТЕМА ВВОДА - предотвращение залипания
boolean inputProcessed = true;
int lastInputValue = 0;
int inputCooldown = 0;
int m = 1;
// ДОБАВЛЕНО: Система непрерывного перемещения (только для игрового процесса)
int lastMoveTime = 0;
int currentMoveDirection = 0; // 0 - нет движения, 1-4 - направления
boolean isMoving = false;

// ДОБАВЛЕНО: Система перемещения курсора в меню
int pendingDirectionY = 0; // 0 - нет движения, -1 - вверх, 1 - вниз
int lastCursorMoveTime = 0; // Время последнего перемещения курсора

// ДОБАВЛЕНО: Защита от залипания клавиш
int lastKeyPressTime = 0;
boolean keyUpPressed = false;
boolean keyDownPressed = false;
boolean keyLeftPressed = false;
boolean keyRightPressed = false;
boolean keyEnterPressed = false;

// ДОБАВЛЕНО: Время последней проверки порта
int lastPortCheckTime = 0;

// ДОБАВЛЕНО: Система блокировки перемещения в меню
boolean menuJoystickNeedsReset = false; // Флаг необходимости сброса джойстика
int lastMenuInput = 0; // Последнее направление в меню

// ========== НАСТРОЙКА ==========
void setup() {
  size(1500, 700);
  smooth(8);
  textSize(50);
  textAlign(LEFT, BASELINE);

  initDifficultyConfigs();
  initDifficultyMenu();
  initSerial(); // Пытаемся подключиться к порту при запуске
}

void initDifficultyConfigs() {
  difficultyConfigs.put("ЛЕГКО", new DifficultyConfig(
    config.EASY_LEVEL,
    config.EASY_BONUS_WORDS,
    config.EASY_HINTS,
    true
    ));
  difficultyConfigs.put("НОРМАЛЬНО", new DifficultyConfig(
    config.NORMAL_LEVEL,
    config.NORMAL_BONUS_WORDS,
    config.NORMAL_HINTS,
    true
    ));
  difficultyConfigs.put("СЛОЖНО", new DifficultyConfig(
    config.HARD_LEVEL,
    config.HARD_BONUS_WORDS,
    config.HARD_HINTS,
    false
    ));
}

void initDifficultyMenu() {
  difficultyItems[0] = "ЛЕГКО";
  difficultyItems[1] = "НОРМАЛЬНО";
  difficultyItems[2] = "СЛОЖНО";
  inMainMenu = true;
}

// ДОБАВЛЕНО: Поиск доступного COM-порта
String findAvailableComPort() {
  String[] ports = Serial.list();
  if (ports.length == 0) {
    return null;
  }

  for (String portName : ports) {
    if (portName.contains("Arduino") || portName.contains("ttyUSB") || portName.contains("COM")) {
      return portName;
    }
  }

  // Если не нашли "именованные" порты, возвращаем первый доступный
  return ports[0];
}

// ПЕРЕРАБОТАНА: Функция инициализации последовательного порта
void initSerial() {
  // Если порт уже подключен, закрываем его
  if (port != null) {
    try {
      port.stop();
      port = null;
    } catch (Exception e) {
      println("Ошибка при закрытии порта: " + e.getMessage());
    }
  }

  comPort = findAvailableComPort();
  
  if (comPort == null || comPort.isEmpty()) {
    println("Нет доступных COM-портов");
    p = 0;
    return;
  }

  try {
    port = new Serial(this, comPort, config.BAUD_RATE);
    port.bufferUntil('\n');
    println("Успешное подключение к " + comPort);
    p = 1; // Порт активен
  }
  catch (RuntimeException e) {
    println("Ошибка подключения к порту " + comPort + ": " + e.getMessage());
    p = 0; // Порт неактивен
    port = null;
  }
}

// ДОБАВЛЕНО: Функция для принудительного отключения порта
void disconnectPort() {
  if (port != null) {
    try {
      port.stop();
      println("Порт принудительно отключен");
    } catch (Exception e) {
      println("Ошибка при отключении порта: " + e.getMessage());
    }
    port = null;
  }
  p = 0;
  comPort = "";
}

// ДОБАВЛЕНО: Функция для принудительного подключения порта
void connectPort() {
  println("Попытка принудительного подключения порта...");
  initSerial();
}

// ДОБАВЛЕНО: Функция отправки данных в порт с проверкой состояния
void sendToPort(char data) {
  if (p == 1 && port != null) {
    try {
      port.write(data);
      // println("Отправлено в порт: " + data); // Для отладки
    } catch (Exception e) {
      println("Ошибка отправки данных в порт: " + e.getMessage());
      p = 0; // При ошибке отправки помечаем порт как неактивный
    }
  }
}

// ДОБАВЛЕНО: Функция автоматической проверки подключения порта
void checkPortConnection() {
  if (millis() - lastPortCheckTime > config.PORT_CHECK_INTERVAL) {
    lastPortCheckTime = millis();
    
    // Если порт считается активным, но произошла ошибка - переподключаемся
    if (p == 1 && (port == null)) {
      println("Обнаружено отключение порта, пытаемся переподключиться...");
      p = 0;
      initSerial();
    }
    
    // Если порт отключен, пробуем найти и подключиться к доступному порту
    if (p == 0) {
      String availablePort = findAvailableComPort();
      if (availablePort != null && !availablePort.equals(comPort)) {
        println("Найден доступный порт: " + availablePort + ", пробуем подключиться...");
        initSerial();
      }
    }
  }
}

// ========== ГЛАВНЫЙ ЦИКЛ ==========
void draw() {
  // Обработка кулдауна ввода
  if (inputCooldown > 0) {
    inputCooldown--;
  }

  // ДОБАВЛЕНО: Автоматическая проверка подключения порта
  checkPortConnection();

  // ДОБАВЛЕНО: Обработка непрерывного движения (только для игрового процесса)
  if (isMoving && millis() - lastMoveTime >= config.MOVE_INTERVAL && inMainMenu == false) {
    handleContinuousMove();
  }

  // ДОБАВЛЕНО: Обработка клавиатуры в реальном времени
  handleKeyboardInput();

  // ДОБАВЛЕНО: Обновление курсора меню
  if (inMainMenu) {
    updateMenuCursor();
    drawDifficultyMenu();
    return;
  }

  if (showGameOver) {
    drawGameOverScreen();
    return;
  }

  if (showWinMessage) {
    displayWinMessage();
    return;
  }

  if (gameEnded) {
    return;
  }

  updateCursorPosition();
  drawUI();
}

// ДОБАВЛЕНО: Обработка клавиатурного ввода в реальном времени
void handleKeyboardInput() {
  if (inMainMenu || showGameOver || showWinMessage) {
    // В меню и экранах окончания игры используем обычную обработку
    return;
  }

  // Проверяем, есть ли активные нажатия клавиш
  boolean anyKeyPressed = keyUpPressed || keyDownPressed || keyLeftPressed || keyRightPressed;
  
  if (!anyKeyPressed) {
    // Если никакие клавиши не нажаты, останавливаем движение
    isMoving = false;
    currentMoveDirection = 0;
    return;
  }

  // Определяем направление движения с приоритетом
  int newDirection = 0;
  if (keyUpPressed) newDirection = 1;
  else if (keyDownPressed) newDirection = 2;
  else if (keyLeftPressed) newDirection = 3;
  else if (keyRightPressed) newDirection = 4;

  // Если направление изменилось, обновляем немедленно
  if (newDirection != currentMoveDirection) {
    currentMoveDirection = newDirection;
    isMoving = true;
    if (millis() - lastMoveTime >= config.MOVE_INTERVAL) {
      handleContinuousMove();
    }
  }
}

// ИЗМЕНЕНО: Обновление курсора меню с учетом блокировки
void updateMenuCursor() {
  // Эта функция теперь в основном для анимации, если потребуется
  // Основная логика перемещения обрабатывается в processInput
}

// ДОБАВЛЕНО: Перемещение курсора меню
void moveMenuCursor(int dy) {
  int newRow = selectedRow + dy;

  if (newRow >= 0 && newRow < config.MENU_ROWS) {
    selectedRow = newRow;
  }

  menuCursorY = config.MENU_START_Y + selectedRow * config.MENU_STEP_Y;
}

// ДОБАВЛЕНО: Обработка непрерывного движения (только для игрового процесса)
void handleContinuousMove() {
  if (!isMoving) return;

  switch(currentMoveDirection) {
  case 1:
    moveCursor(0, -1);
    break;
  case 2:
    moveCursor(0, 1);
    break;
  case 3:
    moveCursor(-1, 0);
    break;
  case 4:
    moveCursor(1, 0);
    break;
  }
  lastMoveTime = millis();
}

// ========== МЕНЮ ВЫБОРА СЛОЖНОСТИ ==========
void drawDifficultyMenu() {
  background(config.BG_COLOR);

  fill(204, 85, 0);
  textSize(150);
  textAlign(CENTER, CENTER);
  text("МЕГАСЛОВ", width/2, 200);

  fill(0);
  textSize(50);
  text("Выберите сложность, чтобы начать", width/2, 300);

  drawDifficultyInterface();
  drawMenuCursor();
  textAlign(LEFT, BASELINE);
}

void drawDifficultyInterface() {
  textSize(36);
  textAlign(CENTER, CENTER);
  fill(0);

  for (int row = 0; row < config.MENU_ROWS; row++) {
    int y = config.MENU_START_Y + row * config.MENU_STEP_Y;
    if (y == menuCursorY)
    {
      fill(204, 85, 0);
    }
    text(difficultyItems[row], width/2, y);
      fill(0);
  }
}

void drawMenuCursor() {
  fill(255, 0, 0);
  textSize(36);
  textAlign(CENTER, CENTER);
  text("", width/2, menuCursorY + 25);
}

void handleDifficultySelection() {
  String selectedDifficulty = difficultyItems[selectedRow];
  currentDifficulty = difficultyConfigs.get(selectedDifficulty);

  if (currentDifficulty != null) {
    println("Запуск игры со сложностью: " + selectedDifficulty);
    applyDifficultyConfig(currentDifficulty);
    inMainMenu = false;
    
    // ДОБАВЛЕНО: Сброс блокировки при выходе из меню
    menuJoystickNeedsReset = false;
    
    startNewGame();
  }
}

void applyDifficultyConfig(DifficultyConfig config) {
  wordsForBonus = config.bonusWords;
  hintsCount = config.startHints;

  println("Установлено подсказок: " + hintsCount + ", бонус через " + wordsForBonus + " слов");
}

// ========== СБРОС В ГЛАВНОЕ МЕНЮ ==========
void resetToMainMenu() {
  inMainMenu = true;
  showWinMessage = false;
  showGameOver = false;
  gameEnded = false;

  // Сброс игровых переменных
  attempts = config.MAX_ATTEMPTS;
  score = 0;
  hintsCount = config.MAX_HINTS;
  wordsWithoutHints = 0;
  usedWordIndexes.clear();

  // Сброс курсора меню
  selectedRow = 0;
  menuCursorY = config.MENU_START_Y;
  pendingDirectionY = 0;

  // ДОБАВЛЕНО: Сброс системы блокировки меню
  menuJoystickNeedsReset = false;
  lastMenuInput = 0;

  // СБРОС СИСТЕМЫ ВВОДА
  inputProcessed = true;
  inputCooldown = 20; // Задержка перед следующим вводом

  // ДОБАВЛЕНО: Сброс системы движения
  isMoving = false;
  currentMoveDirection = 0;

  // ДОБАВЛЕНО: Сброс состояния клавиш
  resetKeyboardState();

  println("Возврат в главное меню");
}

// ДОБАВЛЕНО: Сброс состояния клавиш
void resetKeyboardState() {
  keyUpPressed = false;
  keyDownPressed = false;
  keyLeftPressed = false;
  keyRightPressed = false;
  keyEnterPressed = false;
  lastKeyPressTime = 0;
}

// ========== ИГРОВАЯ ЛОГИКА ==========
void startNewGame() {
  int currentLevel = currentDifficulty.level;
  selectedLetterIndex = 0;
  float r = random(1);
  print(r);


  gameEnded = false;
  showGameOver = false;
  showWinMessage = false;
  cursorInHintZone = false;
  cursorX = config.CURSOR_START_X;
  cursorY = config.CURSOR_START_Y;
  selectedLetterIndex = 0;
  attempts = config.MAX_ATTEMPTS;
  usedHintThisWord = false;
  winMenuOption = 0; // Сброс выбора в меню победы
  gameOverMenuOption = 0; // Сброс выбора в меню поражения

  // СБРОС СИСТЕМЫ ВВОДА
  inputProcessed = true;
  inputCooldown = 20; // Задержка перед следующим вводом

  // ДОБАВЛЕНО: Сброс системы движения
  isMoving = false;
  currentMoveDirection = 0;
  lastMoveTime = millis();

  // ДОБАВЛЕНО: Сброс состояния клавиш
  resetKeyboardState();

  currentWordIndex = getUniqueRandomIndex(gameData.dictionary.length);
  resetHiddenWord();

  // ИНИЦИАЛИЗАЦИЯ ПОЗИЦИИ КУРСОРА
  updateSelectedLetterIndex();

  println("Начато новое слово. Подсказок осталось: " + hintsCount);
    if (currentLevel == config.EASY_LEVEL) {
        println("Текущая сложность: ЛЕГКО");
        if(r <= 0.75)
        {
        useHintf();
        }
    } else if (currentLevel == config.NORMAL_LEVEL) {
       if(r <= 0.50)
        {
        useHintf();
        }
        println("Текущая сложность: НОРМАЛЬНО");
    } else if (currentLevel == config.HARD_LEVEL) {
       if(r <= 0.25)
        {
        useHintf();
        }
        println("Текущая сложность: СЛОЖНО");
    }
}

int getUniqueRandomIndex(int max) {
  if (usedWordIndexes.size() >= max) {
    usedWordIndexes.clear();
    println("Все слова использованы, начинаем заново");
  }

  int newIndex;
  do {
    newIndex = (int)random(max);
  } while (usedWordIndexes.hasValue(newIndex));

  usedWordIndexes.append(newIndex);
  return newIndex;
}

void resetHiddenWord() {
  for (int i = 0; i < gameData.wordLengths[currentWordIndex]; i++) {
    gameData.hiddenDisplay[currentWordIndex][i] = '_';
  }
}

void checkLetter() {
  if (gameEnded || showWinMessage) return;

  // Дополнительная проверка корректности индекса
  if (selectedLetterIndex < 0 || selectedLetterIndex >= gameData.russianAlphabet.length) {
    println("ОШИБКА: Неверный индекс буквы: " + selectedLetterIndex);
    return;
  }

  char selectedLetter = gameData.russianAlphabet[selectedLetterIndex];
  
  // ОТЛАДОЧНАЯ ИНФОРМАЦИЯ
  println("Проверка буквы: " + selectedLetter + " (индекс: " + selectedLetterIndex + ")");
  println("Текущее слово: " + new String(gameData.dictionary[currentWordIndex]));
  
  boolean found = false;

  for (int i = 0; i < gameData.wordLengths[currentWordIndex]; i++) {
    if (gameData.dictionary[currentWordIndex][i] == selectedLetter) {
      gameData.hiddenDisplay[currentWordIndex][i] = selectedLetter;
      println("Угадал букву: " + selectedLetter);
      sendToPort('1'); // ЗАМЕНА: port.write на sendToPort
      found = true;
    }
  }

  if (!found) {
    attempts--;
    println("Не угадал. Осталось попыток: " + attempts);
    sendToPort('0'); // ЗАМЕНА: port.write на sendToPort

    if (attempts <= 0) {
      gameOver();
      return;
    }
  }

  checkWinCondition();
}

void useHint() {
  if (gameEnded || showWinMessage || hintsCount <= 0) {
    println("Подсказка недоступна");
    return;
  }

  if (getHiddenLettersCount() == 0) {
    println("Все буквы уже открыты");
    return;
  }

  IntList hiddenIndices = new IntList();
  for (int i = 0; i < gameData.wordLengths[currentWordIndex]; i++) {
    if (gameData.hiddenDisplay[currentWordIndex][i] == '_') {
      hiddenIndices.append(i);
    }
  }

  if (hiddenIndices.size() > 0) {
    int randomIndex = hiddenIndices.get((int)random(hiddenIndices.size()));
    char correctLetter = gameData.dictionary[currentWordIndex][randomIndex];

    gameData.hiddenDisplay[currentWordIndex][randomIndex] = correctLetter;
    hintsCount--;
    usedHintThisWord = true;

    println("Использована подсказка! Открыта буква: " + correctLetter);
    println("Осталось подсказок: " + hintsCount);
    sendToPort('5'); // ЗАМЕНА: port.write на sendToPort

    checkWinCondition();
  }
}

void useHintf() {
  if ( showWinMessage ) {
    println("Подсказка недоступна");
    return;
  }

  if (getHiddenLettersCount() == 0) {
    println("Все буквы уже открыты");
    return;
  }

  IntList hiddenIndices = new IntList();
  for (int i = 0; i < gameData.wordLengths[currentWordIndex]; i++) {
    if (gameData.hiddenDisplay[currentWordIndex][i] == '_') {
      hiddenIndices.append(i);
    }
  }

  if (hiddenIndices.size() > 0) {
    int randomIndex = hiddenIndices.get((int)random(hiddenIndices.size()));
    char correctLetter = gameData.dictionary[currentWordIndex][randomIndex];

    gameData.hiddenDisplay[currentWordIndex][randomIndex] = correctLetter;
    //hintsCount--;
    usedHintThisWord = true;

    println("Использована подсказка! Открыта буква: " + correctLetter);
    println("Осталось подсказок: " + hintsCount);
    sendToPort('5'); // ЗАМЕНА: port.write на sendToPort

    checkWinCondition();
  }
}

int getHiddenLettersCount() {
  int count = 0;
  for (int i = 0; i < gameData.wordLengths[currentWordIndex]; i++) {
    if (gameData.hiddenDisplay[currentWordIndex][i] == '_') {
      count++;
    }
  }
  return count;
}

void checkWinCondition() {
  if (gameEnded || showWinMessage) return;

  boolean allRevealed = true;
  for (int i = 0; i < gameData.wordLengths[currentWordIndex]; i++) {
    if (gameData.hiddenDisplay[currentWordIndex][i] == '_') {
      allRevealed = false;
      break;
    }
  }

  if (allRevealed) {
    showWinMessage = true;
    score++;
    sendToPort('3'); // ЗАМЕНА: port.write на sendToPort

    // СБРОС СИСТЕМЫ ВВОДА ПРИ ПОБЕДЕ
    inputProcessed = true;
    inputCooldown = 20;

    // Бонусная система
    if (!usedHintThisWord) {
      wordsWithoutHints++;

      if (wordsWithoutHints >= wordsForBonus) {
        hintsCount++;
        wordsWithoutHints = 0;
        println("Бонус: получена подсказка за " + wordsForBonus + " слов без подсказок!");
        println("Теперь подсказок: " + hintsCount);
      }
    }
  }
}

// ========== ИНТЕРФЕЙС ==========
void drawUI() {
  background(config.BG_COLOR);
  drawHiddenWord();
  drawAlphabetGrid();

  drawAttemptsCounter();
  drawHintsCounter();
 // drawComPortInfo();
  drawScore();
  drawBonusProgress();
  drawCursor();

  if (currentDifficulty != null && currentDifficulty.hintsEnabled) {
    drawWordHint();
  }
}

void drawWordHint() {
  fill(0);
  textSize(30);
  textAlign(CENTER, CENTER);
  text(gameData.wordHints[currentWordIndex], 500, 120);
  textAlign(LEFT, BASELINE);
}

void drawHiddenWord() {
  float xPos = 500;
  fill(0);
  textSize(50);
  for (int i = 0; i < gameData.wordLengths[currentWordIndex]; i++) {
    text(gameData.hiddenDisplay[currentWordIndex][i], xPos, 50);
    xPos += 50;
  }
}

void drawAlphabetGrid() {
  int x = config.CURSOR_START_X, y = config.CURSOR_START_Y;
  fill(0);
  textSize(50);
  
  for (int i = 0; i < gameData.russianAlphabet.length; i++) {
    // Вычисляем позицию для каждой буквы
    int currentX = config.CURSOR_START_X + (i % 8) * config.CURSOR_STEP;
    int currentY = config.CURSOR_START_Y + (i / 8) * config.CURSOR_STEP;
    
    // Подсвечиваем выбранную букву
    if (i == selectedLetterIndex && !cursorInHintZone) {
      fill(204, 85, 0);
    } else {
      fill(0);
    }
    
    text(gameData.russianAlphabet[i], currentX, currentY);
  }
}

void drawCursor() {
  fill(0);
  textSize(50);

  if (cursorInHintZone) {
    fill(204, 85, 0);
    textSize(50);
    text("Подсказки:", 1200, 200 + 150+50);
    text(hintsCount, 1300, 250 + 150+50);
  }
}

void drawAttemptsCounter() {
  fill(0);
  textSize(50);
  text("Попытки:", 1200, 50 + 150);
  text(attempts, 1300, 100 + 150);

  if (attempts == 1) {
    fill(config.RED_COLOR);
    text("Последняя ", 1200, 150 + 150);
    text("попытка!", 1200, 150+150+50);
  }
}

void drawHintsCounter() {
  fill(0);
  textSize(50);
  text("Подсказки:", 1200, 200 + 150+50);
  text(hintsCount, 1300, 250 + 150+50);
}

void drawComPortInfo() {
  fill(0);
  textSize(20);
if(p == 1)  text("Порт: " + (comPort.isEmpty() ? "не выбран" : comPort), 50, 30);
  
  // Отображение состояния порта
  if (p == 1) {
    fill(0, 150, 0); // Зеленый для активного порта
    text("Статус: АКТИВЕН", 50, 60);
  } else {
    fill(150, 0, 0); // Красный для неактивного порта
    text("Статус: ОТКЛЮЧЕН", 50, 60);
  }
  
  // Подсказка по управлению
  fill(100);
  text("Управление: R - подключить порт, D - отключить порт", 50, 90);
}

void drawScore() {
  fill( 0);
  textSize(50);
  text("Счёт:", 1200 + 60, 50);
  text(score, 1300, 100);
}

void drawBonusProgress() {
  fill(100);
  textSize(20);
  text("Слов без подсказок: " + wordsWithoutHints + "/" + wordsForBonus, 1200, 300 + 150+50);
}

// ========== ОБРАБОТКА СОБЫТИЙ ==========
void serialEvent(Serial port) {
  // Проверяем, активен ли порт
  if (p != 1 || this.port != port) {
    return;
  }
  
  try {
    String data = port.readStringUntil('\n');
    if (data == null) return;

    data = data.trim();
    if (data.isEmpty()) return;

    // Проверка что данные содержат только цифры
    if (!data.matches("\\d+")) {
      println("Некорректные данные: " + data);
      return;
    }

    int inputValue = Integer.parseInt(data);

    // ИГНОРИРОВАТЬ ПОВТОРНЫЕ НАЖАТИЯ ТЕХ ЖЕ КНОПОК (только для действий, не для перемещения)
    if (inputValue == lastInputValue && inputValue != 0 && inputValue != 1 && inputValue != 2 && inputValue != 3 && inputValue != 4) {
      return;
    }

    lastInputValue = inputValue;

    // ПРОПУСКАТЬ ВВОД ВО ВРЕМЯ КУЛДАУНА (только для действий)
    if (inputCooldown > 0 && inputValue != 0 && inputValue != 1 && inputValue != 2 && inputValue != 3 && inputValue != 4) {
      return;
    }

    // ОБРАБОТАТЬ ТОЛЬКО ЕСЛИ ПРЕДЫДУЩИЙ ВВОД ОБРАБОТАН (только для действий)
    if (inputProcessed || inputValue == 0 || inputValue == 1 || inputValue == 2 || inputValue == 3 || inputValue == 4) {
      processInput(inputValue);
      if (inputValue != 0 && inputValue != 1 && inputValue != 2 && inputValue != 3 && inputValue != 4) {
        inputProcessed = false;
        inputCooldown = 10; // Кулдаун после нажатия
      } else {
        inputProcessed = true;
      }
    }
  }
  catch (NumberFormatException e) {
    println("Ошибка преобразования данных: " + e.getMessage());
  }
  catch (Exception e) {
    println("Неожиданная ошибка при чтении из порта: " + e.getMessage());
    // При ошибке чтения помечаем порт как неактивный
    p = 0;
  }
}

// ИЗМЕНЕНО: Добавлена система блокировки перемещения в меню
void processInput(int value) {
  if (value == 0) {
    // ДОБАВЛЕНО: Сброс блокировки меню при получении 0
    menuJoystickNeedsReset = false;
    c = 1;
    m = 1;
    isMoving = false;
    currentMoveDirection = 0;
    inputProcessed = true;
    return;
  }

  // ОСОБАЯ ОБРАБОТКА ДЛЯ ГЛАВНОГО МЕНЮ
  if (inMainMenu) {
    if (menuJoystickNeedsReset) {
      // Игнорируем ввод, пока джойстик не вернется в ноль
      return;
    }
    
    // Обрабатываем ввод и устанавливаем блокировку
    handleMenuInput(value);
    if (value == 1 || value == 2) {
      menuJoystickNeedsReset = true; // Блокируем до сброса
    }
    return;
  }

  // Остальная обработка для игрового режима...
  if (showGameOver) {
    handleGameOverInput(value);
    return;
  }

  if (showWinMessage) {
    handleWinScreenInput(value);
    return;
  }

  if (gameEnded) {
    return;
  }

  handleGameInput(value);
}

void handleMenuInput(int value) {
  switch(value) {
  case 1:
    moveMenuCursor(-1);  // Вверх
    break;
  case 2:
    moveMenuCursor(1);   // Вниз
    break;
  case 11:
    handleDifficultySelection();  // Выбор
    break;
  }
}

void handleWinScreenInput(int value) {
  switch (value) {
  case 3: // Влево
    winMenuOption = 0;
    break;
  case 4: // Вправо
    winMenuOption = 1;
    break;
  case 11: // Выбор
    if (winMenuOption == 0) {
      // Продолжить - начать новую игру
      startNewGame();
    } else if (winMenuOption == 1) {
      // Возврат в меню - сброс всех состояний игры
      resetToMainMenu();
    }
    break;
  }
}

// ========== ОБРАБОТКА МЕНЮ ПОРАЖЕНИЯ ==========
void handleGameOverInput(int value) {
  switch (value) {
  case 3: // Влево
    gameOverMenuOption = 0;
    break;
  case 4: // Вправо
    gameOverMenuOption = 1;
    break;
  case 11: // Выбор
    if (gameOverMenuOption == 0) {
      // Новая игра
      startNewGame();
    } else if (gameOverMenuOption == 1) {
      // Возврат в меню
      resetToMainMenu();
    }
    break;
  }
}

// ИСПРАВЛЕНО: Система перемещения курсора в игре
void handleGameInput(int value) {
  switch(value) {
  case 1: // Вверх
  case 2: // Вниз
  case 3: // Влево
  case 4: // Вправо
    // Устанавливаем направление движения
    currentMoveDirection = value;
    isMoving = true;

    // Немедленное перемещение при первом нажатии
    if (millis() - lastMoveTime >= config.MOVE_INTERVAL) {
      handleContinuousMove();
    }
    break;

  case 11: // Выбор
    if (cursorInHintZone) {
      useHint();
    } else {
      checkLetter();
    }
    break;
  }
}

void updateCursorPosition() {
  // Обновляем позицию курсора на основе выбранного индекса
  if (!cursorInHintZone) {
    updateCursorPositionFromIndex();
  }
}

// НОВАЯ ФУНКЦИЯ: Обновление позиции курсора на основе индекса буквы
void updateCursorPositionFromIndex() {
  int cols = 8; // Количество столбцов в сетке алфавита
  int row = selectedLetterIndex / cols;
  int col = selectedLetterIndex % cols;
  
  cursorX = config.ALPHABET_START_X + col * config.CURSOR_STEP;
  cursorY = config.CURSOR_START_Y + row * config.CURSOR_STEP;
  
  // Проверяем, что координаты не выходят за пределы сетки
  if (cursorY > 600) {
    cursorY = 600; // Максимальная Y-координата для последней строки
  }
}

// НОВАЯ ФУНКЦИЯ: Обновление индекса буквы на основе координат курсора
void updateSelectedLetterIndex() {
  int cols = 8; // Количество столбцов в сетке алфавита
  int col = (cursorX - config.ALPHABET_START_X) / config.CURSOR_STEP;
  int row = (cursorY - config.CURSOR_START_Y) / config.CURSOR_STEP;
  
  selectedLetterIndex = row * cols + col;
  
  // Проверяем, что индекс в пределах массива
  if (selectedLetterIndex < 0) {
    selectedLetterIndex = 0;
  } else if (selectedLetterIndex >= gameData.russianAlphabet.length) {
    selectedLetterIndex = gameData.russianAlphabet.length - 1;
  }
  
  // Дополнительная проверка: если курсор находится в позиции, где нет буквы
  // (например, в пустых ячейках последней строки), корректируем индекс
  if (row >= 4) { // 5-я строка (индексы с 32)
    if (col > 0) { // В 5-й строке только первая ячейка (буква "Я")
      selectedLetterIndex = 32; // Принудительно устанавливаем на букву "Я"
    }
  }
}

void moveCursor(int dx, int dy) {
  if (cursorInHintZone) {
    // Возврат из зоны подсказки в алфавит - на последнюю букву текущей строки
    cursorX =100; // Последний столбец
    cursorY = 200; // Первая строка (можно улучшить для запоминания строки)
    cursorInHintZone = false;
    updateSelectedLetterIndex();
    return;
  }

  int newX = cursorX + dx * config.CURSOR_STEP;
  int newY = cursorY + dy * config.CURSOR_STEP;

  // ПРОВЕРКА: Если движемся вправо и выходим за правую границу алфавита
  if (dx == 1 && newX > config.ALPHABET_END_X) {
    // Переходим в зону подсказки
    cursorX = config.HINT_ZONE_X;
    cursorY = config.HINT_ZONE_Y;
    cursorInHintZone = true;
    return;
  }

  // Проверка границ алфавитной сетки по X
  if (newX >= config.ALPHABET_START_X && newX <= config.ALPHABET_END_X) {
    cursorX = newX;
  }

  // Проверка границ алфавитной сетки по Y
  if (newY >= config.CURSOR_START_Y && newY <= 600) {
    cursorY = newY;
  }

  // Обновляем индекс выбранной буквы на основе новых координат
  updateSelectedLetterIndex();
  
  // Отладочная информация
  println("Курсор: X=" + cursorX + ", Y=" + cursorY + 
          ", Индекс=" + selectedLetterIndex + 
          ", Буква=" + gameData.russianAlphabet[selectedLetterIndex] +
          ", В зоне подсказки: " + cursorInHintZone);
}

// ========== СООБЩЕНИЯ О КОНЦЕ ИГРЫ ==========
void gameOver() {
  sendToPort('4'); // ЗАМЕНА: port.write на sendToPort
  gameEnded = true;
  showGameOver = true;
  showWinMessage = false;

  // Сброс подсказок только при поражении
  if (currentDifficulty != null) {
    if (currentDifficulty.level == config.EASY_LEVEL) {
      hintsCount = config.EASY_HINTS;
    } else if (currentDifficulty.level == config.NORMAL_LEVEL) {
      hintsCount = config.NORMAL_HINTS;
    } else if (currentDifficulty.level == config.HARD_LEVEL) {
      hintsCount = config.HARD_HINTS;
    }
  }

  // СБРОС СИСТЕМЫ ВВОДА ПРИ ПОРАЖЕНИИ
  inputProcessed = true;
  inputCooldown = 20;

  // ДОБАВЛЕНО: Сброс системы движения
  isMoving = false;
  currentMoveDirection = 0;

  // ДОБАВЛЕНО: Сброс состояния клавиш
  resetKeyboardState();

  println("Поражение! Подсказки сброшены до: " + hintsCount);
  attempts = config.MAX_ATTEMPTS;
  usedHintThisWord = false;
  wordsWithoutHints = 0;
}

void drawGameOverScreen() {
  background(config.BG_COLOR);
  fill(config.RED_COLOR);
  textSize(70);
  textAlign(CENTER, CENTER);
  text("ИГРА ОКОНЧЕНА", width/2, height/2 - 250);

  fill(5, 7, 62);
  textSize(50);
  text("слово:", width/2, height/2 - 150);

  String secretWord = "";
  for (int i = 0; i < gameData.wordLengths[currentWordIndex]; i++) {
    secretWord += gameData.dictionary[currentWordIndex][i];
  }
  fill(6, 113, 12);
  text(secretWord, width/2, height/2 - 80);

  fill(5, 7, 62);
  textSize(40);
  text("Ваш счёт: " + score, width/2, height/2 - 10);

  fill(5, 7, 62);
  textSize(50);

  // Опция "новая игра"
  if (gameOverMenuOption == 0) {
    fill(255, 0, 0); // Красный для выбранной опции
  } else {
    fill(5, 7, 62); // Синий для невыбранной
  }
  text("НОВАЯ ИГРА", width/2 - 200, height/2 + 50);

  // Опция "в меню"
  if (gameOverMenuOption == 1) {
    fill(255, 0, 0); // Красный для выбранной опции
  } else {
    fill(5, 7, 62); // Синий для невыбранной
  }
  text("В МЕНЮ", width/2 + 200, height/2 + 50);

  // Подсказка управления
  fill(100);
  textSize(20);
//  text("Используйте ← → для выбора и ⏎ для подтверждения", width/2, height/2 + 120);

  textAlign(LEFT, BASELINE);
}

void displayWinMessage() {
  background(config.BG_COLOR);
  fill(config.WIN_COLOR);
  textSize(70);
  textAlign(CENTER, CENTER);
  text("УГАДАНО СЛОВО:", width/2, height/2 - 200);

  String guessedWord = "";
  for (int i = 0; i < gameData.wordLengths[currentWordIndex]; i++) {
    guessedWord += gameData.hiddenDisplay[currentWordIndex][i];
  }
  fill(146, 222, 9);
  text(guessedWord, width/2, height/2 - 100);

  fill(5, 7, 62);
  textSize(40);
  text("Ваш счёт: " + score, width/2, height/2 - 30);

  fill(5, 7, 62);
  textSize(50);

  // Опция "продолжить"
  if (winMenuOption == 0) {
    fill(255, 0, 0); // Красный для выбранной опции
  } else {
    fill(5, 7, 62); // Синий для невыбранной
  }
  text("ПРОДОЛЖИТЬ", width/2 - 200, height/2 + 50);

  // Опция "в меню"
  if (winMenuOption == 1) {
    fill(255, 0, 0); // Красный для выбранной опции
  } else {
    fill(5, 7, 62); // Синий для невыбранной
  }
  text("В МЕНЮ", width/2 + 200, height/2 + 50);

  // Подсказка управления
  fill(100);
  textSize(20);
 // text("Используйте ← → для выбора и ⏎ для подтверждения", width/2, height/2 + 120);

  textAlign(LEFT, BASELINE);
}

// ДОБАВЛЕНО: Улучшенная обработка клавиатуры
void keyPressed() {
  // Защита от быстрых повторных нажатий
  if (millis() - lastKeyPressTime < config.KEY_COOLDOWN) {
    return;
  }

  // ДОБАВЛЕНО: Управление портом с клавиатуры
  if (key == 'r' || key == 'R') {
    // R для принудительного подключения порта
    connectPort();
    lastKeyPressTime = millis();
    return;
  }
  
  if (key == 'd' || key == 'D') {
    // D для принудительного отключения порта
    disconnectPort();
    lastKeyPressTime = millis();
    return;
  }

  // Устанавливаем флаги нажатых клавиш
  switch(keyCode) {
  case UP:
    keyUpPressed = true;
    if (inMainMenu) {
      moveMenuCursor(-1);
      lastCursorMoveTime = millis();
    } else {
      processInput(1);
    }
    break;
  case DOWN:
    keyDownPressed = true;
    if (inMainMenu) {
      moveMenuCursor(1);
      lastCursorMoveTime = millis();
    } else {
      processInput(2);
    }
    break;
  case LEFT:
    keyLeftPressed = true;
    processInput(3);
    break;
  case RIGHT:
    keyRightPressed = true;
    processInput(4);
    break;
  case ENTER:
  case RETURN:
    keyEnterPressed = true;
    processInput(11);
    break;
  case ' ':
  case 'h':
  case 'H':
    // Пробел или H для подсказки
    if (!inMainMenu && !showWinMessage && !showGameOver) {
      useHint();
    }
    break;
  }
  lastKeyPressTime = millis();
}

// ДОБАВЛЕНО: Обработка отпускания клавиш
void keyReleased() {
  switch(keyCode) {
  case UP:
    keyUpPressed = false;
    break;
  case DOWN:
    keyDownPressed = false;
    break;
  case LEFT:
    keyLeftPressed = false;
    break;
  case RIGHT:
    keyRightPressed = false;
    break;
  case ENTER:
  case RETURN:
    keyEnterPressed = false;
    break;
  }
  
  // ДОБАВЛЕНО: Проверяем, остались ли нажатые клавиши движения
  handleKeyboardInput();
}
