final int FIELD_W = 4;
final int FIELD_H = 10;
final int FIELD_D = 4;

final int PROCESS_INTERVAL = 30;

final int BLOCK_SCALE = 75;

final int SCORE_PROCESS = 1;
final int SCORE_FILL = 50;

final int AXIS_NULL = 0;
final int AXIS_X = 1;
final int AXIS_Y = 2;
final int AXIS_Z = 3;

final int SCENE_TITLE = 0;
final int SCENE_PLAY = 1;
final int SCENE_GAMEOVER = 2;

ArrayList<Tetrimino> tetriminoList;
Tetrimino currentTetrimino;

int currentDx, currentDy, currentDz;

int currentRotationAxis;

int scene;

boolean nextGenerateTetrimino;

boolean speedUp;

int score;

int t;
int effectTime;
int shakeTime;

PImage titleImage; 
Tetrimino titleTetrimino;
PImage bgImage; 
PImage gameoverImage; 

// テトリミノの種類
final Block[][] tetriminoTemplates = new Block[][] {
  // 白
  new Block[] {
    new Block(1, 0, 0), 
    new Block(0, 1, 0), 
    new Block(1, 1, 0), 
    new Block(2, 1, 0)
  }
  , 
  // 紫
  new Block[] {
    new Block(1, 0, 0), 
    new Block(0, 1, 0), 
    new Block(0, 1, 1), 
    new Block(1, 1, 0)
  }
  , 
  // 赤
  new Block[] {  
    new Block(0, 0, 0), 
    new Block(1, 0, 0), 
    new Block(1, 1, 0), 
    new Block(2, 1, 0)
  }
  , 
  // 黄緑
  new Block[] {
    new Block(0, 0, 0), 
    new Block(0, 1, 0), 
    new Block(1, 1, 0)
  }
  , 
  // 深緑
  new Block[] {
    new Block(0, 0, 0), 
    new Block(0, 1, 0), 
    new Block(0, 1, 1), 
    new Block(1, 1, 0)
  }
  , 
  // 茶
  new Block[] {
    new Block(0, 0, 0), 
    new Block(0, 0, 1), 
    new Block(1, 0, 0), 
    new Block(1, 0, 1)
  }
  , 
  // 黄
  new Block[] {
    new Block(0, 0, 0), 
    new Block(0, 1, 0), 
    new Block(1, 1, 0), 
    new Block(2, 1, 0)
  }
};

// テトリミノの種類別の色(塗り)
final color[] tetriminoFillColors = new color[] {
  color(240, 240, 255, 128), 
  color(192, 128, 255, 128), 
  color(255, 0, 0, 128), 
  color(180, 255, 24, 128), 
  color(72, 192, 60, 128), 
  color(128, 72, 0, 128), 
  color(255, 255, 128, 128)
};

// テトリミノの種類別の色(線)
final color[] tetriminoStrokeColors = new color[] {
  color(255, 255, 255, 128), 
  color(255, 255, 255, 128), 
  color(255, 255, 255, 128), 
  color(255, 255, 255, 128), 
  color(255, 255, 255, 128), 
  color(255, 255, 255, 128), 
  color(255, 255, 255, 128)
};

// ブロックのクラス
class Block implements Cloneable {
  public int x;
  public int y;
  public int z;

  public Block(int x, int y, int z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  public void draw() {
    pushMatrix();
    translate(x + 0.5, y + 0.5, z + 0.5);
    box(1, 1, 1);
    popMatrix();
  }

  @Override
  public Block clone() {
    Block block = null;
    try {
      block = (Block)super.clone();
    }
    catch(Exception e) {
      e.printStackTrace();
    }
    return block;
  }
}

// テトリミノのクラス
class Tetrimino {
  public int x;
  public int y;
  public int z;
  public color fillColor;
  public color strokeColor;
  public Block[] blocks;

