import grafica.*;
import controlP5.*;
import java.util.*;
import http.requests.*;
import mqtt.*;

GPlot plot;
GPointsArray points;
MQTTClient client;
ControlP5 cp5;
Button btn;
Textfield txt;
Numberbox num_box;
ScrollableList sl;

PFont f1, f2,f3,f4,f5,f6,f7,f8;

color retro_green = color(34,163,159);
color retro_grey = color(216,217,207);
color retro_light_grey = color(238,238,238);
color retro_dark_grey = color(67,66,66);
color broken_white = color(247,247,247);
color retro_grey_2 = color(227,228,218);
color retro_light_blue = color(95, 157, 247);

// SPR Graph Variable
float x0 = 580;         // x0 of the graph
float y0 = 924;         // y0 of the graph
float xAxis = 1000;     // the length of the graph axis
float yAxis = 500;      // the length of the graph ordinate
float xRange = 90;      // maximum incident angle
float yRange = 1;       // maximum total pixel value (normalized)

// Device communication
String serverIP = "http://192.168.0.198/";
String command;

// Driver
int additional_step = 1;
int step_mode = 1;
int total_step = 598;

int imgRes = 320*240;
// Image Data to be displayed
int[] picArray = new int[77000];   // array to store CAM image pixel value
// Image
// Window
int boundUp = 0;
int boundDown = 320;
String upper_win = "0";
String lower_win = "0";
// SPR Data
float[] brightnessVal = new float[6372];
float[] incidentAngle = new float[6372];

// Enhance 
int enhanceThreshold = 0;
// Laser
String slctdDir; // variable to store direction
String slctdMode; // variable to store mode
// Graph
int offset = 0;


// Button ifs
boolean get_visual_active = false;
boolean draw_spr_graph_active = false;

// Draw Interface Layout-------------------------------------------------------------------------
void drawInterfaceBackground() {
  background(broken_white);
  smooth();
  
  // control box
  fill(retro_green); rectMode(CORNER); noStroke(); rect(0,0, 310,1024);
  stroke(0); strokeWeight(1); line(310,0 ,310,1024);
  
  // "SPR GUI" text
  textFont(f1); fill(0); textAlign(CENTER); text("SPR SENSOR GUI", 15,34, 281,32);
  
  // line
  stroke(0); strokeWeight(4); line(38,70 ,38+235,70);
}

void drawSetupBox(){
  //"SET UP" text
  textFont(f2); fill(0); textAlign(CENTER); text("CONFIG", 119-5,88, 73+10,25);
  
  // laser box
  fill(retro_light_grey); stroke(0); strokeWeight(1); rectMode(CORNER); rect(38,118, 235,268,5);
  //"LASER" text
  textFont(f3); fill(0); textAlign(CENTER); text("LASER", 124-3,121, 68,26);
  // on-off box
  fill(retro_light_grey); stroke(0); strokeWeight(1); rectMode(CORNER); rect(55,150, 201,46);
  //"ON" text
  textFont(f5); fill(0); textAlign(CENTER); text("ON", 84,164, 28,20);
  //"OFF" text
  textFont(f5); fill(0); textAlign(CENTER); text("OFF", 199,164, 33,17);
  
  // move laser box
  fill(retro_light_grey); stroke(0); strokeWeight(1); rectMode(CORNER); rect(55,200, 201,115);
  //"Direction" text
  textFont(f5); fill(0); textAlign(CORNER); text("ROTATION", 82,218, 78,26);
  //"Step Count" text
  textFont(f5); fill(0); textAlign(CORNER); text("ANGLE", 82,245, 82,26);
  // homing box
  fill(retro_light_grey); stroke(0); strokeWeight(1); rectMode(CORNER); rect(55,319, 201,46);
  
  // camera box
  fill(retro_light_grey); stroke(0); strokeWeight(1); rectMode(CORNER); rect(38,393, 235,262,5);
  //"CAMERA" text
  textFont(f3); fill(0); textAlign(CENTER); text("CAMERA", 113,397, 90,26);
  // get visual box
  fill(retro_light_grey); stroke(0); strokeWeight(1); rectMode(CORNER); rect(55,426, 201,45);
  // window box
  fill(retro_light_grey); stroke(0); strokeWeight(1); rectMode(CORNER); rect(55,475, 201,92);
  //"Set Window" text
  textFont(f4); fill(0); textAlign(CENTER); text("SET WINDOW", 96,478, 122,23);
  //"Upper" text
  textFont(f6); fill(0); textAlign(CENTER); text("UPPER", 70,511, 52,17);
  //"Lower" text
  textFont(f6); fill(0); textAlign(CENTER); text("LOWER", 72,537, 52,17);
  // enhance box
  fill(retro_light_grey); stroke(0); strokeWeight(1); rectMode(CORNER); rect(55,571, 201,63);
  //"Enhance" text
  textFont(f4); fill(0); textAlign(CENTER); text("ENHANCE", 109,574, 92,22);
  //"Value" text
  textFont(f6); fill(0); textAlign(CENTER); text("VALUE", 74,607, 52,17);
}

