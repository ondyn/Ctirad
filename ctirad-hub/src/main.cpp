/*********
  Rui Santos
  Complete instructions at https://RandomNerdTutorials.com/esp32-ble-server-client/
  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files.
  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
*********/

#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
// #include <Wire.h>
// #include <Adafruit_Sensor.h>
// #include <Adafruit_BME280.h>

// Default Temperature is in Celsius
// Comment the next line for Temperature in Fahrenheit
#define temperatureCelsius

#define DEBUG

// BLE server name
#define bleServerName "Ctirad hub"

// Adafruit_BME280 bme; // I2C

float temp;
float tempF;
float hum;

// Timer variables
unsigned long lastTime = 0;
unsigned long timerDelay = 1000;

int deviceConnected = 0;
bool oldDeviceConnected = false;

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/
#define SERVICE_UUID "91bad492-b950-4226-aa2b-4ede9fa42f59"

// Temperature Characteristic and Descriptor
#ifdef temperatureCelsius
// BLECharacteristic bmeTemperatureCelsiusCharacteristics("cba1d466-344c-4be3-ab3f-189f80dd7518", BLECharacteristic::PROPERTY_NOTIFY);
BLECharacteristic bmeTemperatureCelsiusCharacteristics(BLEUUID((uint16_t)0x2A6E), BLECharacteristic::PROPERTY_NOTIFY);
BLEDescriptor bmeTemperatureCelsiusDescriptor(BLEUUID((uint16_t)0x2902));
#else
BLECharacteristic bmeTemperatureFahrenheitCharacteristics("f78ebbff-c8b7-4107-93de-889a6a06d408", BLECharacteristic::PROPERTY_NOTIFY);
BLEDescriptor bmeTemperatureFahrenheitDescriptor(BLEUUID((uint16_t)0x2902));
#endif

// Humidity Characteristic and Descriptor
// BLECharacteristic bmeHumidityCharacteristics("ca73b3ba-39f6-4ab3-91ae-186dc9577d99", BLECharacteristic::PROPERTY_NOTIFY);
BLECharacteristic bmeHumidityCharacteristics(BLEUUID((uint16_t)0x2A6F), BLECharacteristic::PROPERTY_NOTIFY);
BLEDescriptor bmeHumidityDescriptor(BLEUUID((uint16_t)0x2902));

BLECharacteristic bmeSetIntervalCharacteristics("5745929c-5d2b-4e1b-b007-0913c3a86589", BLECharacteristic::PROPERTY_WRITE);
BLEDescriptor bmeSetIntervalDescriptor(BLEUUID((uint16_t)0x2902));

// Setup callbacks onConnect and onDisconnect
class MyServerCallbacks : public BLEServerCallbacks
{
     void onConnect(BLEServer *pServer)
     {
          deviceConnected++;
          BLEDevice::startAdvertising();
#ifdef DEBUG
          Serial.print("Device connected. Now there are ");
          Serial.print(deviceConnected);
          Serial.println(" devices connected.");
#endif
     };
     void onDisconnect(BLEServer *pServer)
     {
          deviceConnected--;
          pServer->startAdvertising(); // restart advertising
#ifdef DEBUG
          Serial.print("Device disconnected. Now there are ");
          Serial.print(deviceConnected);
          Serial.println(" devices connected.");
#endif
     }
};

class MyCallbacks : public BLECharacteristicCallbacks
{
     // při příjmu zprávy proveď následující
     void onWrite(BLECharacteristic *pCharacteristic)
     {
          // načti přijatou zprávu do proměnné
          uint8_t *data = pCharacteristic->getData();
          timerDelay = (data[0] << 8) + data[1];
          // pokud není zpráva prázdná, vypiš její obsah
          // po znacích po sériové lince
          Serial.print("New interval=");
          Serial.println(timerDelay);
     }
};

// void initBME(){
//   if (!bme.begin(0x76)) {
//     Serial.println("Could not find a valid BME280 sensor, check wiring!");
//     while (1);
//   }
// }