  public Tetrimino(int x, int y, int z, Block[] blocks, color fillColor, color strokeColor) {
    this.x = x;
    this.y = y;
    this.z = z;

    this.blocks = new Block[blocks.length];
    for (int i = 0; i < blocks.length; i++) {
      this.blocks[i] = blocks[i].clone();
    }

    this.fillColor = fillColor;
    this.strokeColor = strokeColor;
  }

  public Tetrimino(int x, int y, int z, Block[] blocks) {
    this.x = x;
    this.y = y;
    this.z = z;

    this.blocks = new Block[blocks.length];
    for (int i = 0; i < blocks.length; i++) {
      this.blocks[i] = blocks[i].clone();
    }

    this.fillColor = 0;
    this.strokeColor = 0;
  }

  public Tetrimino(Block[] blocks) {
    this.x = 0;
    this.y = 0;
    this.z = 0;

    this.blocks = new Block[blocks.length];
    for (int i = 0; i < blocks.length; i++) {
      this.blocks[i] = blocks[i].clone();
    }

    this.fillColor = 0;
    this.strokeColor = 0;
  }

  public void draw() {
    color _fillColor = g.fillColor;
    color _strokeColor = g.strokeColor;
    fill(fillColor);
    stroke(strokeColor);
    pushMatrix();
    translate(x, y, z);
    for (Block block : blocks) {
      block.draw();
    }
    popMatrix();
    fill(_fillColor);
    stroke(_strokeColor);
  }

  public int getWidth() {
    int maxX = blocks[0].x;

    for (int i = 1; i < blocks.length; i++) {
      maxX = max(maxX, blocks[i].x);
    }

    return maxX + 1;
  }

  public int getHeight() {
    int maxY = blocks[0].y;

    for (int i = 1; i < blocks.length; i++) {
      maxY = max(maxY, blocks[i].y);
    }

    return maxY + 1;
  }

  public int getDepth() {
    int maxZ = blocks[0].z;

    for (int i = 1; i < blocks.length; i++) {
      maxZ = max(maxZ, blocks[i].z);
    }

    return maxZ + 1;
  }

  public boolean collidesWith(Tetrimino targetTetrimino, int dx, int dy, int dz) {
    for (Block block : blocks) {
      if ((x + block.x + dx < 0) || (x + block.x + dx >= FIELD_W) || (y + block.y + dy < 0) || (y + block.y + dy >= FIELD_H) || (z + block.z + dz < 0) || (z + block.z + dz >= FIELD_D)) {
        return true;
      }
      for (Block targetBlock : targetTetrimino.blocks) {
        if ((targetTetrimino.x + targetBlock.x == x + block.x + dx) && (targetTetrimino.y + targetBlock.y == y + block.y + dy) && (targetTetrimino.z + targetBlock.z == z + block.z + dz)) {
          return true;
        }
      }
    }
    return false;
  }