void drawGetData(){
  //"GET SPR DATA" text
  textFont(f2); fill(0); textAlign(CENTER); text("DATA ACQUISITION", 39-3,674, 232+7,26);
  // draw box
  fill(retro_light_grey); stroke(0); strokeWeight(1); rectMode(CORNER); rect(38,703, 235,257,5);
  
  // setup box
  fill(retro_light_grey); stroke(0); strokeWeight(1); rectMode(CORNER); rect(55,719, 201,115);
  //"Step Mode" text
  textFont(f5); fill(0); textAlign(CORNER); text("STEP MODE", 82,737, 82,19);
  //"Max Angle" text
  textFont(f5); fill(0); textAlign(CORNER); text("MAX ANGLE", 82,764, 91,19);
  
  // draw graph box
  fill(retro_light_grey); stroke(0); strokeWeight(1); rectMode(CORNER); rect(55,838, 201,45);
  // save data box
  fill(retro_light_grey); stroke(0); strokeWeight(1); rectMode(CORNER); rect(55,887, 201,45);
}

void drawGetSPRGraph(){
  //"DRAW SPR Graph" text
  textFont(f2); fill(0); textAlign(CENTER); text("DRAW SPR GRAPH", 58-3,768, 195+7,26);
  
  // main box
  fill(retro_light_grey); stroke(0); strokeWeight(1); rectMode(CORNER); rect(38,797, 235,137,5);
  // draw box
  fill(retro_light_grey); stroke(0); strokeWeight(1); rectMode(CORNER); rect(55,807, 201,48);
  // offset box
  fill(retro_light_grey); stroke(0); strokeWeight(1); rectMode(CORNER); rect(55,859, 201,63);
  //"OFFSET" text
  textFont(f4); fill(0); textAlign(CENTER); text("OFFSET", 109,862, 92,22);
  //"Value" text
  textFont(f6); fill(0); textAlign(CENTER); text("VALUE", 74,894, 52,17);
}

void drawDataDisplay(){
  // Draw Background
  //fill(broken_white); stroke(0); strokeWeight(1); rectMode(CORNER); rect(331,20, 1569,300);
  //fill(broken_white); stroke(0); strokeWeight(1); rectMode(CORNER); rect(331,330, 1569,730);
  
  // CAM Visual
  textFont(f2); fill(0); textAlign(CENTER); text("CAM VISUAL", 1035,30, 161,25);
  fill(retro_dark_grey); stroke(0); strokeWeight(1); rectMode(CORNER); rect(951,64, 321,241);
  
  // SPR Graph
  textFont(f2); fill(0); textAlign(CENTER); text("SPR GRAPH", 1035,341, 161,25);
  
}

// Data Processing Functions---------------------------------------------------------------------------
// Calculate total step for data acquisition
int calculateStep(int _stepMode, int _angle) {
  int _totalStep = round((_stepMode*64/11.25)*(_angle-30));
  return _totalStep;
}

