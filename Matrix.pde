/**
 * @brief Matrix rain animation sketch with glitch effects.
 *
 * This Processing sketch renders falling character streaks, applies
 * random glitch behavior, and displays a topic string across the screen.
 * This simulates the infamous Matrix screen.
 *
 * @details
 * - Main Processing sketch file for project.
 *
 * @file Matrix.pde
 * @author Asanka Sovis (Skeptic Studios)
 * @version 1.0
 * @license MIT license
 * @date 21/06/2026
 */

int COLUMN_COUNT = 80;                // Text column count
int TEXT_OFFSET = 2;                  // Text offset from container - Adjust as needed

color STATIC = color(22, 111, 33);    // Static text colour
color CURSOR = color(255, 255, 255);  // Cursor text colour
color BACKGROUND = color(0, 0, 0);    // Background colour

int FADE = 50;                        // Fade intensity
int FRAMERATE = 10;                   // Framerate

int MESSAGE_SIZE = 50;                // Message size
int MESSAGE_DELAY = 3000;             // Message delay
int MESSAGE_Y = 300;                  // Message y position

int GLITCH_ENTROPY = 20;              // Randomness to toggle a glitch (1 - any)

int STREAK_ENTROPY = 6;               // Randomness to add new streak (1 - 10)
int STREAK_LIVES = 100;               // Lives available for streak

char PAUSE_KEY = ' ';                 // Set the pause key

int TOPIC_SIZE = 50;                  // Topic size
int TOPIC_Y = 100;                    // Topic y position
int TOPIC_FADE = 200;                 // Topic background fade

char[] CHARACTER_SET = { // Set of characters used for matrix. Change as needed for font 
  '!',      '"',      '#',      '$',      '%',      '&',      '\'',
  '(',      ')',      '*',      '+',      ',',      '-',      '.',      '/',
  '0',      '1',      '2',      '3',      '4',      '5',      '6',      '7',
  '8',      '9',      ':',      ';',      '<',      '=',      '>',      '?',
  'A',      'B',      'C',      'D',      'E',      'F',      'G',
  'H',      'I',      'J',      'K',      'L',      'M',      'N',      'O',
  'P',      'Q',      'R',      'S',      'T',      'U',      'V',      'W',
  'X',      'Y',      'Z',      '[',      '\\',     ']',      '^',      '_',
  'a',      'b',      'c',      'd',      'e',      'f',      'g',
  'h',      'i',      'j',      'k',      'l',      'm',      'n',      'o',
  'p',      'q',      'r',      's',      't',      'u',      'v',      'w',
  'x',      'y',      'z',      '{',      '|',      '}',      '~'
};

int[] topic = {50, 38, 35, 61, 43, 31, 50, 48, 39, 54}; // Topic charset. Numbers map to CHARACTER_SET

// Message string
String message = "PRESS THE SPACE KEY TO EXIT THE MATRIX\nCLICK ANYWHERE TO GENERATE A GLITCH";

char[] characters = new char[CHARACTER_SET.length];           // Character pattern printed on streak
boolean[] character_glitch = new boolean[characters.length];  // Glitch switch for each char
// CHARACTER_SET will contain the fixed list of chars available for streaks. Initially, this is copied
// to characters. Characters list is 'glitched' randomly using character_glitch. Randomly selected
// chars are chosen for glitch and marked in character_glitch. If glitch is enabled for a particular
// char, that char is randomly changed at each frame with a randomly selected char from CHARACTER_SET.

ArrayList <Streak> buffer = new ArrayList <Streak>();         // Streak buffer

boolean matrix = true;                                        // Matrix switch
// Disabling this blocks the program from generating new streaks to replace dying ones

int column_size, row_size;    // Column size and row size
int row_count;                // Row count
int text_size;                // Text size
PFont font;                   // Font

/**
 * @brief Configure the sketch size and load resources.
 *
 * This function is called before setup() in Processing. It initializes the
 * rendering size, loads the font, and computes column/row dimensions.
 */