  public boolean collidesWith(ArrayList<Tetrimino> targetTetriminos, int dx, int dy, int dz) {
    if (targetTetriminos.size() == 0) {
      for (Block block : blocks) {
        if ((x + block.x + dx < 0) || (x + block.x + dx >= FIELD_W) || (y + block.y + dy < 0) || (y + block.y + dy >= FIELD_H) || (z + block.z + dz < 0) || (z + block.z + dz >= FIELD_D)) {
          return true;
        }
      }
    } else {
      for (Tetrimino targetTetrimino : targetTetriminos) {
        if (collidesWith(targetTetrimino, dx, dy, dz)) {
          return true;
        }
      }
    }
    return false;
  }
}

void setup() {
  size(800, 600, P3D);
  smooth();

  // 背景画像
  titleImage = loadImage("title.jpg");
  bgImage = loadImage("bg.jpg");
  gameoverImage = loadImage("gameover.jpg");

  // タイトル画面のテトリミノをランダムに選択
  int templateIdx = int(random(tetriminoTemplates.length));
  titleTetrimino = new Tetrimino(0, 0, 0, tetriminoTemplates[templateIdx], tetriminoFillColors[templateIdx], tetriminoStrokeColors[templateIdx]);

  // テトリミノリストを初期化して最初のテトリミノを生成
  tetriminoList = new ArrayList<Tetrimino>();
  generateTetrimino();
  nextGenerateTetrimino = false;

  // 次フレームでの移動座標の差分
  currentDx = 0;
  currentDy = 0;
  currentDz = 0;

  // 次フレームでの回転軸
  currentRotationAxis = AXIS_NULL;

  speedUp = false;

  score = 0;
  t = 0;
  effectTime = 0;
  shakeTime = 0;
  scene = SCENE_TITLE;
}

// テトリミノを生成
void generateTetrimino() {
  int templateIdx = int(random(tetriminoTemplates.length));
  currentTetrimino = new Tetrimino(1, 0, 1, tetriminoTemplates[templateIdx], tetriminoFillColors[templateIdx], tetriminoStrokeColors[templateIdx]);
  shakeTime = t;
}

// ゲーム処理
void process() {
  if (nextGenerateTetrimino) {
    nextGenerateTetrimino = false;

    // 現在のテトリミノを地面として追加
    tetriminoList.add(currentTetrimino);

    // 塗りつぶされた行を検索
    searchBlockFill();

    // 新しいテトリミノを生成
    generateTetrimino();
  } else {
    fallCurrentTetrimino();
  }
  score += SCORE_PROCESS;
}

// 枠を描画
void drawField() {
  noFill();
  stroke(255);
  pushMatrix();
  translate(FIELD_W / 2.0, FIELD_H / 2.0, FIELD_D / 2.0);
  box(FIELD_W, FIELD_H, FIELD_D);
  popMatrix();
}

// フレームごとの処理(シーン別にルーティング)
void draw() {
  switch(scene) {
  case SCENE_TITLE:
    drawTitle();
    break;
  case SCENE_PLAY:
    drawPlay();
    break;
  case SCENE_GAMEOVER:
    drawGameover();
    break;
  }
}

// タイトル画面
void drawTitle() {
  // 2D描画
  background(titleImage);

  // 3D描画
  strokeWeight(1.0/BLOCK_SCALE);
  camera(mouseX / 4.0 + width / 4.0, mouseY / 4.0 + height, (height / 2.0) / tan(PI * 60.0 / 360.0), width / 2.0, height / 2.0, 0, 0, 1, 0);

  // テトリミノの描画
  pushMatrix();
  rotateX(-PI / 3);
  translate(width / 2.0, height / 2.0);
  scale(BLOCK_SCALE * 2);
  rotateY(t * PI / 200);
  rotateY((mouseX - width / 2) * 4.0 / width);
  translate(-titleTetrimino.getWidth() / 2.0, -1.0, -titleTetrimino.getDepth() / 2.0); // 回転軸をブロックの中央へ
  titleTetrimino.draw();
  popMatrix();

  t++;
}

// プレイ画面
void drawPlay() {
  if (t % (speedUp ? PROCESS_INTERVAL / 4 : PROCESS_INTERVAL) == 0) {
    process();
  }

  if (scene == SCENE_GAMEOVER) {
    return;
  }

  rotateCurrentTetrimino();
  moveCurrentTetrimino();

  // 2D描画
  background(bgImage);
  camera();
  fill(255);
  textSize(24);
  text("SCORE: " + score, width - 160, 32);

  // 3D描画
  strokeWeight(1.0 / BLOCK_SCALE);
  camera(mouseX, mouseY - height / 4, mouseY + (height / 1.25 / 2.0) / tan(PI * 60.0 / 360.0) + sin(t) * max(0, (effectTime + 10 - t) * 120 / 10), width / 2.0, height / 2.0, 0, 0, 1, 0);

  pushMatrix();
  rotateX(-PI / 3 * (height - mouseY) / height);
  translate(width / 3.0, height / 3.0 - mouseY / 1.75, 0);
  scale(BLOCK_SCALE);
  translate(FIELD_W / 2.0, 0, FIELD_D / 2.0);
  rotateY((mouseX - width / 2) * 4.0 / width);
  translate(-FIELD_W / 2.0, 0, -FIELD_D / 2.0);
  drawField();
  for (Tetrimino tetrimino : tetriminoList) {
    tetrimino.draw();
  }

  pushMatrix();
  translate(0, sin(t / 1.5) * max(0, (shakeTime + PROCESS_INTERVAL - t) / 120.0), 0);
  currentTetrimino.draw();
  popMatrix();

  popMatrix();

  t++;
}

// ゲームオーバー画面
void drawGameover() {
  // 2D描画
  background(gameoverImage);
  camera();
  fill(255);
  textSize(24);
  text("SCORE: " + score, width - 160, 32);

  // 3D描画
  strokeWeight(1.0 / BLOCK_SCALE);
  camera(mouseX / 2, mouseY / 2 + height, height / tan(PI * 60.0 / 360.0), width / 2.0, height / 2.0, 0, 0, 1, 0);

  pushMatrix();
  rotateX(-PI / 3);
  translate(width / 3.0, height / 3.0);
  scale(BLOCK_SCALE);
  translate(FIELD_W / 2.0, 0, FIELD_D / 2.0);
  rotateY(t * PI / 200 + (mouseX - width / 2) * 4.0 / width);
  translate(-FIELD_W / 2.0, -4.0, -FIELD_D / 2.0);
  drawField();
  for (Tetrimino tetrimino : tetriminoList) {
    tetrimino.draw();
  }
  popMatrix();

  t++;
}

// ブロックを回転したものを取得
Block[] rotateBlocks(Block[] blocks, int axis) {
  // 一時的にTetriminoのインスタンスを生成して幅・高さ・奥行きを取得
  Tetrimino tetrimino = new Tetrimino(blocks);
  int w = tetrimino.getWidth();
  int h = tetrimino.getHeight();
  int d = tetrimino.getDepth();

  // 回転処理
  Block[] result = new Block[blocks.length];
  for (int i = 0; i < blocks.length; i++) {
    if (axis == AXIS_X) {
      int x = blocks[i].x;
      int y = d - blocks[i].z - 1;
      int z = blocks[i].y;
      result[i] = new Block(x, y, z);
    }
    if (axis == AXIS_Y) {
      int y = blocks[i].y;
      int z = w - blocks[i].x - 1;
      int x = blocks[i].z;
      result[i] = new Block(x, y, z);
    }
    if (axis == AXIS_Z) {
      int z = blocks[i].z;
      int x = h - blocks[i].y - 1;
      int y = blocks[i].x;
      result[i] = new Block(x, y, z);
    }
  }
  return result;
}

// フレームごとのブロックの回転処理
void rotateCurrentTetrimino() {
  if (currentRotationAxis == AXIS_NULL) {
    return;
  }
  Block[] rotatedBlocks = rotateBlocks(currentTetrimino.blocks, currentRotationAxis);
  if (!(new Tetrimino(currentTetrimino.x, currentTetrimino.y, currentTetrimino.z, rotatedBlocks)).collidesWith(tetriminoList, 0, 0, 0)) {
    currentTetrimino.blocks = rotatedBlocks;
  }
  currentRotationAxis = AXIS_NULL;
}

// フレームごとのテトリミノの移動処理
void moveCurrentTetrimino() {
  boolean collides = currentTetrimino.collidesWith(tetriminoList, currentDx, currentDy, currentDz);
  if (!collides) {
    currentTetrimino.x += currentDx;
    currentTetrimino.y += currentDy;
    currentTetrimino.z += currentDz;
  }
  currentDx = 0;
  currentDy = 0;
  currentDz = 0;
}

// テトリミノの落下処理
void fallCurrentTetrimino() {
  boolean collides = currentTetrimino.collidesWith(tetriminoList, 0, 1, 0);
  if (!collides) {
    currentTetrimino.y++;
    shakeTime = t;
  } else {
    if (currentTetrimino.y == 0) {
      scene = SCENE_GAMEOVER;
      tetriminoList.add(currentTetrimino);
      currentTetrimino = null;
    } else {
      nextGenerateTetrimino = true;
    }
  }
}

// 塗りつぶし判定の処理
void searchBlockFill() {
  // 3次元配列の生成
  boolean[][][] blockExists = new boolean[FIELD_W][][];
  for (int x = 0; x < FIELD_W; x++) {
    blockExists[x] = new boolean[FIELD_H][];
    for (int y = 0; y < FIELD_H; y++) {
      blockExists[x][y] = new boolean[FIELD_D];
    }
  }

  // ブロックが存在するかを3次元配列にリストアップ
  for (Tetrimino tetrimino : tetriminoList) {
    for (Block block : tetrimino.blocks) {
      blockExists[tetrimino.x + block.x][tetrimino.y + block.y][tetrimino.z + block.z] = true;
    }
  }

  // 塗りつぶされた行がないか調べ, 塗りつぶされていればブロックを削除
  for (int y = 0; y < FIELD_H; y++) {
    // 塗られていない座標を探す
    boolean isFilled = true;
    for (int x = 0; x < FIELD_W; x++) {
      for (int z = 0; z < FIELD_D; z++) {
        if (!blockExists[x][y][z]) {
          isFilled = false;
          break;
        }
      }
    }

    // ブロック削除
    if (isFilled) {
      for (Tetrimino tetrimino : tetriminoList) {
        // 塗りつぶされたブロックが削除された配列の要素数を数える
        int newBlockCount = 0;
        for (Block block : tetrimino.blocks) {
          if (tetrimino.y + block.y != y) {
            newBlockCount++;
          }
        }

        // 塗りつぶされたブロックを削除, 上のブロックを1段下にずらした配列を生成
        Block[] newBlocks = new Block[newBlockCount];
        int i = 0;
        for (Block block : tetrimino.blocks) {
          if (tetrimino.y + block.y != y) {
            newBlocks[i++] = block;
          }
          if (tetrimino.y + block.y < y) {
            block.y++;
          }
        }

        // 新しい配列で置き換え
        tetrimino.blocks = newBlocks;
      }
      effectTime = t;
      score += SCORE_FILL;
    }
  }
}

void keyPressed() {
  if (scene == SCENE_TITLE) {
    if (keyCode == ' ') {
      scene = SCENE_PLAY;
      t = 0;
      return;
    }
  } else if (scene == SCENE_PLAY) {
    if (keyCode == ' ') {
      speedUp = true;
      return;
    }

    if (nextGenerateTetrimino) {
      return;
    }

    if (key == CODED) {
      switch(keyCode) {
      case UP:
        currentDz = -1;
        break;
      case DOWN:
        currentDz = 1;
        break;
      case LEFT:
        currentDx = -1;
        break;
      case RIGHT:
        currentDx = 1;
        break;
      }
    } else {
      switch(keyCode) {
      case 'z':
      case 'Z':
        currentRotationAxis = AXIS_X;
        break;
      case 'x':
      case 'X':
        currentRotationAxis = AXIS_Y;
        break;
      case 'c':
      case 'C':
        currentRotationAxis = AXIS_Z;
        break;
      }
    }
  } else if (scene == SCENE_GAMEOVER) {
    if (keyCode == ' ') {
      setup();
      scene = SCENE_TITLE;
      t = 0;
      return;
    }
  }
}

void keyReleased() {
  if (scene == SCENE_PLAY) {
    if (keyCode == ' ') {
      speedUp = false;
      return;
    }
  }
}