// Function to display CAM Visual
void drawPicture(int _boundUp, int _boundDown){
  for(int j=0; j<imgRes; j++){
    if(j/320<_boundUp || j/320>_boundDown){
      set((j%320)+952, (j/320)+65, color(0));
    }
    else{
      if(picArray[j] >= enhanceThreshold){
        set((j%320)+952, (j/320)+65, color(picArray[j]));
      }
      else if(picArray[j] < enhanceThreshold){
        set((j%320)+952, (j/320)+65, color(0));
      }
    }
  }
}

// function to normalize data
void normalizeData(){
  float maxData = 0;
  float minData = 1000000000;
  
  for(int j=0; j<total_step;j++){
    if(brightnessVal[j] > maxData){
      maxData = brightnessVal[j];
    }
    if(brightnessVal[j] < minData){
      minData = brightnessVal[j];
    }
  }
  //println("minData: "+minData+", maxData: "+maxData);
  for(int j = 0; j<total_step; j++){
     brightnessVal[j] = (brightnessVal[j]-minData)/(maxData-minData);
   }
}

// Widgets Set Up--------------------------------------------------------------------------------
void drawWidgets(){
  // On-Off Switch
  cp5.addToggle("on_off")
    .setPosition(122,165)
    .setSize(66,17)
    .setColorBackground(retro_dark_grey)
    .setColorActive(retro_grey)
    .setColorForeground(color(0))
    .setMode(ControlP5.SWITCH)
    .getState()
    ;
  cp5.getController("on_off").getCaptionLabel().setColor(color(retro_light_grey));
  
  
  // Move Laser Button
  cp5.addButton("move_laser")
    .setPosition(91,277)
    .setSize(131,24)
    .setFont(f5)
    .setColorBackground(retro_grey)
    .setColorActive(color(55))
    .setColorForeground(retro_grey_2)
    ;
  cp5.getController("move_laser").getCaptionLabel().setText("Move Laser").setColor(color(0));
  
  // Step Count Text Box
  cp5.addTextfield("step_count")
     .setPosition(170,245)
     .setSize(64,19)
     .setFont(f5)
     .setFocus(true)
     .setColorBackground(broken_white)
     .setColorActive(color(0))
     .setColorForeground(color(100))
     .setColor(color(0))
     ;
  cp5.getController("step_count").getCaptionLabel().setFont(f7).setColor(color(retro_light_grey));
  
  //Direction List
  String dir_list[]={"CW", "CCW"};
  sl = cp5.addScrollableList("select")
    .setPosition(170, 217)
    .setSize(64, 75)
    .addItems(dir_list)
    .setItemHeight(22)
    .setBarHeight(20)
    .setBackgroundColor(color(190))
    .setColorBackground(retro_dark_grey)
    .setColorActive(color(95, 157, 247))
    .setFont(f6)
    .close()
    ;
  sl.getCaptionLabel().getStyle().marginLeft = 1;
  sl.getCaptionLabel().getStyle().marginTop = 3; 
  cp5.getController("select").addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      switch(theEvent.getAction()) {
        case(ControlP5.ACTION_RELEASE): 
        slctdDir = cp5.getController("select").getLabel();
        }
    }
  }
  );
  
  // Homing Button
  cp5.addButton("homing")
    .setPosition(91,331)
    .setSize(131,24)
    .setFont(f5)
    .setColorBackground(retro_grey)
    .setColorActive(color(55))
    .setColorForeground(retro_grey_2)
    ;
  cp5.getController("homing").getCaptionLabel().setText("Homing").setColor(color(0));
  
  // Get Visual Button
  cp5.addButton("get_visual")
    .setPosition(91,437)
    .setSize(131,24)
    .setFont(f5)
    .setColorBackground(retro_grey)
    .setColorActive(color(55))
    .setColorForeground(retro_grey_2)
    ;
  cp5.getController("get_visual").getCaptionLabel().setText("Get Visual").setColor(color(0));
  
  // Upper Window Text Box
  cp5.addTextfield("upper_window")
     .setPosition(133,508)
     .setSize(48,19)
     .setFont(f5)
     .setFocus(true)
     .setColorBackground(broken_white)
     .setColorActive(color(0))
     .setColorForeground(color(100))
     .setColor(color(0))
     ;
  cp5.getController("upper_window").getCaptionLabel().setFont(f7).setColor(color(retro_light_grey));
  
  // Set Upper Window Button
  cp5.addButton("set_upper_window")
    .setPosition(194,509)
    .setSize(39,17)
    .setFont(f8)
    .setColorBackground(retro_grey)
    .setColorActive(color(55))
    .setColorForeground(retro_grey_2)
    ;
  cp5.getController("set_upper_window").getCaptionLabel().setText("Set").setColor(color(0));
  
  // Set Lower Window Button
  cp5.addButton("set_lower_window")
    .setPosition(194,535)
    .setSize(39,17)
    .setFont(f8)
    .setColorBackground(retro_grey)
    .setColorActive(color(55))
    .setColorForeground(retro_grey_2)
    ;
  cp5.getController("set_lower_window").getCaptionLabel().setText("Set").setColor(color(0));
  
  // Lower Window Text Box
  cp5.addTextfield("lower_window")
     .setPosition(133,534)
     .setSize(48,19)
     .setFont(f5)
     .setFocus(true)
     .setColorBackground(broken_white)
     .setColorActive(color(0))
     .setColorForeground(color(100))
     .setColor(color(0))
     ;
  cp5.getController("lower_window").getCaptionLabel().setFont(f7).setColor(color(retro_light_grey));
  
  // Enhance Text Box
  cp5.addTextfield("enhance_val")
     .setPosition(133,604)
     .setSize(48,19)
     .setFont(f5)
     .setFocus(true)
     .setColorBackground(broken_white)
     .setColorActive(color(0))
     .setColorForeground(color(100))
     .setColor(color(0))
     ;
  cp5.getController("enhance_val").getCaptionLabel().setFont(f7).setColor(color(retro_light_grey));
  
  // Set Enhance Button
  cp5.addButton("set_enhance")
    .setPosition(194,605)
    .setSize(39,17)
    .setFont(f8)
    .setColorBackground(retro_grey)
    .setColorActive(color(55))
    .setColorForeground(retro_grey_2)
    ;
  cp5.getController("set_enhance").getCaptionLabel().setText("Set").setColor(color(0));
  
  // Max Angle Text Box
  cp5.addTextfield("max_angle")
     .setPosition(172,763)
     .setSize(61,19)
     .setFont(f5)
     .setFocus(true)
     .setColorBackground(broken_white)
     .setColorActive(color(0))
     .setColorForeground(color(100))
     .setColor(color(0))
     ;
  cp5.getController("max_angle").getCaptionLabel().setFont(f7).setColor(color(retro_light_grey));
  
  // Get SPR Data Button
  cp5.addButton("get_spr_data")
    .setPosition(91,796)
    .setSize(131,24)
    .setFont(f5)
    .setColorBackground(retro_grey)
    .setColorActive(color(55))
    .setColorForeground(retro_grey_2)
    ;
  cp5.getController("get_spr_data").getCaptionLabel().setText("Start").setColor(color(0));
  
  // Step Mode Dropdwon
  String mode_list[]={"1", "1/2", "1/4", "1/8", "1/16"};
  sl = cp5.addScrollableList("mode")
    .setPosition(170, 735)
    .setSize(64, 75)
    .addItems(mode_list)
    .setItemHeight(22)
    .setBarHeight(20)
    .setBackgroundColor(color(190))
    .setColorBackground(retro_dark_grey)
    .setColorActive(color(95, 157, 247))
    .setFont(f6)
    .close()
    ;
  sl.getCaptionLabel().getStyle().marginLeft = 1;
  sl.getCaptionLabel().getStyle().marginTop = 3; 
  cp5.getController("mode").addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      switch(theEvent.getAction()) {
        case(ControlP5.ACTION_RELEASE): 
        slctdMode = cp5.getController("mode").getLabel();
        }
    }
  }
  );
  
  // Draw SPR Graph Button
  cp5.addButton("draw_spr_graph")
    .setPosition(91,849)
    .setSize(131,24)
    .setFont(f5)
    .setColorBackground(retro_grey)
    .setColorActive(color(55))
    .setColorForeground(retro_grey_2)
    ;
  cp5.getController("draw_spr_graph").getCaptionLabel().setText("Draw Graph").setColor(color(0));
  
  // Save Data Button
  cp5.addButton("save_data")
    .setPosition(91,898)
    .setSize(131,24)
    .setFont(f5)
    .setColorBackground(retro_grey)
    .setColorActive(color(55))
    .setColorForeground(retro_grey_2)
    ;
  cp5.getController("save_data").getCaptionLabel().setText("Save Data").setColor(color(0));
  
  // Offset Text Box
  //cp5.addTextfield("offset_val")
  //   .setPosition(133,891)
  //   .setSize(48,19)
  //   .setFont(f5)
  //   .setFocus(true)
  //   .setColorBackground(broken_white)
  //   .setColorActive(color(0))
  //   .setColorForeground(color(100))
  //   .setColor(color(0))
  //   ;
  //cp5.getController("offset_val").getCaptionLabel().setFont(f7).setColor(color(retro_light_grey));
  
  // Set Offset Button
  //cp5.addButton("set_offset")
  //  .setPosition(194,891)
  //  .setSize(39,17)
  //  .setFont(f8)
  //  .setColorBackground(retro_grey)
  //  .setColorActive(color(55))
  //  .setColorForeground(retro_grey_2)
  //  ;
  //cp5.getController("set_offset").getCaptionLabel().setText("Set").setColor(color(0));
  
}