void setup()
{
     // Start serial communication
     Serial.begin(115200);

     // Init BME Sensor
     // initBME();

     // Create the BLE Device
     BLEDevice::init(bleServerName);

     // Create the BLE Server
     BLEServer *pServer = BLEDevice::createServer();
     pServer->setCallbacks(new MyServerCallbacks());

     // Create the BLE Service
     // BLEService *bmeService = pServer->createService(SERVICE_UUID);
     BLEService *bmeService = pServer->createService(BLEUUID((uint16_t)0x181A));

// Create BLE Characteristics and Create a BLE Descriptor
// Temperature
#ifdef temperatureCelsius
     bmeService->addCharacteristic(&bmeTemperatureCelsiusCharacteristics);
     bmeTemperatureCelsiusDescriptor.setValue("BME temperature Celsius");
     bmeTemperatureCelsiusCharacteristics.addDescriptor(&bmeTemperatureCelsiusDescriptor);
#else
     bmeService->addCharacteristic(&bmeTemperatureFahrenheitCharacteristics);
     bmeTemperatureFahrenheitDescriptor.setValue("BME temperature Fahrenheit");
     bmeTemperatureFahrenheitCharacteristics.addDescriptor(&bmeTemperatureFahrenheitDescriptor);
#endif

     BLEDescriptor outdoorHumidityDescriptor(BLEUUID((uint16_t)0x2901));
     BLEDescriptor outdoorTemperatureDescriptor(BLEUUID((uint16_t)0x2901));
     outdoorHumidityDescriptor.setValue("Humidity 0 to 100%");
     outdoorTemperatureDescriptor.setValue("Temperature -40-60°C");
     bmeHumidityCharacteristics.addDescriptor(&outdoorHumidityDescriptor);
     bmeTemperatureCelsiusCharacteristics.addDescriptor(&outdoorTemperatureDescriptor);

     // Humidity
     bmeService->addCharacteristic(&bmeHumidityCharacteristics);
     bmeHumidityDescriptor.setValue("BME humidity");
     bmeHumidityCharacteristics.addDescriptor(&bmeHumidityDescriptor);

     bmeService->addCharacteristic(&bmeSetIntervalCharacteristics);
     bmeSetIntervalDescriptor.setValue("Interval");
     bmeSetIntervalCharacteristics.addDescriptor(&bmeSetIntervalDescriptor);

     bmeSetIntervalCharacteristics.setCallbacks(new MyCallbacks());

     // Start the service
     bmeService->start();

     // Start advertising
     BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
     pAdvertising->addServiceUUID(SERVICE_UUID);
     pServer->getAdvertising()->start();
     Serial.println("Waiting a client connection to notify...");
}

void loop()
{
     if (deviceConnected)
     {
          if ((millis() - lastTime) > timerDelay)
          {
               // Read temperature as Celsius (the default)
               // temp = bme.readTemperature();
               temp = millis() / 100;
               // Fahrenheit
               tempF = 1.8 * temp + 32;
               // Read humidity
               // hum = bme.readHumidity();
               hum = millis() / 10;

// Notify temperature reading from BME sensor
#ifdef temperatureCelsius
               static char temperatureCTemp[6];
               dtostrf(temp, 6, 2, temperatureCTemp);
               // Set temperature Characteristic value and notify connected client
               // bmeTemperatureCelsiusCharacteristics.setValue(temperatureCTemp);

               int16_t nTempOut = millis();
               bmeTemperatureCelsiusCharacteristics.setValue((uint8_t *)&nTempOut, 2);
               bmeTemperatureCelsiusCharacteristics.notify();
               Serial.print("Temperature Celsius: ");
               Serial.print(temp);
               Serial.print(" ºC");
#else
               static char temperatureFTemp[6];
               dtostrf(tempF, 6, 2, temperatureFTemp);
               // Set temperature Characteristic value and notify connected client
               bmeTemperatureFahrenheitCharacteristics.setValue(temperatureFTemp);
               bmeTemperatureFahrenheitCharacteristics.notify();
               Serial.print("Temperature Fahrenheit: ");
               Serial.print(tempF);
               Serial.print(" ºF");
#endif

               // Notify humidity reading from BME
               static char humidityTemp[6];
               dtostrf(hum, 6, 2, humidityTemp);
               // Set humidity Characteristic value and notify connected client
               // bmeHumidityCharacteristics.setValue(humidityTemp);

               bmeHumidityCharacteristics.setValue((uint8_t *)&nTempOut, 2);

               bmeHumidityCharacteristics.notify();
               Serial.print(" - Humidity: ");
               Serial.print(hum);
               Serial.println(" %");

               lastTime = millis();
          }
     }
}