void settings() {
  size(1800, 1000); // Size - Change as needed
  font = loadFont("font.vlw"); // Loading the font
  // NOTE: Refer to README.md on how to load fonts

  column_size = width/COLUMN_COUNT; // Calculating column size from count
  row_size = column_size; // Row size set to same for convenience. This
  // creates a grid where any given character can be placed
  row_count = ceil((height * 1.0) / row_size); // Calculating row count
  // from size. Ceiling used to avoid missing row on the bottom
  text_size = column_size - (TEXT_OFFSET * 2); // Text size set using
  // column size and text offset * 2

  System.arraycopy(CHARACTER_SET, 0, characters, 0, CHARACTER_SET.length);
  // Copies the CHARACTER_SET to characters for initial charset. characters
  // can be used for glitching
}

/**
 * @brief Initialize the sketch state.
 *
 * Sets up the background, frame rate, font, initial streaks, and a
 * welcome prompt before the animation begins.
 */
void setup() {
  background(BACKGROUND); // Background set to BACKGROUND
  frameRate(FRAMERATE); // Set the framerate
  textFont(font); // Set font

  // Generate a random number of streaks at random points for start
  for (int i = 0; i < (int)random(0, COLUMN_COUNT); i++) {
    buffer.add(new Streak((int)random(0, COLUMN_COUNT), (int)random(0, row_count)));
  }

  // Render init message and delay
  textSize(MESSAGE_SIZE);
  fill(STATIC);
  textAlign(CENTER);
  text(message, width/2, MESSAGE_Y);

  delay(MESSAGE_DELAY);
}

/**
 * @brief Render a single frame of the Matrix animation.
 *
 * Draws the fade overlay, updates streaks, applies glitches, and renders
 * the moving topic text.
 */
void draw() {
  // Set fill and add rect to simulate a fade
  fill(BACKGROUND >> 16 & 0xFF, BACKGROUND >> 8 & 0xFF, BACKGROUND & 0xFF, FADE);
  rect(0, 0, width, height);

  // If matrix is enabled, randomly decide to add a new streak to buffer
  if ((random(0, 10) < STREAK_ENTROPY) && (matrix)) {
    buffer.add(new Streak((int)random(0, COLUMN_COUNT), (int)random(0, row_count)));
  }

  // For each streak in buffer, check if dead and remove; else draw
  for (int i = 0; i < buffer.size(); i++) {
    Streak streak = buffer.get(i);

    if (streak.dead()) {
      buffer.remove(i);
      i--;
    } else {
      streak.draw();
    }
  }

  glitch(); // Glitch the matrix
  
  drawTopic(); // Draw topic

  // saveFrame("./export/export-######.png");
}

/**
 * @brief Handle keyboard input.
 *
 * Toggles the Matrix stream on or off when the space key is pressed.
 */
void keyPressed() {
  // When space is pressed, disable/enable the matrix
  if (key == PAUSE_KEY) {
    matrix = !matrix;
  }
}

/**
 * @brief Handle mouse input.
 *
 * Adds a streak to a position where user clicks.
 */
void mouseClicked() {
  // Calculate grid location
  int x = (mouseX * COLUMN_COUNT) / width;
  int y = (mouseY * row_count) / height;

  // Add a rectangle to show location
  fill(STATIC);
  rect(x * column_size, y * row_size, column_size, row_size, 5);

  // Adds a streak
  buffer.add(new Streak(x, y));
}

/**
 * @brief Update character glitch state.
 *
 * Randomly changes glitch-enabled characters and toggles glitch state for
 * a random position, producing visual noise in the display.
 */