// Setting Widget Function-----------------------------------------------------------------------
// funtion for led on-off button
void on_off(){
  boolean led_state = cp5.get(Toggle.class,"on_off").getState();
  //println(led_state);
  if (led_state == false){
    println("Laser OFF");
    command = "laserOff:";
    
    GetRequest get = new GetRequest(serverIP+command);
    get.send();
    println("Command sent");
    println("Reponse Content: " + get.getContent());
  }
  else if (led_state == true){
    println("Laser ON");
    command = "laserOn:";
    
    GetRequest get = new GetRequest(serverIP+command);
    get.send();
    println("Command sent");
    println("Reponse Content: " + get.getContent());
  }
}
// function for move laser button
void move_laser(){
  String step_txt = cp5.get(Textfield.class,"step_count").getText();
  int step_val = round((step_mode*64/11.25)*(int(step_txt)));
  step_txt = Integer.toString(step_val);
  String dir_val = "null";
  println("-- Moving laser");
  println("Direction: " + slctdDir);
  println("Step Count: " + step_txt);
  
  if(slctdDir == "CW"){
    //dir_val = "0";        // old
    dir_val = "1";        // new
  }
  else if(slctdDir == "CCW"){
    //dir_val = "1";        // old
    dir_val = "0";        // new
  }
  
  command = "moveStepper"+":"+dir_val+","+step_txt+";";
  
  GetRequest get = new GetRequest(serverIP+command);
  get.send();
  println("Command sent");
  println("Reponse Content: " + get.getContent());      
}
// function for homing button
void homing(){
  println("--Homing Laser");
  command = "setReference:";
  
  GetRequest get = new GetRequest(serverIP+command);
  get.send();
  println("Command sent");
  println("Reponse Content: " + get.getContent());
}
// function for get visual button
void get_visual(){
  println("--Getting Visual from ESP32 CAM");
  command = "getPicture:";
  
  GetRequest get = new GetRequest(serverIP+command);
  get.send();
  println("Command sent");
  println("Reponse Content: ");
  
  delay(2000);
  String content = new String(get.getContent());
  println(content);
  for(int j=9; j< content.length(); j++){
    int brightness = int(content.charAt(j));
      picArray[j-9] = brightness;
  }
  get_visual_active = true;
}
// function for window button
void set_upper_window(){
  upper_win = cp5.get(Textfield.class,"upper_window").getText();
  boundUp = int(upper_win);
  println("--Setting upper window to " + upper_win);
}
void set_lower_window(){
  lower_win = cp5.get(Textfield.class,"lower_window").getText();
  boundDown = int(lower_win);
  println("--Setting upper window to " + lower_win);
  command = "window"+":"+upper_win+","+lower_win+";";
  
  GetRequest get = new GetRequest(serverIP+command);
  get.send();
  println("Command sent");
  println("Reponse Content: " + get.getContent());
}
// function for enhance button
void set_enhance(){
  String enhance_val_txt = cp5.get(Textfield.class,"enhance_val").getText();
  enhanceThreshold = int(enhance_val_txt);
  println("--Setting upper window to " + enhance_val_txt);
  command = "enhance"+":"+enhance_val_txt+";";
  
  GetRequest get = new GetRequest(serverIP+command);
  get.send();
  println("Command sent");
  println("Reponse Content: " + get.getContent());
}

