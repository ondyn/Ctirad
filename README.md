# ctirad

Smart Caravan

# serial protocol
header: 0xDEED
footer: 0XBEEF

tablet - Arduino

-> start/stop charging



# data
- vnitřní teplota
- vnější teplota
- teplota v lednici
- teplota v odpadní nádrži
- GPS tracker
- ovládání topení/ventilace
- ovládání ventilátoru
- pohybový alarm- kamera
- měření proudu baterie
- měření napětí baterií
- 4G modem
- OBD
- měření soláru
- hladina pitné vody (ultrazvukově) - IIC
- hladina odpadní vody

spotřeba:
- automaticky uspat/probudit při napětí < Vbatmin
- inteligentní nabíjení tabletu

připojení
- datová SIM - LTE
- vypnout data při detekci hotspotu
- na wifi/hotspotu zálohování dat
- šetření dat při LTE

arduino:
- teploměr - venkovní/vnitřní/lednice/odpadní nádrž
- osvitoměr-luxmetr BH1750, nebo z kamery-obrázku?
- měření baterie
	- 2x napětí
	- 1x proud
- pitná voda
- odpadní voda
- truma- LIN protocol?
- solar charger-rs232?
- stav 230
- stav 12
- ovladani 12v
- ovladani pumpy
- hladina pitné vody + alarm při dopouštění
- <- baterie tabletu start/stop nabíjení

Data
||||
|-|-|-|
teplota|DS18B20|11 bit (0.125°C)
luxmetr|BH1750|16 bit
napětí|arduino ADC|10 bit
proud|arduino ADC|10 bit
odpadní voda|4 piny
pitná voda|4 piny
pitná voda - ultrazvuk|2 piny IIC|16bit
start/stop nabíjení|0/1|1 bit
230v indikace
zap/vyp 12v
zap/vyp pumpa
12v stav


usb hub
1. arduino
2. solar charger
3. uart proximity (mozna jen pres usb)
4. truma?


Pin 1: 12 V -- OFF bílá
Pin 2: 12 V -- ON hnědá
Pin 3: 12 V -- Check zelená
Pin 4: Mains žlutá
Pin 5: -- Sensor WB šedá
Pin 6: + Sensor WB růžová
Pin 7: SB(starter batt) modrá
Pin 8: Pump
Pin 9: Light
Pin10: AUX


electroblock
1 x         shunt consumer
2 šedá    negative leasure batt
3 x   
4 x        shunt battery
5 zelená 12V indicator
6 žlutá    mains indicator
7 x
8 modrá?  + starter batt
9 hnědá    12V ON
10 x
11 růžová    + leasure batt
12 bílá        12V off

pumpe switch
1 bílá
2 hnědá
3zelená
4 žlutá
5 šedá
6 růžová
7 modrá
8 červená



akcelerometr přes uart-usb do palubního androidu, tam aplikace na vyčítání


tablet: umax 8C LTE
8 octa core 1.6GHz, Unisoc SC9863a
gpu PowerVR Rogue GE8322
java heap 192MB
2GB RAM
32BG ROM
board sp9863a_1h10_32b
800x1280 px
189.46 ppi
Anroid Q 10, api 29


./emulator -list-avds
./emulator  -avd 10.1_WXGA_Tablet_API_29 -qemu -serial /dev/tty.usbserial-1410



differential ADC:
hello guys!
I searched about this issue but didn’t find any library! but we can use differential ADC by using registers. the code is here:
```
uint8_t low, high;

void setup() {
  Serial.begin(9600);
  ADMUX = 1<<REFS0;                //choose AVCC for reference ADC voltage
  ADCSRA = (1<<ADEN)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0);    //enable ADC, ADC frequency=16MB/128=125kHz (set of prescaler)
  ADCSRB = 0x00;
}

void loop() {
  Serial.println(read_differential());
  delay(100);
}

int16_t read_differential() {
  ADMUX |= (1<<MUX4);             //set MUX5:0 to 010000. Positive Differential Input => ADC0 and Negative Differential Input => ADC1 with Gain 1x. 
           
  ADCSRA |= (1<<ADSC);            //start conversion
  while (ADCSRA & (1<<ADSC));     //wait untill coversion be completed(ADSC=0);

  low = ADCL;
  high = ADCH;
  return (high << 8) | low;       //arrange (ADCH ADCL) to a 16 bit and return it's value.
}

```
this code can read differential ADC by A0(posetive) and A1(negetive) pins and show it on Serial Monitor. these registers are explained in the “ATmega 2560 datasheet”. so you can change differential mode or differential with gain or single ended mode by changing MUX5:0 bits according to “table 26-4” at the datasheet.
But I see a problem! if we use differential mode or differential with gain, the out number is about 512(499 or 502) not 1023 :o ! but if use single ended mode the out number can be 1023.
Can any one tell me what’s the problem??? :o I guess its because of its analog inner opamps. but not sure!


https://forum.arduino.cc/u/Robin2
Robin2
květen 2018

amin_mdn: But I see a problem! if we use differential mode or differential with gain, the out number is about 512(499 or 502) not 1023

Is that because it can range from -512 to +511 ?
...R


https://forum.arduino.cc/u/amin_mdn
amin_mdn
květen 2018

Is that because it can range from -512 to +511 ?

yes you’re right 


I corrected my code and it works 


```
uint8_t low, high;

void setup() {
  Serial.begin(9600);
  ADMUX = 1<<REFS0;                //choose AVCC for reference ADC voltage
  ADCSRA = (1<<ADEN)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0);    //enable ADC, ADC frequency=16MB/128=125kHz (set of prescaler)
  ADCSRB = 0x00;
}

void loop() {
  
  Serial.println(read_differential());
  delay(100);
}

//int16_t read_differential() {
int read_differential() {
  ADMUX |= (1<<MUX4);             //set MUX5:0 to 010000. Positive Differential Input => ADC0 and Negative Differential Input => ADC1 with Gain 1x.
           
  ADCSRA |= (1<<ADSC);            //start conversion
  while (ADCSRA & (1<<ADSC));     //wait untill coversion be completed(ADSC=0);

  low = ADCL;
  high = ADCH;
  if(high & (1<<1)){              //in differential mode our value is between -512 to 511 (not 0 to 1023). it means we have 9 bits and 10th bit is the sign bit. but because 
    high |= 0b11111110;           //the number of ADCH and ADCL bits are 10, for signed number we dont have repeatition of 1 in "ADCH" byte.
  }                               //so we repeat 1 Ourselves.:) 
  return (high << 8) | low;       //arrange (ADCH ADCL) to a 16 bit and return it's value.
}

```
I saw about 3 bit errors at a same positive and negative voltage but its negligible 

Place a 0.1-µF capacitor near the V+ pin on the INA1x9-Q1. Additional capacitance may be required for applications with noisy supply voltages.

# links
https://www.ti.com/lit/ds/symlink/ina214.pdf?ts=1636621930308&ref_url=https%253A%252F%252Fwww.ti.com%252Fsitesearch%252Fdocs%252Funiversalsearch.tsp%253FlangPref%253Den-US%2526searchTerm%253DINA214%2526nr%253D209  
https://github.com/muccc/WomoLIN
https://conference.c3w.at/media/Camper_Easterhegg2019.pdf  


# USB  
\+ červený  
\- černý  
D+ zelený  
D- bílý  

# Protocol
header: 0xDE AD
footer: 0xBE EF

nebo CBOR, BSON



