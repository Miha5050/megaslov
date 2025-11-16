#include <EncButton.h>
int delm = 0;
const int sw_pin = A3;

bool m2 = 0;
bool e = 0;
bool e2 = 0;
Button b(sw_pin);
#include <GyverJoy.h>
GyverJoy jx(A2);
GyverJoy jx1(A1);

#define LED_PIN A0
#define LED_NUM 6
#include <FastLED.h>

// Пьезоэлемент на ШИМ-пине
const int buzzerPin = 5; // ШИМ пин
int volume = 20; // Громкость по умолчанию (0-255)

CRGB leds[LED_NUM];
CRGB targetColor;
CRGB targetColor2;
CRGB mode;
int transitionSpeed = 5;
uint32_t tmr;

// Мелодии для успеха - разные длительности для 1 и 3
int successMelody1[] = {262, 330, 392, 523}; // Короткая мелодия для 1
int successMelody3[] = {262, 330, 392, 523, 392, 330}; // Длинная мелодия для 3

// Мелодии для неудачи - разные длительности для 2 и 4
int failureMelody2[] = {220, 196, 175}; // Короткая мелодия для 2
int failureMelody4[] = {220, 196, 175, 147, 131}; // Длинная мелодия для 4

// Длительности нот
int successNoteDurations1[] = {200, 200, 200, 400}; // Для символа 1
int successNoteDurations3[] = {300, 300, 300, 400, 300, 500}; // Для символа 3 (длиннее)

int failureNoteDurations2[] = {300, 300, 500}; // Для символа 2
int failureNoteDurations4[] = {400, 400, 400, 400, 800}; // Для символа 4 (длиннее)

// Функция установки громкости
void setVolume(int vol) {
  volume = constrain(vol, 0, 255);
}

// Воспроизведение ноты с громкостью
void playNote(int frequency, int duration, int vol) {
  vol = constrain(vol, 0, 255);
  analogWrite(buzzerPin, vol);
  tone(buzzerPin, frequency, duration);
  delay(duration);
  analogWrite(buzzerPin, 0);
  noTone(buzzerPin);
}

void playMelody(int melody[], int noteDurations[], int notesCount, int vol) {
  for (int i = 0; i < notesCount; i++) {
    playNote(melody[i], noteDurations[i], vol);
    delay(noteDurations[i] * 0.3); // Короткая пауза между нотами
  }
}

// Отдельные функции для каждого типа мелодий
void playSuccessMelody1() {
  playMelody(successMelody1, successNoteDurations1, 4, volume);
}

void playSuccessMelody3() {
  playMelody(successMelody3, successNoteDurations3, 6, volume);
}

void playFailureMelody2() {
  playMelody(failureMelody2, failureNoteDurations2, 3, volume);
}

void playFailureMelody4() {
  playMelody(failureMelody4, failureNoteDurations4, 5, volume);
}

void setup() {
  pinMode(buzzerPin, OUTPUT);
  analogWrite(buzzerPin, 0); // Изначально выключено
  
 // attachInterrupt(0, isr, FALLING);
  Serial.begin(115200);
  jx.calibrate();
  jx.deadzone(100);
  jx.exponent(GJ_LINEAR);
  jx1.calibrate();
  jx1.deadzone(100);
  jx1.exponent(GJ_LINEAR);
  FastLED.addLeds<WS2812, LED_PIN, GRB>(leds, LED_NUM);
  FastLED.setMaxPowerInVoltsAndMilliamps(5, 500);
  FastLED.setBrightness(50);
  randomSeed(analogRead(7));
  for (int i = 0; i < LED_NUM; i++) {
    leds[i] = CRGB::Black;
  }
  targetColor = CRGB(random(0, 255), random(0, 255), random(0, 255));
  targetColor2 = CRGB(0, 0, 0);
}

void isr() {
  b.pressISR();
}

unsigned long previousMillis = 0;
const unsigned long interval = 40; 
const unsigned long interval2 = 20; // Интервал 20 мс
int currentLedIndex = 0; // Текущий светодиод для последовательного обновления (для delm == 0)