// function for get spr data button (need works)
void get_spr_data(){
  String max_angle = cp5.get(Textfield.class,"max_angle").getText();
  
  String stp_mode_txt = "null";
  if(slctdMode == "1"){
    stp_mode_txt = "1";
  }
  else if(slctdMode == "1/2"){
    stp_mode_txt = "2";
  }
  else if(slctdMode == "1/4"){
    stp_mode_txt = "4";
  }
  else if(slctdMode == "1/8"){
    stp_mode_txt = "8";
  }
  else if(slctdMode == "1/16"){
    stp_mode_txt = "16";
  }
  
  println("--Getting SPR Data from Sensor");
  command = "getSPRData:" + stp_mode_txt + "," + max_angle + ";";
  
  
  GetRequest get = new GetRequest(serverIP+command);
  get.send();
  println("Command sent");
  println("Reponse Content: " + get.getContent());
  
  total_step = calculateStep(step_mode, int(max_angle));
  
  //SPR data 
  String content = get.getContent();
  String[] brightDataArray = split(content,",");
  for(int j=3; j<=total_step+2; j++){
    brightnessVal[j-3] = float(brightDataArray[j]);
  }
  normalizeData();
  
  for(int j=0; j<total_step; j++){
     float phi = (30+j*11.25/(step_mode*64))*PI/180;
     float beta = asin(sin(phi-PI/4)/1.517);
     float theta = (beta+PI/4)*180/PI;
     incidentAngle[j] = theta;
  }
}
// function for draw spr graph button
void draw_spr_graph(){
  println("--Drawing SPR Graph");
  points = new GPointsArray(total_step-1);
  for (int j = 1; j < total_step-1; j++) {
    points.add(incidentAngle[j], brightnessVal[j]);
  }
  plot.setPoints(points);
  draw_spr_graph_active = true;
}
// function for setting spr graph offset button
void set_offset(){
  draw_spr_graph_active = false;
  String offset_val_txt = cp5.get(Textfield.class,"offset_val").getText();
  offset = int(offset_val_txt);
  println("--Setting Graph Offset to " + offset_val_txt);
  println("Offset value:",offset);
  points = new GPointsArray(total_step-1-offset);
  for (int j = 1; j < total_step-1-offset; j++) {
    points.add(incidentAngle[j], brightnessVal[j]);
  }
  plot.setPoints(points);
  draw_spr_graph_active = true;
}

