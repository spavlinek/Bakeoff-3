import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 125; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;

int numLetters = 26; // Number of letters in the alphabet
char[] letters = new char[numLetters];
float radius;
PVector center;

float apoButtonWidth;
float apoButtonHeight;
float apoButtonX;
float apoButtonY;

float spaceButtonWidth;
float spaceButtonHeight;
float spaceButtonX;
float spaceButtonY;

float deleteButtonWidth;
float deleteButtonHeight;
float deleteButtonX;
float deleteButtonY;

//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing
 
  orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
  size(800, 800); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 24)); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes
  
  radius = sizeOfInputArea/2 - 10; // Radius of the circle
  center = new PVector(width/2, height/2); // Center of the circle
  
  // Populate the letters array with the alphabet
  for (int i = 0; i < numLetters; i++) {
    letters[i] = char('a' + i);
  }
  apoButtonWidth = 30;
  apoButtonHeight = 20;
  apoButtonX = center.x - apoButtonWidth / 2;
  apoButtonY = center.y + 15;
  
  spaceButtonWidth = 30;
  spaceButtonHeight = 20;
  spaceButtonX = center.x - spaceButtonWidth / 2;
  spaceButtonY = center.y - 10;
  
  deleteButtonWidth = 30;
  deleteButtonHeight = 20;
  deleteButtonX = center.x - deleteButtonWidth / 2;
  deleteButtonY = center.y - deleteButtonHeight - 15;
  }

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(255); //clear background
  drawWatch(); //draw watch background
  fill(100);
  rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"
  if (finishTime!=0)
  {
    fill(128);
    textAlign(CENTER);
    text("Finished", 280, 150);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped +"|", 70, 140); //draw what the user has entered thus far 

    //draw very basic next button
    fill(255, 0, 0);
    rect(600, 600, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", 650, 650); //draw next label
  
  // Draw the letters around the circle
  float angleStep = TWO_PI / numLetters;
  float offset = radians(-90);
  int textSize;
  for (int i = 0; i < numLetters; i++) {
    float angle = i * angleStep;
    float x = center.x + radius * cos(angle + offset);
    float y = center.y + radius * sin(angle + offset);
    
    if (dist(mouseX, mouseY, x, y) < 5) { // If mouse is hovering over a letter
      fill(0, 255, 0); // Highlight the letter in green
      textSize = 20;
    } else {
      fill(0);
      textSize = 15;
    }
    textAlign(CENTER, CENTER);
    textSize(textSize);
    text(letters[i], x, y);
  }
  // Draw the delete button
  fill(255, 0, 0);
  rect(deleteButtonX, deleteButtonY, deleteButtonWidth, deleteButtonHeight);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(15);
  text("<<", center.x, deleteButtonY + deleteButtonHeight / 2);
  
  // Draw the space button
  fill(100, 149, 237);
  rect(spaceButtonX, spaceButtonY, spaceButtonWidth, spaceButtonHeight);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(15);
  text("└─┘", center.x, spaceButtonY + spaceButtonHeight / 2 + 5);
  textSize(24);
  
  // Draw the ' button
  fill(96, 130, 182);
  rect(apoButtonX, apoButtonY, apoButtonWidth, apoButtonHeight);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(15);
  text("'", center.x, apoButtonY + apoButtonHeight / 2 + 5);
  textSize(24);
  }
}

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

////my terrible implementation you can entirely replace
void mousePressed(){
  // Check if the mouse is hovering over any letter
  float angleStep = TWO_PI / numLetters;
  float offset = radians(-90);
  for (int i = 0; i < numLetters; i++) {
    float angle = i * angleStep;
    float x = center.x + radius * cos(angle + offset);
    float y = center.y + radius * sin(angle + offset);
    
    if (dist(mouseX, mouseY, x, y) < 5) {
      currentTyped+=letters[i];
      break;
    }
  }
    //You are allowed to have a next button outside the 1" area
  if (didMouseClick(600, 600, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
  
  if (didMouseClick(apoButtonX, apoButtonY, apoButtonWidth, apoButtonHeight)) {
    currentTyped+="'";
  }
  
  if (didMouseClick(deleteButtonX, deleteButtonY, deleteButtonWidth, deleteButtonHeight)) {
    if (currentTyped.length() > 0){
      currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
    }
  }
  
  if (didMouseClick(spaceButtonX, spaceButtonY, spaceButtonWidth, spaceButtonHeight)) {
    currentTyped+=" ";
  }
  //move mouse back to center of screen
  mouseX = width / 2;
  mouseY = height / 2;
}
//  if (didMouseClick(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2)) //check if click in left button
//  {
//    currentLetter --;
//    if (currentLetter<'_') //wrap around to z
//      currentLetter = 'z';
//  }

//  if (didMouseClick(width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2)) //check if click in right button
//  {
//    currentLetter ++;
//    if (currentLetter>'z') //wrap back to space (aka underscore)
//      currentLetter = '_';
//  }

//  if (didMouseClick(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea/2)) //check if click occured in letter area
//  {
//    if (currentLetter=='_') //if underscore, consider that a space bar
//      currentTyped+=" ";
//    else if (currentLetter=='`' & currentTyped.length()>0) //if `, treat that as a delete command
//      currentTyped = currentTyped.substring(0, currentTyped.length()-1);
//    else if (currentLetter!='`') //if not any of the above cases, add the current letter to the typed string
//      currentTyped+=currentLetter;
//  }


void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    
    System.out.println("Raw WPM: " + wpm); //output
    System.out.println("Freebie errors: " + freebieErrors); //output
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } 
  else
    currTrialNum++; //increment trial number

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}


void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0;
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch, 0, 0);
  popMatrix();
}





//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