void glitch() {
  // For each glitch toggle, if it is set, change the char to a random char from
  // CHARACTER_SET to simulate a glitch
  for (int i = 0; i < character_glitch.length; i++) {
    if (character_glitch[i]) {
      characters[i] = CHARACTER_SET[(int)random(0, CHARACTER_SET.length)];
    }
  }

  // Randomly decide to toggle a glitch and if decided, randomly choose a location
  // and toggle it
  if ((int)random(0, GLITCH_ENTROPY) == 4) {
    int pos = (int)random(0, character_glitch.length);
    character_glitch[pos] = !character_glitch[pos];
    // println("hit", pos, character_glitch[pos]);
  }
}

/**
 * @brief Draw the topic string on the screen.
 *
 * Builds the current topic from the character buffer and renders it at the
 * top of the sketch with a translucent background.
 */
void drawTopic() {
  // Build topic string
  // NOTE: Topic string is built on the fly to facilitate glitching of
  // the topic as well
  String topic_str = "";
  for (int i = 0; i < topic.length; i++) {
    topic_str += characters[topic[i]];
  }

  // Set a translucent band to highlight the topic
  fill(0, 0, 0, TOPIC_FADE);
  rect(0, (TOPIC_Y / 2) + 5, width, TOPIC_SIZE);

  // Render the topic
  textSize(TOPIC_SIZE);
  fill(STATIC);
  textAlign(CENTER);
  text(topic_str, width/2, TOPIC_Y);
}

/**
 * @brief Represents a single vertical streak in the Matrix animation.
 *
 * Each streak moves down a column of characters and fades out after its
 * lifetime expires.
 */
public class Streak {
  private int x, y; // x, y coordinate (Given in grid position)
  private int cursor = (int)random(0, characters.length/2); // Cursor position
  // relative to grid size
  private int lives = STREAK_LIVES; // Lives left till death
  private int state = 0; // State machine for Streak
  // 0 - Alive, 1 - Dead
  private int floor = cursor; // Start char of cursor (Relative to characters)
  private int ceiling = (int)random(cursor + 1, characters.length); // End 
  // char of cursor (Relative to characters)

  /**
   * @brief Construct a new Streak object.
   *
   * @param x Starting column index for the streak.
   * @param y Starting row index for the streak.
   */
  public Streak(int x, int y) {
    // Set x and y positions as given by program
    this.x = x; this.y = y;
  }

  /**
   * @brief Draw the streak for the current frame.
   *
   * Advances the streak, renders the cursor and body characters, and handles
   * transition to the dead state.
   */
  public void draw() {
    // If state is 0, we draw the streak.
    if (this.state == 0) {
      // If cursor has not hit the ceiling, we draw the cursor on white and
      // advance the cursor. If not, we draw the char with green and reduce
      // the TTL.
      if (this.cursor >= this.ceiling) {
        draw_char(this.cursor - 1, STATIC);
        this.lives--;

        // When TTL reach 0, we kill the streak. (set state to 1)
        if (this.lives <= 0) {
          this.state = 1;
        }
      } else {
        draw_char(this.cursor, CURSOR);
        this.cursor++;
      }

      // Deaw rest of the chars other than cursor
      for (int j = this.floor; j < this.cursor - 1; j++) {
        draw_char(j, STATIC);
      }
    }
  }

  /**
   * @brief Check whether the streak has finished.
   *
   * @return true if the streak is dead and should be removed from the buffer.
   * @return false if the streak is still active.
   */
  public boolean dead() {
    return (this.state == 1);
  }

  /**
   * @brief Draw a single character cell for the streak.
   *
   * @param j Index into the character buffer.
   * @param colour Color to render the character with.
   */
  private void draw_char(int j, color colour) {
    textSize(text_size);
    fill(colour);
    textAlign(CENTER);

    // Draw the char. If char is below screen, wrap to the top
    if (this.y + j >= row_count) {
      text(characters[j], (this.x * column_size) + (column_size / 2), (this.y + 1 + j - this.floor - row_count) * row_size);
    } else {
      text(characters[j], (this.x * column_size) + (column_size / 2), (this.y + 1 + j - this.floor) * row_size);
    }
  }
}