void save_data(){
  int _day = day();    // Values from 1 - 31
  int _month = month();  // Values from 1 - 12
  int _year = year();   // 2003, 2004, 2005, etc.
  int _second = second();  // Values from 0 - 59
  int _minute = minute();  // Values from 0 - 59
  int _hour = hour();    // Values from 0 - 23
  
  String dateTime = String.valueOf(_year)+String.valueOf(_month)+String.valueOf(_day)+
                      String.valueOf(_hour)+String.valueOf(_minute)+String.valueOf(_second);
  
  String savePath = "C:/Users/User/Documents/Kuliah/Tugas Akhir/SPR Data/"+ dateTime;
  //println(savePath);
  Table dataTable = new Table();
  dataTable.addColumn("Theta");
  dataTable.addColumn("Total Pixels (Normalized)");
  for(int j=0; j<total_step; j++){
    dataTable.addRow();
    float _phi=(30+j*11.25/(step_mode*64))*PI/180;
    float _beta=asin(sin(_phi-PI/4)/1.517);
    float _theta=(_beta+PI/4)*180/PI;
    dataTable.setFloat(j,"Theta",_theta);
    dataTable.setFloat(j,"Total Pixels",brightnessVal[j]);
  }
  saveTable(dataTable,savePath);
  println("Saving table at "+savePath);
}
// ---------------------------------------------------------------------------------------------
void setup() { 
  // interface
  size(1940,1080); 
  surface.setResizable(true);
  
  cp5 = new ControlP5(this);
  plot = new GPlot(this);
  
  surface.setTitle("SPR Sensor GUI");
  // font
  f1 = createFont("Arial Bold",28,true);
  f2 = createFont("Arial Bold",20,true);
  f3 = createFont("Arial Bold",18,true);
  f4 = createFont("Arial Bold",14,true);
  f5 = createFont("Arial",14,true);
  f6 = createFont("Arial",12,true);
  f7 = createFont("Arial",1,true);
  f8 = createFont("Arial",11,true);

  drawInterfaceBackground();
  drawSetupBox();
  drawGetData();
  drawWidgets();
  drawDataDisplay();
  
  for(int j=0;j<imgRes;j++){
     picArray[j] = 0;
   }
  for(int j=0;j<6372;j++){
     brightnessVal[j] = 0;
     incidentAngle[j] = 0;
   }
  
  plot = new GPlot(this);
  plot.setPos(600, 400);
  plot.setDim(900, 450);
  // Set the plot title and the axis labels
  //plot.setTitleText("A very simple example");
  plot.setTitleText("SPR Curve");
  plot.getXAxis().setAxisLabelText("Incident Angle ("+char(186)+")");
  plot.getYAxis().setAxisLabelText("Pixel Value (Normalized)");
  plot.setPointColor(color(100, 100, 255));
  plot.activatePanning();
  plot.activateZooming(1.1, CENTER, CENTER);
  
}
// ---------------------------------------------------------------------------------------------
public void draw(){
  drawInterfaceBackground();
  drawSetupBox();
  drawGetData();
  drawDataDisplay();
  
  plot.beginDraw();
  plot.drawBackground();
  plot.drawBox();
  plot.drawXAxis();
  plot.drawYAxis();
  plot.drawTopAxis();
  plot.drawRightAxis();
  plot.drawTitle();
  plot.endDraw();
  
  if(slctdMode == "1"){
    step_mode = 1;
  }
  else if(slctdMode == "1/2"){
    step_mode = 2;
  }
  else if(slctdMode == "1/4"){
    step_mode = 4;
  }
  else if(slctdMode == "1/8"){
    step_mode = 8;
  }
  else if(slctdMode == "1/16"){
    step_mode = 16;
  }
  
  if(get_visual_active == true){      // drawing cam visual
    drawPicture(boundUp, boundDown);
  }
  if(draw_spr_graph_active == true){  // drawing spr curve
    plot.beginDraw();
    plot.drawBackground();
    plot.drawBox();
    plot.drawXAxis();
    plot.drawYAxis();
    plot.drawTopAxis();
    plot.drawRightAxis();
    plot.drawTitle();
    plot.drawPoints();
    plot.endDraw();
  }
  
}
