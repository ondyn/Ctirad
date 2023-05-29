#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define DEBUG

// BLE server name
#define BLE_SERVER_NAME "Ctirad hub"

// Service UUID
#define ENVIRONMENTAL_SENSING 0x181A
#define COMMAND_CHARACTERISTIC_UUID "d3dce6c6-4f16-4f03-9098-69bb542682ce"
#define SENDING_INTERVAL_CHARACTERISTIC_UUID "5745929c-5d2b-4e1b-b007-0913c3a86589"

// Characteristic UUID
#define TEMPERATURE 0x2A6E
#define TEMPERATURE2 "ca788368-1012-4adf-8442-135e3a041058"
#define HUMIDITY 0x2A6F
#define CHARGING_SWITCH "3fc4597a-627c-4999-97f0-fa9c9d04a5f8"

// descriptors UUID
#define CHARACTERISTIC_USER_DESCRIPTION 0x2901
#define CLIENT_CHARACTERISTIC_CONFIGURATION 0x2902

float temp;
float tempF;
float hum;

// Timer variables
unsigned long lastTime = 0;
unsigned long timerDelay = 1000;

int devicesConnected = 0;

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

// Temperature Characteristic
BLECharacteristic temperatureCharacteristic(BLEUUID((uint16_t)TEMPERATURE), BLECharacteristic::PROPERTY_NOTIFY);

// T2
BLECharacteristic t2(BLEUUID(TEMPERATURE2), BLECharacteristic::PROPERTY_NOTIFY);

// Humidity Characteristic
BLECharacteristic humidityCharacteristic(BLEUUID((uint16_t)HUMIDITY), BLECharacteristic::PROPERTY_NOTIFY);
// Sending interval Characteristic
BLECharacteristic sendingIntervalCharacteristic(SENDING_INTERVAL_CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_WRITE);

BLECharacteristic chargingSwitchCharacteristic(BLEUUID(CHARGING_SWITCH), BLECharacteristic::PROPERTY_WRITE);

// Setup callbacks onConnect and onDisconnect
class MyServerCallbacks : public BLEServerCallbacks
{
     void onConnect(BLEServer *pServer)
     {
          devicesConnected++;
          BLEDevice::startAdvertising(); // restart advertising
#ifdef DEBUG
          Serial.print("Device connected. Now there are ");
          Serial.print(devicesConnected);
          Serial.println(" devices connected.");
#endif
     };
     void onDisconnect(BLEServer *pServer)
     {
          devicesConnected--;
          pServer->startAdvertising(); // restart advertising
#ifdef DEBUG
          Serial.print("Device disconnected. Now there are ");
          Serial.print(devicesConnected);
          Serial.println(" devices connected.");
#endif
     }
};

class MyCallbacks : public BLECharacteristicCallbacks
{
     // při příjmu zprávy proveď následující
     void onWrite(BLECharacteristic *pCharacteristic)
     {
          if (pCharacteristic->getUUID().toString() == BLEUUID(SENDING_INTERVAL_CHARACTERISTIC_UUID).toString())
          {
               // načti přijatou zprávu do proměnné
               uint8_t *data = pCharacteristic->getData();
               timerDelay = (data[0] << 8) + data[1];
               // pokud není zpráva prázdná, vypiš její obsah
               // po znacích po sériové lince
               Serial.print("New interval=");
               Serial.println(timerDelay);
          }
          if (pCharacteristic->getUUID().toString() == BLEUUID(CHARGING_SWITCH).toString())
          {
               Serial.print("New charging switch cmd=");
               Serial.println(pCharacteristic->getData()[0]);
          }
     }
};

void setupCharacteristic(BLECharacteristic characteristic, std::string userDescription, BLEService *service)
{
     BLEDescriptor configDescriptor(BLEUUID((uint16_t)CLIENT_CHARACTERISTIC_CONFIGURATION));
     characteristic.addDescriptor(&configDescriptor);
     BLEDescriptor userDescriptor(BLEUUID((uint16_t)CHARACTERISTIC_USER_DESCRIPTION));
     userDescriptor.setValue(userDescription);
     characteristic.addDescriptor(&userDescriptor);
     service->addCharacteristic(&characteristic);
}

