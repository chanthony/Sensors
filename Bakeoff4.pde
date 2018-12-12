import java.util.ArrayList;
import java.util.Collections;
import ketai.sensors.*;


KetaiSensor sensor;

float cursorX, cursorY;
float light = 0; 
float proxSensorThreshold = 20; //you will need to change this per your device.

// Side to side rotation
float zero_angle;
float current_angle;

// Tilt
float zero_tilt;
float current_tilt;

float current_force;
float zero_force;

// Which of the two boxes have been selected. 0 or 1
int current_cursor = 0;

// A countdown for when to swap the cursor
int cursor_swap = 60;

// Which stage we're in
int current_stage = 1;

private class Target
{
  int target = 0;
  int action = 0;
}

int trialCount = 5; //this will be set higher for the bakeoff
int trialIndex = 0;
ArrayList<Target> targets = new ArrayList<Target>();

int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
int countDownTimerWait = 0;

void setup() {
  size(2300, 1300); //you can change this to be fullscreen
  frameRate(60);
  sensor = new KetaiSensor(this);
  sensor.start();
  orientation(LANDSCAPE);

  rectMode(CENTER);
  ellipseMode(RADIUS);
  textFont(createFont("Arial", 40)); //sets the font to Arial size 20
  textAlign(CENTER);

  for (int i=0; i<trialCount; i++)  //don't change this!
  {
    Target t = new Target();
    t.target = ((int)random(1000))%4;
    t.action = ((int)random(1000))%2;
    targets.add(t);
    println("created target with " + t.target + "," + t.action);
  }

  Collections.shuffle(targets); // randomize the order of the button;

}

void draw() {
  int index = trialIndex;

  //uncomment line below to see if sensors are updating
  //println("light val: " + light +", cursor accel vals: " + cursorX +"/" + cursorY);
  background(80); //background is light grey
  noStroke(); //no stroke

  countDownTimerWait--;

  //text("Trial #: " + trialIndex, 50, 50);

  if (startTime == 0)
    startTime = millis();

  if (index>=targets.size() && !userDone)
  {
    userDone=true;
    finishTime = millis();
  }

  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, 50);
    text("User took " + nfc((finishTime-startTime)/1000f/trialCount, 1) + " sec per target", width/2, 150);
    return;
  }

  if(current_stage == 1){

    stroke(255);

    // Draw the squares
    if (targets.get(index).target==0)
      fill(0, 255, 0);
    else
      noFill();
    ellipse(0,0,500,500);
    //rect(width/2 - 100 - 300, height/2 - 200 - 100, 300, 300);

    if (targets.get(index).target==1)
      fill(0, 255, 0);
    else
      noFill();
    ellipse(width - 300,0,500,500);
    //rect(width/2 - 100 + 300, height/2 - 200  - 100, 300, 300);

    if (targets.get(index).target==2)
      fill(0, 255, 0);
    else
      noFill();
    ellipse(0,height - 200,500,500);

    if (targets.get(index).target==3)
      fill(0, 255, 0);
    else
      noFill();
    ellipse(width - 300,height - 200,500,500);

    noStroke();

    fill(180);
  }

  if(current_stage == 2){
    // Draw left circle
    if (targets.get(index).action==0)
      fill(0, 255, 0);
    else{
      fill(180);
    }
    ellipse(width/2 - 100 - 400, height/2 - 200 + 100, 300, 300);
    
    if (targets.get(index).action==1)
      fill(0, 255, 0);
    else{
      fill(180);
    }
    ellipse(width/2 - 100 + 400, height/2 - 200 + 100, 300, 300);

    // Draw cursor circle
    noFill();
    stroke(255,0,0);
    strokeWeight(8);
    ellipse(width/2 - 100 + (400 * pow(-1, current_cursor + 1)), height/2 - 200 + 100, 400, 400);

    //Swap cursor every second
    if(cursor_swap <= 0){
      cursor_swap = 60;
      current_cursor = (current_cursor + 1) % 2;
    }
    else{
      cursor_swap--;
    }

    strokeWeight(1);
  }

  countDownTimerWait = countDownTimerWait - 1;
}

void onLightEvent(float v) //this just updates the light value
{
  //println(v);
}

void onOrientationEvent(float x, float y, float z, long time, int accuracy){
  current_angle = y;
  current_tilt = z;

  int index = trialIndex;

  if(countDownTimerWait > 0){
    return;
  }

  // If twisted enough
  if(current_stage == 1 && abs(current_tilt - zero_tilt) > 15 && abs(current_angle - zero_angle) > 10){
    println("TILTED");
    // Tilted to the right
    if (zero_angle - current_angle > 0){
      // Tilted down
      if (zero_tilt - current_tilt > 0){
        if (targets.get(index).target == 1){
          println("Selected 1");
          current_stage = 2;  
        }
        else{
          println("Mistake in stage 1");
          if (trialIndex>0){
            trialIndex--; //move back one trial as penalty!
          }
        }
      }
      // Tilted up
      else{
        if (targets.get(index).target == 3){
          println("Selected 3");
          current_stage = 2;
        }
        else{
          println("Mistake in stage 1");
          if (trialIndex>0){
            trialIndex--; //move back one trial as penalty!
          }
        }
      }
    }
    else{
      // Tilted down
      if (zero_tilt - current_tilt > 0){
        if (targets.get(index).target == 0){
          println("Selected 0");
          current_stage = 2;  
        }
        else{
          println("Mistake in stage 1");
          if (trialIndex>0){
            trialIndex--; //move back one trial as penalty!
          }
        }
      }
      // Tilted up
      else{
        if (targets.get(index).target == 2){
          println("Selected 2");
          current_stage = 2;
        }
        else{
          println("Mistake in stage 1");
          if (trialIndex>0){
            trialIndex--; //move back one trial as penalty!
          }
        }
      }
    }

    countDownTimerWait = 30;
  }
}

void onProximityEvent(float d, long a, int b){
  // Only use the proximity sensor in the second stage
  if(current_stage == 1){
    return;
  }

  // Avoid repeated rapid mistakes
  if(countDownTimerWait > 0){
    println(countDownTimerWait);
    return;
  }

  int index = trialIndex;


  // If the sensor is covered
  if(d == 0.0){
    println("GUESSED");
    // Selected the correct option
    if(current_cursor == targets.get(index).action){
      println("Stage 2 correct");
      trialIndex++;
      if(trialIndex < targets.size()){
        current_cursor = targets.get(trialIndex).action;
        cursor_swap = 60;
      }
      current_stage = 1;
    }
    else{
      println("MISTAKE IN STAGE 2");
      if(trialIndex > 0) trialIndex--;
      current_stage = 1;
    }
  }
}

void mousePressed(){
  zero_angle = current_angle;
  zero_tilt = current_tilt;
}