void del() {
  unsigned long currentMillis = millis();
  
  if (delm == 0) {
    if (currentMillis - previousMillis >= interval) {
      previousMillis = currentMillis;
      
      bool allReached = true;
      // Плавное изменение цвета всех светодиодов к целевому значению
      for (int i = 0; i < LED_NUM; i++) {
        if (leds[i] != targetColor) {
          // Плавное изменение каждого канала цвета (R, G, B)
          if (leds[i].r < targetColor.r) leds[i].r = min(leds[i].r + transitionSpeed, targetColor.r);
          else if (leds[i].r > targetColor.r) leds[i].r = max(leds[i].r - transitionSpeed, targetColor.r);
          if (leds[i].g < targetColor.g) leds[i].g = min(leds[i].g + transitionSpeed, targetColor.g);
          else if (leds[i].g > targetColor.g) leds[i].g = max(leds[i].g - transitionSpeed, targetColor.g);
          if (leds[i].b < targetColor.b) leds[i].b = min(leds[i].b + transitionSpeed, targetColor.b);
          else if (leds[i].b > targetColor.b) leds[i].b = max(leds[i].b - transitionSpeed, targetColor.b);
          allReached = false;  // Если хотя бы один цвет не достиг цели
        }
      }
      FastLED.show();
      
      // Если все светодиоды достигли целевого цвета, выбираем новый цвет
      if (allReached) {
        targetColor = CRGB(random(0, 255), random(0, 255), random(0, 255));
      }
    }
  }
  
  if (delm == 1) {
    if (currentMillis - previousMillis >= interval2) {
      previousMillis = currentMillis;
      
      bool allReached = true;
      // Плавное изменение цвета всех светодиодов к целевому значению
      for (int i = 0; i < LED_NUM; i++) {
        if (leds[i] != targetColor2) {
          // Плавное изменение каждого канала цвета (R, G, B)
          if (leds[i].r < targetColor2.r) leds[i].r = min(leds[i].r + transitionSpeed, targetColor2.r);
          else if (leds[i].r > targetColor2.r) leds[i].r = max(leds[i].r - transitionSpeed, targetColor2.r);
          if (leds[i].g < targetColor2.g) leds[i].g = min(leds[i].g + transitionSpeed, targetColor2.g);
          else if (leds[i].g > targetColor2.g) leds[i].g = max(leds[i].g - transitionSpeed, targetColor2.g);
          if (leds[i].b < targetColor2.b) leds[i].b = min(leds[i].b + transitionSpeed, targetColor2.b);
          else if (leds[i].b > targetColor2.b) leds[i].b = max(leds[i].b - transitionSpeed, targetColor2.b);
          allReached = false;  // Если хотя бы один цвет не достиг цели
        }
      }
      FastLED.show();
      
      // Если все светодиоды достигли целевого цвета, переключаем режим
      if (allReached) {
        if (m2 == 0) {
          targetColor2 = CRGB(0, 0, 0);
          m2 = !m2;
        } else {
          targetColor2 = mode;
          m2 = !m2;
        }
      }
    }
  }
}


void loop() {
  static uint32_t lastUpdate = 0;
  if (millis() - lastUpdate > 50) { // Обновление каждые 30мс
    del();
    lastUpdate = millis();
  }
  
  b.tick();
  
  // Всегда проверяем, есть ли данные в Serial
  if (Serial.available() > 0) {
   // delay(100);
    char receivedChar = Serial.read();
    
    // Регулировка громкости
    if (receivedChar == '+') {
      volume = min(volume + 30, 255);
      Serial.print("Volume: ");
      Serial.println(volume);
      return;
    } else if (receivedChar == '-') {
      volume = max(volume - 30, 0);
      Serial.print("Volume: ");
      Serial.println(volume);
      return;
    }
    
    // Обработка полученного символа
    if (receivedChar == '1') {
      e2 = 1;
      e = 0;  // Сбрасываем e при установке e2
      targetColor2 = CRGB(0, 255, 0);
      mode = CRGB(0, 255, 0);
      delm = 1;
      playSuccessMelody1(); // Короткая мелодия успеха
    } else if (receivedChar == '0') {
      e2 = 1;
      e = 0;  // Сбрасываем e при установке e2
      targetColor2 = CRGB(255, 0, 0);
      mode = CRGB(255, 0, 0);
      delm = 1;
      playFailureMelody2(); // Короткая мелодия неудачи
    } else if (receivedChar == '2') {
      e2 = 1;
      e = 0;  // Сбрасываем e при установке e2
      targetColor2 = CRGB(255, 0, 0);
      mode = CRGB(255, 0, 0);
      delm = 1;
      playFailureMelody2(); // Короткая мелодия неудачи
    } else if (receivedChar == '4') {
      e = 1;
      e2 = 0;  // Сбрасываем e2 при установке e
      targetColor2 = CRGB(255, 0, 0);
      mode = CRGB(255, 0, 0);
      delm = 1;
      playFailureMelody4(); // Длинная мелодия неудачи
    } else if (receivedChar == '3') {
      e = 1;
      e2 = 0;  // Сбрасываем e2 при установке e
      targetColor2 = CRGB(0, 255, 0);
      mode = CRGB(0, 255, 0);
      delm = 1;
      playSuccessMelody3(); // Длинная мелодия успеха
    }
  }
  
  // Обработка кнопки
  if (b.click() || b.hold()) {
    if (e2 == 1) {
      e2 = 0;  // Сброс e2 при нажатии кнопки
      delm = 0; // Возврат в обычный режим
    }
    Serial.println(11);
  }
  
  // ИСПРАВЛЕНИЕ: Убрана блокировка джойстиков по флагу e
  // Обработка джойстиков всегда, независимо от состояния e и e2
  jx.tick();
  jx1.tick();
  if (jx.value() >= 220 && jx1.value() == 0) {
    Serial.println(3);
  }
  if (jx.value() <= -220 && jx1.value() == 0) {
    Serial.println(4);
  }
  if (jx.value() == 0 && jx1.value() >= 220) {
    Serial.println(2);
  }
  if (jx.value() == 0 && jx1.value() <= -220) {
    Serial.println(1);
  }
  if (jx.value() == 0 && jx1.value() == 0) {
    Serial.println(0);
  }
  
  // Отдельная обработка для сброса режима e
  if ((b.click() || b.hold()) && e == 1) {
    e = 0;
    delm = 0;
    Serial.println("11");
  }
}