void setup()
{
     // Start serial communication
     Serial.begin(115200);

     // Init the BLE Device
     BLEDevice::init(BLE_SERVER_NAME);

     // Create the BLE Server
     BLEServer *pServer = BLEDevice::createServer();
     pServer->setCallbacks(new MyServerCallbacks());

     // Create the BLE Service
     BLEService *sensorService = pServer->createService(BLEUUID((uint16_t)ENVIRONMENTAL_SENSING));

     // Create BLE Characteristics and Create a BLE Descriptor
     // Temperature
     BLEDescriptor temperatureConfigDescriptor(BLEUUID((uint16_t)CLIENT_CHARACTERISTIC_CONFIGURATION));
     temperatureCharacteristic.addDescriptor(&temperatureConfigDescriptor);
     BLEDescriptor temperatureUserDescriptor(BLEUUID((uint16_t)CHARACTERISTIC_USER_DESCRIPTION));
     temperatureUserDescriptor.setValue("T1");
     temperatureCharacteristic.addDescriptor(&temperatureUserDescriptor);
     sensorService->addCharacteristic(&temperatureCharacteristic);

     // T2
     BLEDescriptor t2ConfigDescriptor(BLEUUID((uint16_t)CLIENT_CHARACTERISTIC_CONFIGURATION));
     t2.addDescriptor(&t2ConfigDescriptor);
     BLEDescriptor t2UserDescriptor(BLEUUID((uint16_t)CHARACTERISTIC_USER_DESCRIPTION));
     t2UserDescriptor.setValue("T2");
     t2.addDescriptor(&t2UserDescriptor);
     sensorService->addCharacteristic(&t2);

     // Humidity
     BLEDescriptor humidityConfigDescriptor(BLEUUID((uint16_t)CLIENT_CHARACTERISTIC_CONFIGURATION));
     humidityCharacteristic.addDescriptor(&humidityConfigDescriptor);
     BLEDescriptor humidityUserDescriptor(BLEUUID((uint16_t)CHARACTERISTIC_USER_DESCRIPTION));
     humidityUserDescriptor.setValue("H1");
     humidityCharacteristic.addDescriptor(&humidityUserDescriptor);
     sensorService->addCharacteristic(&humidityCharacteristic);

     // Sending interval
     BLEDescriptor sendingIntervalConfigDescriptor(BLEUUID((uint16_t)CLIENT_CHARACTERISTIC_CONFIGURATION));
     sendingIntervalCharacteristic.addDescriptor(&sendingIntervalConfigDescriptor);
     sendingIntervalCharacteristic.setCallbacks(new MyCallbacks());
     sensorService->addCharacteristic(&sendingIntervalCharacteristic);

     // Charging switch
     BLEService *commandService = pServer->createService(BLEUUID(COMMAND_CHARACTERISTIC_UUID));

     BLEDescriptor chargingSwitchConfigDescriptor(BLEUUID((uint16_t)CLIENT_CHARACTERISTIC_CONFIGURATION));
     chargingSwitchCharacteristic.addDescriptor(&chargingSwitchConfigDescriptor);
     // BLEDescriptor chargingSwitchUserDescriptor(BLEUUID((uint16_t)CHARACTERISTIC_USER_DESCRIPTION));
     // chargingSwitchUserDescriptor.setValue("Charging switch");
     // chargingSwitchCharacteristic.addDescriptor(&chargingSwitchUserDescriptor);
     chargingSwitchCharacteristic.setCallbacks(new MyCallbacks());
     commandService->addCharacteristic(&chargingSwitchCharacteristic);

     // Start the service
     sensorService->start();
     commandService->start();

     // Start advertising
     pServer->getAdvertising()->start();
     Serial.println("Waiting a client connection to notify...");
}

void loop()
{
     if (devicesConnected)
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

               static char temperatureCTemp[6];
               dtostrf(temp, 6, 2, temperatureCTemp);
               // Set temperature Characteristic value and notify connected client
               // temperatureCharacteristic.setValue(temperatureCTemp);

               int16_t nTempOut = millis();
               temperatureCharacteristic.setValue((uint8_t *)&nTempOut, 2);
               temperatureCharacteristic.notify();
               t2.setValue((uint8_t *)&nTempOut, 2);
               t2.notify();

               Serial.print("Temperature Celsius: ");
               Serial.print(temp);
               Serial.print(" ºC");

               // Notify humidity reading from BME
               static char humidityTemp[6];
               dtostrf(hum, 6, 2, humidityTemp);
               // Set humidity Characteristic value and notify connected client
               // humidityCharacteristic.setValue(humidityTemp);

               humidityCharacteristic.setValue((uint8_t *)&nTempOut, 2);

               humidityCharacteristic.notify();
               Serial.print(" - Humidity: ");
               Serial.print(hum);
               Serial.println(" %");

               lastTime = millis();
          }
     }
}